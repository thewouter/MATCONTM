disp('>>global x15 v15 s15  opt cds fpmds');
global x15 v15 s15  opt cds fpmds
%@LeslieGower15;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>x1=x15(1:4,s15(3).index);p1=p;p1(fpmds.ActiveParams)=x15(5,s15(3).index); ');
x1=x15(1:4,s15(3).index);p1=p;p1(fpmds.ActiveParams)=x15(5,s15(3).index);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> [x16,v16]=init_PDm_FP2m(@LeslieGower,x1,p1,s15(3),0.01,2);');
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s15(3),0.000001,1);
disp('>> [x16,v16,s16,h16,f16]=cont(@fixedpointnmap,x2,[],opt);');
[x16,v16,s16,h16,f16]=cont(@fixedpointmap,x2,[],opt);
