
function matcontm(varargin)
if (verLessThan('matlab', '7.6'))
    disp('matlab version needs to be 7.6 or higher');
    return;
end

addpath([pwd '/GUI/']);
if (~isempty(varargin))  % startgui new    , any arg will do
    delete ('Systems/Session.mat');
    gui 'nodebug'
else
    gui 'nodebug'
end

end
