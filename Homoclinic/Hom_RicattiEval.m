% Ricatti evaluation file
% =======================

function result =Hom_RicattiEval(x0,p,unstable_flag,Y)

global homds
J=homds.niteration;
A = homjac(x0,p,J);
result = [];

if unstable_flag
    if  ~isempty(Y)
    Q0U = homds.Q0;
    % Riccati blocks from unstable eigenspace
    [U11, U12, UE21, U22] = Hom_RicattiCoeff(Q0U,A,homds.nu);
    tmp = (U22*Y - Y*U11 + UE21 - Y*U12*Y)';
    for i=1:homds.ns
        result(end+1:end+homds.nu,1) = tmp(:,i);
    end
    end
else
    if  ~isempty(Y)
    Q1S = homds.Q1;
    % Riccati blocks from stable eigenspace
    [S11, S12, SE21, S22] = Hom_RicattiCoeff(Q1S,A,homds.ns);
    tmp = (S22*Y - Y*S11 + SE21 - Y*S12*Y)';
    for i=1:homds.nu
        result(end+1:end+homds.ns,1) = tmp(:,i);
    end
    end
end
