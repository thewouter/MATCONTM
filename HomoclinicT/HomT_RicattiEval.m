% Ricatti evaluation file
% =======================

function result = HomT_RicattiEval(x0,p,unstable_flag,Y)

global homTds
J=homTds.Niterations;
A = homT_jac(x0,p,J);
result = [];

if unstable_flag
  if  ~isempty(Y)
    Q0U = homTds.Q0;
    % Riccati blocks from unstable eigenspace
    [U11, U12, UE21, U22] = HomT_RicattiCoeff(Q0U,A,homTds.nu);
    tmp = (U22*Y - Y*U11 + UE21 - Y*U12*Y)';
    for i=1:homTds.ns
        result(end+1:end+homTds.nu,1) = tmp(:,i);
    end
  end
else
  if  ~isempty(Y)
    Q1S = homTds.Q1;
    % Riccati blocks from stable eigenspace
    [S11, S12, SE21, S22] = HomT_RicattiCoeff(Q1S,A,homTds.ns);
    tmp = (S22*Y - Y*S11 + SE21 - Y*S12*Y)';
    for i=1:homTds.nu
      result(end+1:end+homTds.ns,1) = tmp(:,i);
    end
  end
end