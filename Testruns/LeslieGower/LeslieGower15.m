disp('>> global opt cds fpmds');
global opt cds fpmds 
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> ap=11; p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0;.08];');
p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0;.08];ap=11;
disp('>> x=[0;0;32.68698060;23.68138391] ');
x=[0;0;32.68698060;23.68138391];
disp('>> [x0,vO]=init_FPm_FPm(@LeslieGower,x, p, ap,1);');
[x0,vO]=init_FPm_FPm(@LeslieGower,x, p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',200);');
opt=contset(opt,'MaxNumPoints',200);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> [x15,v15,s15,h15,f15]=cont(@fixedpointmap,x0,[],opt);');
[x15,v15,s15,h15,f15]=cont(@fixedpointmap,x0,[],opt,1);

