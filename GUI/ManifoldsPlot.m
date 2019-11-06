classdef ManifoldsPlot < handle
    
    
    properties
        manifoldlist = {};
        coordmap = [1 2 3]; %coordmap(1) = abss . %coordinate(2) = ord , %coordnate(3) = app
        dimension = 2;
        
        fighandle = 0;
        axhandle = 0;

        coordNames;
        windowmanager;
        session;
    end
    
    events
       listChanged;
       regionChanged; 
       plotShutdown
    end
        
    
    methods
        function obj =  ManifoldsPlot(session)
            obj.coordNames = session.getSystem().getCoordinateList();
            obj.windowmanager = session.getWindowManager();
            obj.session = session;
        end
        
        function addManifold(obj, manifold)
            plotops = {};
            if (manifold.isStable())
               plotops =  [plotops(:) , {'color'} , {'blue'}];
            else
               plotops =  [plotops(:) , {'color'} , {'red'}];
            end
            
            fp_plotops = {'marker' , '.' , 'color' , 'black' };
            obj.manifoldlist{end+1} = plotStruct(manifold , plotops , fp_plotops);  
            obj.notify('listChanged');
        end
        function addOrbit(obj , orbit)
            plotops =  { 'color' ,  'black' ,  'LineStyle' ,  ':' , 'Marker' , 'o' };
            fp_plotops = {};
            obj.manifoldlist{end+1} = plotStruct(orbit , plotops , fp_plotops); 
            obj.notify('listChanged');
        end
        
        function delManifold(obj , index)
            obj.manifoldlist(index) = [];
            obj.notify('listChanged');
        end
        
        
        function setupPlot(obj)
            obj.fighandle = figure('DeleteFcn' , @(o,e) obj.figureDeleted());
            obj.axhandle = axes('Parent' , obj.fighandle);
            installRegionSync(obj , obj.fighandle);
            installMenuOnFig(obj , obj.fighandle);
            obj.drawPlot();
        end
        
        function drawPlot(obj)
            axes(obj.axhandle);
            if (obj.dimension == 2)
                
                for i = 1:length(obj.manifoldlist)
                    s = obj.manifoldlist{i};
                    points = s.manifold.getAllPoints();
                    line(points(obj.coordmap(1) ,:) , points(obj.coordmap(2),:) , s.plotops{:});
                    if (~isempty(s.fp_plotops))
                        line(points(obj.coordmap(1) ,1) , points(obj.coordmap(2),1) , s.fp_plotops{:});
                    end
                end
                
            end    
            obj.setFigLabels();
        end
        function redrawPlot(obj)
            if (obj.axhandle == 0)
                return;
            end
           cla(obj.axhandle); 
           obj.drawPlot();
        end
        function n =  getDimension(obj)
            n = obj.dimension;
        end
        function list = getCoordinateList(obj)
            list = obj.coordNames;
        end
        
        function setCoordMap(obj , dim , coordindex)
           obj.coordmap(dim) = coordindex; 
        end
        function xm = getCoordMap(obj , dim)
            xm = obj.coordmap(dim);
        end

 
        
        function region = getAxesRegion(obj)
            if (obj.axhandle ~= 0)
                region = axis(obj.axhandle);
            else
                region = [-1 1 -1 1 -1 1];
            end
        end
        function setAxesRegion(obj , region)
            if (obj.axhandle ~= 0)
                axis(obj.axhandle , region);
            end
        end
        
        function setFigLabels(obj)
           if(obj.axhandle == 0)
               return;
           end
            
           coordlist = obj.getCoordinateList();
           xlbl = coordlist{obj.coordmap(1)};
           ylbl = coordlist{obj.coordmap(2)};
           xlabel(obj.axhandle , xlbl);
           ylabel(obj.axhandle , ylbl);
           
           windowlabel = [xlbl ',' ylbl];
           if (obj.dimension == 3)
               zlbl = coordlist{obj.coordmap(3)};
               zlabel(obj.axhandle , zlbl);
               windowlabel = [windowlabel ',' zlbl];
           end
           set(obj.fighandle , 'Name' , ['Manifolds  '  windowlabel]);
            
        end
        function installMenuOnFig(obj , fighandle)
            mhandle = uimenu(fighandle, 'Label' , 'MatContM');
            uimenu(mhandle , 'Label' , 'Layout' , 'Callback' , @(o,e)  ManifoldPlotCFGMainPanel(obj.windowmanager , obj));
            obj.makeManageMenuButton(mhandle);
            uimenu(mhandle , 'Label' , 'Redraw' , 'Callback' , @(o,e) obj.redrawPlot())
            uimenu(mhandle , 'Label' , 'Fit Range' , 'Callback' , @(o,e) obj.fitAxis())
            
        end
        
        function handle = makeManageMenuButton(obj , parentmenu)
            handle = uimenu(parentmenu , 'Label' , 'Manage Manifolds' , 'Callback' , ...
            @(o,e) ManifoldPlotManagePanel( obj.session.getWindowManager().demandWindow('managemanifolds')  ...
            , obj , obj.session.system.tempstorage.mc, obj.session.starterdata.manifolddata.conorbitcol ));
        end
        
        function list = getStringList(obj)
            len = length(obj.manifoldlist);
            list = cell(1, len);
            for i = 1:len
                s = obj.manifoldlist{i};
                list{i} = s.manifold.toString();
            end
            
        end
        
        function nr = getNrManifolds(obj)
           nr =  length(obj.manifoldlist);
        end
        
        function plotops = getPlotOps(obj , index)
            plotops = obj.manifoldlist{index}.plotops;
        end
        function plotops = getPlotOpsFP(obj , index)
            plotops = obj.manifoldlist{index}.fp_plotops;
        end
        
        function setPlotOps(obj , index, plotops)
            obj.manifoldlist{index}.plotops = plotops;
        end
               
        function setPlotOpsFP(obj , index, plotops)
            obj.manifoldlist{index}.fp_plotops = plotops;
        end
                   
        function fitAxis(obj)
           axis(obj.axhandle , 'tight');
           obj.notify('regionChanged'); 
        end
        
        function figureDeleted(obj)
            
           obj.fighandle = 0;
           obj.axhandle = 0;
           obj.notify('plotShutdown');
        end

        
    end
    methods(Static)
        function setupSingleManifoldPlot(manifold)
           mplot = ManifoldsPlot();
           mplot.addManifold(manifold);
           mplot.setupPlot();
        end
         function setupDoubleManifoldPlot(manifold1,manifold2)
           mplot = ManifoldsPlot();
           mplot.addManifold(manifold1);
           mplot.addManifold(manifold2);
           mplot.setupPlot();
        end       
        
        
    end
    
    
    
    
end


function s = plotStruct( manifold , plotops , fp_plotops )
s = struct('manifold' , manifold , 'plotops' , {plotops} , 'fp_plotops' , {fp_plotops});
end

function installRegionSync(manifoldsplot, figurehandle )
    panh = pan(figurehandle);
    set(panh, 'ActionPostCallback' , @(o,e) manifoldsplot.notify('regionChanged'));
    zoomh = zoom(figurehandle);
    set(zoomh, 'ActionPostCallback' , @(o,e) manifoldsplot.notify('regionChanged'));
end


