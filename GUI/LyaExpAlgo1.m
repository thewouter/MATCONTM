classdef LyaExpAlgo1
   

    
    methods
        
        
        function model = getFieldsModel(~)
            model = FieldsModel();
            model.declareField('lyapsteps' , 'lyapunov steps' , InputRestrictions.INT_g0 , 100000);
            model.declareField('normsteps' , 'norm steps' ,  InputRestrictions.INT_g0 , 10);     
            model.declareField('report' , 'report every x normalizations' ,  InputRestrictions.INT_g0 , 2000);
            model.declareField('paramvals' , 'parametervalues' ,  InputRestrictions.VECTOR , []);            
        end
        
        function paramstruct = prepareStruct(~, session, model)
            %startdata = session.getStartData();
            %itn = startdata.getSetting('iterationN');
            
            lyapsteps = model.getVal('lyapsteps');
            normsteps = model.getVal('normsteps');
            reportpoints = model.getVal('report');
            
            paramstruct = struct('lyapsteps' , lyapsteps, 'normsteps' , normsteps, 'reportpoints' , reportpoints);
            
        end
        
        function [exponents, killed] = computeLE(~, ps , fun, x0 , p)
            global sOutput
            killed = 0;
            dim = length(x0);
            lyap=zeros(dim,1);
            vec=eye(dim);
            steps = 0;
            for i=1:ceil(ps.lyapsteps/ps.normsteps)
                for j=1:ps.normsteps
                    vec = feval(fun{3},[],x0,p{:})*vec;
                    x0 = feval(fun{2},[],x0,p{:});
                end
                steps = steps + ps.normsteps;
                [vec,R] = qr(vec);
                lyap = lyap+log(abs(diag(R)));
                
                if all(~isfinite(lyap))
                    exponents = lyap/steps;
                    printconsole('steps: %i \n' , steps);
                    printconsole('exponents: %s \n\n' , vector2string(exponents));
                    return;
                end
                
                if (mod(steps, ps.normsteps * ps.reportpoints) == 0)
                    
                    printconsole('steps: %i \n' , steps);
                    printconsole('exponents: %s \n\n' , vector2string( sort(lyap/steps , 'descend')));
                    
                    drawnow;
                    if sOutput.checkPauseResumeStop(0,[],-1) ~= 0
                        killed = 1;
                        break;
                    end
                end
            end
            exponents = lyap/steps;
            
        end
        
    end
    
    
    
    
    
    
    
    
    
    
end