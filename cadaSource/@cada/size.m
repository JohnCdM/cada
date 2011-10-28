function varargout = size(x,varargin)
%CADA overloaded operation for size
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

if nargout > 1 && ~isempty(varargin)
    error('Unknown command option.');
end

if nargout == 0 || nargout == 1
    if length(varargin) == 1
        if varargin{1} == 1
            NUMvar = size(x.variable,1);
            y.variable = x.variable;
            y.function = cell(1,3);
            y.function{1} = x.function{2}(1);
            y.function{2} = [1,1];
            y.derivative = cell(NUMvar,2);
            y = class(y,'cada');
            varargout{1} = y;
        elseif varargin{1} == 2
            NUMvar = size(x.variable,1);
            y.variable = x.variable;
            y.function = cell(1,3);
            y.function{1} = x.function{2}(2);
            y.function{2} = [1,1];
            y.derivative = cell(NUMvar,2);
            y = class(y,'cada');
            varargout{1} = y;
        else 
            error('CADA can only be used with two dimensions.');
        end
    else
        NUMvar = size(x.variable,1);
        y.variable = x.variable;
        y.function = cell(1,3);
        y.function{1} = [x.function{2}(1),x.function{2}(2)];
        y.function{2} = [1,2];
        y.derivative = cell(NUMvar,2);
        y = class(y,'cada');
        varargout{1} = y;
        return
    end
elseif nargout == 2
    NUMvar = size(x.variable,1);
    y1.variable = x.variable;
    y1.function = cell(1,3);
    y1.function{1} = x.function{2}(1,1);
    y1.function{2} = [1,1];
    y1.derivative = cell(NUMvar,2);
    y1 = class(y1,'cada');
    y2.variable = x.variable;
    y2.function = cell(1,3);
    y2.function{1} = x.function{2}(2);
    y2.function{2} = [1,1];
    y2.derivative = y1.derivative;
    y2 = class(y2,'cada');
    varargout{1} = y1;
    varargout{2} = y2;
    return
else
    NUMvar = size(x.variable,1);
    y1.variable = x.variable;
    y1.function = cell(1,3);
    y1.function{1} = x.function{2}(1,1);
    y1.function{2} = [1,1];
    y1.derivative = cell(NUMvar,2);
    y1 = class(y1,'cada');
    y2.variable = x.variable;
    y2.function = cell(1,3);
    y2.function{1} = x.function{2}(2);
    y2.function{2} = [1,1];
    y2.derivative = y1.derivative;
    y2 = class(y2,'cada');
    varargout{1} = y1;
    varargout{2} = y2;
    yy.variable = x.variable;
    yy.function = cell(1,3);
    yy.function{1} = 1;
    yy.function{2} = [1,1];
    yy.derivative = y1.derivative;
    yy = class(yy,'cada');
    for Icount = 3:nargout;
        varargout{Icount} = yy;
    end

end