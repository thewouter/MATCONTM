function T4=tens4(mapsf,mapsDer4,x,p,n)
global cds
%
% Tensor4 of f at x1,x2,..xn
%
    x1=x;
    T4(:,:,:,:,:,1)= feval(mapsDer4, 0, x1, p{:});
    for m=2:n
     x1=feval(mapsf,0,x1,p{:});
     T4(:,:,:,:,:,m)= feval(mapsDer4, 0, x1, p{:});
    end
    
    