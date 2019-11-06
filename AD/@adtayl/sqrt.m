function u = sqrt(x)

% sqrt for adtayl objects.
[m,n,p1] = size(x.tc);
xtc = reshape(x.tc,[m*n,p1]);
x0 = xtc(:,1); %array of constant coefficients
ind = find(x0==0); % positions where const coeff is zero
indall0 = find(sum(abs(xtc),2)==0); %always a subset of ind
if numel(indall0) < numel(ind) % some TS has const coeff 0 but is not all 0
    error('Cannot take sqrt of nonzero TS with zero constant term');
end
x0(ind) = 1; % Dummy 1's in places of identically zero TS's
x.tc(:,:,1) = reshape(x0,[m,n]);
u=adtayl(sqrt(x.tc(:,:,1)));
ncoeff=1;
while ncoeff<p1
    u=(u+x./u)/2;
    ncoeff=2*ncoeff;
end
u.tc(ind) = 0;
