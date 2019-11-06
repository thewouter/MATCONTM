function display(X)
% Display ADTAYL object
if isequal(get(0,'FormatSpacing'),'compact')
  disp([inputname(1) ' = adtayl object']);
  disp(X);
else
  disp(' ');
  disp([inputname(1) ' = adtayl object']);
  disp(' ');
  disp(X);
end
