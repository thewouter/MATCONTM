%% Ghmap test homoclinic
    clc
    clear all
    init
    %%
    global opt
    opt=contset;
    x0=[-1.621146385;-1.621146385];
    p0=[-0.4,1.03,-0.1,0];
    optM=init_FPm_1DMan(@Ghmap,x0,p0,1);
    %% Uman
    optM.function='Umanifold';  
    % I varied parameters in different continuations and in order to check 
    % the results
    optM.distanceInit=-optM.distanceInit;
    optM.eps=1e-10;
    optM.nmax=20000;
    optM.deltaMax=0.011;
    optM.deltak=1e-5;
    optM.deltaAlphaMax=0.001;
    optM.deltaAlphaMin=0.0001;
    optM.Niterations=1;

    [a,l]=contman(optM);toc
    %% Sman
    optM.function='Smanifold';
    % n.b. some parameters are used only here, ex: NtwMax
    [b,l]=contman(optM);toc
    %% plot
    figure
    ylim([-2,1]);
    xlim([-2,1]);
    line(x0(1),x0(2),'marker','.','color','k')
    line(a(1,:),a(2,:),'color','r')
    line(b(1,:),b(2,:),'color','b')
    %% homocline curves
    hom=findintersections(a,b)
    %% plot some homoclinic curves
    % the primaries (the 2 longest curves)
    c=hom{4};
    d=hom{end};
    line(c(1,:),c(2,:),'color','g','marker','.')
    line(d(1,:),d(2,:),'color','m','marker','.')
    % some secondaries
    e=hom{12};
    f=hom{13};
    g=hom{14};
    h=hom{15};
    line(e(1,:),e(2,:),'color','g','marker','.')
    line(f(1,:),f(2,:),'color','m','marker','.')
    line(g(1,:),g(2,:),'color','c','marker','.')
    line(h(1,:),h(2,:),'color','y','marker','.')
    %% continuation of the primary curve
    opt=contset;
    opt=contset(opt,'MaxNumPoints',100);
    opt=contset(opt,'Singularities',1);
    opt=contset(opt,'MinStepsize',1e-8);
    [x0hom,v0hom]=init_Hom_Hom(@Ghmap,[x0,c],p0,2,1);
    [xhomc1,vhomc1,shomc1,hhomc1,fhomc1]=cont(@homoclinic,x0hom,[],opt);
    opt=contset(opt,'Backward',1);
    [xhomc2,vhomc2,shomc2,hhomc2,fhomc2]=cont(@homoclinic,x0hom,[],opt);
    
    figure
    cpl(xhomc1,vhomc1,shomc1,[size(xhomc1,1),14])
    cpl(xhomc2,vhomc2,shomc2,[size(xhomc2,1),14])
    
% func_handles = feval(@Ghmap);
% [V,D]=eig(cjac(@Ghmap,func_handles{3},x0,n2c(p0)));
% lu=D(2,2);ls=D(1,1);
% Nu_ext=15;Ns_ext=15;
% cextend=[(c(:,end)-x0)*lu.^(-Nu_ext:-1)+repmat(x0,1,Nu_ext) ...
%           c (c(:,end)-x0)*ls.^(1:Ns_ext)+repmat(x0,1,Ns_ext)];
% opt=contset(opt,'Singularities',1);
% opt = contset(opt,'Backward',0);
% opt=contset(opt,'MaxNumPoints',40);
% [x0hom,v0hom]=init_Hom_Hom(@Ghmap,[x0,cextend],p0,2,1);
% [xhomc1,vhomc1,shomc1,hhomc1,fhomc1]=cont(@homoclinic,x0hom,[],opt);
% 
% opt=contset(opt,'Singularities',0);
% opt = contset(opt,'Backward',1);
% opt=contset(opt,'MaxNumPoints',10);
% p1=p0;p1(2)=xhomc1(end,shomc1(2).index);
% [x0lphom,v0lphom]=init_HomT_HomT(@Ghmap,xhomc1(1:end-1,shomc1(2).index),2,1,1,p1,[1 2],1);
% [xhomT,vhomT,shomT,homT,fhomT]=cont(@homoclinicT,x0lphom,[],opt);
% cpl(xhomT,vhomT,shomT,[size(xhomT,1),size(xhomT,1)-1]); %plot in (beta,alpha) plane
%% GHM test Heteroclinic
%     global opt
    opt=contset;
    x0=[ .4666170238;  .4666170238];
    x1=[-.4286170238; -.4286170238];
   
    p0=[0.3,-1.057,-0.5,0];
    optM=init_FPm_1DMan(@Ghmap,x1,p0,2);
    %% Uman
    optM.function='Smanifold';  
    optM.distanceInit=-optM.distanceInit;
    optM.eps=1e-10;
    optM.nmax=15000;
    optM.deltaMax=0.001;
    optM.deltak=1e-5;
    optM.deltaAlphaMax=0.001;
    optM.deltaAlphaMin=0.0001;
    optM.Niterations=2;

    [a,l]=contman(optM);toc
    %% Uman
    optM=init_FPm_1DMan(@Ghmap,x0,p0,2);
    optM.function='Umanifold';
    optM.distanceInit=optM.distanceInit;
    optM.Niterations=2;
    optM.eps=1e-10;
    optM.nmax=15000;
    optM.deltaMax=0.001;
    optM.deltak=1e-5;
    optM.deltaAlphaMax=0.001;
    optM.deltaAlphaMin=0.0001;

    % n.b. some parameters are used only here, ex: NtwMax
    [b,l]=contman(optM);toc
    %% plot
    figure
    ylim([-2,2]);
    xlim([-2,2]);
    line(x0(1),x0(2),'marker','.','color','k')
    line(x1(1),x1(2),'marker','.','color','k')
    line(a(1,:),a(2,:),'color','b')
    line(b(1,:),b(2,:),'color','r')
    %% heteroclinic orbit
    het=findintersections(a,b);
    %reordering necessary
    for i=1:2:size(het,1);
      e(:,(i+1)/2)=het{i};
    end
    line(e(1,:),e(2,:),'color','g','marker','.')


%% Shear map test
%     clc
%     clear all
%     init
%     %%
%     global opt
%     opt=contset;
%     
%     x0=[0;0];
%     p=[2;0.4;0.9]; %a,b,c 
% 
%     optS=init_FPm_1DMan(@Shear,x0,p);
%     %%
%     
%% Euler-Lorenz test Umanif
    clc
    clear all
    init
    %%
    global opt
    opt=contset;
    
    x0=[0,0,0]';
    sig=10;r=8.37;b=8/3;h=0.1;
    p0=[sig,r,b,h]; 
    
    optM=init_FPm_1DMan(@EulerLorenz,x0,p0,1);
    %%
    optM.NwtMax=50;
    optM.nmax=60000;
    optM.deltaMax=0.11;
    optM.Arc=500;
    optM.distanceInit=1e-4;
    optM.searchListLength=100;
    
    [M,l]=contman(optM);toc
    %% plot
    figure
    plot3(M(1,:),M(2,:),M(3,:))
%% Euler-Lorenz test Smanif
    clc
    clear all
    init
    %%
    global opt
    opt=contset;
    
    x0=[0,0,0]';
    sig=10;r=30.37;b=8/3;h=-0.1;
    p0=[sig,r,b,h]; 
    
    optM=init_FPm_1DMan(@EulerLorenz,x0,p0,1);
    %%
    optM.NwtMax=50;
    optM.nmax=60000;
    optM.deltaMax=0.11;
    optM.Arc=500;
    optM.distanceInit=1e-4;
    optM.searchListLength=100;
    
    [M,l]=contman(optM);toc
    %% plot
    figure
    plot3(M(1,:),M(2,:),M(3,:))



