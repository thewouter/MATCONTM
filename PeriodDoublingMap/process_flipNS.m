 
 function result=process_flipNS(x,jac)
%
%
%
global cds pdmds
n=pdmds.Niterations;
[x1,p] =rearr(x);p1=n2c(p);
nphase=size(x1,1);
jac=pdmjac(x1,p1,n);
nphase = size(x1,1);%'reza',eig(jac),pause
% calculate eigenvalues and eigenvectors
[V,D] = eig(jac);
% find pair of complex eigenvalues
d=diag(D);
idx1=0;idx2=0;
    for k=1:nphase
       for j=k+1:nphase
              if  (d(k)== conj(d(j))) &(imag(d(k))>0.0001) & (abs(1-d(k)*d(j))<0.0001)
               idx1=k;
               idx2=j;
           end
            end
    end
        
if idx1==0
       result='Neutral saddle';
       return;
end 
result=real(d(idx1));
return;

% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds pdmds
p = pdmds.P0;
p(pdmds.ActiveParams) = x0(end-1:end);
x = x0(1:end-2);



