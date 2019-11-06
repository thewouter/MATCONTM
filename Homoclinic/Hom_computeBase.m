%function  [Q0,evl,NSub] =  computeBase(hom, A0, unstable_flag, NSub)
%
% Compute an orthonormal basis Q0 for the invariant subspace
% corresponding to the NSub 
%       most unstable eigenvalues of A0 if unstable_flag = 1
%   and most stable eigenvalues of A0 if unstable_flag = 0.
%
% If resizeable_flag is true, then the size of the space NSub may
% be adjusted. 

function  [Q0,evl,NSub] =  computeBase(A0, unstable_flag, NSub)
evl = eig(A0);
if unstable_flag
    
    % Compute all eigenvalues and eigenvectors and check number of unstable
    % ones
   
    % Compute eigenvalues and -vectors, ordered
    % (the ones with largest norm are first)
    
    [VU, DU] = eigs(A0,size(A0,1),'LM');
    [~, indices] = sort(diag(abs(DU)), 'descend'); %manualy sort eigenvalues.
    
    % Select first NSub eigenvectors: unstable eigenspace
    VU = VU(:,indices(1:NSub));
    % Compute orthonormal basis for the eigenspace
    [Q0,RU] = qr(VU);
    
else
    
    % Compute all eigenvalues and eigenvectors and check number of stable
    % ones
 
    % Compute eigenvalues and -vectors, ordered
    % (the ones with smallest norm are first)
    
    [VS, DS] = eigs(A0,size(A0,1),'SM');
    [~, indices] = sort(diag(abs(DS)), 'ascend'); %manualy sort eigenvalues
    
    % Select first NSub eigenvectors: stable eigenspace
    VS = VS(:,indices(1:NSub));
    % Compute orthonormal basis for the eigenspace
    [Q0,RS] = qr(VS);
end
