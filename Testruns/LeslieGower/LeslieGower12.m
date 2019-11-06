disp('>> global  opt cds fpmds  ');
global  opt cds fpmds
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> ap=13; p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.;0.23;0.;.08];');
p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.;0.23;0.;.08];ap=13;
disp('>>opt = contset(opt,''MaxNumPoints'',50);' );
opt = contset(opt,'MaxNumPoints',50);
disp('>>opt = contset(opt,''Singularities'',1);' );
opt = contset(opt,'Singularities',1);
disp('>> [x0,vO]=init_FPm_FPm(@LeslieGower,[21.50285631;22.99611022;0;0], p, ap);');
[x0,vO]=init_FPm_FPm(@LeslieGower,[21.50285631;22.99611022;0;0], p, ap,1);
disp('>> [x12,v12,s12,h12,f12]=cont(@fixedpointmap,x0,[],opt);');
[x12,v12,s12,h12,f12]=cont(@fixedpointmap,x0,[],opt,1);

