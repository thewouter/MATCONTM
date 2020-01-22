function diverges=ICstop(nphase, coeff, CN, nAv)
    %
    % ICstop(x, N)
    %
    % Calculates if the fourier coefficients converge in C_N
    % options is a option-vector created with CONTSET
    % Three parameters are mandatory.
    
    convergence_test = true;
    fit_method = false;
    backtrack_method = true;
    

    length = size(coeff,1);
    N = ((length - 1)/ nphase -1 )/2; %% Because fourier works with sin and cos, N is simultanious half way the coefficients array
    y = coeff(:,1);
    y = [y(1:2*nphase); 0; y(2*nphase+1:end-2)];
    fc=reshape(y(nphase+1:end),nphase,2*N); %reshape coeff such that different dimensions are seperated
    
    if convergence_test
        convergence_factor = 1.5;
        zero_threshold = 10^-5;
        data = abs(fc);
        data_length = numel(data)/nphase;
        data = data.*reshape( cat( 1, [1:N], [1:N] ), 1, [] ).^CN;
        
        if fit_method
            P = polyfit(1:size(data, 2), sum(data, 1), 1);
            diverges = P(1) > 0;
        else
            if nargin == 3 %no nAv given
                nAv = round(data_length / 4);
            end
            diverges = sum(sum(data(:,1:1+nAv))) < sum(sum(data(:,end-nAv:end)))*convergence_factor;
            diverges = diverges && fc(end:end) > zero_threshold;
            
%             [ sum(sum(data(:,N:N+nAv)))  sum(sum(data(:,end-nAv:end)))]
        end
%         figure(10)
%         plot(data')
        
        %Fourier coefficients diverge if the average of the third qarter is
        %smaller than the sum of the fourth quarter
        
    else
        xx=coeff(1:nphase); %a0 is our fixed point, found in the first n coefficients
        theta = linspace(0,2*pi); % Give MATLAB the angles to draw the curve
        for ii=1:N
            xx=xx+fc(:,2*ii-1)*cos(ii*theta)+fc(:,2*ii)*sin(ii*theta); % Add each next term of the sum to the point.
        end
        if backtrack_method
            angles = atan((xx(1,:) - coeff(1))./(xx(2,:) - coeff(2)));
            
            diverges = false;
            for ii = 2:size(theta,2)
                if angles(ii) > angles(ii-1) && abs(angles(ii) - angles(ii-1)) < 0.9*pi
                    diverges = true;
                    break;
                end
            end
            
        else
            diverges = ~isempty(selfintersect(xx(1,:), xx(2,:)));
        end
    end
    
end