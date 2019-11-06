% TEST CIV
function X4 = testciv(mapfile, firstX, firstP) % The input we want to have here but isnt being used, are the hard coded x1 and p1 for each map, as we cannot find these automatically

%% Preparing initial data from fixed point continuation and Neimark-Sacker
init;
% global opt cds fpmds;
opt = contset; % prepare the options section
opt = contset(opt, 'Singularities', 1);
opt = contset(opt, 'Multipliers', 1);
opt = contset(opt, 'MaxNumPoints', 100);
x1 = [1;1;0.38]; %Test values for the Delayed Logistic Map and Adaptive Control Map are [0.444444;0.444444] [1;1;0.38]
p1 = [-0.54;1.14;0.1]; %Test values for DLM and ACM[1.8; 0.1] [-0.54;1.14;0.1]
[X10, V10] = init_FPm_FPm(mapfile, x1, p1,1,1);
[X1, V1, s1, h1, f1] = cont(@fixedpointmap, X10, V10, opt);

opt = contset(opt, 'MaxNumPoints', 50); % Amount of curves to be generated
opt = contset(opt, 'IgnoreSingularity', [2 3 5]);
x3 = X1(1:end-1, s1(2).index); % Get fixed point without parameter and add parameter
p3 = p1; p3(1) = X1(end, s1(2).index); % Set parameters
[X30, V30] = init_NSm_NSm(mapfile, x3, p3, [1 2],15);
[X3, V3, s3, h3, f3] = cont(@neimarksackermap, X30, V30, opt);
addpath('ClosedInvariantCurve')

%% Extracting the NS-point
id=s1(2).index;x4=X1(1:end-1,id);p4=p1;p4(1)=X1(end,id);
N=15; %Number of Fourier modes used, only initializing the first
amp=0.02; %Initial amplitude
[X40,V40]=init_NSm_ICm(mapfile,x4,p4,N,amp,[1,2],1);
[X4,V4,s4,h4,f4]=cont(@closedinvariantcurve,X40,V40);