 
 function result=process_NSm(x,n)
%
%
%
global cds fpmds
[x1,p] =rearr(x);p1=n2c(p);
jac=mjac(x1,p1,n);
nphase = size(x1,1);
% calculate eigenvalues and eigenvectors
[V,D] = eig(jac);
% find pair of complex eigenvalues
d=diag(D); 
idx1=0;idx2=0;
for k=1:nphase
  for j=k+1:nphase
     if  (d(k)== conj(d(j))) &&(imag(d(k))>0.0001) & (abs(1-d(k)*d(j))<0.00001)
        idx1=k;idx2=j;
     end
  end
end
if idx1==0
  printconsole('Neutral saddle\n');
  result='Neutral saddle'
  return;
end 
result=[];
return

% [Q,R]=qr([real(V(:,idx1)) imag(V(:,idx1))]);
% borders.v=Q(:,1:2);
% [V,D] = eig(jac');
% % find pair of complex eigenvalues
% d = diag(D);
% i=1;
% for j=1:nphase
%     if abs(d(j))==1
%         if imag(d(j))~=0
%             b(i)=d(j);i=i+1;
%         end
%     end
% end
% idx1=0;idx2=0;
% if size(b)~=0
%   m=size(b);
%   for i=1:m
%         for j=i+1:m
%             if b(i)==conj(b(j))
%                 idx1=i;idx2=j;
%             end
%         end
%   end
% end
% [Q,R]=qr([real(V(:,idx1)) imag(V(:,idx1))]); 
% borders.w=Q(:,1:2);
% k=real(d(idx1)*d(idx2));
% % calculate eigenvalues
% % ERROR OR WARNING
% RED=jac*jac+k*eye(nphase);
% jacp=mjacp(x1,p1,n);
% A=[jac  jacp zeros(nphase,1)];
% [Q,R]=qr(A');
% Bord=[RED borders.w;borders.v' zeros(2)];
% bunit=[zeros(nphase,2);eye(2)];
% vext=Bord\bunit;
% wext=Bord'\bunit;
            
% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds fpmds
p = fpmds.P0;
p(fpmds.ActiveParams) = x0(end);
x = x0(1:end-1);
