classdef EvalVectorBox < handle
    %EDITBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        setter
        getter

        vectorlength
        eventlistener = [];
    end
    
    methods
        
        
        function obj = EvalVectorBox(parent , setter , getter , model , varargin )
            
            vector = getter();
            obj.handle = uicontrol(parent , 'Style' , 'edit' , 'Unit' , 'Pixels'  , 'String' , EvalVectorBox.vector2string(vector) , 'Callback' , @(src,ev) obj.newValue()  , varargin{:} );  
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            obj.setBackgroundOK();
            obj.setter = setter;
            obj.getter = getter;
            obj.vectorlength = length(vector);
            
            if ~isempty(model)
                obj.eventlistener = model.addlistener('settingChanged' , @(srv,ev) obj.settingChanged()); 
            end
            
        end
        
        function newValue(obj)
            string = get(obj.handle ,'String');
            if (isempty(strtrim(string)))   
               obj.settingChanged(); %%used to restore default value; 
               return;
            else
            
            try 
                x = evalin('base' , string);
                x = x(:)'; %convert to row vector.
                if (isnumeric(x) && (length(x) == obj.vectorlength))
                    obj.setter(x);
                else
                    obj.setBackgroundERROR();
                    fprintf('Error while evaluating editbox entry: ');
                    fprintf('Entry is not a vector with the correct length\n'); 
                end
            catch error
                obj.setBackgroundERROR();
                fprintf('Error while evaluating editbox entry: ');
                disp(error.message);
            end
            end
        end
        
        function settingChanged(obj)
           set(obj.handle , 'String' , EvalVectorBox.vector2string(obj.getter())); 
           obj.setBackgroundOK();
        end
        
        function destructor(obj)
            delete (obj.eventlistener);
            delete(obj);
        end

        function setBackgroundOK(obj)
           set(obj.handle, 'BackgroundColor' , [0.80 0.90 0.60]);
        end

        function setBackgroundERROR(obj)
           set(obj.handle, 'BackgroundColor' ,  [1    0.3    0.3]);
        end
                
        

    end
    methods(Static)
       function s = vector2string(x)
            s = ['[ ' sprintf('%.16g, ',x) ']'];
            s(length(s) - 2) = []; %%removes extra ',' at the end:  example  [ 5, 0.234324, 1e-12, ] --> [ 5, 0.234324, 1e-12 ]
        end       
        
    end
    
end

