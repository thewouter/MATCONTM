function res = contmrg(options, opt)
%
% res = CONTMRG(options, opt)
%
% Merges options in 'opt' to 'options'
% Options in 'options' will be overwritten by defined options in 'opt'

if isempty(opt)
  res = options;
  return;
end

allopt = contidx;

[m,n] = size(allopt);

for i=1:m
  eval(['val = opt.' allopt(i,:) ';']);
  if ~isempty(val)
    eval(['options.' allopt(i,:) '= val;']);
  end
end

res = options;
