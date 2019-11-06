function [x0,v0]= init_NSm_ICm(mapfile, x, p, NN,amp, ap,n)

global cds civds
zerocomponent = 0;   % if we would like to have our fixed component of b[1] in another place, we can put it here

cds.options.SymDerivative=0;
nphase=length(x);
civds.n = nphase; % The dimension of x, small n
civds.mapfile = mapfile; % The map we want to evaluate
func_handles = feval(civds.mapfile);
civds.func = func_handles{2};
civds.NN = NN; %Number of Fourier cos+sin modes, excluding constant term
civds.p = p; % System parameters
civds.ap = ap; % Active parameters

pss = civds.p(length(civds.ap)+1:end); % Static parameters
pss = num2cell(pss); % Turn into cell list
civds.pss = pss;

A=cjac(civds.func, [], x, n2c(p)); % HGE: To be changed so that the Jacobian is called
[V, D]=eig(A); D=diag(D);
for i=1:nphase-1
  for j=i+1:nphase
    if (abs(D(i) * D(j)-1)<1e-3)
      if (imag(D(i))==0)
          debug('Neutral Saddle');return;
      elseif(imag(D(i))>0)
          idx=i;
      else
          idx=j;
      end
    end
  end
end

q=V(:, idx);
q=exp(-1i* angle(q(1)))*q; %Ensure the first component of q is real by rotating q;
x0=[x;amp*real(q);amp*imag(q);zeros(2 * nphase * (NN - 1), 1)]; %padding by zeros as close to the NS-point only the first mode matters
x0=[x0([1:2*nphase 2*nphase+2:end]); p(ap)];   %Omit the zero component from the continuation variable and add parameters.
rho=angle(D(idx));

civds.zerocomponent = zerocomponent;
civds.rho = rho; % The initial curve radius
v0 = []; %initial tangent vectors

