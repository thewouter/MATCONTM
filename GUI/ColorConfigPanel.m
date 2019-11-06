classdef ColorConfigPanel < handle

    properties
        panelhandle;
        mainnode;

        eventlistener;

        sessiondata;
    end
    
    events
       settingChanged
    end
    

    methods
        function obj = ColorConfigPanel(parent , session , varargin)
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95]  , varargin{:});
            uimenu(parent, 'Label' , 'Help' , 'Callback' , @(o,e) ColorConfigPanel.displayHelp());
            
            obj.sessiondata = session.sessiondata;
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor() , 'ResizeFcn' , @(o,e) obj.onResize(o));
            
            obj.mainnode =  LayoutNode(-1 , -1 , 'vertical');
            curvelist = CurveType.getList();
            
            for i = 1:length(curvelist)
                ct = curvelist{i};
                
                obj.mainnode.addHandle( 1, 1, uicontrol( obj.panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , [ct.getName() , ':'] ), 'halign' , 'l', 'minsize' , [Inf,20]);
                
                subnode = LayoutNode(1,1);
                
                 subnode.addGUIobject(1, 10,EvalPlotOpsBox( obj.panelhandle , ...
                              @(x) obj.sessiondata.setColorCfg( ct.getLabel() , x) ...
                             , @() obj.sessiondata.getColorCfg( ct.getLabel()) ...
                             , obj )  ,'minsize' , [Inf, 40]);
                 subnode.addHandle(1,1, uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Default' ...
                , 'Callback' , @(o,e) obj.setDefaultCurve(ct.getLabel()) ));
                obj.mainnode.addNode(subnode);
            end
            
            %pause:
                obj.mainnode.addHandle( 1, 1, uicontrol( obj.panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , [' '] ), ...
                    'halign' , 'l', 'minsize' , [Inf,20]);
         
            
            % Singularity
                obj.mainnode.addHandle( 1, 1, uicontrol( obj.panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , ['Singularity' , ':'] ), ...
                    'halign' , 'l', 'minsize' , [Inf,20]);
                subnode = LayoutNode(1,1);
                subnode.addGUIobject(1, 10, EvalPlotOpsBox( obj.panelhandle , ...
                      @(x) obj.sessiondata.setColorCfgSing(x) ...
                    , @() obj.sessiondata.getColorCfgSing() ...
                    , obj )  ,'minsize' , [Inf, 40]);
                subnode.addHandle(1,1, uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Default' ...
                    , 'Callback' , @(o,e) obj.setDefault('Sing') ));
                obj.mainnode.addNode(subnode);
            
            
            % User Singularity
                obj.mainnode.addHandle( 1, 1, uicontrol( obj.panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , ['Userfunction Singularity' , ':'] ), ...
                    'halign' , 'l', 'minsize' , [Inf,20]);
                subnode = LayoutNode(1,1);
                subnode.addGUIobject(1, 10, EvalPlotOpsBox( obj.panelhandle , ...
                      @(x) obj.sessiondata.setColorCfgUserSing(x) ...
                    , @() obj.sessiondata.getColorCfgUserSing() ...
                    , obj )  ,'minsize' , [Inf, 40]);
                subnode.addHandle(1,1, uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Default' ...
                    , 'Callback' ,@(o,e) obj.setDefault('UserSing') ));
                obj.mainnode.addNode(subnode);
            
            % Orbit point
                obj.mainnode.addHandle( 1, 1, uicontrol( obj.panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , ['Orbit points' , ':'] ), ...
                    'halign' , 'l', 'minsize' , [Inf,20]);
                subnode = LayoutNode(1,1);
                subnode.addGUIobject(1, 10, EvalPlotOpsBox( obj.panelhandle , ...
                      @(x) obj.sessiondata.setColorCfgOrbitpoint(x) ...
                    , @() obj.sessiondata.getColorCfgOrbitpoint() ...
                    , obj )  ,'minsize' , [Inf, 40]);
                subnode.addHandle(1,1, uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Default' ...
                    , 'Callback' , @(o,e) obj.setDefault('orbitpoint') ));
                obj.mainnode.addNode(subnode);                
            % Label
                obj.mainnode.addHandle( 1, 1, uicontrol( obj.panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , ['Labels' , ':'] ), ...
                    'halign' , 'l', 'minsize' , [Inf,20]);
                subnode = LayoutNode(1,1);
                
                evalbox =  EvalPlotOpsBox( obj.panelhandle , ...
                      @(x) obj.sessiondata.setColorCfgLabel(x) ...
                    , @() obj.sessiondata.getColorCfgLabel() ...
                    , obj );
                evalbox.setTextMode();
                subnode.addGUIobject(1, 10,  evalbox  ,'minsize' , [Inf, 40]);
                subnode.addHandle(1,1, uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Default' ...
                    , 'Callback' , @(o,e) obj.setDefault('label') ));
                obj.mainnode.addNode(subnode);                   
            
            obj.mainnode.setOptions('Add', true);
            obj.mainnode.makeLayoutHappen(  get(obj.panelhandle , 'Position')    );
            set(parent , 'Visible' , 'on');
            
            
        end
        
        function onResize(obj,handle)
           set(handle,'Units' , 'Pixels');
           pos = get(handle, 'Position');
           if (~isempty(pos)) %empty komt niet voor in dit geval (alleen bij normalized units van parentobject)
                obj.mainnode.makeLayoutHappen( get(handle, 'Position'));
           end
           set(handle,'Units' , 'normalize');
        end
           
        
        function destructor(obj)
           delete(obj.mainnode);
           delete(obj.eventlistener);
           delete(obj);
        end
        
        function setDefaultCurve(obj, curvelabel)
            try
                obj.sessiondata.setColorCfg(curvelabel, DefaultValues.CURVECOLORCFG.(curvelabel));
            catch
            end
            obj.notify('settingChanged');
        end
        
        function setDefault(obj, label)
           if strcmp('label' , label)
               obj.sessiondata.setColorCfgLabel( DefaultValues.OTHERCOLORCFG.LABEL );
           elseif strcmp('Sing' , label)
               obj.sessiondata.setColorCfgSing( DefaultValues.OTHERCOLORCFG.SING );
           elseif strcmp('UserSing', label)
               obj.sessiondata.setColorCfgUserSing( DefaultValues.OTHERCOLORCFG.USERSING );
           elseif strcmp('orbitpoint' , label)
               obj.sessiondata.setColorCfgOrbitpoint( DefaultValues.OTHERCOLORCFG.ORBITPOINT );
           end
           obj.notify('settingChanged');

        end
        
    end
    methods(Static)
        function displayHelp()
           helpdlg( ...
             [ 'The options in these editboxes will be passed along to the MATLAB plot instructions.', ... 
             'The syntax of these instructions are the same as the one MATLAB uses for the instrunctions "plot", "line" and "text" and can be consulted in the documentation pages of these instructions.' ]...
           , 'Plot Settings');
            
        end
        
        
    end

end


%{
function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end
         
%}