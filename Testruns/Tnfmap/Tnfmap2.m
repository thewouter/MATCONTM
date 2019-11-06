disp('>> global x1 v1 s1  opt cds  fpmds')
global x1 v1 s1  opt cds  fpmds
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt=contset(opt,'Singularities',1);
disp(' >>>>> Branch switching at BPm >>>>>>>')
disp('>> xx2=x1(1:2,s1(3).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(3).index);');
xx2=x1(1:2,s1(3).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(3).index); 
disp('>> opt=contset(opt,''backward'',0);');
opt=contset(opt,'backward',0);
disp('>>opt=contset(opt,''MaxNumPoints'',50);');
opt=contset(opt,'MaxNumPoints',50);
disp('>>[x2,v2]=init_BPm_FPm(@Tnfmap,xx2,p1,s1(5),0.01);');
[x2,v2]=init_BPm_FPm(@Tnfmap,xx2,p1,s1(5),0.01);
disp('>>[x21,v21,s21,h21,f21]=cont(@fixedpointmap,xx2,[],opt);');
[x21,v21,s21,h21,f21]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x21,v21,s21,[3 1]);');
cpl(x21,v21,s21,[3 1])
disp('>>opt=contset(opt,''backward'',1);;');
opt=contset(opt,'backward',1);
disp('>> [x22,v22,s22,h22,f22]=cont(@fixedpointmap,x2,[],opt);');
[x22,v22,s22,h22,f22]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x22,v22,s22,[3 1])');
cpl(x22,v22,s22,[3  1])
