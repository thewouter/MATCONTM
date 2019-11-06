function M = UManifold(fun_eval,jacobian)
% Compute 1-D unstable manifold
    global man_ds
    global opt_man
    
    p0=man_ds.x0;
    Arc=opt_man.Arc;
    alphamax=opt_man.alphaMax;
    alphamin=opt_man.alphaMin;
    deltamax=opt_man.deltaMax;
    deltamin=opt_man.deltaMin;
    deltaalphamax=opt_man.deltaAlphaMax;
    deltaalphamin=opt_man.deltaAlphaMin;
    deltak=opt_man.deltak;
    param=man_ds.P0;
    epsb=opt_man.eps;
    delInit=opt_man.distanceInit;
    v=opt_man.direction;
    NMax=opt_man.nmax;
       
    % at least first 2 points initialization:
    [M,Npoint,arcl]=InitManifold(fun_eval,jacobian,p0,Arc,alphamax,alphamin,deltamax,deltamin,deltaalphamax,deltaalphamin,deltak,param,epsb,delInit,v,NMax);
    
    i=Npoint;
       
    eps=0.2;
    PreImage=M(:,i-1);
    
    while (arcl<Arc)&&(Npoint<NMax)&&(i<=Npoint)&&(~isempty(deltak))
        % I'm searching a point that has image with distance dk from M(end)
        bisection=1;
        bisecIndex=0;
        newPoint=0;
        
        qL=PreImage;
        qR=M(:,i);
        [qL,qR,i,deltak]=findSegment(qL,qR,M,i,Npoint,fun_eval,param,deltak,deltamin);
        while (bisection==1)&&(bisecIndex<100)
            bisecIndex=bisecIndex+1;
            q=(qL+qR)/2;
            pk=feval(fun_eval,0,q,param{:});
            distR=norm(feval(fun_eval,0,qR,param{:})-M(:,Npoint));
        
            distance=norm(pk-M(:,Npoint));
            try
            if (distance<=(1+eps)*deltak)&&(distance>=(1-eps)*deltak)  %% case 1
                alphak=angle((pk-M(:,Npoint)),(M(:,Npoint)-M(:,Npoint-1)));
                if (alphak<=alphamax)&&(deltak*alphak<=deltaalphamax)
                    Npoint=Npoint+1;
                    M(:,Npoint)=pk;
                    arcl=arcl+distance;
                    PreImage=q;
                    if mod(Npoint,1000)==0
                        printconsole(['accepted points: ',num2str(Npoint),';  arc length: ',num2str(arcl) , '\n']);
                    end % if
                    newPoint=1;
                    if (alphak<=alphamin)&&(deltak*alphak<=deltaalphamin)
                        deltak=doubleDelta(deltak,deltamax);
                    end % if
                else
                    deltak=bisectionDelta(deltak,deltamin);   
                end % if
                bisection=0;
            elseif ((distR>deltak)&&(distance<deltak))||((distR<deltak)&&(distance>deltak)) %% case 2
                qL=q;
            elseif ((distR>deltak)&&(distance>deltak))||((distR<deltak)&&(distance<deltak)) %% case 3
                qR=q;
            end % if
            catch errore
                if isempty(deltak)
                    continue
                else
                    errorconsole(errore);
                end
            end %catch
        end % while
        
        if (newPoint==0)
            deltak=bisectionDelta(deltak,deltamin);
        end % if
                
    end % while
    
    
    if (Npoint<NMax)&&(i<=Npoint)&&(arcl>=Arc)
        M=M(:,1:Npoint);
        printconsole(['Joint maximum searched manifold length: ',num2str(arcl),'    in: ',num2str(Npoint),' points.\n'])
    elseif Npoint==NMax
        printconsole(['Joint Nmax: ',num2str(Npoint),'.    Manifold length: ',num2str(arcl),'\n'])
    else
        M=M(:,1:Npoint);
        printconsole(['Computation error: no convergence. \n Computation stopped at point ',num2str(Npoint),' and manifold length: ',num2str(arcl),'\n'])
    end  
    
    man_ds.arcl=arcl;
    
end
%% InitManifold
function [M,Np,arclength]=InitManifold(fun_eval,jacobian,p0,Arc,alphaMax,alphaMin,deltaMax,deltaMin,deltaalphaMax,deltaalphaMin,deltak,param,epsb,deltaInit,v,Nmax)
    %first iterations in a 1D manifold continuation

    if size(p0,2)~=1
    p0=p0';
    end
    
    M=zeros(size(p0,1),Nmax);
    Np=1;
    M(:,Np)=p0;
    pnew=p0+deltaInit*v/norm(v);

    delta=deltaInit;
    arclength=0;
    alpha=0;
    
    while ((delta<=deltak)&&(alpha<alphaMax)&&(delta*alpha<deltaalphaMax)&&(arclength<Arc))
        M(:,Np+1)=pnew;
        Np=Np+1;
        arclength=arclength+delta;
        
        vold=pnew-M(:,Np-1);
        pold=pnew;
        
        pnew=feval(fun_eval,0,pold,param{:});
        
        vnew=pnew-pold;
        delta=norm(vnew);
        alpha=angle(vnew,vold); %angle between two vectors
    end %while
    
    if size(M,2)<2
        errorconsole('myErr:ParamDef','deltaInit TOO BIG \n define a new initial step size \n or control other parameter values.')
    end %if

end

%%  Find the segment (after the last preImage) that contains the hoped newImage
function [qL,qR,i,dk]=findSegment(qL,qR,M,i,Npoint,fun,param,dk,dMin)
    istart=i;
    qLstart=qL;
    qRstart=qR;
    segment=0;
    j=0;
    while (i<=Npoint)&&(segment==0)
        distL=norm(feval(fun,0,qL,param{:})-M(:,Npoint));
        distR=norm(feval(fun,0,qR,param{:})-M(:,Npoint));
        if ((distL<dk)&&(distR>dk))||((distL>dk)&&(distR<dk))
            segment=1;
        else
            j=j+1;
            i=i+1;
            qL=qR;
            qR=M(:,i);
        end % if
    end % while
    
    if j>20
        warnconsole('ConvErr:NoConvergence','Probable continuation error');
    elseif i>Npoint
        i=istart;
        qL=qLstart;
        qR=qRstart;
        dk=bisectionDelta(dk,dMin);
    end % if
end
            
%% Bisection delta
function deltak=bisectionDelta(dk,dM)
    if dk/2>dM  
        deltak=dk/2;
    else
       deltak=[];
       % errorconsole('ConvErr:NoConvergence','ConvErr:NoConvergence          Joint delta_k min.');
    end % if
end

%% DoubleDelta
function deltak=doubleDelta(dk,dM)
    if 2*dk<=dM  
        deltak=2*dk;
    else
        deltak=dk;
    end % if
end
%% Angle between two vectors
function alfa=angle(A,B)
    alfa=acos(A'*B/norm(A)/norm(B));
end
%%

