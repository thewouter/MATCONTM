function [man,arcl]=contman(options)
    global opt_man
    global man_ds
    tic
    
    opt_man=options;
    
    if opt_man.nmax<1e5 
        opt_man.file=0;
    elseif opt_man.nmax>=1e5 
        opt_man.file=0;
    else
        opt_man.file=0;
    end
    
    if isempty(opt_man.direction) && man_ds.nphase == 2
        if opt_man.function(1)=='U'
            opt_man.direction=man_ds.eigenvectors(:,man_ds.UEigenvalues);
        else
            opt_man.direction=man_ds.eigenvectors(:,man_ds.SEigenvalues);
        end
    else
        [adjointEigenvectors,adjointEigenvalues]=eig(man_ds.J0');
        if (opt_man.function(1)=='U')&&(any(abs(opt_man.direction'*adjointEigenvectors(:,man_ds.SEigenvalues(:)))>opt_man.eps))
            warnconsole('UserError:direction','The initial selected direction "direction" is not on the unstable manifold.')
        elseif (opt_man.function(1)=='S')&&(any(abs(opt_man.direction'*adjointEigenvectors(:,man_ds.UEigenvalues(:)))>opt_man.eps))
            warnconsole('UserError:direction','The initial selected direction "direction" is not on the stable manifold.')
        elseif (opt_man.function(1)~='U')&&(opt_man.function(1)~='S')
            errorconsole('Not specified if the continuation regards the stable or unstable manifold.')
        end
    end
    
    % opt_man.file=0;
    if opt_man.function(1)=='U' && opt_man.file==0
        man=UManifold(@funcN,@jacN);
    elseif opt_man.function(1)=='U' && opt_man.file==1
        man=UManifoldFile(@funcN,@jacN);
    elseif opt_man.function(1)=='S' && opt_man.file==0
        man=SManifold(@funcN,@jacN);
    elseif opt_man.function(1)=='S' && opt_man.file==1    
        man=SManifoldFile(@funcN,@jacN);
    else
        errorconsole('Wrong input file.')
    end
    arcl=man_ds.arcl;
end

function x=funcN(t,x,varargin)
    global man_ds
    global opt_man
    
    for i=1:opt_man.Niterations
        x=feval(man_ds.func,0,x,man_ds.P0{:});
    end
end

function jac=jacN(t,x,varargin)
    global man_ds
    global opt_man
    
    nphase = man_ds.nphase;
    jac=eye(nphase);
    x1=x;
    p=man_ds.P0;
    n=opt_man.Niterations;
    if (man_ds.SymDerivative >=1)
        for i=1:n      
            jac = feval(man_ds.Jacobian, 0, x1, p{:})*jac;
            x1=feval(man_ds.func,0,x1,p{:});
        end
    else
        for i=1:nphase
            x1 = x; x1(i) = x1(i)-opt_man.JacobianIncrement;
            x2 = x; x2(i) = x2(i)+opt_man.JacobianIncrement;
            for m=1:n     
                x1= feval(man_ds.func, 0, x1, p{:});
                x2=  feval(man_ds.func, 0, x2,p{:});
            end
        jac(:,i) =(x2-x1)/(2*opt_man.JacobianIncrement);
        end
    end
    jac=reshape(jac',nphase,nphase)';
end
