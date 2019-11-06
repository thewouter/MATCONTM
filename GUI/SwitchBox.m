classdef SwitchBox < handle
    %EDITBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        setter
        getter
        model
        
        eventlistener = [];
    end
    
    methods
        
        
        function obj = SwitchBox(parent , style , string ,  setter , getter , model , varargin )
            obj.handle = uicontrol(parent , 'Style' , style  , 'String' , string , 'Value' , getter() , 'Callback' , @(src,ev) obj.newValue()  , varargin{:} );  
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            set(obj.handle , 'Min' , 0);
            set(obj.handle , 'Max' , 1);
            obj.setter = setter;
            obj.getter = getter;
            if ~isempty(model)
                obj.eventlistener = model.addlistener('settingChanged' , @(srv,ev) obj.settingChanged()); 
            end
            
        end
        
        function newValue(obj)
            value = get(obj.handle ,'Value');
            obj.setter( value );   
        end
        
        function settingChanged(obj)
           set(obj.handle , 'Value' , obj.getter()); 
        end
        
        
        function destructor(obj)
           %D disp(['Destructor: ' mfilename]);
           delete(obj.eventlistener);
           delete(obj);
        end
        
    end
    
end

