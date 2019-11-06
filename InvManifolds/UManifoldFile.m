function M = UManifoldFile(fun_eval,jacobian)
% Conpute 1-D unstable manifold
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
    SearchListLength=opt_man.searchListLength;
    
    filename='manifold';
    delete(filename);
    precision=['%1.',mat2str(-log10(epsb)),'e'];
    
    % at least first 2 points initialization:
    [Npoint,arcl]=InitManifold(fun_eval,jacobian,p0,Arc,alphamax, alphamin,deltamax,deltamin,deltaalphamax,deltaalphamin,deltak,param,epsb,delInit,v,NMax,filename);
    reader=fopen(filename,'r');
    for j=1:Npoint
        fgetl(reader);
    end
    ndim=length(p0);
    
    i=Npoint;
       
    eps=0.2;
    Mend=dlmread(filename,'\t',[Npoint-1,0,Npoint-1,ndim-1])';
    Mend_1=dlmread(filename,'\t',[Npoint-2,0,Npoint-2,ndim-1])';
    
    PreImage=Mend_1;
    qR=Mend;
    
    qRSearch=zeros(ndim,SearchListLength);
    qRSearch(:,1)=qR;
    qRSearchInd=2;
    
    if isempty(NMax)
        NMax=inf;
    end
    
    while (arcl<Arc)&&(i<=Npoint)&&(Npoint<NMax)&&(~isempty(deltak))
        % I'm searching a point that has image with distance dk from M(end)
        bisection=1;
        bisecIndex=0;
        newPoint=0;
        
        qL=PreImage;
        [qL,qR,qRIndex,deltak]=findSegment(qL,qRSearch,SearchListLength,Mend,fun_eval,param,deltak,deltamin);
        while (bisection==1)&&(bisecIndex<100)
            bisecIndex=bisecIndex+1;
            q=(qL+qR)/2;
            pk=feval(fun_eval,0,q,param{:});
            distR=norm(feval(fun_eval,0,qR,param{:})-Mend);
        
            distance=norm(pk-Mend);
            
            if (distance<=(1+eps)*deltak)&&(distance>=(1-eps)*deltak)  %% case 1
                alphak=angle((pk-Mend),(Mend-Mend_1));
                if (alphak<=alphamax)&&(deltak*alphak<=deltaalphamax) %point accepted
                    dlmwrite(filename,pk','-append','delimiter','\t','roffset',-1,'precision',precision);
                    Npoint=Npoint+1;
                    Mend_1=Mend;
                    Mend=pk;
                    arcl=arcl+distance;
                    PreImage=q;
                    newPoint=1;
                    if (alphak<=alphamin)&&(deltak*alphak<=deltaalphamin)
                        deltak=doubleDelta(deltak,deltamax);
                    end % if
                    if mod(Npoint,1000)==0
                        printconsole(['accepted points: ',num2str(Npoint),';  arc length: ',num2str(arcl) , '\n']);
                    end % if
                    if qRSearchInd<=SearchListLength % to fill the searching qR list
                        qRSearch(:,qRSearchInd)=pk;
                        qRSearchInd=qRSearchInd+1;
                        fgetl(reader);
                        if qRIndex>0
                            qRSearchInd=qRSearchInd-qRIndex;
                            qRSearch(:,1:end-qRIndex)=qRSearch(:,1+qRIndex:end);
                            i=i+qRIndex;
                        end % if
                    elseif qRIndex>0 % mainteining the searching qR list
                        qRSearch(:,1:end-qRIndex)=qRSearch(:,1+qRIndex:end);
                        for j=1:qRIndex
                            if Npoint==(i+SearchListLength)
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
                                    end %for
                                    pippo=str2num(fgetl(reader))';
                                end %try
                            end %if
                            qRSearch(:,end-qRIndex+j)=pippo;
                        end %for
                        i=i+qRIndex;
                    end % if
                else            % point in a not correct position
                    deltak=bisectionDelta(deltak,deltamin);   
                end % if
                bisection=0;
                
            elseif ((distR>deltak)&&(distance<deltak))||((distR<deltak)&&(distance>deltak)) %% case 2
                qL=q;
            elseif ((distR>deltak)&&(distance>deltak))||((distR<deltak)&&(distance<deltak)) %% case 3
                qR=q;
            end % if
        end % while
        
        if (newPoint==0)
            deltak=bisectionDelta(deltak,deltamin);
        end % if        
    end % while
    
    if arcl>=Arc
        printconsole(['Joint maximum searched manifold length: ',num2str(arcl),'    in: ',num2str(Npoint),' points.\n'])
    elseif Npoint==NMax
        printconsole(['Joint Nmax: ',num2str(Npoint),'.    Manifold length: ',num2str(arcl) , '\n'])
    else
        printconsole(['Computation error: no convergence. \n Computation stopped at point: ',num2str(Npoint),' and manifold length: ',num2str(arcl),'\n'])
    end  
    
    fclose(reader);
    M=load(filename)';
    man_ds.arcl=arcl;
    
end
%% InitManifold
function [Np,arclength]=InitManifold(fun_eval,jacobian,p0,Arc,alphaMax,alphaMin,deltaMax,deltaMin,deltaalphaMax,deltaalphaMin,deltak,param,epsb,deltaInit,v,Nmax,filename)
    %first iterations in a 1D manifold continuation

    if size(p0,2)~=1
    p0=p0';
    end
    
    Np=1;
    
    precision=['%1.',mat2str(-log10(epsb)),'e'];
    dlmwrite(filename,p0','delimiter','\t','roffset',0,'precision',precision);
    
    pold=p0;
    pnew=p0+deltaInit*v/norm(v);

    delta=deltaInit;
    arclength=0;
    alpha=0;
    
    while ((delta<=deltak)&&(alpha<alphaMax)&&(delta*alpha<deltaalphaMax)&&(arclength<Arc))
        dlmwrite(filename,pnew','-append','delimiter','\t','roffset',-1,'precision',precision);
        Np=Np+1;
        arclength=arclength+delta;
        
        vold=pnew-pold;
        pold=pnew;
        
        pnew=feval(fun_eval,0,pold,param{:});
        
        vnew=pnew-pold;
        delta=norm(vnew);
        alpha=angle(vnew,vold); %angle between two vectors
    end %while
    
    if Np<2
        errorconsole('myErr:ParamDef','deltaInit TOO BIG \n define a new initial step size \n or control other parameters value.')
    end %if

end

%%  Find the segment (after the last preImage) that contains the hoped newImage
function [qL,qR,i,dk]=findSegment(qL,qRList,ListLength,Mend,fun,param,dk,dMin)
    i=0;
    qLstart=qL;
    qRstart=qRList(:,1);
    qR=qRstart;
    segment=0;
    while (i<ListLength-1)&&(segment==0)
        distL=norm(feval(fun,0,qL,param{:})-Mend);
        distR=norm(feval(fun,0,qR,param{:})-Mend);
        if ((distL<dk)&&(distR>dk))||((distL>dk)&&(distR<dk))
            segment=1;
        else
            i=i+1;
            qL=qR;
            qR=qRList(:,i+1);
        end % if
    end % while
    
    if i>10
        warnconsole('ConvErr:NoConvergence','Probable continuation error');
    end
    if i==ListLength-1
        i=0;
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


