classdef Branch_O
    %BRANCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        curvetypetag
        pointtypetag
        conditional
        initfunc
        periodmult

        type
        bps
        
    end
    
    methods
        function obj = Branch_O()
            obj.pointtypetag = 'P';
            obj.curvetypetag = 'O';
            obj.initfunc = 'Orbit';
            obj.periodmult = 1;
            obj.conditional = false;
            options = 'D';
            [obj.type,rest] = strtok(options,'+');
            obj.bps = ~isempty(strtok(rest,'+'));
        end
        
        function type = getType(obj)
            type = obj.type;
        end
        function mult = getPeriodMult(obj)
           mult = obj.periodmult; 
        end
        function initfunc = getInitFunc(obj)
           initfunc = obj.initfunc; 
        end
        function bool  = isConditional(obj)
           bool = obj.conditional; 
        end
        
        function ct = getCurveType(obj)
            ct = CurveType.getCurveTypeObject(obj.curvetypetag);
        end
        
        function display(obj)
           fprintf( [obj.toString() '\n']);  
        end
        
        function str = toString(obj)
            str = 'Orbit (Simulation)';
        end
        function lbl = getLabel(obj)
            lbl = 'Orbit';
        end
        function bool = callRedirect(~)
           bool = 0; 
        end
    end

    
    
    
    
end


