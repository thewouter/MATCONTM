classdef ManifoldPlotManagePanel < handle

    properties
        panelhandle;
        popuphandle;
        deletebuttonhandle;
        
        manifoldsplot;

        indexSelected = -1;
        mainnode;
        
        eventlistener;
        eventlistener2;
    end
    
    events
        
       settingChanged; 
    end
    

    methods
        function obj = ManifoldPlotManagePanel(parent , manifoldsplot , manifoldcollection , conorbcol , varargin)
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95]  , varargin{:});
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor() , 'ResizeFcn' , @(o,e) obj.onResize(o));
            obj.manifoldsplot = manifoldsplot;
            
            
            obj.mainnode =  LayoutNode(-1 , -1 , 'vertical');
   
            
            popupmenuhandle = uicontrol(obj.panelhandle , 'Style' , 'popupmenu' , 'String' , {' '} , 'Enable' , 'off' , 'Callback' , @(o,e) obj.changeIndex(o));
            obj.popuphandle = popupmenuhandle;
            obj.mainnode.addHandle(1 ,1 , popupmenuhandle , 'minsize' , [Inf,0]);
            
            
            obj.mainnode.addGUIobject(1, 1,EvalPlotOpsBox( obj.panelhandle , @(x) obj.setPlotOpsSelected(x) ...
                , @()obj.getPlotOpsSelected()  , obj )  ,'minsize' , [Inf, 40]);
            
            obj.mainnode.addGUIobject(1, 1,EvalPlotOpsBox( obj.panelhandle , @(x) obj.setPlotOpsSelectedFP(x) ...
                , @()obj.getPlotOpsSelectedFP()  , obj )  ,'minsize' , [Inf, 40]);  
            
            
            
            
            buttonhandle = uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Add Manifold' ...
                , 'Callback' , @(o,e) obj.addManifold(manifoldcollection));
            
            obj.mainnode.addHandle(1 ,1 , buttonhandle , 'minsize' , [Inf,30]);
            
            
            buttonhandle = uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Add Connecting Orbit' ...
                , 'Callback' , @(o,e) obj.addConOrbit(conorbcol));
            
            obj.mainnode.addHandle(1 ,1 , buttonhandle , 'minsize' , [Inf,30]);
            
            buttonhandle = uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Remove Selected' , 'Enable' , 'on' ...
                , 'Callback' , @(o,e) obj.deleteSelected());
            obj.deletebuttonhandle = buttonhandle;
            
            obj.mainnode.addHandle(1 ,1 , buttonhandle , 'minsize' , [Inf,30]); 
            
           %obj.mainnode.setOptions('Add', true);          
            
            obj.mainnode.makeLayoutHappen(  get(obj.panelhandle , 'Position')    );
            
            obj.changeIndex(popupmenuhandle);
            obj.installListOnPopupmenu(popupmenuhandle);
            
            obj.eventlistener = manifoldsplot.addlistener('listChanged' , @(o,e) obj.onListChange());
            obj.eventlistener = manifoldsplot.addlistener('plotShutdown' , @(o,e) delete(parent));
            set(parent , 'Visible' , 'on');
            
            
        end
        
        function onResize(obj,handle)
            %     later      %%
        end
        
        function plotops = getPlotOpsSelected(obj)
           if (obj.isValidIndex())
               plotops = obj.manifoldsplot.getPlotOps(obj.indexSelected);
           else
               plotops = {};
           end
        end
        function setPlotOpsSelected(obj , plotops)
           if (obj.isValidIndex())
               obj.manifoldsplot.setPlotOps(obj.indexSelected , plotops);
	       obj.manifoldsplot.redrawPlot();
           end
            
        end
        
        function plotops = getPlotOpsSelectedFP(obj)
           if (obj.isValidIndex())
               plotops = obj.manifoldsplot.getPlotOpsFP(obj.indexSelected);
           else
               plotops = {};
           end
        end
        function setPlotOpsSelectedFP(obj , plotops)
           if (obj.isValidIndex())
               obj.manifoldsplot.setPlotOpsFP(obj.indexSelected , plotops) 
	       obj.manifoldsplot.redrawPlot();
           end
            
        end
                
        
        function changeIndex(obj , popuphandle)
            i = get(popuphandle , 'Value');
            if (obj.indexSelected ~= i)
               obj.indexSelected = i;
               obj.notify('settingChanged'); 
            end
            
        end
        
        function installListOnPopupmenu(obj , popuphandle)
            list = obj.manifoldsplot.getStringList();
            % 'popupmenu control requires a non-empty String'  -> special
            % case for no items in list:
            
           
            if (isempty(list))
                obj.indexSelected = 1; %%empty entry
                set(popuphandle , 'String' , {' '} , 'Enable' , 'off' , 'Value' , obj.indexSelected);
            else
               set(popuphandle  , 'String' , list , 'Enable' , 'on' , 'Value' , obj.indexSelected); 
            end
            
        end

        function b = isValidIndex(obj)
            b = (obj.indexSelected > 0) &&  (obj.manifoldsplot.getNrManifolds() > 0);
        end
        
        function deleteSelected(obj)
            if (obj.isValidIndex())
                index = obj.indexSelected;
          
               
                if (obj.indexSelected >  obj.manifoldsplot.getNrManifolds() - 1)
                    obj.indexSelected = obj.manifoldsplot.getNrManifolds() - 1;
                end
                
              
                obj.manifoldsplot.delManifold( index);

            end
        end
        
        
        function  onListChange(obj)
           obj.installListOnPopupmenu(obj.popuphandle);
           set(obj.deletebuttonhandle , 'Enable' , bool2str(obj.isValidIndex));
	   obj.manifoldsplot.redrawPlot();
           obj.notify('settingChanged');
        end
        
        function addManifold(obj , manifoldcollection)
              global session;
              InspectorManifolds.selectAManifold(session , ...
                  manifoldcollection , @(manifold) obj.manifoldsplot.addManifold(manifold));
        end
        
        function addConOrbit(obj , conorbcol)
              global session;
              InspectorConOrbits.selectAConOrbit(session , conorbcol , @(x) obj.manifoldsplot.addOrbit(x));
        end        
        function destructor(obj)
           delete(obj.mainnode);
           delete(obj.eventlistener);
           delete(obj.eventlistener2);
           delete(obj);
        end
        
    end

end



function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end
         

