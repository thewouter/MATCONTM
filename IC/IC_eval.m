function [dd,JAC]=IC_eval(FC,ps,rho)
NN=(length(FC)/3-1)/2;
theta=2*pi*(0:2*NN)/(2*NN+1);
ind=[1:6,8:length(FC)]; %Keep first component of sine fixed to zero
eps=1e-4;
dd=zeros(3,length(theta));
func_handles = feval(@AdaptiveControlMap);map=func_handles{2};


%Evaluate the map DD=F(x(t))-x(t+rho)
for ii=1:length(theta)
  dd(:,ii)=feval(map,0,FCMAP(theta(ii),FC),ps{:})-FCMAP(theta(ii)+rho,FC);
end

% Compute the Jacobian
% wrt Fourier coefficients
JAC=zeros(length(FC));
parfor kk=1:length(FC)-1
  jj=ind(kk);
  d1=nan(size(dd));
  d2=nan(size(dd));
  F1=FC;F1(jj)=F1(jj)+eps;
  F2=FC;F2(jj)=F2(jj)-eps;
  for ii=1:length(theta)
    d1(:,ii)=feval(map,0,FCMAP(theta(ii),F1),ps{:})-FCMAP(theta(ii)+rho,F1);
    d2(:,ii)=feval(map,0,FCMAP(theta(ii),F2),ps{:})-FCMAP(theta(ii)+rho,F2);
  end
  JAC(:,kk)=(reshape(d1,length(FC),1)-reshape(d2,length(FC),1))/(2*eps);
end
%wrt System Parameter
ps1=ps;ps2=ps;ps1{1}=ps1{1}+eps;ps2{1}=ps2{1}-eps;
for ii=1:length(theta)
  d1(:,ii)=feval(map,0,FCMAP(theta(ii),FC),ps1{:})-FCMAP(theta(ii)+rho,FC);
  d2(:,ii)=feval(map,0,FCMAP(theta(ii),FC),ps2{:})-FCMAP(theta(ii)+rho,FC);
end
JAC(:,end)=(reshape(d1,length(FC),1)-reshape(d2,length(FC),1))/(2*eps);

end

