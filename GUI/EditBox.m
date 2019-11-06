classdef EditBox < handle
    %EDITBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        setter
        getter
        model
        strconvert
        
        eventlistener = [];
    end
    
    methods
        
        
        function obj = EditBox(parent , setter , getter , model , strconvert , varargin )
            obj.handle = uicontrol(parent , 'Style' , 'edit' , 'Unit' , 'Pixels'  , 'String' , getter() , 'Callback' , @(src,ev) obj.newValue()  , varargin{:} );  
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            
            obj.setter = setter;
            obj.getter = getter;

            if ~isempty(model)
                obj.eventlistener = model.addlistener('settingChanged' , @(srv,ev) obj.settingChanged()); 
            end
            if isempty(strconvert)
               obj.strconvert = @(x) x; 
            else
                obj.strconvert = strconvert;
            end
            
        end
        
        function newValue(obj)
            value =  obj.strconvert( get(obj.handle ,'String')  );
            obj.setter(value);   
        end
        
        function settingChanged(obj)
           set(obj.handle , 'String' , obj.getter()); 
        end
        
        function destructor(obj)
            %D disp(['Destructor: ' mfilename]);
            %if (ishandle(obj.handle))
            %   delete(obj.handle); 
            %end          

 		
            delete (obj.eventlistener);
            delete(obj);
        end
    end
    
end

