disp('>> global x12 v12 s12  opt cds fpmds ');
global x12 v12 s12 opt cds fpmds
@LeslieGower12;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>x1=x12(1:4,s12(4).index);p1=p;p1(fpmds.ActiveParams)=x12(5,s12(4).index); ');
x1=x12(1:4,s12(4).index);p1=p;p1(fpmds.ActiveParams)=x12(5,s12(4).index);
disp('>> opt = contset(opt,''MaxNumPoints'',100);');
opt=contset(opt,'MaxNumPoints',100);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> [x5,v5]=init_PDm_FP2m(@LeslieGower,x1,p1,s12(4),0.01);');
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s12(4),0.01,1);
disp('>> opt=contset(opt,''Backward'',1);');
opt=contset(opt,'Backward',1);
disp('>> [x14,v14,s14,h14,f14]=cont(@@fixedpointnmap,x2,[],opt);');
[x14,v14,s14,h14,f14]=cont(@fixedpointmap,x2,[],opt,2);



