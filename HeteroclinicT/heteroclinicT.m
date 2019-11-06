function out = heteroclinicT
%
% heteroclinic tangency curve definition file for a problem in mapfile
% 
    out{1}  = @curve_func;
    out{2}  = @defaultprocessor;
    out{3}  = @options;
    out{4}  = [];%@jacobian;
    out{5}  = [];%@hessians;
    out{6}  = [];%@testf;
    out{7}  = [];%@userf;
    out{8}  = [];%@process;
    out{9}  = [];%@singmat;
    out{10} = [];%@locate;
    out{11} = @init;
    out{12} = @done;
    out{13} = @adapt;
return

%----------------------------------------------------
function func = curve_func(arg)
global hetTds

  [x,YS,YU,p] = rearr(arg);
  n =hetTds.nphase;
  N =hetTds.npoints;
  nu=hetTds.nu;
  ns=hetTds.ns;
  b =hetTds.b;
  c =hetTds.c;
  K1=n*(N-1)+(n-nu)*nu+(n-ns)*ns+2*n-nu-ns;
  jac=BVP_HetT_jac(x,YS,YU,p);
  Bord=[jac b;c' 0];
  bunit=[zeros(K1,1);1];
  v=Bord\bunit;
%   g=Bord'\bunit;
  f = BVP_HetT(x,YS,YU,p);
  func = [f ; v(end)];   
  
%-----------------------------------------------------
function varargout = jacobian(varargin)

%-----------------------------------------------------
function varargout = hessians(varargin)

%------------------------------------------------------
function varargout = defaultprocessor(varargin)
global hetTds 
% set data in special point structure
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
%all done succesfully
  varargout{1} = 0;
  varargout{2} = hetTds.npoints';

%-------------------------------------------------------
  
function option = options
global hetTds cds
% Check for symbolic derivatives in mapfile

  symjac  = ~isempty(hetTds.Jacobian);
  symhes  = ~isempty(hetTds.Hessians);
  symder  = ~isempty(hetTds.Der3);

  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symder, symord = 3; end
  
  option = contset;
  option = contset(option, 'SymDerivative', symord);
%   option = contset(option, 'Workspace', 1);
%   option = contset(option, 'Locators', zeros(1,13));
  symjacp = ~isempty(hetTds.JacobianP); 
  symhes  = ~isempty(hetTds.HessiansP);
  symordp = 0;
  if symjacp, symordp = 1; end
  if symhes,  symordp = 2; end
  option = contset(option, 'SymDerivativeP', symordp);
  
%  cds.symjac  = 0;
%  cds.symhess = 1;
  
%------------------------------------------------------  
  
function [out, failed] = testf(id, x0, v)
% global hetTds cds        
% 
% [x,YS,YU,p] = rearr(x0);
% p = n2c(p);
% ndim = cds.ndim;
% J=contjac(x0);%eig((J(:,1:ndim-1))+eye(ndim-1)),
% failed = [];
% for i=id
%   lastwarn('');
%   
%   switch i
%      
%   case 1 % LP
%     out(1) = v(end);
%   case 2 % BP
%     B = [J; v'];
%     out(2) = det(B);
%   otherwise
%     error('No such testfunction');
%   end
%   if ~isempty(lastwarn)
%     msg = sprintf('Could not evaluate tf %d\n', i);
%     failed = [failed i];
%   end
% end
out=[];failed=[];  

%-------------------------------------------------------------

function [out, failed] = userf(userinf, id, x, v)
global  hetTds cds
dim =size(id,2);
failed = [];
[x0,YU,YS,p] = rearr(x); p = num2cell(p);
for i=1:dim
  lastwarn('');
  if (userinf(i).state==1)
      out(i)=feval(hetTds.user{id(i)},0,x0,p{:});
  else
      out(i)=0;
  end
  if ~isempty(lastwarn)
    msg = sprintf('Could not evaluate userfunction %s\n', id(i).name);
    failed = [failed i];
  end
end

%-----------------------------------------------------------------

function [failed,s] = process(id, x, v, s)
global  cds hetTds
[x0,YS,YU,p] = rearr(x);
p = n2c(p);
ndim = cds.ndim; 
nphase=hetTds.nphase;
n=hetTds.niteration;
 % WM: Removed SL array
printconsole('label = %s, x = %s \n', s.label , vector2string(x)); 
p1=p;
 switch id     
  case 1 % LP      
     jac =hetjac(x,p,n);
     [V,D]= eig(jac-eye(nphase));
     [Y,i]=min(abs(diag(D)));
     vext=real(V(:,i));
     vext=vext/norm(vext);
     [V,D]= eig(jac'-eye(nphase));
     [Y,i]=min(abs(diag(D)));
     wext=real(V(:,i));      
     wext=wext/(vext'*wext);
     s.msg=sprintf('Limit point\n');
       
  case 2 %BP
      s.msg=sprintf('Branch point\n');  
      s.data.v=v;
end

% Compute eigenvalues for every singularity
J=contjac(x);
if ~issparse(J)
  [v,d]=eig(J(:,1:ndim-1));
else
  opt.disp=0;
  % WM: fixed a bug (incompatability between MatLab 6.0 and 5.5?)
  [v,d]=eigs(J(:,1:ndim-1),min(6,ndim-1),'lm',opt);
end
%d=d+eye(nphase);
s.data.evec = v;
%s.data.eval = diag(d)';

failed = 0;

%-------------------------------------------------------------  

function [S,L] = singmat
global hetTds cds
 
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [  0 8 
         8 1 ] ;

  L = [  'LP  ';'BP  ' ];


  %elseif strcmp(arg, 'locate')

%--------------------------------------------------------

function [x,v] = locate(id, x1, v1, x2, v2)
msg = sprintf('No locator defined for singularity %d', id);
error(msg);
    
%----------------------------------------------------------

function varargout = init(varargin)

WorkspaceInit(varargin{1:2});
% all done succesfully
varargout{1} = 0;

%-----------------------------------------------------------

function varargout = done

%-----------------------------------------------------------

function [res,x,v] = adapt(x,v)
global hetTds cds

res = []; % no re-evaluations needed
cds.adapted = 1;
[x1,YS,YU,p] = rearr(x);
J=hetTds.Niterations;

% update unstable part;
A1= hetT_jac(x1(1:hetTds.nphase),p,J);
[Q0, eigvlU, dimU] = Het_computeBase(A1,1,hetTds.nu);
hetTds.Q0=Q0;
hetTds.YU=zeros(hetTds.nphase-hetTds.nu,hetTds.nu);

%update stable part
AN = hetT_jac(x1(end-hetTds.nphase+1:end),p,J);
[Q1, eigvlS, dimS] = Het_computeBase(AN,0,hetTds.ns);
hetTds.Q1=Q1;
hetTds.YS=zeros(hetTds.nphase-hetTds.ns,hetTds.ns);

%recompose continuation variable
x=[x1;reshape(hetTds.YU,(hetTds.nphase-hetTds.nu)*hetTds.nu,1);...
  reshape(hetTds.YS,(hetTds.nphase-hetTds.ns)*hetTds.ns,1);p(hetTds.ActiveParams)];
%p(hetTds.ActiveParams)  (Debug ? NN)
%update boundary vectors
jac =BVP_HetT_jac(x1,hetTds.YS,hetTds.YU,p);
[U,S,V]=svd(full(jac));
hetTds.b=U(:,end);
hetTds.c=V(:,end);

res = 1;

%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
function [x,YS,YU,p] = rearr(x1)
% Rearranges x1 into all of its components
global hetTds

x = x1(1:hetTds.nphase*hetTds.npoints,1);
p = hetTds.P0;
ap=hetTds.ActiveParams;
% eps0 = hetTds.eps0;
% eps1 = hetTds.eps1;
idx=hetTds.npoints*hetTds.nphase;%+hetTds.nu.hetTds.ns;
ju=hetTds.nphase-hetTds.nu;
js=hetTds.nphase-hetTds.ns;
YU = reshape(x1(idx+1:idx+ju*hetTds.nu,1),hetTds.nphase-hetTds.nu,hetTds.nu);
idx = idx + ju*hetTds.nu;
YS = reshape(x1(idx+1:idx+js*hetTds.ns,1),hetTds.nphase-hetTds.ns,hetTds.ns);
idx = idx + js*hetTds.ns;
p(hetTds.ActiveParams) = x1(end-1:end,1);

% ---------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
function WorkspaceInit(x,v)

% ------------------------------------------------------
function [x,v,s] = WorkspaceDone(x,v,s)

%------------------------------------------------------------
