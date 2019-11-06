
% Computing Two half lines of LP4 emanate from the R4 point

disp('>>> curve of fixed point <<< ')
p=[55;0.5;0.5;0.5;3;2;1];ap=1;
opt = contset;
opt = contset(opt,'Backward',1);
opt = contset(opt,'MaxNumPoints',50);
opt = contset(opt,'Singularities',1);
[x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1);
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);
%cpl(x1,v1,s1,[3 1])

disp('>>>> NS curve  starting in NSm >>>>>>')
global  opt fpmds nsmds
xx2=x1(1:2,s1(2).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(2).index);
opt=contset(opt,'MaxNumPoints',200);
opt=contset(opt,'Singularities',1);
opt = contset(opt,'Backward',0);
[x2,v2]=init_NSm_NSm(@NAFstock,xx2,p1,[1 7],1);
opt=contset(opt,'IgnoreSingularity',[5]); 
[x31,v31,s31,h31,f31]=cont(@neimarksackermap,x2,[],opt);
cpl(x31,v31,s31,[ 4 3 ]);
global pdmds fpmds x31 v31 s31 f31   x3 v3 s3 h3 f3  opt cds
opt=contset(opt,'MaxNumPoints',90);
ap=[1 7];yy1=x31(1:2,s31(2).index);pp1=p;pp1(ap)=x31(3:4,s31(2).index);%R4  
opt=contset(opt,'MaxNumPoints',100);

disp('>>>>>>>>>>>>>>>>switching at R4 to LP41 <<<<<<<<<<<<<<<<<<');
opt=contset(opt,'MaxNumPoints',250);
[xxx,yy2]=init_R4_LP4m1(@NAFstock,1e-5,yy1,pp1,ap,1);
opt=contset(opt,'Backward',1);            
[x7,v7,s7,h7,f7]=cont(@limitpointmap,xxx,[],opt);
cpl(x7,v7,s7,[4 3]);
opt=contset(opt,'MaxNumPoints',250);
disp('>>>>>>>>>>>>>>>>switching at R4 to the second LP41 <<<<<<<<<<<<<<<<<<');
[xx,y2]=init_R4_LP4m2(@NAFstock,1e-10,yy1,pp1,ap,1);
opt=contset(opt,'Backward',0);
[x7,v7,s7,h7,f7]=cont(@limitpointmap,xx,[],opt);
cpl(x7,v7,s7,[4 3])

