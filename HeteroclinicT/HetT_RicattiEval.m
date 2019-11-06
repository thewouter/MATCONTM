% Ricatti evaluation file
% =======================

function result = HetT_RicattiEval(x0,p,unstable_flag,Y)

global hetTds
J=hetTds.Niterations;
A = hetjac(x0,p,J);
result = [];

if unstable_flag
    if  ~isempty(Y)
    Q0U = hetTds.Q0;
    % Riccati blocks from unstable eigenspace
    [U11, U12, UE21, U22] = Het_RicattiCoeff(Q0U,A,hetTds.nu);
    tmp = (U22*Y - Y*U11 + UE21 - Y*U12*Y)';
    for i=1:hetTds.ns
        result(end+1:end+hetTds.nu,1) = tmp(:,i);
    end
    end
else
    if  ~isempty(Y)
    Q1S = hetTds.Q1;
    % Riccati blocks from stable eigenspace
    [S11, S12, SE21, S22] = Het_RicattiCoeff(Q1S,A,hetTds.ns);
    tmp = (S22*Y - Y*S11 + SE21 - Y*S12*Y)';
    for i=1:hetTds.nu
        result(end+1:end+hetTds.ns,1) = tmp(:,i);
    end
    end
end
%result,pause