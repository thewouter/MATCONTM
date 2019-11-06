function h=nshesspvect(xit,p,v,AA,n)
%
% h=d/dp(A)*v where A is jacobian of f^(n) and p is a parameter.
%

global nsmds cds
 x=xit(:,1);nphase=size(x,1);
 vvt=zeros(nphase,n);vvt(:,1)=v;
 wwt=zeros(nphase,nphase,n);
 wwt(:,:,n)=eye(nphase);
 hess=zeros(nphase,nphase,nphase,n);
 hessp=zeros(nphase,nphase,2,n);
 jacp=zeros(nphase,2,n);
for j=2:n
  vvt(:,j)=AA(:,:,j-1)*vvt(:,j-1);
  wwt(:,:,n-(j-1))=wwt(:,:,n-(j-2))*AA(:,:,n-(j-2));
end %end loop j
for h=1:n
  hess(:,:,:,h)=nsmhess(xit(:,h),p,1);
  hessp(:,:,:,h)=nsmhessp(xit(:,h),p,1);
  jacp(:,:,h)= nsmjacp(x,p,h);
end
pp=size(nsmds.ActiveParams,2);
sump=zeros(nphase,2);
for k=1:2
    pp=zeros(nphase,nphase);
    for m=2:n        
        for j=1:nphase
           pp(:,j)=hess(:,:,j,m)*jacp(:,k,m-1);
        end
        s3=hessp(:,:,k,m)+pp;
        sump(:,k)=sump(:,k)+wwt(:,:,m)*s3*vvt(:,m);
    end % loop m
     sump(:,k)=sump(:,k)+(wwt(:,:,1))*hessp(:,:,k,1)*vvt(:,1);
end %of loop k
h=sump;
