classdef PushButton < handle
    %EDITBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        model
        
        eventlistener = [];
    end
    
    methods
        
        
        function obj = PushButton(parent,  callback, labelgetter, model, validator, eventdescr, varargin)
            
            if ~isa(labelgetter, 'function_handle')
               labelgetter = @() labelgetter; %if string is given, make a function that returns the string. 
            end

            obj.handle = uicontrol(parent ,'Unit' , 'Pixels' ,'Style' , 'pushbutton'  , 'Callback' , @(src,ev) feval(callback) , varargin{:});  
            obj.updateLabel(labelgetter,validator);
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            
            
            if ~isempty(model)
                obj.eventlistener = model.addlistener(eventdescr , @(srv,ev) obj.updateLabel(labelgetter,validator) ); 
            end
            
        end
        
        function updateLabel(obj, labelgetter, validator)

            set(obj.handle,'String', labelgetter());
            set(obj.handle,'Enable' , bool2str(validator()));
        end
        function destructor(obj)
           %D disp(['Destructor: ' mfilename]);
           delete(obj.eventlistener);
           delete(obj);
        end
        
    end
    
end

function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end
