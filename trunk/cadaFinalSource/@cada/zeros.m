function y = zeros(varargin)
%CADA overloaded operation for zeros
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

varargSize = length(varargin);
if varargSize == 1
    if ~isnumeric(varargin{1}.function{1})
        error('input must be numeric CADA number.');
    end
    if varargin{1}.function{2}(2) > 2
        error('input must be a scaler or vector.');
    end
    if varargin{1}.function{2}(1) > 1
        error('CADA can only be used with 2 dimensions.');
    end
    if varargin{1}.function{2}(2) == 1
        Mrow = varargin{1}.function{1}(1,1);
        Ncol = Mrow;
    else
        Mrow = varargin{1}.function{1}(1,1);
        Ncol = varargin{1}.function{1}(1,2);
    end
    NUMvar = size(varargin{1}.variable,1);
    y.variable = varargin{1}.variable;
    y.function = cell(1,3);
    y.function{1} = zeros(Mrow,Ncol);
    y.function{2} = [Mrow,Ncol];
    y.derivative = cell(NUMvar,2);
    y = class(y,'cada');
elseif varargSize == 2
    if isa(varargin{1},'cada') && isa(varargin{2},'cada')
        if ~isnumeric(varargin{1}.function{1}) || ~isnumeric(varargin{2}.function{1})
            error('inputs must be numeric CADA numbers.');
        end
        if varargin{1}.function{2}(1) > 1 || varargin{1}.function{2}(2) > 1
            error('input must be a scaler.');
        end
        Mrow = varargin{1}.function{1}(1,1);
        if varargin{2}.function{2}(1) > 1 || varargin{2}.function{2}(2) > 1
            error('input must be a scaler.');
        end
        Ncol = varargin{2}.function{1}(1,1);
        NUMvar = size(varargin{1}.variable,1);
        y.variable = varargin{1}.variable;
        y.function = cell(1,3);
        y.function{1} = zeros(Mrow,Ncol);
        y.function{2} = [Mrow,Ncol];
        y.derivative = cell(NUMvar,2);
        y = class(y,'cada');
    elseif isa(varargin{1},'cada')
        if ~isnumeric(varargin{1}.function{1})
            error('input must be numeric CADA number.');
        end
        if varargin{1}.function{2}(1) > 1 || varargin{1}.function{2}(2) > 1
            error('input must be a scaler.');
        end
        Mrow = varargin{1}.function{1}(1,1);
        Ncol = varargin{2};
        NUMvar = size(varargin{1}.variable,1);
        y.variable = varargin{1}.variable;
        y.function = cell(1,3);
        y.function{1} = zeros(Mrow,Ncol);
        y.function{2} = [Mrow,Ncol];
        y.derivative = cell(NUMvar,2);
        y = class(y,'cada');
    elseif isa(varargin{2},'cada')
        if ~isnumeric(varargin{2}.function{1})
            error('input must be numeric CADA number.');
        end
        if varargin{2}.function{2}(1) > 1 || varargin{2}.function{2}(2) > 1
            error('input must be a scaler.');
        end
        Ncol = varargin{2}.function{1}(1,1);
        Mrow = varargin{1};
        NUMvar = size(varargin{2}.variable,1);
        y.variable = varargin{2}.variable;
        y.function = cell(1,3);
        y.function{1} = zeros(Mrow,Ncol);
        y.function{2} = [Mrow,Ncol];
        y.derivative = cell(NUMvar,2);
        y = class(y,'cada');
    end
elseif varargSize == 3
    if isa(varargin{3},'cada') && isnumeric(varargin{3}.function{1}) && varargin{3}.function{2}(1) == 1 && varargin{3}.function{2}(2) == 1
        if isa(varargin{1},'cada') && isa(varargin{2},'cada')
            if ~isnumeric(varargin{1}.function{1}) || ~isnumeric(varargin{2}.function{1})
                error('inputs must be numeric CADA numbers.');
            end
            if varargin{1}.function{2}(1) > 1 || varargin{1}.function{2}(2) > 1
                error('input must be a scaler.');
            end
            Mrow = varargin{1}.function{1}(1,1);
            if varargin{2}.function{2}(1) > 1 || varargin{2}.function{2}(2) > 1
                error('input must be a scaler.');
            end
            Ncol = varargin{2}.function{1}(1,1);
            NUMvar = size(varargin{1}.variable,1);
            y.variable = varargin{1}.variable;
            y.function = cell(1,3);
            y.function{1} = zeros(Mrow,Ncol);
            y.function{2} = [Mrow,Ncol];
            y.derivative = cell(NUMvar,2);
            y = class(y,'cada');
        elseif isa(varargin{1},'cada')
            if ~isnumeric(varargin{1}.function{1})
                error('input must be numeric CADA number.');
            end
            if varargin{1}.function{2}(1) > 1 && varargin{1}.function{2}(2) > 1
                error('input must be a scaler or vector.');
            end
            Mrow = varargin{1}.function{1}(1,1);
            Ncol = varargin{2};
            NUMvar = size(varargin{1}.variable,1);
            y.variable = varargin{1}.variable;
            y.function = cell(1,3);
            y.function{1} = zeros(Mrow,Ncol);
            y.function{2} = [Mrow,Ncol];
            y.derivative = cell(NUMvar,2);
            y = class(y,'cada');
        elseif isa(varargin{2},'cada')
            if ~isnumeric(varargin{2}.function{1})
                error('input must be numeric CADA number.');
            end
            if varargin{2}.function{2}(1) > 1 || varargin{2}.function{2}(2) > 1
                error('input must be a scaler.');
            end
            Ncol = varargin{2}.function{1}(1,1);
            Mrow = varargin{1};
            NUMvar = size(varargin{2}.variable,1);
            y.variable = varargin{2}.variable;
            y.function = cell(1,3);
            y.function{1} = zeros(Mrow,Ncol);
            y.function{2} = [Mrow,Ncol];
            y.derivative = cell(NUMvar,2);
            y = class(y,'cada');
        else
            Mrow = varargin{1};
            Ncol = varargin{2};
            NUMvar = size(varargin{3}.variable,1);
            y.variable = varargin{3}.variable;
            y.function = cell(1,3);
            y.function{1} = zeros(Mrow,Ncol);
            y.function{2} = [Mrow, Ncol];
            y.derivative = cell(NUMvar,2);
            y = class(y,'cada');
        end
    else
        error('CADA can only be used with 2 dimensions.');
    end
else
    error('CADA can only be used with 2 dimensions.');
end