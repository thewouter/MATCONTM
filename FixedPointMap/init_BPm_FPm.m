function [x0,v0]= init_BPm_FPm(mapfile, x, p, s, h,n)
%
%[x0,v0]= init_BP_FP(mapfile, x, p, s, h)
%
% Defines mapfile
% Sets all parameters for an fixed point continuation (p)
% and the active parameter (ap)
%
global fpmds cds
x0 = [x;p(fpmds.ActiveParams)];
v0 = [];
fpmds.P0 = p;
fpmds.mapfile = mapfile;
if ~isfield(s.data,'v') 
    [x0,v0] = init_FPm_FPm(mapfile,x,p,fpmds.ActiveParams,n);
    return
else
    fpmds.v = s.data.v;
end    
func_handles = feval(fpmds.mapfile);
fpmds.func = func_handles{2};
fpmds.Jacobian  = func_handles{3};
fpmds.JacobianP = func_handles{4};
fpmds.Hessians  = func_handles{5};
fpmds.HessiansP = func_handles{6};
siz = size(func_handles,2);
if siz > 9
    j=1;
    for i=10:siz
       fpmds.user{j}= func_handles{i};
        j=j+1;
    end
end
jac = contjac(x0);
p = n2c(p);
if issparse(jac)
    Q=qr(jac)
    R=qr(jac')
    if (abs(Q(size(x,1),size(x,1))) >= cds.options.FunTolerance)|abs((Q(size(x,1),size(x,1)+1)) >= cds.options.FunTolerance)
        printconsole('Last singular value exceeds tolerance\n');
    end
    q = Q(1:end-1,1:end-2)\-Q(1:end-1,end-1:end);
    q = [q;eye(2)];
    q1 = q(:,1); q2 = q(:,2);
    p1 = [R(1:end-2,1:end-1)\-R(1:end-2,end);1];
else
    [Q,R,E] = qr(jac');
    if (abs(R(size(x,1),size(x,1))) >= cds.options.FunTolerance)
    printconsole('Last singular value exceeds tolerance\n');
    end
    q1 = Q(:,end-1);
    q2 = Q(:,end);
    p1 = [R(1:end-2,1:end-1)\-R(1:end-2,end);1];
    p1 = E*p1;
end

p1 = p1/norm(p1);
t1 = 0; t2 = 0;
for i=1:size(x0,1)
    x1 = x0; x1(i) = x1(i)-cds.options.Increment;
    x2 = x0; x2(i) = x2(i)+cds.options.Increment;
    t1(i) = p1'*((contjac(x2)-contjac(x1))/(2*cds.options.Increment))*q1;
    t2(i) = p1'*((contjac(x2)-contjac(x1))/(2*cds.options.Increment))*q2;
end
a = (t1*q1)/2;
b = (t1*q2)/2;
c = (t2*q2)/2;
if (abs(c) >= abs(a)) & (abs(c) > cds.options.FunTolerance)

    alpha1 = 1; alpha2 = 1;
    poly = [c 2*b a];
    beta = roots(poly);
    beta1 = beta(1);
    beta2 = beta(2);
    elseif (abs(a) > abs(c))&(abs(a) > cds.options.FunTolerance)
    
    beta1 = 1;beta2 = 1;
    poly = [a 2*b c];
    alpha = roots(poly);
    alpha1 = alpha(1);
    alpha2 = alpha(2);
else
    if(abs(b) < cds.options.FunTolerance)
        printconsole('Degeneracy in branching equation suspected\n');
    end
    alpha1 = 1;beta1 = 0;
    alpha2 = 0;beta2 = 1;
end
q3 = alpha1*q1+beta1*q2;
q4 = alpha2*q1+beta2*q2;
q3 = q3/norm(q3);
q4 = q4/norm(q4);
if abs(q3'*s.data.v) < abs(q4'*s.data.v)

    v0 = q3;
else
    v0 = q4;    
end
x0 = x0+h*v0;
