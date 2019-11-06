classdef Branch_LyaExp
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
        
        fieldsmodel
        lyaExpAlgo
        displayname
    end
    
    methods
        function obj = Branch_LyaExp(LEalgo, label , displayname)
            obj.pointtypetag = 'P';
            obj.curvetypetag = 'LYA';
            obj.initfunc = label;
            obj.periodmult = 1;
            obj.conditional = false;
            options = 'D';
            [obj.type,rest] = strtok(options,'+');
            obj.bps = ~isempty(strtok(rest,'+'));
            
            obj.displayname = displayname;
            obj.lyaExpAlgo = LEalgo;
            obj.fieldsmodel = obj.lyaExpAlgo.getFieldsModel();
            obj.fieldsmodel.declareField('paramvals' , 'parametervalues' ,  InputRestrictions.VECTOR , []);  

        end

        function o = getFieldsModel(obj)
            o = obj.fieldsmodel;
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
            str = obj.displayname;
        end
        function lbl = getLabel(obj)
            lbl = obj.initfunc;
        end
        function bool = callRedirect(~)
           bool = 1; 
        end
        
        function call(obj, session , direction)
            if ~strcmp(direction,'forward')
                return 
            end
            
            startdata = session.getStartData();
            
            fun = feval(session.getSystem().getFunctionHandle());
            p = num2cell(startdata.getParameterValues());
            x0 = startdata.getCoordinateValues();
            nrFreeParam =  startdata.getNrFreeParams();
            paramstruct = obj.lyaExpAlgo.prepareStruct(session, obj.fieldsmodel);
            paramvalues =  obj.fieldsmodel.getVal('paramvals');
            
            tic;
            session.lock();
            global sOutput; sOutput = SessionOutput(session );
            sOutput.setPauseNever();
            
            MonitorPanel(session);
            sOutput.setStatus('Computing ...');
            
            if (nrFreeParam == 1) && (~isempty(paramvalues))
                paramindex = startdata.getActiveParams();
                paramnames = startdata.getParameters();
                paramname = paramnames{paramindex};
                
                printconsole('Computing Lyapunov exponents with %i values for parameter %s \n', length(paramvalues) , paramname);
                
                clear results;
                
                count = 1;
                for paramvalue = paramvalues
                   p{paramindex} = paramvalue;
                   printconsole('(%i/%i) setting %s = %.15g \n' , count , length(paramvalues) , paramname , paramvalue);
                   
                   
                   [exponents, killed] = obj.lyaExpAlgo.computeLE(paramstruct, fun , x0 , p);

                   results(:,count) =  sort(exponents, 'Descend');
                   count = count + 1;
                   
                   if killed
                      paramvalues = paramvalues(1:count);
                      break; 
                   end
                   printconsole('---');
                end
                exponents = struct(paramname , paramvalues , 'exponents' ,  results);
                varname = 'lyapunovExponents';
            else
                exponents = obj.lyaExpAlgo.computeLE(paramstruct, fun , x0 , p);
                varname = 'lyapunovExponents';
            end
            
            
            printconsole('Elapsed time is %5.5g seconds.\n', toc);

            printconsole('computation has ended\n'); 
            printconsole('results are stored in "%s" in the main workspace\n' , varname);
            sOutput.endRun();
            session.unlock();
            assignin('base' , varname , exponents);
            
        end

    end
end


