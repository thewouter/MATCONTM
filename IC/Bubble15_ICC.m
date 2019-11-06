%% ENOC2017 -- Period 15
  clc
  clear all
  init
  global opt
  opt=contset;
  format compact;

%% Simulation for a particular parameter setting
  nint=1e4;
  p=[-.512,1.195,.1];x0=[.55; .44; 1.72]; %Bubblepaper
  x=zeros(size(x0,1),nint);ps=num2cell(p);
  func_handles = feval(@AdaptiveControlMap);
  map=func_handles{2};
  der=func_handles{3};

  if 1==2
  x(:,1)=x0;
  for i2=2:nint
    x(:,i2)=feval(map,0,x(:,i2-1),ps{:});
  end
  % Compute rotation number
  for ii=1:nint
    aa(ii)=angle(x(1,ii)+1i*x(2,ii)-mean(x(1,:))-1i*mean(x(2,:)));
  end
  rho=2*pi*sum(diff(aa)<0)/nint;
  end

%% Stability computation
  load FC15_init; NN=25;dim=3;rho=4.62505205;
  theta=2*pi*(0:2*NN)/(2*NN+1);eps=1e-5;
  AA=zeros((2*NN+1)*dim);
  BB=zeros((2*NN+1)*dim);
  CC=zeros((2*NN+1)*dim);
  d1=zeros(3,length(theta));d2=d1;
  for jj=1:length(FC)
    F1=FC;F1(jj)=F1(jj)+eps;
    F2=FC;F2(jj)=F2(jj)-eps;
    for ii=1:length(theta)
%      d1(:,ii)=feval(map,0,FCMAP(theta(ii),F1),ps{:})-FCMAP(theta(ii)+rho,F1);
%      d2(:,ii)=feval(map,0,FCMAP(theta(ii),F2),ps{:})-FCMAP(theta(ii)+rho,F2);
      d1(:,ii)=FCMAP(theta(ii),F1);
      d2(:,ii)=FCMAP(theta(ii),F2);
    end
  CC(:,jj)=(reshape(d1,length(FC),1)-reshape(d2,length(FC),1))/(2*eps);
  end



  for ii=1:length(theta)
    xx=FCMAP(theta(ii),FC);
    ind=[1:dim]+(ii-1)*dim;
    AA(ind,ind)=feval(der,0,xx,ps{:});
    BB(ind,1:dim)=eye(dim);
    for jj=1:NN
      BB(ind,[1:dim]+(jj*2-1)*dim)=eye(dim)*cos(jj*theta(ii));
      BB(ind,[1:dim]+(jj*2-0)*dim)=eye(dim)*sin(jj*theta(ii));
    end
  end
  TT=zeros((2*NN+1)*dim);
  TT(1:dim,1:dim)=eye(3);
  for ii=1:NN
    cc=cos(ii*rho)*eye(3);
    ss=sin(ii*rho)*eye(3);
    ind=[1:2*dim]+(2*ii-1)*dim;
    TT(ind,ind)=[cc ss; -ss cc];
  end
  DF=TT*AA*BB;


return;
  NN=50;
  theta=2*pi*(0:2*NN)/(2*NN+1);
  FC=zeros(3*(2*NN+1),1);
  ind=[1:6,8:length(FC)];
  FC(1:3)=[.982 .982 .5226];
  FC(4:6)=[0.865 -0.075 -.475];
  FC(7:9)=[0  0.8619 -.555];
  rho=4.60;
  load FC_init;FC=[FC;zeros(25*3*2,1)];
  h=figure('visible','off');hold on;
  FC0=FC;

for rr=0:60
  rho=4.60+.0005*rr;disp(rho)
  NSTEP=60;FC=FC0;
  list=nan(NSTEP+1,2);
  for step=0:NSTEP
    ps{2}=1.18+.0005*step; err=1;kk=0;
    while (err>5e-4 && kk<10)
      [DD,JAC]=IC_eval(FC,ps,rho);
      newx=[FC(ind);ps{1}]-(JAC\reshape(DD,length(FC),1));
      FC(ind)=newx(1:end-1); ps{1}=newx(end);
      err=norm(DD);kk=kk+1;
      %norm(DD)
    end
    if(step==0)
      FC0=FC;
    end
    disp([ps{1} ps{2} kk]);
    list(step+1,:)=[ps{1} ps{2}];
    if(step>0)
      if (kk==10 || abs(diff(list(step+[0:1],1)))>.1)
        list=list(1:step,:);
        break;
      end
    end
  end
  fff=strcat('IC_',num2str(rr));
  save(fff,'list','FC0','rho');
% Visualize results
  plot(list(:,2),list(:,1))
end
  ylim([-.52 -.505']);xlabel('k');ylabel('b');
  saveas(h,'../Dropbox/IC1','fig')
  saveas(h,'../Dropbox/IC1','png')

%  h=figure(1);clf(1);hold on;
%  plot(x(1,:),x(2,:),'LineStyle','none','Marker','.');
%  for ii=1:length(theta)
%    xx(:,ii)=FCMAP(theta(ii),FC);
%  end
%  plot(xx(1,:),xx(2,:),'Marker','*','color','red')
%  saveas(h,'PhaseSpace','png')

