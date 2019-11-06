function opt_man=init_FPm_1DMan(mapfile, x0, p, n)
    global man_ds
    global opt 
    
    if ~iscell(p)
        p=num2cell(p);
    end
    
    opt_man.deltaMin = contget(opt,'MinStepsize',  1e-10);
    opt_man.deltaMax = contget(opt,'MaxStepsize',  0.1*sqrt(2));
    opt_man.deltak   = contget(opt,'InitStepsize', 0.0001);
    opt_man.nmax     = contget(opt,'MaxNumPoints', 5000);
    opt_man.eps      = contget(opt,'FunTolerance', 1e-6);
    opt_man.NwtMax   = contget(opt,'MaxNewtonIters',10);
    man_ds.Niterations=n;
    
    opt_man.Niterations=n;  %% NN: contman() depends on Niterations being in 'optM' (opt_man)

    man_ds.x0 = x0;
    man_ds.P0 = p;
    man_ds.mapfile = mapfile;
    func_handles = feval(man_ds.mapfile);
    man_ds.func = func_handles{2};
    man_ds.Jacobian  = func_handles{3};
    if isempty(man_ds.Jacobian)
        man_ds.SymDerivative=0;
        opt_man.JacobianIncrement=contget(opt,'Increment', 1e-5);
    else
        man_ds.SymDerivative=1;
    end
    man_ds.nphase = size(man_ds.x0,1);

    if feval(man_ds.func,0,man_ds.x0, man_ds.P0{:})-man_ds.x0 > opt_man.eps
        errorconsole('The initial point must be a fixed point.');
    end
      
    man_ds.J0=computeJacobian(opt_man);
    [man_ds.eigenvectors, man_ds.eigenvalues]=eig(man_ds.J0);
    man_ds.eigenvalues=diag(man_ds.eigenvalues);
    
    man_ds.UEigenvalues=find(abs(man_ds.eigenvalues)>1);
    man_ds.SEigenvalues=find(abs(man_ds.eigenvalues)<1);
    opt_man.function = ' '; % stable or unstable manifold
    opt_man.direction = []; % initial direction
    
    if (man_ds.nphase>2)&&((length(man_ds.UEigenvalues)==1)||(length(man_ds.SEigenvalues)==1))
        if length(man_ds.UEigenvalues)==1
            opt_man.function  = 'UManifold';
            opt_man.direction = man_ds.eigenvectors(:,man_ds.UEigenvalues);
            opt_man.Niterations=1+(man_ds.eigenvalues(man_ds.UEigenvalues)<0);
        elseif length(man_ds.SEigenvalues)==1
            opt_man.function = 'SManifold';
            opt_man.direction = man_ds.eigenvectors(:,man_ds.SEigenvalues);
            opt_man.Niterations=1+(man_ds.eigenvalues(man_ds.SEigenvalues)<0);
        end
        printconsole(['Default chosen manifold: ', opt_man.function,', with initial direction: ', num2str(opt_man.direction') , '\n'])
        printconsole('To change those values redefine "function" and "direction"\n')
    elseif (man_ds.nphase>2)
        printconsole(['The fixed point is not a saddle. The eigenvalues are: ', num2str(man_ds.eigenvalues') , '\n'])
    else
        printconsole('Choose the manifold you want to compute: SManifold or UManifold and write it in "function" .\n')
    end
    
    % Default values for the algorithm
    opt_man.Arc = Inf;
    opt_man.alphaMax = pi;
    opt_man.alphaMin = pi/4;
    opt_man.deltaAlphaMax = 10^-3;
    opt_man.deltaAlphaMin = 10^-4;
    opt_man.distanceInit = 10^-4;
    opt_man.searchListLength = 20;
end

function jac=computeJacobian(opt_man)
global man_ds
    nphase=man_ds.nphase;
    p=man_ds.P0;
    x=man_ds.x0;
    if man_ds.SymDerivative ==0
        jac=zeros(nphase);
        for i=1:nphase
            x1 = x; x1(i) = x1(i)-opt_man.JacobianIncrement;
            x2 = x; x2(i) = x2(i)+opt_man.JacobianIncrement;
            for ii=1:man_ds.Niterations
            x1= feval(man_ds.func, 0, x1, p{:});
            x2= feval(man_ds.func, 0, x2,p{:});
            end
            jac(:,i) =(x2-x1)/(2*opt_man.JacobianIncrement);
        end
    else
      jac=eye(nphase);x1=man_ds.x0;
      for ii=1:man_ds.Niterations
        jac=feval(man_ds.Jacobian, 0, x1, man_ds.P0{:})*jac;
        x1=feval(man_ds.func, 0, x1, p{:});
      end
    end
%     jac=reshape(jac',nphase,nphase)';    
end
