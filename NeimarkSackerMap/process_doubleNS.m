 
 function result=process_doubleNS(x,jac)
%
%
%
global cds nsmds
[x1,p] =rearr(x);p1=n2c(p);
nphase = size(x1,1);
jac1=jac(:,1:nsmds.nphase-2);
% calculate eigenvalues and eigenvectors
[V,D] = eig(jac1);
% find pair of complex eigenvalues
d=diag(D);
idx1=0;idx2=0;
    for k=1:nsmds.nphase-2
       for j=k+1:nsmds.nphase-2
              if  (d(k)== conj(d(j))) &(imag(d(k))>0.0001)  %(abs(1-d(k)*d(j))<0.001)
               idx1=k;
               idx2=j;
           end
            end
        end
if idx1==0
    result='Neutral saddle';
       
else
result=d(idx1); 
end

% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds nsmds
p = nsmds.P0;
p(nsmds.ActiveParams) = x0(end-1:end);
x = x0(1:end-2);



