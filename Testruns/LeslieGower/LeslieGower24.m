disp('>> global x221 v221 s221  opt cds fpmds cds')
global x221 v221 s221  opt cds fpmds cds
LeslieGower22;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> x1=x221(1:4,s221(2).index);p1=p; ');
x1=x221(1:4,s221(2).index);p1=p;
disp('>> p1(fpmds.ActiveParams)=x221(5,s221(2).index);');
p1(fpmds.ActiveParams)=x221(5,s221(2).index);
opt=contset(opt,'MaxNumPoints',1300);
opt=contset(opt,'Backward',1);
opt=contset(opt,'Singularities',1);
disp('>> [x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s221(2),0.01,1); ');
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s221(2),0.01,1);
disp('>> [x24,v24,s24,h24,f24]=cont(@fixedpointmap,x2,[],opt); ');
[x24,v24,s24,h24,f24]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x24,v24,s24,[1 5]) ');
cpl(x24,v24,s24,[1 5])
