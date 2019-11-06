disp('>> global  x15 v15 s15 opt  fpmds cds')
global  x15 v15 s15 opt  fpmds cds
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> ap=11; p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0;.08];');
p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0;.08];ap=11;
disp('>> [x0,vO]=init_FPm_FPm(@@LeslieGower,[0;0;32.68698060;23.68138391], p, ap,1);');
[x0,vO]=init_FPm_FPm(@LeslieGower,[0;0;32.68698060;23.68138391], p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',200);');
opt=contset(opt,'MaxNumPoints',200);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> [x15,v15,s15,h15,f15]=cont(@fixedpointmap,x0,[],opt);');
[x15,v15,s15,h15,f15]=cont(@fixedpointmap,x0,[],opt,1);

p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.0170849;0.23;0.0;.08];ap=11;
clc


disp('>>>>> fixed points curve of the second iterate<<<<')
disp('>> global x15 v15 s15 opt cds fpmds')
global x15 v15 s15 opt cds fpmds
disp('>> x1=x15(1:4,s15(3).index);p1=p;')
x1=x15(1:4,s15(3).index);p1=p;
disp('>> p1(fpmds.ActiveParams)=x15(5,s15(3).index);')
p1(fpmds.ActiveParams)=x15(5,s15(3).index);
disp('>> opt=contset(opt,''MaxNumPoints'',300);')
opt=contset(opt,'MaxNumPoints',300);
opt=contset(opt,'Backward',1);
opt=contset(opt,'Singularities',1);
disp('>> [x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s15(3),0.01,1);')
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s15(3),0.01,1);
disp('>>[x35,v35,s35,h35,f35]=cont(@fixedpointmap,x2,[],opt);')
[x35,v35,s35,h35,f35]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x35,v35,s35,[1 5])')
cpl(x35,v35,s35,[1 5])
