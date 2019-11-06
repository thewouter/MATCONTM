classdef EditBox2 < handle
    %EDITBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        setter
        getter
        validator
        adjuster
        convert2string
        
        eventlistener = [];
    end
    
    methods
        
        
        function obj = EditBox2(parent , setter , getter , model ,  validator, adjuster , convert2string, varargin )
            if (isempty(convert2string))
               convert2string = @(x) num2str(x , '%.16g'); 
            end
            if (isempty(adjuster))
               adjuster = @(x) x; 
            end
            if (isempty(validator))
               validator = @(x) true; 
            end
            
            obj.handle = uicontrol(parent , 'Style' , 'edit'  , 'Unit' , 'Pixels'  , 'String' , convert2string(getter()) , 'Callback' , @(src,ev) obj.newValue()  , varargin{:} );  
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            obj.setBackgroundOK();
            
            obj.setter = setter;
            obj.getter = getter;
            obj.validator = validator;
            obj.adjuster  = adjuster;
            obj.convert2string = convert2string;
            
            
            if ~isempty(model)
                obj.eventlistener = model.addlistener('settingChanged' , @(srv,ev) obj.settingChanged()); 
            end
            
        end
        
        function newValue(obj)
            string =  get(obj.handle ,'String');
            if (isempty(strtrim(string)))
                obj.settingChanged(); %%used to restore default value;
                return;
            end
            
            try
                x = evalin('base' , string);
                %{
                if (~ isscalar(x))
                    obj.performErrorDisplay();
                    obj.settingChanged(); %restore original value
                    return;
                end
                %}
                if (~obj.validator(x))
                    x = obj.adjuster(x);
                end
                
                if (obj.validator(x))
                    obj.setter(x);
                    obj.settingChanged();
                    return;
                else
                    obj.performErrorDisplay();
                    obj.settingChanged(); %restore original value
                    return;
                end
            catch error
                obj.performErrorDisplay();
                obj.settingChanged(); %restore original value
                return;
            end
            
            
        end
        function performErrorDisplay(obj)
            obj.setBackgroundERROR();
            pause(0.3)
            obj.setBackgroundOK();
            
        end
        function setBackgroundOK(obj)
           set(obj.handle, 'BackgroundColor' , [0.90 0.90 0.90]);
        end

        function setBackgroundERROR(obj)
           set(obj.handle, 'BackgroundColor' ,  [1    0.3    0.3]);
        end
                       
        
        function settingChanged(obj)
           set(obj.handle , 'String' , obj.convert2string(obj.getter())); 
        end
        
        function destructor(obj)

            delete (obj.eventlistener);
            delete(obj);
        end
    end
    
end

