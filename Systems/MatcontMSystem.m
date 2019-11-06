classdef MatcontMSystem
properties(Hidden)
    nrParams
    eval
    jacobian
    jacobianp
    hessians  
    hessiansp
    der3

end

properties
    iteration = 1;
end

methods
        function obj = MatcontMSystem(systemfile)
            functionlist  = systemfile();
            obj.eval = functionlist{2};
            obj.jacobian = functionlist{3};
            obj.jacobianp = functionlist{4}; %% klopt dit wel ? FIXME
            obj.hessians = functionlist{4};
            obj.hessiansp = functionlist{5};
            obj.der3 = functionlist{6};
            
            obj.nrParams = nargin(obj.eval) - 2; %(t and X)

            
        end
        
        function newobj = getIteratedMap(obj , iteration)
            newobj = obj;
            newobj.iteration = obj.iteration * iteration;
        end
        
        
        function out = subsref(obj , S)
            
            if (length(S) == 2)
                if isequal(S(1).subs,'getIteratedMap')
                    out = getIteratedMap(obj, S(2).subs{:});
                    return
                elseif isequal(S(1).subs,'orbit')
                    nrpoints = S(2).subs{1};
                    S(2).subs(1) = [];
                    [Co,Pa] = parseParenthesis(obj , S(2));
                    out = zeros(length(Co) , nrpoints);
                    out(:,1) = Co;
                    for i = 2:nrpoints
                        out(:,i) = obj.evaluate(out(:,i-1) , Pa);
                    end
                    
                    return
                elseif isequal(S(1).subs,'jacobian')
                    [x,Pa] = parseParenthesis(obj , S(2));
                    param = num2cell(Pa);
                    func = obj.eval;
                    jacfunc  = obj.jacobian;
                    
                    nphase = length(x);
                    jac=eye(nphase);
                    if (isempty(jacfunc))
                        
                        increment = 10^-5;
                        for i=1:nphase
                            x1 = x; x1(i) = x1(i)-increment;
                            x2 = x; x2(i) = x2(i)+increment;
                            for m=1:n
                                x1= feval(func, 0, x1, param{:});
                                x2=  feval(func, 0, x2,param{:});
                            end
                            jac(:,i) =(x2-x1)/(2*increment);
                        end
                        jac=reshape(jac',nphase,nphase)';  %?
                    else
                        
                        for pointindex = 1:obj.iteration
                            jac =  feval(jacfunc, 0 , x , param{:} ) * jac;
                            x = feval(func,0, x ,param{:});
                        end
                        
                    end
                    out = jac;
                    return;
                    
                else
                    [Co,Pa] = parseParenthesis(obj , S(2));
                    out = evalfeature(obj, S(1).subs, Co , Pa);
                    return;
                end
                
            elseif (length(S) == 1)
                
                if (isequal(S.type, '()'))
                    [Co, Pa] = parseParenthesis(obj , S);
                    out = obj.evaluate(Co,Pa);
                    
                    return;
                end
                
                
                
            end
            out = [];
        end
end
methods(Hidden)

    function [Co , Pa] = parseParenthesis(obj , S)
               args = length(S.subs);
               if (args == 2)
                   Co = S.subs{1};
                   Pa = S.subs{2};
               elseif (args == obj.nrParams + 1)
                   Co = S.subs{1};
                   Pa = zeros(1, obj.nrParams);
                   for i = 2:length(S.subs)
                      Pa(i - 1) = S.subs{i}; 
                   end
               else
                   error('incorrect call of the evaluation function');  
               end         
    end
    
    
    function xx = evaluate(obj, X , param)
        param = num2cell(param);
        xx = X;
        for i = 1:obj.iteration
            xx = obj.eval(0 , xx , param{:});
        end
        
    end
    
    function out = evalfeature(obj , feature, X , param)
        param = num2cell(param);
        func = obj.(feature);
        out = func(0, X , param{:});
    end
    
end
end