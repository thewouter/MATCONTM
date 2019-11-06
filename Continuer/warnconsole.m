function warnconsole(varargin)
fprintf('WARNING: '); fprintf(varargin{:}); fprintf('\n');
warning(varargin{:});
end
