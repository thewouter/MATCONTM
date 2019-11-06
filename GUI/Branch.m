classdef Branch
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
        function obj = Branch(pttag, cttag , initfunc, periodmult, conditional , options)
            obj.pointtypetag = pttag;
            obj.curvetypetag = cttag;
            obj.initfunc = initfunc;
            obj.periodmult = periodmult;
            obj.conditional = conditional;
            
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
            
            str = [ obj.curvetypetag '-curve  x' num2str(obj.periodmult) '  (' func2str(obj.initfunc)];
            
            if (obj.conditional)
                str = [str ', Conditional)'];
            else
                str = [str ')'];
            end
        end
        function lbl = getLabel(obj)
            lbl = func2str(obj.initfunc);
        end

        function bool = callRedirect(~)
           bool = 0; 
        end
        
        
    end

    
    
    
    
end


