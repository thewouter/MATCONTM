classdef ManifoldComputeButton < handle
    
    properties
       handle; 
       settinglistener;
       stagelistener;
       
    end
    
    
    methods
        function obj = ManifoldComputeButton(parent , manifoldmodel , varargin)
            obj.handle = uicontrol(parent , 'Style' , 'pushbutton'  , 'Callback' , @(src,ev) obj.buttonPressed(manifoldmodel) , 'DeleteFcn' , @(o,e) obj.destructor() , varargin{:} );

            obj.settinglistener = manifoldmodel.addlistener('settingChanged' , @(o,e)  obj.buttonNaming(manifoldmodel));
            obj.stagelistener = manifoldmodel.addlistener('stageChanged' , @(o,e)  obj.buttonNaming(manifoldmodel));
            obj.buttonNaming(manifoldmodel);
        end
        
        function buttonNaming(obj , manifoldmodel)
            
            [selectionMade , isStable] = manifoldmodel.getManifoldTypeSelection();
            if (selectionMade && manifoldmodel.isOptionStage())
                guiopt = {'Enable' , 'on' };
                if (isStable)
                    guiopt = [ guiopt , {'String' } , {'Compute Stable Manifold'} ];
                else
                    guiopt = [ guiopt , {'String' } , {'Compute Unstable Manifold'} ];
                end
                
                
            else
                guiopt = {'Enable' , 'off' , 'String' , 'Please select manifold type'};
            end
            
            set(obj.handle , guiopt{:} );
            
        end
        
        function buttonPressed(obj , manifoldmodel)
            manifoldmodel.doContMan();
        end
        
        
        function destructor(obj)
            delete(obj.settinglistener);
            delete(obj.stagelistener);
            delete(obj); 
        end
    end
    
    
    
    
end



