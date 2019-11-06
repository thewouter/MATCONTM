disp('>> global opt cds fpmds');
global opt cds fpmds
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> ap=11; p=[20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.3;0.23;0.3;.08];');
p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.3;0.23;0.3;.08];ap=11;%11
disp('>> x=[11.17052012;11.94625068;20.99523834;15.21083594]; ');
x=[11.17052012;11.94625068;20.99523834;15.21083594];
disp('>> [x0,vO]=init_FPm_FPm(@LeslieGower,x, p, ap,1);');
[x0,vO]=init_FPm_FPm(@LeslieGower,x, p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',900);');
opt=contset;opt=contset(opt,'MaxNumPoints',900);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> [x221,v221,s221,h221,f221]=cont(@fixedpointmapx0,[],opt);');
[x221,v221,s221,h221,f221]=cont(@fixedpointmap,x0,[],opt,1);
disp('>> opt=contset(opt,''Backward'',1);');
opt=contset(opt,'Backward',1);
disp('>> [x222,v222,s222,h222,f222]=cont(@fixedpointmap,x0,[],opt);');
[x222,v222,s222,h222,f222]=cont(@fixedpointmap,x0,[],opt);

