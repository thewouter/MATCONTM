disp('global x32 v32 s32   opt cds fpmds lpmds')global x32 v32 v32    opt cds fpmds lpmdsdisp('>> opt = contset; ');opt = contset;disp('>> opt = contset(opt,''Multipliers'',1); ');opt = contset(opt,'Multipliers',1);disp('>> global opt fpmds cds ')global opt fpmds cdsLeslieGower12;disp('>> opt = contset; ');opt = contset;disp('>> opt = contset(opt,''Multipliers'',1); ');opt = contset(opt,'Multipliers',1);opt=contset(opt,'MaxNumPoints',150);p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.2201;0.23;0.450625;.08];ap=13;disp('>> global  x12 v12 s12 opt fpmds cds fpmds ') global  x12 v12 s12 opt fpmds cds fpmdsdisp('>>>>>> flip curve <<<<<<<<<<<<<')disp('>> x1=x12(1:4,s12(4).index);p1=p;')x1=x12(1:4,s12(4).index);p1=p;disp('>> p1(fpmds.ActiveParams)=x12(5,s12(4).index);')p1(fpmds.ActiveParams)=x12(5,s12(4).index);disp('>> opt=contset(opt,''MaxNumPoints'',1000);')opt=contset(opt,'MaxNumPoints',1000);disp('>> opt=contset(opt,''Backward'',1);')opt=contset(opt,'Backward',1);opt=contset(opt,'Singularities',1);disp('>> [x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s12(4),0.01,1);')[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s12(4),0.01,1);disp('>> [x32,v32,s32,h32,f32]=cont(@fixedpointmap,x2,[],opt);')[x32,v32,s32,h32,f32]=cont(@fixedpointmap,x2,[],opt);clcdisp('>>>>>>> fold curve <<<<<<<');disp('>> global x32 v32 s32 opt cds fpmds lpmds')global x32 v32 s32 opt cds fpmds lpmdsdisp('>> p1=p;p1(fpmds.ActiveParams)=x32(end,s32(3).index);x1=x32(1:4,s32(3).index);');opt = contset;opt=contset(opt,'Singularities',1);p1=p;p1(fpmds.ActiveParams)=x32(end,s32(3).index);x1=x32(1:4,s32(3).index);disp('>> opt=contset(opt,''Maxnumpoints'',500);');opt=contset(opt,'Maxnumpoints',500);disp('>> [x0,v0]=init_LPm_LPm(@LeslieGower,x1,p1,[11 13],2);');[x0,v0]=init_LPm_LPm(@LeslieGower,x1,p1,[11 13],2);disp('>> opt=contset(opt,''Backward'',1);');opt=contset(opt,'Backward',1);disp('>> [x33,v33,s33,h33,f33]=cont(@limitpointmap,x0,v0,opt);');[x33,v33,s33,h33,f33]=cont(@limitpointmap,x0,v0,opt);disp('>> cpl(x33,v33,s33,[6 5]);');cpl(x33,v33,s33,[6 5]);disp('>> opt=contset(opt,''Backward'',0);');opt=contset(opt,'Backward',0);disp('>> opt=contset(opt,''Maxnumpoints'',300); ');opt=contset(opt,'Maxnumpoints',300); disp('>>[x332,v332,s332,h332,f332]=cont(@limitpointmap,x0,v0,opt);');[x332,v332,s332,h332,f332]=cont(@limitpointmap,x0,v0,opt);disp('>> cpl(x332,v332,s332,[6 5]);');cpl(x332,v332,s332,[6 5]);  
