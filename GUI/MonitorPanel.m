 classdef MonitorPanel < handle
    %PANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        panelhandle
        layoutstructure
        
        outputhandle
        statushandle
    end
    
    methods
        function obj = MonitorPanel(session, varargin)
        global sOutput
            
	    parent = session.windowmanager.demandWindow('monitor');
        pos = get(parent, 'Position');

            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels' ,  'BackgroundColor' , [0.85 0.85 0.85], 'DeleteFcn' , @(o,e) obj.destructor() ...
                    , 'Position' , [0 0 pos(3) pos(4)] , varargin{:});
            
                
            mainnode = LayoutNode(-1 , -1 , 'vertical');
            
            mainnode.addNode( LayoutNode(1,1));
            
            subnode_left  = LayoutNode(1,3, 'vertical');
            obj.statushandle = uicontrol(obj.panelhandle,'Style' , 'edit' , 'String' , 'Ready' , 'BackgroundColor' , [0.95 0.95 0.95], 'Unit' , 'Pixels' ,...
                'HorizontalAlignment' , 'center' , 'Enable' , 'inactive', 'FontSize', 13 , 'FontWeight' , 'bold' );
            subnode_left.addHandle(1,1,obj.statushandle , 'minsize',[200,30]);
            subnode_left.addGUIobject(1,1, PauseResumeButton( obj.panelhandle , @() obj.launchCurrentCurve(session, parent)),'minsize',[200,20]);
            subnode_left.addGUIobject(1,1, StopCloseButton( obj.panelhandle , @() close(parent)),'minsize',[200,20]);
            
            
            subnode_right = LayoutNode(1,2, 'vertical');
            
            
%             subnode_right.addGUIobject(1,1, SwitchBox(  obj.panelhandle, 'radiobutton' , 'Pause Always' , @(val) sOutput.setPauseAlways() , @() sOutput.isPauseAlways() , sOutput.model , 'BackgroundColor' , [0.85 0.85 0.85])...
%                 , 'halign' , 'l','minsize', [140,20] );
%             subnode_right.addGUIobject(1,1, SwitchBox(  obj.panelhandle, 'radiobutton' , 'Pause Never' , @(val) sOutput.setPauseNever() , @() sOutput.isPauseNever() , sOutput.model,'BackgroundColor' , [0.85 0.85 0.85] )...
%                 , 'halign' , 'l','minsize', [140,20] );    
%             subnode_right.addGUIobject(1,1, SwitchBox(  obj.panelhandle, 'radiobutton' , 'Pause Special' , @(val) sOutput.setPauseSpecial() , @() sOutput.isPauseSpecial() , sOutput.model, 'BackgroundColor' , [0.85 0.85 0.85])...
%                 , 'halign' , 'l','minsize', [140,20] );
            
            
            subnode = LayoutNode(12,1);
            subnode.addNode(subnode_left);
            subnode.addNode(LayoutNode(1,1));
            subnode.addNode(subnode_right);
            mainnode.addNode(subnode);
            
            mainnode.addNode( LayoutNode(1,1));
            
            obj.outputhandle = uicontrol(obj.panelhandle ,'Style' , 'listbox', 'HorizontalAlignment' , 'left' , 'Enable' , 'inactive' , 'BackgroundColor' , 'white');
            mainnode.addHandle(40,1,obj.outputhandle , 'minsize',[Inf,Inf]);
            
            obj.layoutstructure = mainnode;
            
            mainnode.makeLayoutHappen( get(obj.panelhandle,'Position') );

            
            sOutput.setStatusHandle( obj.statushandle );
            sOutput.setOutputHandle( obj.outputhandle );
            set(obj.outputhandle , 'String' , {'Continuation output:' , ''});
            
            LayoutNode.normalize(obj.panelhandle);
            set(parent, 'Visible' , 'on' , 'CloseRequestFcn' , @(o,e) obj.closefunction(session));
            drawnow;
            
        end
        
        function destructor(obj)
        global sOutput
            sOutput.setStatusHandle( [] );
            sOutput.setOutputHandle( [] );
            
            obj.layoutstructure.destructor();
            delete(obj);
        end
        
        function launchCurrentCurve(obj,session, windowhandle)
            InspectorModel.currentCurve(session);
           % close(windowhandle);  niet gewenst
        end
        
       
        function closefunction(obj , session)
        %global sOutput 
            
            if (session.isUnlocked())
                %sOutput.performStop();
                session.getWindowManager().closeWindow('monitor');
            end
            
        end
        
    end
    
end

