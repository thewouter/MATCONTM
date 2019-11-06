classdef LyaExpAlgo2
   
    methods

        function model = getFieldsModel(~)
            model = FieldsModel();
            model.declareField('iterations' , 'iterations' , InputRestrictions.INT_g0 , 100000);
            model.declareField('report' , 'report every x iterations' ,  InputRestrictions.INT_g0 , 10000);           
        end
        
        function paramstruct = prepareStruct(~, session, model)
            
            paramstruct = struct('iterations' , model.getVal('iterations'), 'reportpoints' , model.getVal('report')  );
            
        end
        
        function [exponent, killed] = computeLE(~, ps , fun, X , p)
            if length(X) ~= 2
               error('This method of computing the largest Lyapunov exonent only works on two-dimensional maps'); 
            end
            global sOutput
              phi = angle(complex(X(1),X(2)));
              s = zeros(1,ps.iterations);
              for i = 1:ps.iterations
                 
                  %Jacobian
                  Jac = feval(fun{3},[],X,p{:});
                  %MAP:
                  X = feval(fun{2},[],X,p{:});
                  
                  Dir = [cos(phi);sin(phi)];
                  E = Jac*Dir;
                  d = norm(E);
                  E = E ./ norm(E);
                  phi1 = angle(complex(E(1), E(2)));
                  
                  s(i) = log(d);
                  phi = phi1;
                  
                  if (mod(i , ps.reportpoints) == 0)
                      printconsole('iteration: %i \n' , i);
                      tempresult = sum(s)/ i;
                      printconsole('exponent:  %16.16g \n' , tempresult);
                      drawnow;
                      if (all(~isfinite(tempresult)))
                          exponent = tempresult;
                          killed = 0;
                          return
                      end
                      if sOutput.checkPauseResumeStop(0,[],-1) ~= 0
                          killed = 1;
                          exponent = sum(s) / i;
                          return;
                      end
                      
                      
                  end
                  
              end
              
              exponent = sum(s) / ps.iterations;
              killed = 0;            
        end
        
    end
    
    
    
    
    
    
    
    
    
    
end