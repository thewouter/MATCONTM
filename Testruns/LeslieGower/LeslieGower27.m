disp('>> global  x221 v221 s221 opt cds fpmds ')
global  x221 v221 s221 opt cds fpmds 
 LeslieGower22;
clc
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> opt=contset(opt,''Maxnumpoints'',250); ');
opt=contset(opt,'Maxnumpoints',250);
opt=contset(opt,'Singularities',1);
disp('>> ap1=11; p1=p; ');
ap1=11; p1=p;
disp('>> p1(ap1)=x221(end,s221(2).index); ');
p1(ap1)=x221(end,s221(2).index);
disp('>> x1=x221(1:4,s221(2).index); ');
 x1=x221(1:4,s221(2).index);
 
 disp('>> [x0,v0]=init_PDm_PDm(@LeslieGower,x1,p1,[11 13],1); ');
 [x0,v0]=init_PDm_PDm(@LeslieGower,x1,p1,[11 13],1);
 opt=contset(opt,'Backward',0);
 %opt=contset(opt,'Increment',0.00001);
 disp('>> [x27,v27,s27,h27,f27]=cont(@perioddoublingmap,x0,v0,opt);');
 [x27,v27,s27,h27,f27]=cont(@perioddoublingmap,x0,v0,opt);
 cpl(x27,v27,s27,[6 5]),
 disp('>> opt=contset(opt,'' Backward'',1)');
  disp('>>  [x1,v1,s1,h1,f1]=cont(@perioddoublingmap,x0,v0,opt);');
  opt=contset(opt,'Backward',1); 
  opt=contset(opt,'Maxnumpoints',270); 
  [x272,v272,s272,h272,f272]=cont(@perioddoublingmap,x0,v0,opt);
      cpl(x272,v272,s272,[6 5 ])
  
 