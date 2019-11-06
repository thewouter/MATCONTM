disp('>>global x15 v15 s15 opt cds fpmds ');
global x15 v15 s15  opt cds fpmds
%LeslieGower15;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>x1=x15(1:4,s15(4).index);p1=p;p1(fpmds.ActiveParams)=x15(5,s15(4).index); ');
x1=x15(1:4,s15(4).index);p1=p;p1(fpmds.ActiveParams)=x15(5,s15(4).index);
disp('>> opt = contset(opt,''MaxNumPoints'',200);');
opt=contset(opt,'MaxNumPoints',200);
disp('>> opt=contset(opt,''Backward'',1);');
opt=contset(opt,'Backward',0);
opt = contset(opt,'Singularities',1);
disp('>>[x2,v2]=init_BPm_FPm(@LeslieGower,x1,p1,s15(4),0.01);');
[x2,v2]=init_BPm_FPm(@LeslieGower,x1,p1,s15(4),0.0000001,1);
disp('>> [x17,v17,s17,h17,f17]=cont(@fixedpointmap,x2,[],opt);');
[x17,v17,s17,h17,f17]=cont(@fixedpointmap,x2,[],opt);
