disp('>> global  opt fpmds nsmds cds ');
global  opt fpmds nsmds cds
%  NS curve starting from the NS point of CodStock1 
disp('>>>>>>>  Fixed points  >>>>')
CodStock1;
clf
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>>>>>>  NS curve  starting from the NS point >>>>')
disp('>> xx2=x1(1:2,s1(2).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(2).index); ');
xx2=x1(1:2,s1(2).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(2).index);
opt=contset(opt,'MaxNumPoints',2750);
opt=contset(opt,'Singularities',1);
disp('>>>>>>>  NS curve  starting from the NS point >>>>')
opt = contset(opt,'Backward',0);
disp('[x2,v2]=init_NSm_NSm(@Rfish,xx2,p1,[1 4],1);')
[x2,v2]=init_NSm_NSm(@Rfish,xx2,p1,[1 4],1);
%opt=contset(opt,'IgnoreSingularity',[2 3]); 
disp('opt=contset(opt,''IgnoreSingularity'',[5]); ')
opt=contset(opt,'IgnoreSingularity',[5]); 
disp('[x31,v31,s31,h31,f31]=cont(@neimarksackermap,x2,[],opt);')
[x31,v31,s31,h31,f31]=cont(@neimarksackermap,x2,[],opt);
cpl(x31,v31,s31,[ 4 3 ]);
opt=contset(opt,'MaxNumPoints',150);
disp('opt = contset(opt,''Backward'',1);')
opt = contset(opt,'Backward',1);
disp('[x32,v32,s32,h32,f32]=cont(@neimarksackermap,x2,[],opt);')
[x32,v32,s32,h32,f32]=cont(@neimarksackermap,x2,[],opt);
cpl(x32,v32,s32,[ 4 3 ]);


