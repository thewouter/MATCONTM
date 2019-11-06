disp('>>global x18 v18 s18  opt cds fpmds');
global x18 v18 s18  opt cds fpmds
LeslieGower18;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt = contset(opt,'Singularities',1);
opt = contset(opt,'Backward',0);
disp('>>x1=x18(1:4,s18(2).index);p1=p;p1(fpmds.ActiveParams)=x18(5,s18(2).index); ');
x1=x18(1:4,s18(2).index);p1=p;p1(fpmds.ActiveParams)=x18(5,s18(2).index);
disp('>> opt = contset(opt,''MaxNumPoints'',12);');
opt=contset(opt,'MaxNumPoints',50);
disp('>> [x2,v2]=init_BPm_FPm(@LeslieGower,x1,p1,s18(2),0.01);');
[x2,v2]=init_BPm_FPm(@LeslieGower,x1,p1,s18(2),0.01,1);
disp('>> [x19,v19,s19,h19,f19]=cont(@fixedpointmap,x2,[],opt);');
[x19,v19,s19,h19,f19]=cont(@fixedpointmap,x2,[],opt,1);
