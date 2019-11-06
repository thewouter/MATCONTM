disp('>> global opt cds fpmds');
global opt cds fpmds
disp('>> ap=2; p=[-1;0;1;1];');
 p=[-1;0;1;1];ap=2;
 disp('>> opt = contset; ');
opt = contset;
disp('>> [x0,v0]=init_FPm_FPm(@versusm,[0;0], p, ap);');
[x0,v0]=init_FPm_FPm(@Tnfmap,[0;0], p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',50);');
opt=contset; opt=contset(opt,'MaxNumPoints',50);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
opt=contset(opt,'Backward',0);
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt= contset(opt,'Userfunctions',1);
UserInfo(1).label= 'B2  ';
UserInfo(1).name='Beta2';
UserInfo(1).state=1;
% 
UserInfo(2).label= 'B3  ';
UserInfo(2).name='Beta3';
UserInfo(2).state=1;
opt=contset(opt,'UserfunctionsInfo',UserInfo);
disp('>>[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);');
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);
cpl(x1,v1,s1,[3 1])
