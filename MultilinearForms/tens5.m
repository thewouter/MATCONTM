function T5=tens5(mapsf,mapsDer5,x,p,n)
global cds
%
% Tensor5 of f at x1,x2,..xn
%
    x1=x;
    T5(:,:,:,:,:,:,1)= feval(mapsDer5, 0, x1, p{:});
    for m=2:n
     x1=feval(mapsf,0,x1,p{:});
     T5(:,:,:,:,:,:,m)= feval(mapsDer5, 0, x1, p{:});
    end
    