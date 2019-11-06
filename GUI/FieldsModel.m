classdef FieldsModel < handle
   %designed for lyapunov methods.
   %for later general use
   
   
   properties
      fields 
   end
    
    
   events
       settingChanged  %unused at the moment.
   end
   
   methods
       function obj = FieldsModel()
           obj.fields = struct();
       end
       
       function declareField(obj, tag , displayname, inputres , defaultval)
            obj.fields.(tag) = struct('displayname' , displayname , 'inputres' , inputres , 'defaultval' , defaultval , 'val' , defaultval);
           
       end
       
       function setVal(obj, tag, val)
          obj.fields.(tag).val =  val;
       end
       
       function val = getVal(obj, tag)
          val =  obj.fields.(tag).val;
       end
       
       
       function ir = getInputRestriction(obj, tag)
            ir = obj.fields.(tag).inputres;
       end
    
       function str = getName(obj, tag)
           str = obj.fields.(tag).displayname;
       end
       
       function l = getFieldTags(obj)
           l = fieldnames(obj.fields);
       end
        
       function installGUI(obj,panelhandle, mainnode)

           editboxsize = [120,20];
           
           tags = obj.getFieldTags();
           for j = 1:length(tags)
               tag = tags{j};
               subnode = LayoutNode(2,1);
               type = obj.getInputRestriction(tag);
               subnode.addHandle( 1, 1, uicontrol( panelhandle  , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                   'String' , obj.getName(tag)) , 'halign' , 'l', 'minsize' , [Inf,20]);
               
               
               box =  EditBox2(panelhandle , @(x) obj.setVal(tag, x) , ...
                   @() obj.getVal(tag)  , obj ,  ...
                   InputRestrictions.VALIDATOR{type} , @(x) x,  InputRestrictions.TOSTRING{type} ...
                   );
               
               subnode.addGUIobject( 1 , 1 , ...
                  box , 'halign' , 'r', 'minsize' , editboxsize);
               mainnode.addNode( subnode );
               
           end
           
       end
   end

end