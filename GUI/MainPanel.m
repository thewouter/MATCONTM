classdef MainPanel < handle
    %STATUSPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        panelhandle
        session
        labellist = { 'Class' , 'System', 'Curve' , 'Point Type' , 'Curve Type' , 'Derivatives' , 'Diagram' };
        
        labelhandlelist
   
       	eventlistener
        
        mainnode
   
    
    end
    
    methods
        function obj = MainPanel(parentfigure , session , varargin)
            obj.panelhandle = uipanel(parentfigure , 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'BorderType' , 'none' ,  varargin{:});
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor(), 'ResizeFcn' , @(o,e) obj.onResize());
            
            
            obj.session = session;
            
            obj.mainnode = LayoutNode(-1,-1,'vertical');
            obj.mainnode.setOptions('sliderthreshold' , [100 100] , 'panel' , obj.panelhandle);
            
            
            
	    
            obj.addHeaderCompartment(parentfigure);
            obj.addSystemCompartment(parentfigure);
            obj.addCurveCompartment(parentfigure);
            
            
            obj.mainnode.makeLayoutHappen( get(obj.panelhandle, 'Position'));
            obj.eventlistener = obj.session.addlistener('stateChanged', @(srv,ev) syncValues(obj, obj.session));
            obj.syncValues(obj.session);
            
            %LayoutNode.normalize( obj.panelhandle);
            %EMBED:
           % figpos = get(parent,'Position');
           % set(parent, 'Position' , [figpos(1) figpos(2) position(3) position(4)]);
           % set(obj.panelhandle , 'Position' , [0 0 position(3) position(4)]);
            set( obj.panelhandle , 'Units','normalize'); %NOTE: must be last!
  
            
        end
        
        function syncValues(obj , session)
            set( obj.labelhandlelist{1} , 'String' ,'Map'); %class
            set( obj.labelhandlelist{2} , 'String' ,session.getSystem().getName()     ); %system
            set( obj.labelhandlelist{3} , 'String' ,session.getCurrentCurve().getLabel()); %curve
            set( obj.labelhandlelist{4} , 'String' ,session.getPointType().getName()  ); %Point Type
            set( obj.labelhandlelist{5} , 'String' ,session.getCurveType().getName()  ); %Curve type
            set( obj.labelhandlelist{6} , 'String' ,session.getSystem().getDerInfo()  ); %derrs
            
            set( obj.labelhandlelist{8} , 'String' ,  getDiagramName(session) );
        end
        
        function destructor(obj)
            printc(mfilename , '--- SHUTDOWN ---');
            obj.session.shutdown();
            delete(obj.eventlistener)
            obj.mainnode.destructor();
      	    delete(obj);
        end
        function onResize(obj)
           set(obj.panelhandle,'Units' , 'Pixels');
           obj.mainnode.makeLayoutHappen( get(obj.panelhandle, 'Position'));
           set(obj.panelhandle,'Units' , 'normalize');
        end
        
        function addHeaderCompartment(obj, ~) %~=parentfigure
            panel = Panel(obj.panelhandle , 0 ,  [5 1] , 'BackgroundColor' , [0.95 0.95 0.95]);
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                 'String' , obj.labellist(1)) , 'halign' , 'l');
            obj.labelhandlelist{1} = uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' ,  'String' , '' );
            subnode.addHandle(1,2,obj.labelhandlelist{1},'halign' , 'l','minsize',[200,20]);
            panel.mainnode.addNode(subnode);
            obj.mainnode.addGUIobject(1,1, panel , 'minsize' , [Inf,Inf], 'margin' , [2,1]);
        end
        
        function addSystemCompartment(obj, parentfigure)
            panel = Panel( obj.panelhandle , 8 , 5 , 'Title' , 'Current System', 'BackgroundColor' , [0.95 0.95 0.95]);
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                'String' , obj.labellist(2)) , 'halign' , 'l');
            obj.labelhandlelist{2} = uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' , 'String' , '' );
            subnode.addHandle(1,2,obj.labelhandlelist{2},'halign' , 'l','minsize',[200,20]);
            panel.mainnode.addNode(subnode);
            
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                 'String' , obj.labellist(6)) , 'halign' , 'l');
            obj.labelhandlelist{6} = uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' ,  'String' , '' );
            subnode.addHandle(1,2,obj.labelhandlelist{6},'halign' , 'l','minsize',[200,20]);
            panel.mainnode.addNode(subnode);

            installSystemContextMenu(obj, [panel.handle, obj.labelhandlelist{2} ,  obj.labelhandlelist{6}], parentfigure);
            
            
	    obj.mainnode.addGUIobject(2,1, panel,'minsize' , [Inf,Inf], 'margin' , [2,1]);
        end
        
        
        
        function addCurveCompartment(obj, parentfigure)

            panel = Panel( obj.panelhandle , 8 , 5 , 'Title' , 'Current Curve', 'BackgroundColor' , [0.95 0.95 0.95]);
            
            
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                 'String' , 'Name'  ),'halign' , 'l');
            obj.labelhandlelist{3} = uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' , 'String' , '');
            subnode.addHandle(1,2,obj.labelhandlelist{3},'halign' , 'l','minsize',[200,20]);
            panel.mainnode.addNode(subnode);

            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                'String' , 'Diagram'  ),'halign' , 'l');
            obj.labelhandlelist{8} = uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' ,  'String' , '');
            subnode.addHandle(1,2,obj.labelhandlelist{8},'halign' , 'l','minsize',[200,20]);
            panel.mainnode.addNode(subnode);            
            
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                'String' , 'Initial Point Type'  ),'halign' , 'l');
            obj.labelhandlelist{4} = uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' ,  'String' , '');
            subnode.addHandle(1,2,obj.labelhandlelist{4},'halign' , 'l','minsize' , [200,20]);
            panel.mainnode.addNode(subnode);            
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                 'String' , 'Curve Type'  ),'halign' , 'l');
            obj.labelhandlelist{5} = uicontrol( panel.handle, 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , ...
                'HorizontalAlignment' , 'left' ,  'String','' );
            subnode.addHandle(1,2,obj.labelhandlelist{5},'halign' , 'l','minsize' , [200,20]);
            panel.mainnode.addNode(subnode);  
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1, ...
                uicontrol( panel.handle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95], 'HorizontalAlignment' , 'left' , ...
                 'String' , 'Initializer'  ),'halign' , 'l');
            
            listbox = SelectBranchListbox(panel.handle , obj.session ,   'Units', 'Pixels' ,   'HorizontalAlignment' , 'left',    'BackgroundColor' , [0.95 0.95 0.95]);
            obj.labelhandlelist{7} = listbox.handle;
            
            
            subnode.addHandle(1,2,obj.labelhandlelist{7},'halign' , 'l','minsize' , [270,20]);
            
            
            
            
            panel.mainnode.addNode(subnode);  
            
            panel.mainnode.addNode(subnode);
            
            installCurveContextMenu(obj,[panel.handle ,  obj.labelhandlelist{4} ,    obj.labelhandlelist{5} , obj.labelhandlelist{3} ,  obj.labelhandlelist{8}  ], parentfigure);

            obj.mainnode.addGUIobject(3 , 1 , panel,'minsize' , [Inf,Inf] , 'margin' , [2,1] );
        end
        function installCurveContextMenu(obj, handlelist, parentfigure)
            context = uicontextmenu('Parent', parentfigure);
            
             MenuItem(context ,@(o,e) InspectorModel.currentCurve(obj.session), @() 'View Curve',...
                 obj.session , @() obj.session.allowPointSelect() , 'stateChanged');
            
             MenuItem(context ,@(o,e) InspectorModel.currentDiagram(obj.session), @() 'View Diagram',...
                 obj.session , @() obj.session.allowCurveSelect() , 'stateChanged' );
             
             MenuItem(context , @(o,e) MainPanel.renamecurve(obj.session) , @() 'Rename Curve' , obj.session,...
                  @() obj.session.getCurrentCurve().hasFile() , 'stateChanged'  , 'Separator' , 'on');
             
              MenuItem(context , @(o,e) MainPanel.newdiagram(obj.session) , @() 'New diagram' , obj.session,...
                  @() ~isempty(obj.session.system) , 'stateChanged' );             
              
              
             WindowLaunchButton(context , obj.session.getWindowManager() , 'uimenu', ...
                @(fhandle) StarterPanel(fhandle,obj.session.getStartData()), 'starter' , 'Separator' , 'on');            
            WindowLaunchButton(context , obj.session.getWindowManager() , 'uimenu', ...
                @(fhandle) ContinuerPanel(fhandle,obj.session.getContData()), 'continuer' );

            
            set(handlelist, 'UIContextMenu' , context);
        end
         
        function installSystemContextMenu(obj, handlelist, parentfigure)
            context = uicontextmenu('Parent', parentfigure);
            
            uimenu(context , 'Label' , 'Systembrowser' , 'Callback', @(o,e) MainPanel.browsesystem(obj.session,obj.session.getSystemsPath())  );

            set(handlelist, 'UIContextMenu' , context);
        end
        
    end
    methods(Static)
        
        function browsesystem(session, systempath)
            im = InspectorModel(session , systempath);
            InspectorPanel.startWindow(session.getWindowManager(),   im);
        end
        
        function newsystem(session)
            
            session.lock();
            sys = SystemSpace.loadNewSystem(session);
            if ~isempty(sys)
                session.loadNewCurve(sys , CurveManager(session, sys.getDefaultDiagramPath()));
            end
            session.unlock();
            MainPanel.popupInput(session);
	    
        end
        

        function userfunctions(session)
           session.lock(); 
           SystemSpace.userfunctionsEdit(session , session.getSystem());
           session.unlock();    
        end

        function renamecurve(session)
            cm = session.getCurveManager();
            oldname = session.getCurrentCurve().getLabel();
            
            newname = inputdlg('Enter new curvename' , 'curvename' , 1 , { oldname });
            
            if (~isempty(newname))
                [s,mess] = cm.renameCurve(oldname , newname{1} , session);
                if (~s)
                    errordlg(mess, 'error');
                end
            end
            
            
        end
        
        
        function  newdiagram(session)
           list = InspectorDiagram.getDiagramList(session.getSystem().getPath());
           
           answer = inputdlg('Enter new diagramname' , 'diagramname');
           if (~isempty(answer))
                if (ismember(answer{1} , list))
                    errordlg('diagramname already exists' , 'error');
                else
                    mkdir([session.getSystem().getPath() '/' answer{1}]);
                    
                    currcurve = session.getCurrentCurve();
                    if (currcurve.hasFile())
                        c = session.curvemanager.getEmptyCurveFrom( currcurve.getLabel());
                    else
                        c = currcurve;
                        c.setPointType(session.getPointType());
                        c.setCurveType(session.getCurveType());
                    end
                    
                    newcm = CurveManager(session , [session.getSystem().getPath() '/' answer{1}]);
                    newcm.unnamed = c;
                    
		    session.changeCurve( session.system ,  newcm , c , [] , []);
                    
                end
           end
           
           
        end                
        function popupInput(session)
            
            if (session.getSwitch('popup'))
            printc(mfilename, 'popupInput');
            
            wm = session.getWindowManager();
            if (~ wm.isWindowOpen('starter'))
                fig = wm.createWindow('starter');
                StarterPanel(fig, session.getStartData());
                set(fig, 'Visible' , 'on');
            end
            if (~wm.isWindowOpen('continuer'))
                fig = wm.createWindow('continuer');
               ContinuerPanel( fig , session.getContData());
               set(fig , 'Visible' , 'on');
            end
            else
               printc(mfilename, 'Popup REQ ignored'); 
            end
        end

    end
end

function str = getDiagramName(session)
    dn = session.getCurveManager();
    if (isempty(dn))
        str = '';
    else
        str = dn.getDiagramName();
    end


end



