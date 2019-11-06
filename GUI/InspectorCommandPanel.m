classdef InspectorCommandPanel
    %INSPECTORCOMMANDPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        im        
        eventlistener;
    end
    
    methods
        
        function obj = InspectorCommandPanel(parent, im, varargin)
            obj.im = im;
            obj.handle = uipanel(parent, 'Unit' , 'Pixels'  , varargin{:},'ResizeFcn' ,  @(o,e) obj.reconfigure());    
            obj.eventlistener = im.addlistener('listChanged' , @(o,e) obj.reconfigure());
            
            obj.configure(get(obj.handle , 'Position' ));
            
        end
        
        function reconfigure(obj)
           if ~isempty(obj.handle); delete(allchild(obj.handle)); end;

           units = get(obj.handle, 'Unit');
           set(obj.handle, 'Unit' , 'pixel');
           pos = get(obj.handle , 'Position');
           if (~isempty(pos))
                obj.configure(pos);
           else
              printc(mfilename, 'Layout resize failed , pos isempty'); 
           end
           set(obj.handle, 'Unit' , units);
        end
        
        function configure(obj, pos)
            ops_ = obj.im.current.getOperations();
            ops_inh = obj.im.current.getInheritedOperations();
            ops = [ops_ ops_inh ];
            
             if (obj.im.getNrElements() > 0)
                ops_item = obj.im.current.getItemOperations();
             else
                 ops_item = [];
             end
          
             ops_len = length(ops) + length(ops_item);
             max_width = pos(3) / ops_len;
             panelheight = min(pos(4) , 23);
             
            left = 0;
            
            for i = 1:length(ops)
                s = ops{i};
                pb = PushButton(obj.handle, s.cmd , s.label , obj.im , @() 1 ...
                    , 'indexChanged');
                
               ext = get(pb.handle , 'Extent');
               width = max( min(max_width , (ext(3)+5) ) , 80);
               set(pb.handle , 'Position' , [left 0 width panelheight]);
               
               left = left + width;
                
            end
            
            
            for i = 1:length(ops_item)
                s = ops_item{i};
                
                
                pb = PushButton(obj.handle, s.cmd , s.label , obj.im , @() obj.im.current.isValidSelection() ...
                    , 'indexChanged');
                ext = get(pb.handle , 'Extent');
                width = max( min(max_width , (ext(3)+5) ) , 80);
                set(pb.handle , 'Position' , [left 0 width panelheight]);
                left = left + width;
            end
        end
        
             
    end
    
end

