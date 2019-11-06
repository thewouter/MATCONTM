classdef StaticPointType
    %POINTTYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        pointtypelist = {};
    end
    
    properties(Constant)
       FP =  PointType('FP');
       X  = PointType('X','');
    end
    
    methods
        function obj = StaticPointType()
           obj.pointtypelist{end+1} = PointType('FP');
           obj.pointtypelist{end+1} = PointType('BP');
           obj.pointtypelist{end+1} = PointType('PD');
           obj.pointtypelist{end+1} = PointType('LP');
           obj.pointtypelist{end+1} = PointType('NS');
           obj.pointtypelist{end+1} = PointType('P');           
           obj.pointtypelist{end+1} = PointType('CO');           
           obj.pointtypelist{end+1} = PointType('X' );

           
        end
        
        function descr = getPointType(obj, pointlabel)
           for i = 1:length(obj.pointtypelist)
               if ( strcmp(obj.pointtypelist{i}.getLabel(), pointlabel ))
                  descr =  obj.pointtypelist{i};
                  return;
                   
               end
               
           end
           descr = [];
        end
        function list = getPointsList(obj)
           list = obj.pointtypelist; 
        end
        function name = getNameByTag(obj, tag)
           if (isfield(obj.pointnames , tag))
               name = obj.pointnames.(tag);
           else
               name = tag;
           end
        end

    end
    
    methods(Static)
        function descr = getPointTypeObject(label)
           pt = StaticPointType();
           descr = pt.getPointType(label);
	   if (isempty(descr))
		%disp(['creating defaultpointhandler: ' label]);
		descr = PointType(label);
	   end

        end

	function pointnames = getNameStruct()
	   pointnames = DefaultValues.POINTNAMES; 
           pointnames.X = '';
    end


    

        function name = getPointTypeName(label)
         	   pointnames = StaticPointType.getNameStruct();
               if (isfield(pointnames,label))
                   name = pointnames.(label);
               else
                   name = label;
               end
        end
    end
end

