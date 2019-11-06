classdef InspectorList < handle
    
    properties
        handle
        prevtime
        previndex;
        
        inspector;
        
        eventlisteners = {};
    end
    
    methods
        function obj = InspectorList(parent, inspector , varargin)
            
            obj.handle = uicontrol(parent, 'Style' , 'listbox' ,  'Unit' , 'Pixels' , ... 
            'Callback' , @(o,e) obj.selectCallback(),'DeleteFcn' , @(o,e) obj.destructor(),varargin{:},...
            'KeyPressFcn' , @(o,e) keypress(o,e,inspector));
      
            obj.setIndex(inspector.getSelectedIndex());
            


            obj.setList(inspector.getSelectList());
            set(obj.handle , 'TooltipString' , inspector.getCurrentTooltipString() );
                
            obj.eventlisteners{end+1} = inspector.addlistener('listChanged', @(o,e) obj.listChanged());
            obj.eventlisteners{end+1} = inspector.addlistener('indexChanged' ,@(o,e) obj.indexChanged());
        
            obj.prevtime = clock;
            obj.previndex = -9;
            obj.inspector = inspector;
        end

        
        
        %%%%%%%
        function setList(obj,list) 
            displist = cell(length(list)+2, 1);
            displist{1} = '..';
            displist{2} = '  ';
            
           for i = 1:length(list)
                displist{i+2} = deblank(list{i}); %list could contain nasty linefeeds and newlines.
           end

           set(obj.handle, 'String' , displist);  
           if (isempty(list))
                set(obj.handle, 'Value' , 1);
           end

        end
        function listm = getList(obj)
           list = get(obj.handle, 'String');
           listm = list(3:end);
        end
        function indexm = getIndex(obj)
            indexm = get(obj.handle,'Value') - 2;
        end
        function setIndex(obj,index)
            set(obj.handle, 'Value' , index + 2);
        end
        %%%%%%%%
        function selectCallback(obj)
           index = obj.getIndex();
           time = clock;
           
           
           if (index == obj.previndex) 
               if (etime(time,obj.prevtime) <= 0.5)
                    obj.previndex = -9;
                    if (index >= 1)
                        obj.inspector.selectItem(index);
                    elseif (index == -1)
                        obj.inspector.goUp();
                    end
                    return %! belangrijk
                end
           elseif (index >= 1)
              obj.inspector.setSelectedIndex(index);
           else
              obj.inspector.unSetIndex(); 
           end
           
           obj.prevtime = time;
           obj.previndex = index;
        end
        
        
        function listChanged(obj)
           obj.setList(obj.inspector.getSelectList());
           obj.setIndex(obj.inspector.getSelectedIndex());
           set(obj.handle , 'TooltipString' , obj.inspector.getCurrentTooltipString() );
        end
        
        function indexChanged(obj)
            index = obj.inspector.getSelectedIndex();
            index_list = obj.getIndex();
            if (index_list ~= index)
                obj.setIndex(obj.inspector.getSelectedIndex());
            end
        end
        
        function destructor(obj)
            for i = 1:length(obj.eventlisteners)
               delete(obj.eventlisteners{i}); 
            end
            
            delete(obj);
        end

                
    end
    
end
function keypress(handle, event, inspector)
inspector.keypress(event);


end
