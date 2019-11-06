classdef StarterPanel < handle
    %STARTERPANEL Summary of this class goes here
    %   Detailed explanation goes here
    % {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'multipliers' ,'userfunction' , 'testfunctions' , 'amplitude' };
    properties
        panelhandle
        starterdatamodel
        layoutstructure
        
        eventlistener
    end
    
    methods
        
        function obj = StarterPanel(parent, starterdatamodel , varargin)
            
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95]  , varargin{:});
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor());
            obj.starterdatamodel = starterdatamodel;
            
            obj.configurePanel(starterdatamodel);
            set(obj.panelhandle, 'ResizeFcn' , @(o,e) obj.onResize(o))
            
            obj.eventlistener = starterdatamodel.addlistener('structureChanged' ,@(o,e) obj.structureChanged(starterdatamodel));

        end
        
        
        function structureChanged(obj, starterdatamodel)
            %TODO:
%             %obj.layoutstructure.applyToHandles(@(h) delete(h));
            if ~isempty(obj.panelhandle); delete(allchild(obj.panelhandle)); end;
             obj.layoutstructure.destructor();
             set(obj.panelhandle,'Units' , 'Pixels');
             obj.configurePanel(starterdatamodel);
             set(obj.panelhandle,'Units' , 'normalize');
        end
        
        function onResize(obj,handle)
           set(handle,'Units' , 'Pixels');
           pos = get(handle, 'Position');
           if (~isempty(pos)) %empty komt niet voor in dit geval (alleen bij normalized units van parentobject)
                obj.layoutstructure.makeLayoutHappen( get(handle, 'Position'));
           end
           set(handle,'Units' , 'normalize');            
        end
        
        function configurePanel(obj,starterdatamodel) 
            
            mainnode = LayoutNode(-1 , -1 , 'vertical');
            
            editboxsize = [120,20];

            
            % COORDINATES %
            
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Initial Point');
            
            %
            

            coords = starterdatamodel.getCoordinates();
            for i=1:length(coords)
                coordname = char(coords(i)); %coords(1) is cell array with one string element, need to convert to string
                
                subnode = LayoutNode( 2 , 1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' , coordname ), 'halign' , 'l', 'minsize' , [Inf,20]);

                box = EditBox(panel.handle , @(x) starterdatamodel.setCoordinate(coordname,x) , ...
                    @() starterdatamodel.getCoordinate(coordname)  , starterdatamodel , @(x) str2double(x) ...
                    );
                subnode.addHandle( 1, 1, box.handle , 'halign' , 'r', 'minsize' , editboxsize);
                panel.mainnode.addNode( subnode );
            end
            

            % PARAMETERS %
            spw = StarterParamWarning(panel.handle , starterdatamodel,'BackgroundColor' , [0.95 0.95 0.95]);
            panel.mainnode.addGUIobject(1, 1 , spw , 'minsize' , [Inf, 0] );
            
            params = starterdatamodel.getParameters();
            
            for i=1:length(params)
                paramname = params{i};
                
                subnode = LayoutNode(2,1);
                
                subnode.addGUIobject( 1 , 1 , ...
                    SwitchBox(panel.handle , 'radiobutton' , [' ' paramname] ,  @(x) starterdatamodel.setFreeParameter(paramname,x) , @() starterdatamodel.getFreeParameter(paramname), ...
                        starterdatamodel, 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left'  )     ...
                , 'halign' , 'l' , 'minsize' , [Inf,20]);

                subnode.addGUIobject( 1 , 1 , ...
                    EditBox(panel.handle , @(x) starterdatamodel.setParameter(paramname,x) , ...
                    @() starterdatamodel.getParameter(paramname)  , starterdatamodel , @(x) str2double(x) ...
                    ) , 'halign' , 'r', 'minsize' , editboxsize);
                
                panel.mainnode.addNode(subnode); 
            end
            
	    mainnode.addGUIobject(length(coords) + length(params) , 1 , panel)
             

            %%%%HACKTIME:
            global session; %immorele HACK
            if (ismember(session.getCurveType.getLabel() , {'HE' , 'HO' , 'HetT' , 'HomT' }))
                if (~isfield(session.system.tempstorage,'mc'))
                    session.system.tempstorage.mc = ManifoldCollection();
		    if (~isempty(starterdatamodel.manifolddata.stable))
			 session.system.tempstorage.mc.addManifold(starterdatamodel.manifolddata.stable , starterdatamodel.manifolddata.stable.getName() );
		    end	
		    if (~isempty(starterdatamodel.manifolddata.unstable))
			 session.system.tempstorage.mc.addManifold(starterdatamodel.manifolddata.unstable , starterdatamodel.manifolddata.unstable.getName() );
		    end	
                end
                manifoldcollection = session.system.tempstorage.mc;
                cocpanel = ConnectingOrbitConfigPanel(obj.panelhandle,starterdatamodel, session , manifoldcollection);
                mainnode.addHandle(7 , 1 , cocpanel.panelhandle);
            end
            
            
            
            % SETTINGS %
            
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Settings');

            settings = starterdatamodel.getSettingsList();
            
            for i = 1:length(settings)
                settingname = settings{i};
            
                if (starterdatamodel.isEnabled(settingname))
                
                    subnode = LayoutNode(2,1);
                    subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                         'String' , StarterPanel.getDispName(settingname)), 'halign' , 'l', 'minsize' , [Inf,20]);

                    subnode.addGUIobject( 1 , 1 , ...
                    EditBox(panel.handle , @(x) starterdatamodel.setSetting(settingname,x) , ...
                        @() starterdatamodel.getSetting(settingname)  , starterdatamodel , @(x) str2double(x) ...
                        )   , 'halign' , 'r', 'minsize' , editboxsize);

                    panel.mainnode.addNode( subnode );    
                
                end
            end

             %  FieldsModel type %
            
            if (starterdatamodel.isEnabled('FieldsModel'))
                %from imoral hack;
                branch = session.getBranchManager().getCurrentBranch();
                if ~isempty(branch)
                   fieldmodel = branch.getFieldsModel(); 
                   fieldmodel.installGUI(panel.handle, panel.mainnode);
                end
            end
            
            
            %MULTIPLIERS

            if (starterdatamodel.isEnabled('multipliers'))
	    subnode = LayoutNode(1,1);
            subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                'String' , 'Calculate multipliers'), 'halign' , 'l', 'minsize' , [Inf,20]);

            subnode.addGUIobject(1,1, ...
                SwitchBox(panel.handle , 'checkbox' , '', @(x) starterdatamodel.setMultipliers(x) , ...
                @() starterdatamodel.getMultipliers()  , starterdatamodel ,   'BackgroundColor' , [0.95 0.95 0.95]  ), 'halign' , 'c', 'minsize' , [20,20]);

            panel.mainnode.addNode(subnode);
            end
            
	    mainnode.addGUIobject(length(settings) + starterdatamodel.isEnabled('multipliers') , 1 , panel)
	    


	    % JACOBIAN DATA%
            
            if (starterdatamodel.isEnabled('jacobian'))
            panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Jacobian Data');
            
            jacdatalist = starterdatamodel.getJacobianList();
            
            for i = 1:length(jacdatalist)
                jacdataname = jacdatalist{i};
                subnode = LayoutNode(2,1);
                
                subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                     'String' , StarterPanel.getDispName(jacdataname) ), 'halign' , 'l', 'minsize' , [Inf,20]);
               
                
                subnode.addGUIobject(1,1, ... 
                    EditBox(panel.handle , @(x) starterdatamodel.setJacobian(jacdataname,x) , ...
                    @() starterdatamodel.getJacobian(jacdataname)  , starterdatamodel , @(x) str2double(x) ...
                    ), 'halign' , 'r', 'minsize' , editboxsize);

                panel.mainnode.addNode(subnode);
                
            end
	    mainnode.addGUIobject( length(jacdatalist) , 1 , panel);
            end
            
            % Test functions %
            
            if (starterdatamodel.isEnabled('testfunctions'))
                panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Monitor Singularities');
                
                
                sings = starterdatamodel.getSingularitiesList();
                for i=1:length(sings)
                    singularity = sings{i};
                    
                    subnode = LayoutNode(2,1);
                    subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                        'String' , [StaticPointType.getPointTypeName(singularity) ' (' singularity ')'] ), 'halign' , 'l', 'minsize' , [Inf,20]);
                    
                    subnode.addGUIobject(1,1, ...
                        SwitchBox(panel.handle , 'checkbox' , '', @(x) starterdatamodel.setMonitorSingularities(singularity,x) , ...
                        @() starterdatamodel.getMonitorSingularities(singularity)  , starterdatamodel  , 'BackgroundColor' , [0.95 0.95 0.95] ), 'halign' , 'c' , 'minsize' , [20,20]);
                    
                    
                    if (~ starterdatamodel.isTestEnabled(singularity))
                       subnode.applyToHandles( @(h) set(h , 'Enable' , 'off'));
                    end
                    
                    panel.mainnode.addNode( subnode);
                    
                end
                mainnode.addGUIobject(  length(sings) , 1 ,   panel);
            end
            
            
            if (starterdatamodel.hasValidUserfunctions())
               panel = Panel(obj.panelhandle , 14 ,  0 , 'BackgroundColor' , [0.95 0.95 0.95] , 'Title', 'Monitor Userfunctions');
               nruserf = starterdatamodel.getNrUserfunctions();
               count = 0;
               for i = 1:nruserf
                   if (starterdatamodel.isValidUserfunction(i))
                        subnode = LayoutNode(2,1);
                        subnode.addHandle( 1, 1, uicontrol( panel.handle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                        'String' , [starterdatamodel.getNameUserfunction(i) ' (' starterdatamodel.getLabelUserfunction(i) ')']), 'halign' , 'l', 'minsize' , [Inf,20]);                   
                       
                        subnode.addGUIobject(1,1, ...
                        SwitchBox(panel.handle , 'checkbox' , '', @(x) starterdatamodel.setEnabledUserfunction(i,x) , ...
                        @() starterdatamodel.isEnabledUserfunction(i) , starterdatamodel , 'BackgroundColor' , [0.95 0.95 0.95]), 'halign' , 'c' , 'minsize' , [20,20]);                       
                       
                        panel.mainnode.addNode( subnode);
                        count = count + 1;
                   end
               end
               mainnode.addGUIobject( count , 1 ,   panel);
            end
            
            

            [~,h] = mainnode.getPrefSize();
            
            mainnode.setOptions('Add', true, 'sliderthreshold' , [200 h] , 'panel' , obj.panelhandle);

            obj.layoutstructure = mainnode;
            obj.layoutstructure.makeLayoutHappen(  get(obj.panelhandle , 'Position')    );

            if (starterdatamodel.isFrozen())
                applyToHandles(obj.layoutstructure , @(handle)  set(handle , 'Enable' , 'Inactive'));
            end
            
        end
        function destructor(obj)
            obj.starterdatamodel.notify('settingChanged');
            obj.layoutstructure.destructor();
            delete(obj.eventlistener);
            delete(obj);
        end     
    end
    
    methods(Static)
            % {'coordinates' , 'parameters' , 'ADnumber' , 'jacobian' , 'iterationN' , 'multipliers' ,'userfunction' , 'testfunctions' , 'amplitude' };
            function name = getDispName(tag)
                switch(tag)
                    case 'ADnumber'
                        name = 'AD threshold';
                    case 'iterationN'
                        name = 'Iteration';
                        
                    case 'amplitude'
                        name = 'Amplitude';
                    
                    case 'increment'
                        name = 'Increment';
               
                    otherwise
                    name = tag;
                end
            end
        
    end
    
end

