function h=pdvecthessvect(xit,p,v,w,AA,n)

%
% h=-w'*d/dx(A)*v where A is jacobian of f^(n) .
%
global cds pdmds
x1=xit(:,1);nphase=size(x1,1);
vvt=zeros(nphase,n);vvt(:,1)=v;
wwt=zeros(nphase,n);wwt(:,n)=w';
hess=zeros(nphase,nphase,nphase,n);
jac=zeros(nphase,nphase,n);
gp=zeros(1,2);
 for j=2:n
 vvt(:,j)=AA(:,:,j-1)*vvt(:,j-1);
 wwt(:,n-(j-1))=(wwt(:,n-(j-2))'*AA(:,:,n-(j-2)))'; 
end %end loop j
 for h=1:n
  hess(:,:,:,h)=pdmhess(xit(:,h),p); 
  jac(:,:,h)=pdmjac(xit,p,h);
 end
for k=1:nphase
 sump=0;pp=zeros(nphase,nphase);
 for l=2:n
  for j=1:nphase
     pp(:,j)=hess(:,:,j,l)*jac(:,k,l-1);
  end
     sump=sump-(wwt(:,l))'*pp*vvt(:,l);
  end % loop l
  sump=sump-(wwt(:,1))'*hess(:,:,k,1)*vvt(:,1);
  gp(:,k)=sump;
end % loop k
h=gp;