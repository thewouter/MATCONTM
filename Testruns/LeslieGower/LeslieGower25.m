disp('>> global opt cds fpmds ')
global opt cds fpmds 
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> ap=11; p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0.474;.08];');
p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0;0.23;0.474;.08];ap=11;
disp('>> x=[21.49714644;22.99000382;0.03249100281;0.02353939999]; ');
x=[21.49714644;22.99000382;0.03249100281;0.02353939999];
disp('>> [x0,vO]=init_FPm_FPm(@LeslieGower,x, p, ap,1);');
[x0,vO]=init_FPm_FPm(@LeslieGower,x, p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',1200);');
opt=contset(opt,'MaxNumPoints',1200);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> opt=contset(opt,''Backward'',1);');
opt=contset(opt,'Backward',1);
disp('>> [x25,v25,s25,h25,f25]=cont(@fixedpointmap,x0,[],opt);');
[x25,v25,s25,h25,f25]=cont(@fixedpointmap,x0,[],opt);
