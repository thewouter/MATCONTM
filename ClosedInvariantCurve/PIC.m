% Plot invariant curves
function out = PIC(X, dim1, dim2)
global civds

% Extract the Fourier coefficients from X for each column
[n1,n2] = size(X); %n1 is the amount of rows, n2 the amount of columns
clist = colormap(hsv(3*n2)); % The color range we will plot. n2 is the entire color range, the multiplier c (=3 here) means we only want the first one third of the full range
% For every column we plot the closed invariant curve
for col = 1:1:n2
    x = X(:,col:col);
    x = [x(1:2*civds.n+civds.zerocomponent); 0; x(2*civds.n+1+civds.zerocomponent:end-2)]; % Get all the coefficients from this column and add the zero coefficient
    theta = linspace(0,2*pi); % Give MATLAB the angles to draw the curve
    V = FCMAP(theta,x); % Get curve from Fourier Coefficients
    x1 = V(dim1:dim1,:); % Enter dimensions
    x2 = V(dim2:dim2,:);
    plot(x1,x2,'color',clist(col,:)) % Plot the curve
    hold on
end
hold off
%legend show
end
