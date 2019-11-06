classdef SyncHandles < handle
%SYNCHANDELS 
%

   properties
       handlelist
       laststate = -9; %dummy value
       predicate
   end

   methods
       function obj = SyncHandles(model, initlist , predicate)
           obj.handlelist = initlist;
           obj.predicate = predicate;
           
           model.addlistener('stateChanged' , @(src,ev) obj.sync() );
 
           sync(obj);
       end
       
       function sync(obj)
          state = obj.predicate();
          if (state ~= obj.laststate)
              if (state)
                 set(obj.handlelist, 'Enable' , 'on'); 
              else
                  set(obj.handlelist, 'Enable' , 'off');
              end
              obj.laststate = state;
          end
       end
       
       
       %need destructor
   end
   
end 
