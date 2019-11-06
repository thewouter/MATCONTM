disp('>> global x6 v6 s6  opt cds  fpmds')
global x6 v6 s6  opt cds  fpmds
disp('>> opt = contset; ');
opt = contset;
opt=contset(opt,'Singularities',1);
disp(' >>>>>  switching at PDm >>>>>>>')
disp('>> xx2=x6(1:2,s6(3).index);p1=p;p1(fpmds.ActiveParams)=x6(3,s6(3).index);');
xx2=x6(1:2,s6(3).index);p1=p;p1(fpmds.ActiveParams)=x6(3,s6(3).index); 
disp('>> opt=contset(opt,''backward'',0);');
opt=contset(opt,'backward',1);
disp('>>opt=contset(opt,''MaxNumPoints'',300);');
opt=contset(opt,'MaxNumPoints',300);
disp('>>[x2,v2]=init_PDm_FP2m(@Tnfmap,xx2,p1,s6(3),0.01,1);');
[x2,v2]=init_PDm_FP2m(@Tnfmap,xx2,p1,s6(3),0.01,1);
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>[x7,v7,s7,h7,f7]=cont(@fixedpointmap,x2,[],opt);');
[x7,v7,s7,h7,f7]=cont(@fixedpointmap,x2,[],opt);
