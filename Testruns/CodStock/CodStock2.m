

disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp(' >>>>> fixed points >>>>>>>')
CodStock1;
clc
disp('>> opt = contset; ');
global x2 v2 s2  opt cds  fpmds
disp(' >>>>> Branch switching at BPm >>>>>>>')
disp('>> xx2=x2(1:2,s2(2).index);p1=p;p1(fpmds.ActiveParams)=x2(3,s2(2).index);  ');
xx2=x2(1:2,s2(2).index);p1=p;p1(fpmds.ActiveParams)=x2(3,s2(2).index); 
disp('>> opt=contset(opt,''backward'',0); ');
opt=contset(opt,'backward',0);
disp('>> opt=contset(opt,''MaxNumPoints'',300); ');
opt=contset(opt,'MaxNumPoints',300);
disp('>> [x2,v2]=init_BPm_FPm(@Rfish,xx2,p1,s2(2),0.0001); ');
[x2,v2]=init_BPm_FPm(@Rfish,xx2,p1,s2(2),0.0001);
disp('>> [x6,v6,s6,h6,f6]=cont(@fixedpointmap,x2,[],opt); ');
[x6,v6,s6,h6,f6]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x6,v6,s6,[3 2]) ');
cpl(x6,v6,s6,[3 2])
