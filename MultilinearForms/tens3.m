function T3=Tens3(mapsf,mapsDer3,x,p,n)
global cds
%
% Tensor3 of f at x1,x2,..xn
%
    x1=x;
    T3(:,:,:,:,1)= feval(mapsDer3, 0, x1, p{:});
    for m=2:n
     x1=feval(mapsf,0,x1,p{:});
     T3(:,:,:,:,m)= feval(mapsDer3, 0, x1, p{:});
    end
    
    