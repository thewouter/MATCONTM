disp('>> global x20 v20 s20 opt cds fpmds');
global x20 v20 s20 opt cds fpmds
%LeslieGower20;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt = contset(opt,'Singularities',1);
disp('>>x1=x20(1:4,s20(2).index);p1=p;p1(fpmds.ActiveParams)=x20(5,s20(2).index); ');
x1=x20(1:4,s20(2).index);p1=p;p1(fpmds.ActiveParams)=x20(5,s20(2).index);
disp('>> opt = contset(opt,''MaxNumPoints'',25);');
opt=contset(opt,'MaxNumPoints',50);

disp('>> opt = contset(opt,''backward'',1);');
opt=contset(opt,'backward',1);
disp('>> [x2,v2]=init_BPm_FPm(@LeslieGower,x1,p1,s20(2),0.01);');
[x2,v2]=init_BPm_FPm(@LeslieGower,x1,p1,s20(2),0.01,1);
disp('>> [x21,v21,s21,h21,f21]=cont(@@fixedpointmap,x2,[],opt);');
[x21,v21,s21,h21,f21]=cont(@fixedpointmap,x2,[],opt,1);

