function y = reshape(x,varargin)
% CADA reshape function
% created by Michael Patterson

varargSize = length(varargin);
if varargSize == 0 ;
    error('Requires at least 2 inputs.');
elseif varargSize == 1
    if length(varargin{1}) > 2
        error('cada can only be used with 2 dimentions.');
    end
    if length(varargin{1}) == 1
        repMrow = varargin{1};
        repNcol = varargin{1};
    else
        repMrow = varargin{1}(1);
        repNcol = varargin{1}(2);
    end
    if repMrow == 1 && repNcol == 1
        y = x;
        return
    end
    y.variable = x.variable;
    y.function = reshape(x.function,repMrow,repNcol);
    NUMvar = size(x.variable,1);
    y.derivative = cell(NUMvar,2);
    arraysize = size(x.function);
    for Acount = 1:NUMvar;
        if ~isempty(x.derivative{Acount,1})
            arraysize(3) = x.variable{Acount,2}(1);
            arraysize(4) = x.variable{Acount,2}(2);
            arrayderivative = cadaind2array(x.derivative{Acount,1}, x.derivative{Acount,2}, arraysize);
            arrayderivative = reshape(arrayderivative,repMrow,repNcol,arraysize(3),arraysize(4));
            [y.derivative{Acount,1}, y.derivative{Acount,2}] = cadaarray2ind(arrayderivative);
        end
    end
elseif varargSize == 2
    repMrow = varargin{1};
    repNcol = varargin{2};
    if repMrow == 1 && repNcol == 1
        y = x;
        return
    end
    y.variable = x.variable;
    y.function = reshape(x.function,repMrow,repNcol);
    NUMvar = size(x.variable,1);
    y.derivative = cell(NUMvar,2);
    arraysize = size(x.function);
    for Acount = 1:NUMvar;
        if ~isempty(x.derivative{Acount,1})
            arraysize(3) = x.variable{Acount,2}(1);
            arraysize(4) = x.variable{Acount,2}(2);
            arrayderivative = cadaind2array(x.derivative{Acount,1}, x.derivative{Acount,2}, arraysize);
            arrayderivative = reshape(arrayderivative,repMrow,repNcol,arraysize(3),arraysize(4));
            [y.derivative{Acount,1}, y.derivative{Acount,2}] = cadaarray2ind(arrayderivative);
        end
    end
else
    error('Too many input arguments.');
end
y = class(y,'cada');