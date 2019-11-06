classdef CategoryBox < handle  
    
    properties
        handle
        eventlistener
        catlist
        
        setter
        getter
        emptystate = true;
    end
    
    methods
        function obj = CategoryBox(parent, setter, getter , model , catlist ,  varargin) 
           obj.handle = uicontrol(parent, 'Style' , 'popupmenu' , 'DeleteFcn' , @(o,e) obj.destructor(),   varargin{:});
           set(obj.handle , 'Callback' , @(o,e) obj.callback());
           
           obj.setter = setter;
           obj.getter = getter;
           
           catlist = { struct('val' , 0 , 'name' , '    ') , catlist{:}};
           obj.emptystate = true;
           obj.configureList(catlist);
           
           
           if ~isempty(model)
                obj.eventlistener = model.addlistener('settingChanged' , @(srv,ev) obj.syncIndex()); 
           end        
           obj.syncIndex();
        end
        
        function configureList(obj , catlist )
           len = length(catlist);
           stringlist = cell(1,len);
           for i = 1:len
               stringlist{i} = catlist{i}.name;
           end
           set(obj.handle , 'Enable' , 'on' , 'String' , stringlist);
           obj.catlist = catlist;
            
        end
        
        
        function syncIndex(obj)
            object = obj.getter();

            len = length(obj.catlist);
            currIndex = get(obj.handle, 'Value');
            
            if (ischar(object))
                compare = @(x,y) strcmp(x,y);
            else
                compare = @(x,y) (isempty(x) && isempty(y))  ||  ((isempty(x) == isempty(y)) && prod(x == y));
            end
            
            i = 1;
            while ((i <= len) && ~compare(object , obj.catlist{i}.val))
                    i = i+1;
            end
            
            if (i > len)
                if (isempty(object))
                   return; 
                else
                    warning('inconsistency found, unknown value for popupbox'); 
                end
            else
                if (currIndex ~= i)
                    set(obj.handle , 'Value' , i);
                    currIndex = i;
                end
                
            end
            if (obj.emptystate && (currIndex > 1))
                obj.catlist(1) = [];
                obj.configureList( obj.catlist )
                set(obj.handle , 'Value' , currIndex - 1);
                obj.emptystate = false;
            end
            
        end
        
        function callback(obj)
            index =  get(obj.handle, 'Value');
            newval = obj.catlist{index}.val;
            obj.setter(newval);
        end
        function destructor(obj)
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
