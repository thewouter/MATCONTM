classdef SessionOutputModel < handle
    %SESSIONOUTPUTMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       listenerlist = {}; 
    end
    
    events
        stateChanged
        settingChanged
    end
    
    methods
        function addToListeners(obj, le)
           obj.listenerlist{end+1} = le; 
        end
        
        
        function destructor(obj)
            for i = 1:length(obj.listenerlist)
                delete (obj.listenerlist{i});
            end
            delete(obj);
        end
    end
    

end

