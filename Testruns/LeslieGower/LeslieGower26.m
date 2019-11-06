disp('>> global x25 v25 s25 h25 f25 opt cds fpmds')
global x25 v25 s25 h25 f25 opt cds fpmds
%LeslieGower25;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> x1=x25(1:4,s25(2).index);p1=p;p1(fpmds.ActiveParams)=x25(5,s25(2).index); ');
x1=x25(1:4,s25(2).index);p1=p;
disp('>> p1(fpmds.ActiveParams)=x25(5,s25(2).index); ');
p1(fpmds.ActiveParams)=x25(5,s25(2).index);
disp('>> opt = contset(opt,''MaxNumPoints'',1700);');
opt=contset(opt,'MaxNumPoints',1700);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> opt=contset(opt,''Backward'',1);');
opt=contset(opt,'Backward',1);
disp('>> [x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s25(2),0.01,2);');
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s25(2),0.01,1);
disp('>> [x26,v26,s26,h26,f26]=cont(@fixedoointofmap,x2,[],opt);');
[x26,v26,s26,h26,f26]=cont(@fixedpointmap,x2,[],opt);
