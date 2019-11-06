classdef PlotConfiguration < handle
    %PLOTOPTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        configs
        
        session
        axeshandle = [];
        layoutmainpanel

        autofit = false;
        autoredraw = false;

    end
    
    properties(Constant)
       
       SELECTIONS = struct('Coordinates' , struct('construct' , @(pc) PlotConfigSelection(PlotConfigSelection.COORDINATES ,'Coordinates',pc), ...
                'validator' , @(s) true),...
                ...
                          'Parameters' , struct('construct' ,@(pc) PlotConfigSelection(PlotConfigSelection.PARAMETERS , 'Parameters', pc),...
                'validator' , @(s) true), ...
                ...
                          'Multipliers', struct('construct' ,@(pc) PlotConfigSelection(PlotConfigSelection.MULTIPLIERS , 'Multipliers', pc),...
                'validator' , @(session) session.getStartData().getMultipliers() && session.getStartData().isEnabled('multipliers')      ), ...
                ...
                          'Testfunctions', struct('construct' ,@(pc) PlotConfigSelection(PlotConfigSelection.TESTFUNCTIONS , 'Testfunctions', pc),...
                'validator' , @(session) session.getStartData().getNrOfEnabledSingularities() > 0), ...
                ...
                          'Userfunctions', struct('construct' ,@(pc) PlotConfigSelection(PlotConfigSelection.USERFUNCTIONS , 'Userfunctions', pc),...
                'validator' , @(session) session.getStartData().userfunctionsEnabled()), ...
                ...
                          'Empty' ,  struct('construct' ,@(pc) PlotConfigSelection(PlotConfigSelection.NOTHING , 'Empty', pc),...
                 'validator' , @(s) false) ...
                      );                  

        AXTITLE = {'Abscissa', 'Ordinate' ,'Applicate'};
    end
    
    
    events
       selectionChanged 
       regionChanged
       %
       layoutChanged

    end
    
    methods

        function obj = PlotConfiguration(session , fig, dimension , configstruct)
            obj.session = session;
            
            dimstr = ['Plot' num2str(dimension) 'D'];
            set(fig , 'NumberTitle' , 'off' , 'Name' , dimstr , 'UserData' , [dimstr ' - ']);
            
            if ((nargin == 3) || isempty(configstruct))
                sels = obj.constructDefaultLayout(dimension);
                
                obj.configs{1} = struct( 'region' , [0 1] , 'selection' , sels{1}  );
                obj.configs{2} = struct('region' , [0 1] , 'selection' ,  sels{2}   ); 

                if (dimension > 2)
                    obj.configs{3} = struct('region' , [0 1] , 'selection' ,  sels{3}); 
                end                 
            else
               obj.configs = configstruct; 
            end
            

            
            
            obj.axeshandle = axes('Parent' , fig , 'DeleteFcn' , @(o,e) obj.shutdown() );
            obj.installRegionSync(fig);
            
            obj.updateAxesLocal();
            
        end
        
        function sels = constructDefaultLayout(obj , dimension)
            activeParam = ContinuerOptionInterface.getActiveParams(obj.session.starterdata); % example: [ 1 4 ]
            coordnr = obj.session.getSystem().getNrCoordinates();
            paramlen = length(activeParam);
            
            sels = cell(1,dimension);
            
            i = 1;
            
            j = 1;
            while ((i <= dimension) && (j <= paramlen)) 
                printc(mfilename, 'adding param %d  on spot %d ' , j , i);
                sels{i} = obj.SELECTIONS.Parameters.construct(@() obj.rebuildGraph());
                sels{i}.setIndex( activeParam(j) );
               i = i+1;
               j= j+1;
                
            end
            
            j = 1;
            while ((i <= dimension) && (j <= coordnr))
                printc(mfilename, 'adding coord %d  on spot %d ' , j , i);
                sels{i} = obj.SELECTIONS.Coordinates.construct(@() obj.rebuildGraph());
                sels{i}.setIndex(j);
               i = i+1;
               j= j+1;               
            end
            
            while (i <= dimension)
                printc(mfilename, 'adding empty  on spot %d ' , i);
                sels{i} = obj.SELECTIONS.Empty.construct([]);
               i = i+1;
            end
        end
        
        
        
        
        function registerMainPanel(obj , layoutmainpanel)
            
            obj.layoutmainpanel = layoutmainpanel;
            
        end
            
            
        function dim = getDimension(obj)
            dim = length(obj.configs);
        end
        
        function title = getAxTitle(obj,dim)
           title = obj.AXTITLE{dim};
        end
        
        function setSelection(obj, dim , selection)
            obj.configs{dim}.selection = selection;
            notify(obj,'selectionChanged');
        end
        
        function sel = getSelection(obj,dim)
            sel = obj.configs{dim}.selection;
        end
        
        function setRegion(obj, dim, left, right)
            obj.configs{dim}.region  = [left,right];
            %regionchanged
        end
        function [left , right] = getRegion(obj,dim)
            region = obj.configs{dim}.region;
            left = region(1);
            right = region(2);
        end
        
        function list = getSelectionList(obj)
            list = fieldnames(PlotConfiguration.SELECTIONS);
             for i = length(list):-1:1
             if (~ PlotConfiguration.SELECTIONS.(list{i}).validator(obj.session))
                 list(i) = [];
             end
             end
             
             includeEmpty = false;
             for i = 1:length(obj.configs)
                if (obj.configs{i}.selection.getType() ==  PlotConfigSelection.NOTHING)
                   includeEmpty = true; 
                end
             end
             if (includeEmpty)
                list{end+1} =  'Empty';
             end
             
	    end


        
        function setSelectionById(obj, dim , ID , parenthandle, layoutnode)

            sel_constructor = PlotConfiguration.SELECTIONS.(ID).construct;
            
            sel = sel_constructor(@() obj.rebuildGraph());
            sel.init(parenthandle, layoutnode, obj.session);
            delete(obj.configs{dim}.selection);
            obj.configs{dim}.selection = sel;
        end
        
        function ID = initSelection(obj, dim , parenthandle , layoutnode)
            sel = obj.configs{dim}.selection;
            sel.init(parenthandle, layoutnode, obj.session);
            ID = sel.getListID(); 
        end
        
        
        function rebuildGraph(obj)
           obj.updateAxes(obj.layoutmainpanel); 
           obj.notify('layoutChanged');
            printc(mfilename, 'layoutCHANGED EVENT');
        end
        
        
        function updateAxes(obj,attribpanel)
            newregion = attribpanel.getRegion();
            
            if ((newregion(1) >= newregion(2)) || (newregion(3) >= newregion(4)))
               return; 
            end
            xlbl = obj.configs{1}.selection.retrieveLabel(obj.session);
            
         
            
            obj.configs{1}.region = newregion(1:2);
            xlabel(obj.axeshandle , xlbl);
            
            
            ylbl = obj.configs{2}.selection.retrieveLabel(obj.session);
            ylabel(obj.axeshandle , ylbl);
            obj.configs{2}.region = newregion(3:4);
            
            labels = [xlbl ',' ylbl];
            
            if (obj.getDimension() > 2)
                if (newregion(5) >= newregion(6))
                    return;
                end
                
                zlbl = obj.configs{3}.selection.retrieveLabel(obj.session);
                zlabel(obj.axeshandle, zlbl);
                obj.configs{3}.region = newregion(5:6);
                
                labels = [labels ',' zlbl];
            end
            
            axis(obj.axeshandle , newregion);
            
            
            axisparent = get(obj.axeshandle, 'Parent');
            set(axisparent, 'Name' , [get(axisparent,'UserData') labels]); 
        end
        
        function updateAxesLocal(obj)
            region = [obj.configs{1}.region  obj.configs{2}.region];
            xlbl = obj.configs{1}.selection.retrieveLabel(obj.session);
            ylbl = obj.configs{2}.selection.retrieveLabel(obj.session);
            xlabel(obj.axeshandle , xlbl);
            ylabel(obj.axeshandle , ylbl);
            
            labels = [xlbl ',' ylbl];
            
            if (obj.getDimension() > 2)
                zlbl = obj.configs{3}.selection.retrieveLabel(obj.session);
                zlabel(obj.axeshandle, zlbl);
                region = [region obj.configs{3}.region];
                labels = [labels ',' zlbl];
            end
            axis(obj.axeshandle , region);
            axisparent = get(obj.axeshandle, 'Parent');
            set(axisparent, 'Name' , [get(axisparent,'UserData') labels]);             
        end
        
        
        function syncRegionWithAxes(obj)
           if (~isempty(obj.axeshandle))
                newregion = axis(obj.axeshandle);
                
                obj.configs{1}.region = newregion(1:2);
                obj.configs{2}.region = newregion(3:4);
                if (obj.getDimension() > 2)
                obj.configs{3}.region = newregion(5:6);
                end
                obj.autofit = false;
                
                obj.notify('regionChanged');

        		obj.notify('layoutChanged');
                printc(mfilename ,'layoutCHANGED:    syncRegionWithAxes');
           end
        end
        
        function installRegionSync(obj, figurehandle)
            panh = pan(figurehandle);
            set(panh, 'ActionPostCallback' , @(o,e) obj.syncRegionWithAxes());
            zoomh = zoom(figurehandle);
            set(zoomh, 'ActionPostCallback' , @(o,e) obj.syncRegionWithAxes()); 
        end
        
        function fhandle = getSelector(obj, dim)
            fhandle = obj.configs{dim}.selection.retrieveSelection(obj.session);
        end
        function plot = makeReadyPlotObject(obj)
            d  = obj.getDimension();
            c = obj.session.getCurrentCurve();


            colorconfig = obj.session.sessiondata.getAllColorConfig(obj.session.getCurveType());
            if (d ==2)
                plot = Plot2D(obj.axeshandle,colorconfig,  obj.configs{1}.selection.retrieveSelection(obj.session),...
                            obj.configs{2}.selection.retrieveSelection(obj.session)  );
                
                
            else
                plot = Plot3D(obj.axeshandle,colorconfig,  obj.configs{1}.selection.retrieveSelection(obj.session),...
                            obj.configs{2}.selection.retrieveSelection(obj.session),...
                            obj.configs{3}.selection.retrieveSelection(obj.session));
            end
            
        end
        
        
        
        function plotCurve(obj , curve)
           cla(obj.axeshandle);
            
           if(obj.getDimension() == 2)
               Plot2D.plot(obj.session, obj.axeshandle , obj.configs{1}.selection.retrieveSelection(obj.session , curve)    , ...
                   obj.configs{2}.selection.retrieveSelection(obj.session , curve)      ,  curve  ,   []);
           else
                Plot3D.plot(obj.session, obj.axeshandle , obj.configs{1}.selection.retrieveSelection(obj.session,curve)    , ...
                   obj.configs{2}.selection.retrieveSelection(obj.session,curve)  ,   obj.configs{3}.selection.retrieveSelection(obj.session,curve)  , curve ...
                   ,   []);   
           end            
        end
        
        function plotDiagram(obj , cm)
            nr = cm.getNrOfCurves();
  
            validator = @(i , curve) obj.configs{i}.selection.checkValidity(obj.session , curve);
            
            cla(obj.axeshandle);
            if(obj.getDimension() == 2)
                for i = 1:nr
                    curve = cm.getCurveByIndex( i );
                    if (validator(1, curve) && validator(2,curve))
                       xmap = obj.configs{1}.selection.retrieveSelection(obj.session, curve);
                       ymap = obj.configs{2}.selection.retrieveSelection(obj.session, curve);
                       Plot2D.plot(obj.session, obj.axeshandle, xmap, ymap , curve, []);
                    else
                        fprint(['Redraw Diagram:  Skipped ' curve.getLabel() ' - data requested not available']);
                    end
               
                end
            else
                
                for i = 1:nr
                    curve = cm.getCurveByIndex( i );
                    if (validator(1, curve) && validator(2,curve) && validator(3,curve))
                        xmap = obj.configs{1}.selection.retrieveSelection(obj.session, curve);
                        ymap = obj.configs{2}.selection.retrieveSelection(obj.session, curve);
                        zmap = obj.configs{3}.selection.retrieveSelection(obj.session, curve);
                        Plot3D.plot(obj.session, obj.axeshandle, xmap, ymap , zmap , curve, []);
                    else
                        fprint(['Redraw Diagram:  Skipped ' curve.getLabel() ' - data requested not available']);                        
                    end
                    
                    
                end
            end
            

            
        end        
        
        
        function plotCurrentCurve(obj)

           cla(obj.axeshandle);
           
           
           if(obj.getDimension() == 2)
               Plot2D.plot(obj.session, obj.axeshandle , obj.configs{1}.selection.retrieveSelection(obj.session)    , ...
                   obj.configs{2}.selection.retrieveSelection(obj.session)      , obj.session.getCurrentCurve()  ,   PlotPointSelector(obj.session));
           else
                Plot3D.plot(obj.session, obj.axeshandle , obj.configs{1}.selection.retrieveSelection(obj.session)    , ...
                   obj.configs{2}.selection.retrieveSelection(obj.session)  ,   obj.configs{3}.selection.retrieveSelection(obj.session)  , obj.session.getCurrentCurve() ...
                   ,   PlotPointSelector(obj.session));   
           end

        end
        
        
        function plotCurrentDiagram(obj)
            cm = obj.session.getCurveManager();
            nr = cm.getNrOfCurves();
            validator = @(i , curve) obj.configs{i}.selection.checkValidity(obj.session , curve);
            selector = PlotPointSelector(obj.session);
            
            cla(obj.axeshandle);
            if(obj.getDimension() == 2)
                for i = 1:nr
                    curve = cm.getCurveByIndex( i );
                    if (validator(1, curve) && validator(2,curve))
                       xmap = obj.configs{1}.selection.retrieveSelection(obj.session, curve);
                       ymap = obj.configs{2}.selection.retrieveSelection(obj.session, curve);
                       Plot2D.plot(obj.session, obj.axeshandle, xmap, ymap , curve, selector);
                    else
                        fprint(['Redraw Diagram:  Skipped ' curve.getLabel() ' - data requested not available']);
                    end
               
                end
            else
                
                for i = 1:nr
                    curve = cm.getCurveByIndex( i );
                    if (validator(1, curve) && validator(2,curve) && validator(3,curve))
                        xmap = obj.configs{1}.selection.retrieveSelection(obj.session, curve);
                        ymap = obj.configs{2}.selection.retrieveSelection(obj.session, curve);
                        zmap = obj.configs{3}.selection.retrieveSelection(obj.session, curve);
                        Plot3D.plot(obj.session, obj.axeshandle, xmap, ymap , zmap , curve, selector);
                    else
                        fprint(['Redraw Diagram:  Skipped ' curve.getLabel() ' - data requested not available']);                        
                    end
                    
                    
                end
            end
            

            
        end
        
        
        
        function b = isAlive(obj)
            b = ishandle(obj.axeshandle);
        end
        
        
        function fitAxis(obj)
         axis(obj.axeshandle , 'tight');
         obj.syncRegionWithAxes();
         
         
        end
         
        function displayError(obj, msg)
            d = axis(obj.axeshandle);
            cla(obj.axeshandle);
            
            if (obj.getDimension() == 2)
                pos = { (d(1) + d(2))/2 , (d(3) + d(4))/2};
            else
                pos = { (d(1) + d(2))/2 , (d(3) + d(4))/2 , (d(5) + d(6))/2 };
            end
            
            text(pos{:},['\bf ' msg] , 'Parent' , obj.axeshandle  , 'Fontsize' , 16 , 'Color' , 'red' , 'HorizontalAlignment' , 'center' )
            
        end
        
        function b = checkLayoutValid(obj)
            b = true;
            for i = 1:length(obj.configs)
               if (~ obj.configs{i}.selection.checkValidity(obj.session))
                   
                  if (obj.configs{i}.selection.getType() ~=   PlotConfigSelection.NOTHING)
                      delete(obj.configs{i}.selection);
                      obj.configs{i}.selection = obj.SELECTIONS.Empty.construct([]);
                  end
                  
                  b = false;
               end
            end
            if (~b)
               obj.displayError('Error: Layoutsettings are no longer correct'); 
            end
            
            return;
        end
        
        function destructor(obj)
           for i = 1:length(obj.configs)
              delete( obj.configs{i}.selection );
           end
           if (ishandle(obj.axeshandle))
               set(obj.axeshandle , 'DeleteFcn' , @(o,e) 0);
               close(get(obj.axeshandle,'Parent'));
           end 
           delete(obj); 
           
        end
        
        function shutdown(obj)          
           obj.session.plotmanager.reportShutdown(obj);
        end
        
        function A = saveobj(obj)
            
            xlbl = obj.configs{1}.selection.retrieveLabel(obj.session);
            ylbl = obj.configs{2}.selection.retrieveLabel(obj.session);
%             descr = [xlbl '(' sprintf('%g',obj.configs{1}.region(1)) ' , ' sprintf('%g' , obj.configs{1}.region(2)) '), ' ...
%                 ylbl '(' sprintf('%g',obj.configs{2}.region(1)) ' , ' sprintf('%g' , obj.configs{2}.region(2)) ')'];
            lbls = {xlbl , ylbl};
            if (obj.getDimension() > 2)
                zlbl = obj.configs{3}.selection.retrieveLabel(obj.session);
%                 descr = [descr ', ' zlbl '('
%                 sprintf('%g',obj.configs{3}.region(1)) ' , ' sprintf('%g'
%                 , obj.configs{3}.region(2)) ')'];
                lbls{3} = zlbl;
            end            

            A.configstruct = obj.configs;
            A.dim = length(obj.configs);
            for i = 1:A.dim
               A.configstruct{i}.selection =  A.configstruct{i}.selection.saveobj();
               A.configstruct{i}.selection.label = lbls{i};
            end
            
        end
        function fh = getFigure(obj)
            fh = get(obj.axeshandle,'Parent');
        end
        function ah =  getAxes(obj)
            ah = obj.axeshandle;
        end
        
        function setAutoFit(obj, bool)
           obj.autofit = bool; 
        end
        function bool = getAutoFit(obj)
           bool = obj.autofit; 
        end
        function setAutoRedraw(obj,bool)
           obj.autoredraw = bool; 
        end
        function bool = getAutoRedraw(obj)
            bool = obj.autoredraw;
        end
        
        function dat = serialize(obj)
            
            
        end
        
 	function clearAx(obj)
		cla(obj.axeshandle);
	end
    end
        
    methods(Static)
        function installMenu(fhandle , plotconf, session)
            mhandle = uimenu(fhandle, 'Label' , 'MatContM');
            uimenu(mhandle , 'Label' , 'Layout' , 'Callback' , @(o,e)  PlotConfigMainPanel(session.getWindowManager() , plotconf));
            
            uimenu(mhandle , 'Label' , 'Redraw Curve' , 'Callback' , @(o,e) plotconf.plotCurrentCurve() , 'Separator' , 'on');
            uimenu(mhandle , 'Label' , 'Redraw Diagram' , 'Callback' , @(o,e) plotconf.plotCurrentDiagram() );
            uimenu(mhandle , 'Label' , 'Clear' , 'Callback' , @(o,e) cla(plotconf.axeshandle));
            uimenu(mhandle , 'Label' , 'Fit Range' , 'Callback' , @(o,e) plotconf.fitAxis());
            SelectSwitchMenu( mhandle , session.sessiondata , 'Orbit Options' ,'draw');
            
        end
        function installPreviewMenu(fhandle , plotconf, session)
            mhandle = uimenu(fhandle, 'Label' , 'MatContM');
            uimenu(mhandle , 'Label' , 'Layout' , 'Callback' , @(o,e)  PlotConfigMainPanel(session.getWindowManager() , plotconf));
            
            uimenu(mhandle , 'Label' , 'Redraw' , 'Callback' , @(o,e) forcedRedraw(plotconf) , 'Separator' , 'on');
            uimenu(mhandle , 'Label' , 'Clear' , 'Callback' , @(o,e) cla(plotconf.axeshandle));
            uimenu(mhandle , 'Label' , 'Fit Range' , 'Callback' , @(o,e) plotconf.fitAxis());
            
            SwitchMenuItem_type2(mhandle , 'Auto Redraw' ,  @(val) plotconf.setAutoRedraw(val) ,@() plotconf.getAutoRedraw() , plotconf , 'layoutChanged' , 'Separator' , 'on');
            SwitchMenuItem_type2(mhandle , 'Auto Fit Range',@(val) plotconf.setAutoFit(val)    ,@() plotconf.getAutoFit() ,    plotconf , 'layoutChanged' ); 

        end
        
        function obj = constructPlotConfiguration(session, fig , data)
            for i = 1:data.dim
               data.configstruct{i}.selection =  PlotConfigSelection.constructPCSelection(data.configstruct{i}.selection);
            end
            obj = PlotConfiguration(session , fig, data.dim , data.configstruct);
            for i = 1:data.dim
                data.configstruct{i}.selection.setUpdateFcn( @() obj.rebuildGraph());
            end

        end
    end
end 


function forcedRedraw(plotconf)
val = plotconf.autoredraw;
plotconf.autoredraw = true;
plotconf.notify('layoutChanged');
plotconf.autoredraw = val;
end

function autoFitAdjust(plotconf)
    plotconf.setAutoFit(true)
    plotconf.notify('layoutChanged');
end
