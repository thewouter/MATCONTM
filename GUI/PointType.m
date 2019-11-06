classdef PointType
    %POINTTYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        label = '';
        name = '';
    end
    
    methods
       function obj = PointType(label,varargin)
            obj.label = label;


            if (length(varargin) >= 1)
               obj.name = varargin{1}; 
            else
               obj.name = StaticPointType.getPointTypeName(obj.label);
            end

        end
        
        function label = getLabel(obj)
            label = obj.label;
        end
        function name = getName(obj)
           name = obj.name; 
        end
        
        
    end
    
end

