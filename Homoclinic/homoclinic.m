function out = homoclinic
%
% homoclinic curve definition file for a problem in mapfile
% 
global homds cds
    out{1}  = @curve_func;
    out{2}  = @defaultprocessor;
    out{3}  = @options;
    out{4}  = @jacobian;
    out{5}  = [];%@hessians;
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
  func = BVP_Hom(x,YS,YU,p);

%-----------------------------------------------------
function varargout = jacobian(varargin)
  [x,YS,YU,p] = rearr(varargin{1});
  varargout{1} = BVP_Hom_jac(x,YS,YU,p);
  
%------------------------------------------------------
function varargout = hessians(varargin)

%------------------------------------------------------

function varargout = defaultprocessor(varargin)
global homds
 
% set data in special point structure
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
% all done succesfully
  varargout{1} = 0;
  varargout{2} = homds.npoints';
%-------------------------------------------------------
  
function option = options
global homds cds
% Check for symbolic derivatives in mapfile
  
  symjac  = ~isempty(homds.Jacobian);
  symhes  = ~isempty(homds.Hessians);
  symder  = ~isempty(homds.Der3);
  
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symder, symord = 3; end

  option = contset;

  option = contset(option, 'SymDerivative', symord);
  option = contset(option, 'Workspace', 1);
  symjacp = ~isempty(homds.JacobianP); 
  symhes  = ~isempty(homds.HessiansP);
  symordp = 0;
  if symjacp, symordp = 1; end
  if symhes,  symordp = 2; end
  option = contset(option, 'SymDerivativeP', symordp);
  
  cds.symjac  = 1;
  cds.symhess = 0;
  
%------------------------------------------------------  
function [out, failed] = testf(id, x0, v)
global homds cds        

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
global  homds
dim =size(id,2);
failed = [];
[x,YS,YU,p] = rearr(x); p = num2cell(p);
for i=1:dim
  lastwarn('');
  if (userinf(i).state==1)
    out(i)=feval(homds.user{id(i)},0,x,p{:});
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

failed = 0;
%-------------------------------------------------------------  

function [S,L] = singmat
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction
  S = [0 8 
       8 1 ] ;
  L = ['LP  ';'BP  '];

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
global homds cds

res = []; % no re-evaluations needed
[x1,YS,YU,p] = rearr(x);
cds.adapted = 1;

Q0S = homds.Q1;
QbS1 = Q0S(:,1:homds.nu);
QbS2 = Q0S(:,homds.nu+1:end);
if ~isempty(YS)
  [U1,S1,R1] = svd(QbS1 + QbS2*YS' , 0);
  [U2,S2,R2] = svd(QbS2 - QbS1*YS, 0);
  Q1S = [U1*R1', U2*R2'];
else
  Q1S = Q0S;
end

Q0U = homds.Q0;
QbU1 = Q0U(:,1:homds.ns);
QbU2 = Q0U(:,homds.ns+1:end);
if ~isempty(YU)
  [U1,S1,R1] = svd(QbU1 + QbU2*YU' , 0);
  [U2,S2,R2] = svd(QbU2 - QbU1*YU, 0);
  Q1U = [U1*R1', U2*R2']; 
else
  Q1U = Q0U;
end
homds.Q0 = Q1U;
homds.Q1 = Q1S;
x=[x1;reshape(0*YU,(homds.nphase-homds.nu)*homds.nu,1);...
  reshape(0*YS,(homds.nphase-homds.ns)*homds.ns,1);p(homds.ActiveParams)];
res = 1;


%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------
 
function [x,YS,YU,p] = rearr(x1)
% Rearranges x1 into all of its components
global homds

x = x1(1:homds.nphase*homds.npoints,1);
p = homds.P0;
idx=homds.npoints*homds.nphase;
ju=homds.nphase-homds.nu;
js=homds.nphase-homds.ns;
YU = reshape(x1(idx+1:idx+ju*homds.nu,1),homds.nphase-homds.nu,homds.nu);
idx = idx + ju*homds.nu;
YS = reshape(x1(idx+1:idx+js*homds.ns,1),homds.nphase-homds.ns,homds.ns);
idx = idx + js*homds.ns;
p(homds.ActiveParams) = x1(end,1);

% ---------------------------------------------------------------
function WorkspaceInit(x,v)

% ------------------------------------------------------
function [x,v,s] = WorkspaceDone(x,v,s)
