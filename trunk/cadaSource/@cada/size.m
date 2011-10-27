function varargout = size(x,varargin)
% CADA size function
% created by Michael Patterson

if nargout > 1 && ~isempty(varargin)
    error('Unknown command option.');
end

out = size(x.function, varargin{:});
if nargout == 0 || nargout == 1
    y.variable = x.variable;
    y.function = cadanum2str(out);
    y.derivative = cell(size(x.variable));
    y = class(y,'cada');
    varargout{1} = y;
elseif nargout == 2
    y1.variable = x.variable;
    y1.function = cadanum2str(out(1));
    y1.derivative = cell(size(x.variable));
    y1 = class(y1,'cada');
    y2.variable = x.variable;
    y2.function = cadanum2str(out(2));
    y2.derivative = y1.derivative;
    y2 = class(y2,'cada');
    varargout{1} = y1;
    varargout{2} = y2;
else
    y1.variable = x.variable;
    y1.function = cadanum2str(out(1));
    y1.derivative = cell(size(x.variable));
    y1 = class(y1,'cada');
    y2.variable = x.variable;
    y2.function = cadanum2str(out(2));
    y2.derivative = y1.derivative;
    y2 = class(y2,'cada');
    varargout{1} = y1;
    varargout{2} = y2;
    yy.variable = x.variable;
    yy.function = {'1'};
    yy.derivative = y1.derivative;
    yy = class(yy,'cada');
    for Icount = 3:nargout;
        varargout{Icount} = yy;
    end
end