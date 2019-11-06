function h=lpvecthesspvect(xit,p,v,w,AA,n)
%
% h=-w'*d/dp(A)*v where A is jacobian of f^(n) and p is a parameter.
%

global lpmds cds
x=xit(:,1);nphase=size(x,1);
vvt=zeros(nphase,n);vvt(:,1)=v;
wwt=zeros(nphase,n);
wwt(:,n)=w';
hess=zeros(nphase,nphase,nphase,n);
hessp=zeros(nphase,nphase,2,n);
jacp=zeros(nphase,2,n);
gp=zeros(1,2);
for j=2:n
 vvt(:,j)=AA(:,:,j-1)*vvt(:,j-1);
 wwt(:,n-(j-1))=(wwt(:,n-(j-2))'*AA(:,:,n-(j-2)))'; 
 end %end loop j
for h=1:n
  hess(:,:,:,h)=lpmhess(xit(:,h),p);
  hessp(:,:,:,h)=lpmhessp(xit(:,h),p);
  jacp(:,:,h)= lpmjacp(x,p,h);
end
for k=1:2
  sump=0;pp=zeros(nphase,nphase);
 for l=2:n
   for j=1:nphase
     pp(:,j)=hess(:,:,j,l)*jacp(:,k,l-1);
  end
    s3=hessp(:,:,k,l)+pp;
  sump=sump-(wwt(:,l))'*s3*vvt(:,l);
  end % loop l
   sump=sump-(wwt(:,1))'*hessp(:,:,k,1)*vvt(:,1);
   gp(:,k)=sump;
end %of loop k
h=gp;

