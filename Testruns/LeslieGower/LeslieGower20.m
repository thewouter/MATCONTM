disp('>> global opt cds fpmds');
global opt cds fpmds 
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> ap=13; p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0;.08];');
p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0;.08];ap=13;
disp('>> x=[16.42912;17.570032;28.871217;20.916902]; ');
x=[16.42912;17.570032;28.871217;20.916902];
disp('>> [x0,vO]=init_FPm_FPm(@LeslieGowere,x, p, ap,1);');
[x0,vO]=init_FPm_FPm(@LeslieGower,[16.42912;17.570032;28.871217;20.916902], p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',400);');
opt=contset;opt=contset(opt,'MaxNumPoints',400);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> [x20,v20,s20,h20,f20]=cont(@fixedpointmap,x0,[],opt);');
[x20,v20,s20,h20,f20]=cont(@fixedpointmap,x0,[],opt,1);
