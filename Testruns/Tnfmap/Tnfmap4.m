disp('>> global x3 v3 s3 opt cds  fpmds');
global x3 v3 s3 opt cds fpmds
disp('>> opt = contset; ');
opt = contset;
opt=contset(opt,'Singularities',1);
disp('>> xx2=x3(1:2,s3(3).index);p1=p;p1(fpmds.ActiveParams)=x3(3,s3(3).index);');
xx2=x3(1:2,s3(3).index);p1=p;p1(fpmds.ActiveParams)=x3(3,s3(3).index); 
disp('>> opt=contset(opt,''backward'',0);');
opt=contset(opt,'backward',0);
disp('>>opt=contset(opt,''MaxNumPoints'',300);');
opt=contset(opt,'MaxNumPoints',300);
disp('>>[x2,v2]=init_BPm_FPm(@Tnfmap,xx2,p1,s3(3),0.001);');
[x2,v2]=init_BPm_FPm(@Tnfmap,xx2,p1,s3(3),0.001);
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>[x41,v41,s41,h41,f41]=cont(@fixedpointmap,xx2,[],opt);');
[x41,v41,s41,h41,f41]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x41,v41,s41,[3 1 2]);');
cpl(x41,v41,s41,[3 1 2])
disp('>>opt=contset(opt,''backward'',1);;');
opt=contset(opt,'backward',1);
disp('>> [x42,v42,s42,h42,f42]=cont(@fixedpointmap,x2,[],opt);');
 [x42,v42,s42,h42,f42]=cont(@fixedpointmap,x2,[],opt);
disp('>> cpl(x42,v42,s422,[3 1 2])');
cpl(x42,v42,s42,[3 1 2])
