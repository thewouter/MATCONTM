classdef CommanderModelEvent < event.EventData
    %COMMANDERMODELEVENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        index;
        curvelist;
        curveindex;
    end
    properties(Constant)
       ADJUSTINDEX = -4; 
    end
    methods
        function obj = CommanderModelEvent(index , list , curveindex)
           obj.index = index; 
           obj.curvelist = list;
           obj.curveindex = curveindex;
        end
    end
    
end

