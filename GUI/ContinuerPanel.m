classdef ContinuerPanel < handle
    %STARTERPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        panelhandle
        contdatamodel
        
        layoutstructure
    end
    
    methods
        
        function obj = ContinuerPanel(parent, contdatamodel , varargin)
            
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , varargin{:});
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor() , 'ResizeFcn' , @(o,e) obj.onResize(o)) ;
            obj.contdatamodel = contdatamodel;
            editboxsize = [120,20];
            
            mainnode = LayoutNode(-1 , -1 , 'vertical');
            
            
            
 	    %CONTINUATION DATA
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Continuation Data');
            
            
            names = contdatamodel.getContinuationDataList();
            for i=1:length(names)
                name = char(names(i));% cell array with one string element, need to convert to string
                
                subnode = LayoutNode( 2 , 1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                     'String' , name ), 'halign' , 'l' , 'minsize' , [Inf,20]);

                subnode.addGUIobject(1,1, ... 
                    EditBox(panel.handle , @(x) contdatamodel.setContinuationData(name,x) , ...
                    @() contdatamodel.getContinuationData(name)  , contdatamodel , @(x) str2double(x) ...
                    ),'halign' , 'r', 'minsize', editboxsize);
                
                panel.mainnode.addNode( subnode );
            end
            
	    mainnode.addGUIobject( length(names), 1, panel);

            
	    %CORRECTOR DATA
            
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Corrector Data' );
            
            names = contdatamodel.getCorrectorDataList();
            for i=1:length(names)
                name = char(names(i));% cell array with one string element, need to convert to string
                
                subnode = LayoutNode( 2 , 1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                     'String' , name ), 'halign' , 'l' , 'minsize' , [Inf,20]);

                subnode.addGUIobject(1,1, ... 
                    EditBox(panel.handle, @(x) contdatamodel.setCorrectorData(name,x) , ...
                    @() contdatamodel.getCorrectorData(name)  , contdatamodel , @(x) str2double(x) ...
                    ),'halign' , 'r', 'minsize', editboxsize);
                
                panel.mainnode.addNode( subnode );
            end
	    mainnode.addGUIobject( length(names) , 1, panel);
            
	    %STOPDATA

            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Stop Data' );
            
            names = contdatamodel.getStopDataList();
            for i=1:length(names)
                name = char(names(i));% cell array with one string element, need to convert to string
                
                subnode = LayoutNode( 2 , 1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                    'String' , name ), 'halign' , 'l' , 'minsize' , [Inf,20]);

                subnode.addGUIobject(1,1, ... 
                    EditBox(panel.handle , @(x) contdatamodel.setStopData(name,x) , ...
                    @() contdatamodel.getStopData(name)  , contdatamodel , @(x) str2double(x) ...
                    ),'halign' , 'r', 'minsize', editboxsize);
                
                panel.mainnode.addNode( subnode );
            end            
            mainnode.addGUIobject(length(names) , 1 , panel);


            [w,h] = mainnode.getPrefSize();
            mainnode.setOptions('Add', true, 'sliderthreshold' , [200 h] , 'panel' , obj.panelhandle);

            obj.layoutstructure = mainnode;
            obj.layoutstructure.makeLayoutHappen(  get(obj.panelhandle , 'Position')    );
            
            if(contdatamodel.isFrozen())
                applyToHandles(obj.layoutstructure , @(handle)  set(handle , 'Enable' , 'Inactive'));
            end
        end
        
        function destructor(obj)
            %D disp(['Destructor: ' mfilename]);
            obj.layoutstructure.destructor();
            delete(obj);
        end
        function onResize(obj,handle)
           set(handle,'Units' , 'Pixels');
           pos = get(handle, 'Position');
           if (~isempty(pos)) %empty komt niet voor in dit geval (alleen bij normalized units van parentobject)
                obj.layoutstructure.makeLayoutHappen( get(handle, 'Position'));
           end
           set(handle,'Units' , 'normalize');            
        end
        
    end
    
end

