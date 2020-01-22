function out = closedinvariantcurve
%
% Fixed Point of  Map curve definition file for a problem in mapfile
% 

global cds nsmds
    out{1}  = @curve_func;
    out{2}  = @defaultprocessor;
    out{3}  = @options;
    out{4}  = @jacobian;
    out{5}  = @hessians;
    out{6}  = @testf;
    out{7}  = @userf;
    out{8}  = @process;
    out{9}  = @singmat;
    out{10} = @locate;
    out{11} = @init;
    out{12} = @done;
    out{13} = @adapt;
return
%-------------------------------------------------------
function dd = curve_func(arg)
global civds
FC = arg(1:end - length(civds.ap)); ps = arg(end-length(civds.ap)+1:end); % The Fourier coefficients as we got them from init, separated from the parameters

ps = num2cell(ps); % Turn the parameters into a format that can be given as arguments
FC = [FC(1:2*civds.n+civds.zerocomponent); 0; FC(2*civds.n+1+civds.zerocomponent:end)]; % Add a zero on spot b[1][zerocomp], which got removed before because it is fixed.
NN = civds.NN;
theta=2*pi*(0:2*NN)/(2*NN+1); % The set of all angles \theta to be evaluated
ind=[1:2*civds.n+civds.zerocomponent,2*civds.n+2+civds.zerocomponent:length(FC)]; %Keep zero component of sine fixed to zero, keep in mind n:m = {n, ..., m} inclusive
dd=zeros(civds.n,length(theta));

%Evaluate the map DD=F(x(t))-x(t+rho)
for ii=1:length(theta)
  dd(:,ii)=feval(civds.func,0,FCMAP(theta(ii),FC, civds),ps{:},civds.pss{:})-FCMAP(theta(ii)+civds.rho,FC, civds); %create all components of defining system
end

dd = reshape(dd, civds.n*(1+2*NN), 1); %put all values in one long array instead of a matrix
%---------------------------------------------------------------
function jac = jacobian(varargin)
global civds
ps = arg(end-length(civds.ap)+1:end); % The Fourier coefficients as we got them from init, separated from the parameters

ps = num2cell(ps); % Turn the parameters into a format that can be given as arguments

NN=(length(FC)/civds.n-1)/2;
theta=2*pi*(0:2*NN)/(2*NN+1);
ind=[1:2*civds.n,2*civds.n+2:length(FC)]; %Keep first component of sine fixed to zero, keep in mind n:m = {n, ..., m} inclusive
eps=1e-4;
dd=zeros(civds.n,length(theta));

% Compute the Jacobian
% wrt Fourier coefficients
jac=zeros(length(FC));
parfor kk=1:length(FC)-1
  jj=ind(kk);
  d1=nan(size(dd));
  d2=nan(size(dd));
  F1=FC;F1(jj)=F1(jj)+eps;
  F2=FC;F2(jj)=F2(jj)-eps;
  for ii=1:length(theta)
    d1(:,ii)=feval(civds.func,0,FCMAP(theta(ii),F1),ps{:})-FCMAP(theta(ii)+civds.rho,F1);
    d2(:,ii)=feval(civds.func,0,FCMAP(theta(ii),F2),ps{:})-FCMAP(theta(ii)+civds.rho,F2);
  end
  jac(:,kk)=(reshape(d1,length(FC),1)-reshape(d2,length(FC),1))/(2*eps);
end
% %wrt System Parameter
% ps1=ps;ps2=ps;ps1{1}=ps1{1}+eps;ps2{1}=ps2{1}-eps;
% for ii=1:length(theta)
%   d1(:,ii)=feval(map,0,FCMAP(theta(ii),FC),ps1{:})-FCMAP(theta(ii)+civds.rho,FC);
%   d2(:,ii)=feval(map,0,FCMAP(theta(ii),FC),ps2{:})-FCMAP(theta(ii)+civds.rho,FC);
% end
% jac(:,end)=(reshape(d1,length(FC),1)-reshape(d2,length(FC),1))/(2*eps);
% 
% end

   %---------------------------------------------------------------    
function hess = hessians(varargin)  
   
%---------------------------------------------------------------
function varargout = defaultprocessor(varargin)

global cds nsmds civds
%elseif strcmp(arg,'defaultprocessor')
  if nargin > 2
    s = varargin{3};
    varargout{3} = s;
  end
 % compute eigenvalues?
  if (cds.options.Multipliers==1)
      n=nsmds.Niterations;
      x0 = varargin{1}; 
      [x,p_cont] = rearr(x0); 
      p = civds.p;
      p(civds.ap) = p_cont;
      jac =nsmjac(x,n2c(p),n);
      varargout{2} = eig(jac);
  else
      varargout{2}= nan;
  end  
  % all done succesfully
  varargout{1} = 0;
%-------------------------------------------------------------
function option = options
global civds
  option = contset;
  option.nphase = civds.n;
  
  %----------------------------------------------------------------
function [out, failed] = testf(id, x, v)
    global civds
    failed = [];
    [~, active_param] = rearr(x);
    param = civds.p;
    param(civds.ap) = active_param;
    set_param_indices = setdiff(1:numel(civds.p),civds.ap);
    param(set_param_indices) = cell2mat(civds.pss);
    param = n2c(param);
    
    for i=id
        lastwarn('');
        switch i
            case 1 % QSN
                jac=civds.jac; 
                dim=civds.n;
                NN=civds.NN;
                theta=2*pi*(0:2*NN)/(2*NN+1);
                AA=zeros((2*NN+1)*dim);

                for ii=1:length(theta)
                    padded_fourier_coef = [x(1:2*dim+civds.zerocomponent); 
                        0; x(2*dim+1+civds.zerocomponent:end-2)];
                    xx=FCMAP(theta(ii),padded_fourier_coef, civds);
                    ind=(1:dim)+(ii-1)*dim;
                    AA(ind,ind)=feval(jac,0,xx,param{:});
                end
                DF=civds.TT'*civds.BI*AA*civds.BB;
                [~,D]=eig(DF);
                full_eigenvalues=diag(D);
                eigenvalues = sort(abs(full_eigenvalues));
                grouped_ev = reshape(eigenvalues, numel(eigenvalues)/dim, dim);
                grouped_ev_without_outliers = rmoutliers(grouped_ev);
                means = mean(grouped_ev_without_outliers);

                distance_from_unit = abs(means - 1);
                [~, indices_sorted] = sort(distance_from_unit);
                closest = (means(indices_sorted(1:2)));
                out(1) = closest(1) + closest(2) - 2;
            otherwise 
                error('No such testfunction');
        end
    end
%-----------------------------------------------------------------
function [out, failed] = userf(userinf, id, x, v)
%---------------------------------------------------------------------
function [failed,s] = process(id, x, v, s)
 printconsole('label = %s, x = %s \n', s.label , vector2string(x));
 s.msg = sprintf('QSN \n'); 
 failed = [];

%------------------------------------------------------------
function [S,L] = singmat
global fpmds cds
% 0: testfunction must vanish
% 1: testfunction must not vanish
% everything else: ignore this testfunction

  S = [0];

  L = ['QSN  '];

%--------------------------------------------------------
function [x,v] = locate(id, x1, v1, x2, v2)
%---------------------------------------------------------
function varargout = init(varargin)
%---------------------------------------------------------
function varargout = done

%----------------------------------------------------------  
function [res,x,v] = adapt(x,v)
res = []; % no re-evaluations needed

%----------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------

function [x,p] = rearr(x0)
global civds
x = x0(1:end-2);
p = x0(end-2+1:end);

% ---------------------------------------------------------------
function [x,v] = locateBP(id, x1, v1, x2, v2)

% ---------------------------------------------------------------

function [A, f] = locjac(x, b, p)

% ---------------------------------------------------------

function WorkspaceInit(x,v)

% ------------------------------------------------------
function WorkspaceDone

% -------------------------------------------------------


%SD:continues equilibrium of mapfile
