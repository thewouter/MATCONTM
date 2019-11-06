classdef ManifoldConfigPanel < handle
    
    
    
    properties
        panelhandle
        
        layoutnode
        
        fixedpointpanel
        settingspanel
        
        eventlistener;
        
        optionbuttonhandle;

    end
    
    methods
        
        function obj = ManifoldConfigPanel(parent, manifoldmodel , varargin)
            
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95]  , varargin{:});
            
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor());
            set(obj.panelhandle, 'ResizeFcn' , @(o,e) obj.onResize(o))
            
            %obj.eventlistener = manifoldmodel.addlistener('valueChanged' ,@(o,e) 0);
            obj.configurePanel(manifoldmodel);
            
            obj.configureStage(manifoldmodel);
            
            obj.eventlistener = manifoldmodel.addlistener('stageChanged' , @(srv,ev) obj.configureStage(manifoldmodel));
        end
        
        
        %function structureChanged(obj, starterdatamodel)
        %if ~isempty(obj.handle); delete(allchild(obj.handle)); end;
        %obj.layoutstructure.destructor();
        %set(obj.panelhandle,'Units' , 'Pixels');
        %obj.configurePanel(starterdatamodel);
        %set(obj.panelhandle,'Units' , 'normalize');
        %end
        
        function onResize(obj,handle)
            set(handle,'Units' , 'Pixels');
            pos = get(handle, 'Position');
            if (~isempty(pos)) %empty komt niet voor in dit geval (alleen bij normalized units van parentobject)
                obj.layoutnode.makeLayoutHappen(pos);
            end
            set(handle,'Units' , 'normalize');
        end
        
        function configurePanel(obj, manifoldmodel)
            
            mainnode = LayoutNode(-1 , -1 , 'vertical');
            editboxsize = [120,20];
            
            % COORDINATES %
            
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Fixed Point');
            obj.fixedpointpanel  = panel;
            %
            
            coords = manifoldmodel.getCoordNames();
            for i=1:length(coords)
                coordname = coords{i};
                
                subnode = LayoutNode( 2 , 1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , coordname ), 'halign' , 'l', 'minsize' , [Inf,20]);
                
                box = EditBox(panel.handle , @(x) manifoldmodel.setCoordByIndex( i , x) , ...
                    @() num2str(manifoldmodel.getCoordVal(i) , '%.16g')  , manifoldmodel , @(x) str2double(x) ...
                    );
                subnode.addHandle( 1, 1, box.handle , 'halign' , 'r', 'minsize' , editboxsize);
                panel.mainnode.addNode( subnode );
            end
            
            
            % PARAMETERS %
	    %{
            panel.mainnode.addNode(LayoutNode( 1 , 1)); %empty space
            
            params = manifoldmodel.getParamNames();
            
            for i=1:length(params)
                paramname = params{i};
                
                subnode = LayoutNode(2,1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , paramname), 'halign' , 'l', 'minsize' , [Inf,20]);
                
                subnode.addGUIobject( 1 , 1 , ...
                    EditBox(panel.handle , @(x) manifoldmodel.setParamByIndex(i ,x) , ...
                    @() manifoldmodel.getParamVal(i)  , manifoldmodel , @(x) str2double(x) ...
                    ) , 'halign' , 'r', 'minsize' , editboxsize);
                
                panel.mainnode.addNode(subnode);
            end
            %}
            subnode = LayoutNode(2,1);
            
            subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                'String' ,  'nIteration' ), 'halign' , 'l', 'minsize' , [Inf,20]);
            subnode.addGUIobject( 1 , 1 , ...
                EditBox2(panel.handle , @(x) manifoldmodel.setIterationN(x) , ...
                @() manifoldmodel.getIterationN()  , manifoldmodel ,  ...
                InputRestrictions.VALIDATOR{InputRestrictions.INT_g0} ,InputRestrictions.ADJUSTER{InputRestrictions.INT_g0}, []  ...
                ) , 'halign' , 'r', 'minsize' , editboxsize);
            
            panel.mainnode.addNode(subnode);
            
            %%% VECTORBOX Test %%%%%
            
            panel.mainnode.addGUIobject(2,1, ...
                EvalVectorBox(panel.handle , @(v) manifoldmodel.setCoord(v) , @() manifoldmodel.getCoord() , manifoldmodel) , 'minsize' , [Inf, 0]);
            
            %{
            panel.mainnode.addGUIobject(2,1, ...
                EvalVectorBox(panel.handle , @(v) manifoldmodel.setParam(v) , @() manifoldmodel.getParam() , manifoldmodel) , 'minsize' , [Inf, 0]);
            %}
            
            mainnode.addGUIobject(length(coords) +  3, 1 , panel)
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%% SETTINGSTEST %%%%%
            obj.optionbuttonhandle = uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'BUTTON!' , 'Callback' , @(src,ev) optionbuttonpress(manifoldmodel)  );
            optionbuttonnaming(obj.optionbuttonhandle , manifoldmodel);
            mainnode.addHandle(1,1, obj.optionbuttonhandle );
            
            % SETTINGS %
            %
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Manifold Algo Settings');
            obj.settingspanel = panel;
            %
            settings = manifoldmodel.getOptNames();
            %
            for i = 1:length(settings)
                settingname = settings{i};
                
                subnode = LayoutNode(2,1);
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  settingname ), 'halign' , 'l', 'minsize' , [Inf,20]);
                
                [type ,catvalues] = manifoldmodel.getOptType(settingname);
                if (type == InputRestrictions.CAT)
                    subnode.addGUIobject( 1 , 1 , ...
                        CategoryBox(panel.handle , @(x) manifoldmodel.setOpt( settingname , x) , @() manifoldmodel.getOpt(settingname) ,...
                        manifoldmodel ,  catvalues ) , 'halign' , 'r', 'minsize' , editboxsize);
                    
                else
                    subnode.addGUIobject( 1 , 1 , ...
                        EditBox2(panel.handle , @(x) manifoldmodel.setOpt(settingname, x) , ...
                        @() manifoldmodel.getOpt(settingname)  , manifoldmodel ,  ...
                        InputRestrictions.VALIDATOR{type} ,InputRestrictions.ADJUSTER{type}, []  ...
                        ) , 'halign' , 'r', 'minsize' , editboxsize);
                end
                panel.mainnode.addNode( subnode );
                
            end
            subnode = LayoutNode(2,1);
            panel.mainnode.addNode( subnode );
            subnode = LayoutNode(2,1);
            subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'Manifold Name' ), 'halign' , 'l', 'minsize' , [Inf,20]);           
            
            
                
            subnode.addGUIobject( 1 , 1 , ...
                        EditBox(panel.handle , @(x) manifoldmodel.setManifoldName(x) , ...
                        @() manifoldmodel.getManifoldName()  , manifoldmodel ,  [] ...
                        ) , 'halign' , 'r', 'minsize' , editboxsize);
                    
            panel.mainnode.addNode( subnode );
            mainnode.addGUIobject(length(settings) + 1 , 1 , panel)
            %
            
            
            mainnode.addGUIobject(1,1,  ManifoldComputeButton(obj.panelhandle , manifoldmodel )  );           
            
            
            %
            [w,h] = mainnode.getPrefSize();
            %
            mainnode.setOptions('Add', true, 'sliderthreshold' , [200 h] , 'panel' , obj.panelhandle);
            %
            obj.layoutnode = mainnode;
            obj.layoutnode.makeLayoutHappen(  get(obj.panelhandle , 'Position')    );
            
        end
        
        function configureStage(obj , manifoldmodel)
            
            if (manifoldmodel.isFixedPointStage())
                obj.fixedpointpanel.mainnode.applyToHandles (@(handle)  set(handle , 'Enable' , 'on'));
            else
                obj.fixedpointpanel.mainnode.applyToHandles (@(handle)  set(handle , 'Enable' , 'off'));
            end
            if (manifoldmodel.isOptionStage())
                obj.settingspanel.mainnode.applyToHandles (@(handle)  set(handle , 'Enable' , 'on'));
            else
                obj.settingspanel.mainnode.applyToHandles (@(handle)  set(handle , 'Enable' , 'off'));
            end
            optionbuttonnaming(obj.optionbuttonhandle , manifoldmodel);
        end
                    
        
        function destructor(obj)
            obj.layoutnode.destructor();
            delete(obj.eventlistener);
            delete(obj);
        end
    end
    
end




function optionbuttonpress( manifoldmodel)
if (manifoldmodel.isFixedPointStage())
    manifoldmodel.doOptionStage();
elseif (manifoldmodel.isOptionStage())
    manifoldmodel.doFixedPointStage();
end
end
function optionbuttonnaming(buttonhandle , manifoldmodel)
if (manifoldmodel.isFixedPointStage())
     set(buttonhandle , 'String' , 'Select fixed point and proceed to configure');
elseif (manifoldmodel.isOptionStage())
     set(buttonhandle , 'String' , 'Go back to selecting a fixed point');
end
end
