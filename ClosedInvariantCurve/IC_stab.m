function [DF,ll] = IC_stab(FC,ps,rho,BB,BI,TT) % rho = rotation number??
  func_handles = feval(@AdaptiveControlMap);
%   map=func_handles{2};
  der=func_handles{3}; 
  dim=3;
  NN=(length(FC)/dim-1)/2;
  theta=2*pi*(0:2*NN)/(2*NN+1);%eps=1e-5;
  AA=zeros((2*NN+1)*dim);
%   BB=zeros((2*NN+1)*dim);

  for ii=1:length(theta)
    xx=FCMAP(theta(ii),FC);
    ind=(1:dim)+(ii-1)*dim;
    AA(ind,ind)=feval(der,0,xx,ps{:});
%     BB(ind,1:dim)=eye(dim);
%     for jj=1:NN
%       BB(ind,[1:dim]+(jj*2-1)*dim)=eye(dim)*cos(jj*theta(ii));
%       BB(ind,[1:dim]+(jj*2-0)*dim)=eye(dim)*sin(jj*theta(ii));
%     end
  end
%   TT=zeros((2*NN+1)*dim);
%   TT(1:dim,1:dim)=eye(3);
%   for ii=1:NN
%     cc=cos(ii*rho)*eye(3);
%     ss=sin(ii*rho)*eye(3);
%     ind=[1:2*dim]+(2*ii-1)*dim;
%     TT(ind,ind)=[cc ss; -ss cc];
%   end
  DF=TT'*BI*AA*BB;
  [X,D]=eig(DF);
  nn=floor(.5*(1:2*NN+1));
  len=size(X,2);
  aa=ones(len,1);
  for ii=1:size(X,2)
    FF=sum(abs(reshape(X(:,ii),3,2*NN+1)));
    aa(ii)=nn*FF';
  end
  [~,jj]=sort(aa);
  ll=diag(D);
  ll=ll(jj(1:floor(len/4)));
  
