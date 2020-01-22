% Plot invariant curves
function out = PIC(curve, X, dim1, dim2, plot2D)

options = struct;
options.n = curve.globals.nsmds.nphase;
options.zerocomponent = 0;
length = size(X,1);
options.NN = ((length - 1)/ options.n -1 )/2;

% Extract the Fourier coefficients from X for each column
[n1,n2] = size(X); %n1 is the amount of rows, n2 the amount of columns
clist = colormap(hsv(3*n2)); % The color range we will plot. n2 is the entire color range, the multiplier c (=3 here) means we only want the first one third of the full range
% For every column we plot the closed invariant curve
for col = 1:1:n2
    x = X(:,col:col);x = [x(1:2*options.n+options.zerocomponent); 0; x(2*options.n+1+options.zerocomponent:end-2)]; % Get all the coefficients from this column and add the zero coefficient
    theta = linspace(0,2*pi); % Give MATLAB the angles to draw the curve
    V = FCMAP(theta,x, options); % Get curve from Fourier Coefficients
    x1 = V(dim1:dim1,:); % Enter dimensions
    x2 = V(dim2:dim2,:);
    if nargin > 4
        plot(x1,x2, 'Parent' , plot2D.group  , plot2D.plotconfig.curve{:}, plot2D.plotops{:}) % Plot the curve
    else
        plot(x1,x2,'color',clist(col,:)) % Plot the curve
    end
    hold on
end
hold off
%legend show
end
