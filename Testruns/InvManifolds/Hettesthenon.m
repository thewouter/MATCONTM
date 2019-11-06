
x1=[ -0.37015621187164; -0.37015621187164];     x2=[ -0.36934530274798;-0.36902977002974];
x3=[-0.36903032797345; -0.36859334096840];     x4=[-0.36859357559333;-0.36798817685143];

x5=[-0.36798823069020; -0.36714947747132];    x6=[-0.36714949119189; -0.36598813651460];  
x7=[-0.36598816658009;-0.36438183638761];     x8=[-0.36438193487681; -0.36216340120670];

x9=[-0.36216365899071; -0.35910588343094];     x10=[-0.35910626499733; -0.35490405069587];
x11=[-0.35490451477016; -0.34915218410470];    x12=[-0.34915282219716; -0.34132084093812];

x13=[-0.34132207405517;  -0.33073653972654];    x14=[-0.33073976154823; -0.31657409955130];
x15=[-0.31658309015565; -0.29787805781874];    x16=[-0.29790012147281; -0.27363903013528];

x17=[-0.27367393702409; -0.24296065679654];    x18=[-0.24300941458245; -0.20529626278605];
x19=[-0.20536836799494; -0.16079300996976];    x20=[-0.16090314649545;-0.11058619242074];

x21=[-0.11074967492063; -0.05688530736976];    x22=[-0.05710747166444; -0.00268422943487];
x23=[-0.00295044499954;  0.04888386987825];    x24= [0.04860662725179;  0.09527120162815];

x25=[0.09501933526464;  0.13497013438347];     x26=[0.13476722017080; 0.16755200653139];   
x27=[0.16740360798080;  0.19340627825801];     x28=[0.19330528659748; 0.21338914218245];  

x29=[0.21332557403837;  0.22852486467001];      x30=[0.22848836650622;0.23981877070794];
x31=[0.23979904077700;  0.24815339556679];      x32=[0.24814279623444; 0.25425357367432];

x33=[0.25424785472566; 0.25869152027123];      x34=[0.25868839729521; 0.26190608596846];
x35=[0.26190438155763; 0.26422712522343];      x36=[0.26422623623101;0.26589920545177];

x37=[0.26589876278663; 0.26710184119087];      x38=[0.26710161639910; 0.26796580604232];
x39=[0.26796568908619; 0.26858594455621];     x40=[0.26858588205587; 0.26903079771309];

x41=[0.26903076452854; 0.26934977002572];     x42=[0.26934975350358; 0.26957841251668];
x43=[0.26957840316328; 0.26974227071044];     x44=[0.26974225646090; 0.26985969012349];

x45=[0.26985965879940; 0.26994382217257];     x46=[0.26994377058581; 0.27000409777723];
x47=[0.27000402755227;0.27004727870638];     x48=[0.27015621187164; 0.27015621187164];


C(:,1)=x1;C(:,2)=x2;C(:,3)=x3;C(:,4)=x4;C(:,5)=x5;C(:,6)=x6;C(:,7)=x7;C(:,8)=x8;
C(:,9)=x9;C(:,10)=x10;C(:,11)=x11;C(:,12)=x12;C(:,13)=x13;C(:,14)=x14;C(:,15)=x15;C(:,16)=x16;
C(:,17)=x17;C(:,18)=x18;C(:,19)=x19;C(:,20)=x20;C(:,21)=x21;C(:,22)=x22;C(:,23)=x23;C(:,24)=x24;
C(:,25)=x25;C(:,26)=x26;C(:,27)=x27;C(:,28)=x28;C(:,29)=x29;C(:,30)=x30;C(:,31)=x31;C(:,32)=x32;
C(:,33)=x33;C(:,34)=x34;C(:,35)=x35;C(:,36)=x36;C(:,37)=x37;C(:,38)=x38;C(:,39)=x39;C(:,40)=x40;
C(:,41)=x41;C(:,42)=x42;C(:,43)=x43;C(:,44)=x44;C(:,45)=x45;C(:,46)=x46;C(:,47)=x47;C(:,48)=x48;

ap=[1];
 
opt = contset;p=[0.1;-0.9;0;0];

opt=contset(opt,'MaxNumpoints',50);
opt=contset(opt,'Singularities',1);
opt=contset(opt,'Backward',0);
opt = contset(opt,'AutDerivative',1);
[x0,v0]=init_Het_Het(@Ghmap,C, p, ap,1);
[xhet,vhet,shet,hhet,fhet]=cont(@heteroclinic,x0,[],opt);

for i=1:48
    cpl(xhet,vhet,shet,[99 2*(i-1)+1])    
end

 