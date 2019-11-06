function M=SManifoldFile(fun_eval,jacobian)
% Conpute 1-D stable manifold     %% writing on file (very usefull for manifold longer than 1e+5 points.)

    global man_ds
    global opt_man
    
    p0=man_ds.x0;
    Arc=opt_man.Arc;
    alphaMax=opt_man.alphaMax;
    alphaMin=opt_man.alphaMin;
    deltaMax=opt_man.deltaMax;
    deltaMin=opt_man.deltaMin;
    deltaalphaMax=opt_man.deltaAlphaMax;
    deltaalphaMin=opt_man.deltaAlphaMin;
    deltak=opt_man.deltak;
    param=man_ds.P0;
    epsb=opt_man.eps;
    deltaInit=opt_man.distanceInit;
    v=opt_man.direction;
    NewtItMax=opt_man.NwtMax;
    Nmax=opt_man.nmax;
    SearchListLength=opt_man.searchListLength;

    filename='manifold';
    delete(filename);
    precision=['%1.',mat2str(-log10(epsb)),'e'];
    
    % at least first 2 points initialization:
    [NPoint,arcl]=InitManifold(fun_eval,jacobian,p0,Arc,alphaMax,alphaMin,deltaMax,deltaMin,deltaalphaMax,deltaalphaMin,deltak,param,epsb,deltaInit,v,NewtItMax,filename);
    reader=fopen(filename,'r');
    for j=1:NPoint
        fgetl(reader);
    end
    ndim=length(p0);
    Mend=dlmread(filename,'\t',[NPoint-1,0,NPoint-1,ndim-1])';
    Mend_1=dlmread(filename,'\t',[NPoint-2,0,NPoint-2,ndim-1])';
    
    fR=Mend;
    
    i=NPoint;
    
    fRSearch=zeros(ndim,SearchListLength);
    fRSearch(:,1)=fR;
    fRSearchInd=2;
    
    if isempty(Nmax)
        Nmax=inf;
    end
    
    while (arcl<Arc)&&(NPoint<Nmax)&&(~isempty(deltak))
        
        vk=Mend-Mend_1;
        
        fL=feval(fun_eval,0,Mend,param{:});
                                        
        [fL,fR,pR,fRIndex]=findSegment(fL,fRSearch,SearchListLength,fun_eval,jacobian,param,Mend,deltak,epsb,NewtItMax);
        % search p_k such that f_pk=p_i-1 + tau*(p_i - p_i-1) & <p_k-pbar,pbar-p_k-1>=0
        
            % 1°: found an initial point: TAYLOR to linearize the system!
            % (I don't know a suitable tau to start the Newton iterations)
    
        % (f_pk = )f_pbar+jacobian(t,pbar,param)*(pk-pbar)'=M(:,i-1)+tau*(M(:,i)-M(:,i-1));
        % (pk-pbar)*(pbar-M(:,end))'=0
        
        % to help Newton to converge (next part) we choose pbar equal to 
        % the point on the line M(:,end)_fR at distance deltak from M(:,end)  
        pbar=Mend+(pR-Mend)*deltak/norm(pR-Mend);
        
        f_pbar=feval(fun_eval,0,pbar,param{:});
        
        A=[feval(jacobian,0,pbar,param{:}),(fL-fR);(pbar-Mend)',0];
        b=[-f_pbar+feval(jacobian,0,pbar,param{:})*pbar+fL;pbar'*(pbar-Mend)];
        
        solut=A\b;
       
        tau=solut(end); 
        pk=solut(1:end-1);
        
        Newvk=(pk-Mend);
        NewDeltak=norm(Newvk);
        
        alphak=angle(Newvk,vk);
        f_pk=feval(fun_eval,0,pk,param{:});
        distance=norm(f_pk-fL-tau*(fR-fL));
        
        if ((tau>=0)&&(tau<=1))||(abs(tau)<epsb) % tau is acceptable
            tau=abs(tau);
            
                % 2°: use some Newton iterations to converge to a point with
                % image on the manifold
            newtonIter=0;
            while (newtonIter<NewtItMax)&&(distance>epsb) % NEWTON ITERATIONS
                
                newtonIter=newtonIter+1;
                pktilde=pk;
                f_pktilde=f_pk;
                % Netwon iterations in order to find the point near pktilde
                % with image on the manifold
                    % f_pk=pi_1+tau(pi-pi_1)
                    % F(p,tau)=[f(p)-pi_1-tau(pi-pi_1)]
                    % dF(p,tau)=[J(p)]
                    % pk=pktilde - dF(ptilde)^(-1) F(ptilde)
                F=f_pktilde-fL-tau*(fR-fL);
                dF=feval(jacobian,0,pktilde,param{:});
                pk=pktilde-dF\F;
                Newvk=(pk-Mend);
                NewDeltak=norm(Newvk);
                alphak=angle(vk,Newvk);
        
                f_pk=feval(fun_eval,0,pk,param{:});
                distance=norm(f_pk-fL-tau*(fR-fL));
            end
            if newtonIter==NewtItMax    % Newton doesn't converge
                deltak=bisectionDelta(deltak,deltaMin);
            else                        % Newton converges
                if (NewDeltak<=deltaMax)&&(alphak<=alphaMax)&&(NewDeltak*alphak<=deltaalphaMax) % conditions: good point
                    dlmwrite(filename,pk','-append','delimiter','\t','roffset',-1,'precision',precision);
                    Mend_1=Mend;
                    Mend=pk;
                    NPoint=NPoint+1;
                    arcl=arcl+NewDeltak;
                    if mod(NPoint,1000)==0
                        printconsole(['accepted points: ',num2str(NPoint),';  arc length: ',num2str(arcl) , '\n']);
                    end % if
                    if fRSearchInd<=SearchListLength % to fill the searching fR list
                        fRSearch(:,fRSearchInd)=pk;
                        fRSearchInd=fRSearchInd+1;
                        fgetl(reader);
                        if fRIndex>0
                            fRSearchInd=fRSearchInd-fRIndex;
                            fRSearch(:,1:end-fRIndex)=fRSearch(:,1+fRIndex:end);
                            i=i+fRIndex;
                        end % if
                    elseif fRIndex>0 % mainteining the searching fR list
                        fRSearch(:,1:end-fRIndex)=fRSearch(:,1+fRIndex:end);
                        for j=1:fRIndex
                            if NPoint==(i+SearchListLength)
                                pippo=pk;
                                fgetl(reader);
                            else
                                try
                                    pippo=str2num(fgetl(reader))';
                                catch  % in some computers fgetl doesn't work properly when it's reading the last file line.
                                    fclose(reader);
                                    reader=fopen(filename,'r');
                                    for skipline=1:(i+SearchListLength-1)
                                        fgetl(reader);
                                    end
                                    pippo=str2num(fgetl(reader))';
                                end %try
                            end %if
                            fRSearch(:,end-fRIndex+j)=pippo;
                        end %for
                        i=i+fRIndex;
                    end % if
                    deltak=NewDeltak;     
                    if (alphak<=alphaMin)&&(alphak*deltak<=deltaalphaMin)&&(NPoint-fRIndex>=3)
                        deltak=doubleDelta(deltak,deltaMax);
                    end % if            
                else        % the new point pk is in an uncorrect position
                    deltak=bisectionDelta(deltak,deltaMin);
                end % if
            end % if
        else            %tau is not acceptable
            deltak=bisectionDelta(deltak,deltaMin);
        end % if
     
    end % while
    
    if arcl>=Arc
        printconsole(['Joint maximum searched manifold length: ',num2str(arcl),'    in: ',num2str(NPoint),' points.\n'])
    elseif NPoint==Nmax
        printconsole(['Joint Nmax: ',num2str(NPoint),'.    Manifold length: ',num2str(arcl) , '\n'])
    else
        printconsole(['Computation error: no convergence. \n Computation stopped at point ',num2str(NPoint),'   and manifold length: ',num2str(arcl),'/n'])
    end
    fclose(reader);
    M=load(filename)';
    man_ds.arcl=arcl;
    
end

%%  InitManifold
function [NPoint,arclength]=InitManifold(fun_eval,jacobian,p0,Arc,alphaMax,alphaMin,deltaMax,deltaMin,deltaalphaMax,deltaalphaMin,deltak,param,epsb,deltaInit,v,NewtItMax,filename)
    %first iterations in a 1D manifold continuation

    if size(p0,2)~=1
    p0=p0';
    end
    
    NPoint=1;
    
    precision=['%1.',mat2str(-log10(epsb)),'e'];
    dlmwrite(filename,p0','delimiter','\t','roffset',0,'precision',precision);
    
    pold=p0;
    pnew=p0+deltaInit*v/norm(v);

    delta=deltaInit;
    arclength=0;
    alpha=0;
 
    while ((delta<=deltak)&&(alpha<=alphaMax)&&(delta*alpha<=deltaalphaMax)&&(arclength<Arc))
        dlmwrite(filename,pnew','-append','delimiter','\t','roffset',-1,'precision',precision);
        NPoint=NPoint+1;
        arclength=arclength+delta;
        
        vold=pnew-pold;
        pold=pnew;
        
        pnew=feval('funInv_eval',fun_eval,jacobian,0,pold,epsb,NewtItMax,param{:});
        
        vnew=pnew-pold;
        delta=norm(vnew);
        alpha=angle(vnew,vold); %angle between two vectors
    end %while
    
    if NPoint<2
        errorconsole('myErr:ParamDef','deltaInit TOO BIG \n define a new initial step size \n or control other parameters value.')
    end %if

end
%% funInv_eval  find the inverse by linearization (to use aroud the fixed point)
function pinv = funInv_eval(fun_eval,jacobian,t,kmrgd,epsb,itmax,varargin)
        % (x_k =) f(x_k+1) = f(x_k) + (x_k+1-x_k)*J(x_k) 
    Jkp1=feval(jacobian,t,kmrgd,varargin{:});
    I=eye(size(Jkp1));
    f_kmrgd=feval(fun_eval,t,kmrgd,varargin{:});
    pinv=(Jkp1)\((I+Jkp1)*kmrgd-f_kmrgd); 
        % adjust using Newton
    [pinv,it]=newton(pinv,kmrgd,fun_eval,jacobian,epsb,itmax,varargin{:});
    if it>=itmax
        warnconsole('ConvErr:NoConvergence',['Convergence problem: Newton does not converge in ',num2str(itmax),' iterations']);
    end % if
end
%% Inverse estimation with Newton mtd
function [x1,it]=newton(x1,ytarget,fun,jac,eps,itmax,varargin)
    it=0;
    y1=feval(fun,0,x1,varargin{:})-ytarget;
    while (norm(y1)>eps)&&(it<itmax)
        y0=y1;
        x0=x1;
        x1=x0-feval(jac,0,x0,varargin{:})\y0;
        y1=feval(fun,0,x1,varargin{:})-ytarget;
        it=it+1;
    end
end

%%  Find the segment (after the last Image) that contains the hoped newImage
function [fL,fR,pR,i]=findSegment(fL,fRSearch,len,fun,jac,param,Mend,dk,eps,itmax)
    pL=Mend;
    fR=fRSearch(:,1);
    [pR,it]=newton(pL,fR,fun,jac,eps,itmax,param{:});
    if it>=itmax
        warnconsole('ConvErr:NoConvergence',['Convergence problem: Newton does not converge in ',num2str(itmax),' iterations']);
    end % if
    
    segment=0;
    i=0;
    while (i<len-1)&&(segment==0)
        distL=norm(pL-Mend);
        distR=norm(pR-Mend);
        if (distL<=dk)&&(distR>=dk)
            segment=1;
        else
            i=i+1;
            pL=pR;
            fL=fR;
            fR=fRSearch(:,i+1);
            [pR,it]=newton(pL,fR,fun,jac,eps,itmax,param{:});
            if it>=itmax
                warnconsole('ConvErr:NoConvergence',['Convergence problem: Newton does not converge in ',num2str(itmax),' iterations']);
            end % if           
        end % if
    end % while
    
    if i>=len-1
        warnconsole('ConvErr:NoConvergence','Probable continuation error. Increase the value of the list length: SearchListLength');
    end
    if segment==0
        errorconsole('ConvErr:NoConvergence','Impossible find the segment with preimage enougth far from the last manifold point.')
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
    if 2*dk<dM  
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



