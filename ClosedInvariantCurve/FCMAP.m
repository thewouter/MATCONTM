function xx=FCMAP(theta,coef)
global civds
  xx=coef(1:civds.n); %a0 is our fixed point, found in the first n coefficients
  N=civds.NN;  %number of Fourier modes
  fc=reshape(coef(civds.n+1:end),civds.n,2*N); % Turn a1, b1, ..., aN, bN into Nxn matrix
  for ii=1:N
    xx=xx+fc(:,2*ii-1)*cos(ii*theta)+fc(:,2*ii)*sin(ii*theta); % Add each next term of the sum to the point.
  end

end
