disp('global x231 v231 s231 opt cds fpmds lpmds')
global x231 v231 s231  opt cds fpmds lpmds
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.3;0.23;0.3;.08];ap=13;
[x0,vO]=init_FPm_FPm(@LeslieGower,[11.17052012;11.94625068;20.99523834;15.21083594], p, ap,1);
opt=contset;opt=contset(opt,'MaxNumPoints',900);
opt=contset(opt,'Singularities',1);
[x231,v231,s231,h231,f231]=cont(@fixedpointmap,x0,[],opt,1);
opt=contset(opt,'Backward',1);
[x232,v232,s232,h232,f232]=cont(@fixedpointmap,x0,[],opt,1);

x1=x231(1:4,s231(2).index);p1=p;p1(fpmds.ActiveParams)=x231(5,s231(2).index);
opt=contset(opt,'MaxNumPoints',1300);
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s231(2),0.01,1);
[x24,v24,s24,h24,f24]=cont(@fixedpointmap,x2,[],opt);
clc
disp('>>>>>>>>>>> fold curve <<<<<<<<<< ');
disp('>>opt=contset(opt,''Backward'',0);');
opt=contset(opt,'Backward',0);
disp('>> x1=x24(1:4,s24(3).index);p1=p; ');
x1=x24(1:4,s24(3).index);p1=p;
disp('>> p1(fpmds.ActiveParams)=x24(5,s24(3).index); ');
p1(fpmds.ActiveParams)=x24(5,s24(3).index);
disp('>> opt=contset(opt,''MaxNumPoints'',150); ');
opt=contset(opt,'MaxNumPoints',200);
disp('>> [x2,v2]=init_LPm_LPm(@LeslieGower,x1,p1,[11 13],2);');
[x2,v2]=init_LPm_LPm(@LeslieGower,x1,p1,[11 13],2);
disp('>>[x3,v3,s3,h3,f3]=cont(@limitpointmap,x2,[],opt);');
[x3,v3,s3,h3,f3]=cont(@limitpointmap,x2,[],opt);
disp('>> cpl(x3,v3,s3,[6 5]),  ');
cpl(x3,v3,s3,[6 5]),  
disp('>>opt=contset(opt,''Backward'',1); ');
opt=contset(opt,'Backward',1);
disp('>> [x3,v3,s3,h3,f3]=cont(@limitpointmap,x2,[],opt); ');
[x3,v3,s3,h3,f3]=cont(@limitpointmap,x2,[],opt);
disp('>> cpl(x3,v3,s3,[6 5]);');
cpl(x3,v3,s3,[6 5]);
