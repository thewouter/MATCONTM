function out = homoclinicT
%
% homoclinic tangency curve definition file for a problem in mapfile
% 

global homds cds
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
  global homTds
  [x,YS,YU,p] = rearr(arg);
  p=n2c(p);
  n1=homTds.nphase;
  n2=homTds.npoints;
  nu=homTds.nu;
  ns=homTds.ns;
  b=homTds.b;
  c=homTds.c;
  K1=n1*(n2-1)+nu*(n1-nu)+ns*(n1-ns)+2*n1-nu-ns;
  jac=BVP_HomT_jac(x,YS,YU,p);
  Bord=[jac b;c' 0];
  bunit=[zeros(K1,1);1];
  v=Bord\bunit;
%   g=Bord'\bunit;
  f = BVP_HomT(x,YS,YU,p);
  func = [f ; v(end)];   
  
%-----------------------------------------------------
function jac = jacobian(varargin)

%-----------------------------------------------------
function varargout = hessians(varargin)

%------------------------------------------------------
function varargout = defaultprocessor(varargin)
global homTds
% set data in special point structure
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
% all done succesfully
   varargout{1} = 0;
   varargout{2} = homTds.npoints';

%-------------------------------------------------------
function option = options
global homTds cds
%Check for symbolic derivatives in mapfile
  symjac  = ~isempty(homTds.Jacobian);
  symhes  = ~isempty(homTds.Hessians);
   
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
    
  option = contset;
  option = contset(option,'Singularities',0);%HGE Switch off singularities explicit
  option = contset(option, 'SymDerivative', symord);
  symjacp = ~isempty(homTds.JacobianP); 
  symhes  = ~isempty(homTds.HessiansP);
  symordp = 0;
  if symjacp, symordp = 1; end
  if symhes,  symordp = 2; end
  option = contset(option, 'SymDerivativeP', symordp);
  
  cds.symjac  = 0;
  cds.symhess = 0;
  
%------------------------------------------------------  
function [out, failed] = testf(id, x0, v)
%HGE: We keep this for future testfunctions
% global homTds cds        

% [x,YS,YU,p] = rearr(x0);
% p = n2c(p);
% ndim = cds.ndim;
% J=contjac(x0);
failed = [];
for i=id
  lastwarn('');
  
  switch i
    case 1 % LP
      out(1) = v(end);
    case 2 % BP
      B = [J; v'];
      out(2) = det(B);
  otherwise
    error('No such testfunction');
  end
  if ~isempty(lastwarn)
    msg = sprintf('Could not evaluate tf %d\n', i);
    failed = [failed i];
  end
  
end
%-------------------------------------------------------------
function [out, failed] = userf(userinf, id, x, v)
global  homTds cds
dim =size(id,2);
failed = [];
[x,YS,YU,p] = rearr(x); p = num2cell(p);x0=x(1:dim);
for i=1:dim
  lastwarn('');
  if (userinf(i).state==1)
      out(i)=feval(homTds.user{id(i)},0,x0,p{:});
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
printconsole('label = %s, x = %s \n', s.label, vector2string(x));
switch id     
  case 1 % LP
    s.msg=sprintf('Limit point\n');       
  case 2 %BP
    s.msg=sprintf('Branch point\n');  
    s.data.v=v;
end

% Computing eigenvalues makes no sense for connecting orbits
failed = 0;

%-------------------------------------------------------------  
function [S,L] = singmat
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction
  S = [0 8 
       8 1 ] ;
  L = ['LP  ';'BP  ' ];
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
global homTds cds

res = []; % no re-evaluations needed
cds.adapted = 1;
[x1,YS,YU,p] = rearr(x);
J=homTds.Niterations;

%UPDATE EIGENSPACES
A1= homT_jac(x1,n2c(p),J);
[QU, eigvlU, dimU] = HomT_computeBase(A1,1,homTds.nu);
[QS, eigvlS, dimS] = HomT_computeBase(A1,0,homTds.ns);
homTds.Q0 = QU;
homTds.Q1 = QS;
homTds.YS=zeros(homTds.nphase-homTds.ns,homTds.ns);
homTds.YU=zeros(homTds.nphase-homTds.nu,homTds.nu);

%recompose continuation variable
x=[x1;reshape(homTds.YU,(homTds.nphase-homTds.nu)*homTds.nu,1);...
  reshape(homTds.YS,(homTds.nphase-homTds.ns)*homTds.ns,1);p(homTds.ActiveParams)];
%p(homTds.ActiveParams) (debug ? , NN)
%update boundary vectors
jac =BVP_HomT_jac(x1,homTds.YS,homTds.YU,n2c(p));
[U,S,V]=svd(full(jac));
homTds.b=U(:,end);
homTds.c=V(:,end);

res = 1;
%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
 
function [x,YS,YU,p] = rearr(x1)
% Rearranges x1 into all of its components
global homTds

x = x1(1:homTds.nphase*homTds.npoints,1);
p = homTds.P0;
idx=homTds.npoints*homTds.nphase;
ju=homTds.nphase-homTds.nu;
js=homTds.nphase-homTds.ns;
YU = reshape(x1(idx+1:idx+ju*homTds.nu,1),homTds.nphase-homTds.nu,homTds.nu);
idx = idx + ju*homTds.nu;
YS = reshape(x1(idx+1:idx+js*homTds.ns,1),homTds.nphase-homTds.ns,homTds.ns);
idx = idx + js*homTds.ns;
p(homTds.ActiveParams) = x1(end-1:end,1);

% ---------------------------------------------------------------
function WorkspaceInit(x,v)

% ------------------------------------------------------
function [x,v,s] = WorkspaceDone(x,v,s)

%------------------------------------------------------------
