function out = heteroclinic
%
% heteroclinic curve definition file for a problem in mapfile
% 

global hetds cds
    out{1}  = @curve_func;
    out{2}  = @defaultprocessor;
    out{3}  = @options;
    out{4}  = @jacobian;
    out{5}  = @hessians;
    out{6}  = @testf;
    out{7}  = [];%@userf;
    out{8}  = @process;
    out{9}  = @singmat;
    out{10} = [];%@locate;
    out{11} = @init;
    out{12} = @done;
    out{13} = @adapt;
return


%----------------------------------------------------
function func = curve_func(arg)
  [x,YS,YU,p] = rearr(arg);
  func = BVP_Het(x,YS,YU,p);
 
%-----------------------------------------------------
function varargout = jacobian(varargin)
  [x,YS,YU,p] = rearr(varargin{1});
  varargout{1} = BVP_Het_jac(x,YS,YU,p);
  arg=varargin{1};
for i=1:size(arg,1)
  a1 = arg; a1(i) = a1(i)-1e-5;
  [x,YS,YU,p] = rearr(a1);f1 = BVP_Het(x,YS,YU,p);
  a2 = arg; a2(i) = a2(i)+1e-5;
  [x,YS,YU,p] = rearr(a2);f2 = BVP_Het(x,YS,YU,p);
  j(:,i) =(f2-f1)/(2*1e-5);
end
  rr=j-varargout{1};
%-----------------------------------------------------
function varargout = hessians(varargin)

%------------------------------------------------------
function varargout = defaultprocessor(varargin)
global hetds
  
% set data in special point structure
if nargin > 2
    s = varargin{3};
    varargout{3} = s;
end
% all done succesfully
varargout{1} = 0;
varargout{2} = hetds.npoints';

%-------------------------------------------------------
function option = options
global hetds cds
% Check for symbolic derivatives in mapfile
  symjac  = ~isempty(hetds.Jacobian);
  symhes  = ~isempty(hetds.Hessians);
     
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
    
  option = contset;
  option = contset(option, 'SymDerivative', symord);
  symjacp = ~isempty(hetds.JacobianP); 
  symhes  = ~isempty(hetds.HessiansP);
  symordp = 0;
  if symjacp, symordp = 1; end
  if symhes,  symordp = 2; end
  option = contset(option, 'SymDerivativeP', symordp);
  
  cds.symjac  = 1;
  cds.symhess = 0;
  
%------------------------------------------------------  
function [out, failed] = testf(id, x0, v)
global hetds cds        

J=contjac(x0);
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
% global  hetds cds
% 
% failed = [];
% [x,YS,YU,p] = rearr(x); p = num2cell(p);
% for i=1:dim
%   lastwarn('');
%   if (userinf(i).state==1)
%       out(i)=feval(hetds.user{id(i)},0,x,p{:});
%   else
%       out(i)=0;
%   end
%   if ~isempty(lastwarn)
%     msg = sprintf('Could not evaluate userfunction %s\n', id(i).name);
%     failed = [failed i];
%   end
% end

%-----------------------------------------------------------------
function [failed,s] = process(id, x, v, s)
global  cds hetds
[x0,YS,YU,p] = rearr(x);

printconsole('label = %s, x = %s \n', s.label , vector2string(x)); 
switch id     
  case 1 % LP      
     s.msg=sprintf('Limit point\n');   
  case 2 %BP
      s.msg=sprintf('Branch point\n');  
      s.data.v=v;
end

s.data.evec = v;

failed = 0;

%-------------------------------------------------------------  

function [S,L] = singmat
global hetds cds
 
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [ 0 8 
        8 1 ] ;

  L = ['LP  ';'BP  '];


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
global hetds cds

res = []; % no re-evaluations needed
cds.adapted = 1;
[x1,YS,YU,p]=rearr(x);
J=hetds.niteration;

% update unstable part;
A1= hetjac(x1(1:hetds.nphase),n2c(p),J);
[Q0, eigvlU, dimU] = Het_computeBase(A1,1,hetds.nu);
hetds.Q0=Q0;
hetds.YU=zeros(hetds.nphase-hetds.nu,hetds.nu);

%update stable part
AN = hetjac(x1(end-hetds.nphase+1:end),n2c(p),J);
[Q1, eigvlS, dimS] = Het_computeBase(AN,0,hetds.ns);
hetds.Q1=Q1;
hetds.YS=zeros(hetds.nphase-hetds.ns,hetds.ns);

x=[x1;reshape(hetds.YU,(hetds.nphase-hetds.nu)*hetds.nu,1);...
  reshape(hetds.YS,(hetds.nphase-hetds.ns)*hetds.ns,1);p(hetds.ActiveParams)];
% v=[];
res = 1;
%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
 
function [x,YS,YU,p] = rearr(x1)
% Rearranges x1 into all of its components
global hetds

x = x1(1:hetds.nphase*hetds.npoints,1);
p = hetds.P0;
idx=hetds.npoints*hetds.nphase;
ju=hetds.nphase-hetds.nu;
js=hetds.nphase-hetds.ns;
YU = reshape(x1(idx+1:idx+ju*hetds.nu,1),hetds.nphase-hetds.nu,hetds.nu);
idx = idx + ju*hetds.nu;
YS = reshape(x1(idx+1:idx+js*hetds.ns,1),hetds.nphase-hetds.ns,hetds.ns);
idx = idx + js*hetds.ns;
p(hetds.ActiveParams) = x1(end,1);

   
% -------------------------------------------------------------

% ---------------------------------------------------------------

function WorkspaceInit(x,v)
global cds hetds
% hetds.cols_p1 = 1:(hetds.ncol+1);
% hetds.cols_p1_coords = 1:(hetds.ncol+1)*hetds.nphase;
% hetds.ncol_coord = hetds.ncol*hetds.nphase;
% hetds.col_coords = 1:hetds.ncol*hetds.nphase;
% hetds.coords = 1:hetds.ncoords;
% hetds.pars = hetds.ncoords+(1:2);
% hetds.tsts = 1:hetds.ntst;
% hetds.cols = 1:hetds.ncol;
% hetds.phases = 1:hetds.nphase;
% hetds.ntstcol = hetds.ntst*hetds.ncol;
% 
% hetds.idxmat = reshape(fix((1:((hetds.ncol+1)*hetds.ntst))/(1+1/hetds.ncol))+1,hetds.ncol+1,hetds.ntst);
% hetds.dt = hetds.msh(hetds.tsts+1)-hetds.msh(hetds.tsts);
% 
% hetds.wp = kron(hetds.wpvec',eye(hetds.nphase));
% hetds.pwwt = kron(hetds.wt',eye(hetds.nphase));
% hetds.pwi = hetds.wi(ones(1,hetds.nphase),:);
% 
% hetds.wi = nc_weight(hetds.ncol)';
% 
% [hetds.bialt_M1,hetds.bialt_M2,hetds.bialt_M3,hetds.bialt_M4]=bialtaa(hetds.nphase);

% ------------------------------------------------------

function [x,v,s] = WorkspaceDone(x,v,s)

%------------------------------------------------------------
