function xx = FCMAP(theta, coef, options)
    xx = coef(1:options.n); %a0 is our fixed point, found in the first n coefficients
    N = options.NN; %number of Fourier modes
    fc = reshape(coef(options.n+1:end), options.n, 2*N); % Turn a1, b1, ..., aN, bN into Nxn matrix
    for ii = 1:N
        xx = xx + fc(:, 2*ii-1) * cos(ii*theta) + fc(:, 2*ii) * sin(ii*theta); % Add each next term of the sum to the point.
    end
end
