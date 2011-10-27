function y = repmat(x,varargin)
% CADA repmat function
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
    [FMrow, FNcol] = size(x.function);
    y.function = repmat(x.function,repMrow,repNcol);
    NUMvar = size(x.variable,1);
    y.derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(x.derivative{Acount,1})
            nz = size(x.derivative{Acount,1},1);
            derivative = repmat(x.derivative{Acount,1},repMrow.*repNcol,1);
            indices    = zeros(nz.*repMrow.*repNcol,4);
            repCount = 0;
            for repIcount = 0:repMrow-1;
                for repJcount = 0:repNcol-1;
                    A = x.derivative{Acount,2};
                    A(:,1) = x.derivative{Acount,2}(:,1) + repIcount.*FMrow;
                    A(:,2) = x.derivative{Acount,2}(:,2) + repJcount.*FNcol;
                    indices((1:nz)+(repCount.*nz),:) = A;
                    repCount = repCount + 1;
                end
            end
            [derivative, indices]  = cadasort(derivative, indices);
            y.derivative{Acount,1} = derivative;
            y.derivative{Acount,2} = indices;
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
    [FMrow, FNcol] = size(x.function);
    y.function = repmat(x.function,repMrow,repNcol);
    NUMvar = size(x.variable,1);
    y.derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(x.derivative{Acount,1})
            nz = size(x.derivative{Acount,1},1);
            derivative = repmat(x.derivative{Acount,1},repMrow.*repNcol,1);
            indices    = zeros(nz.*repMrow.*repNcol,4);
            repCount = 0;
            for repIcount = 0:repMrow-1;
                for repJcount = 0:repNcol-1;
                    A = x.derivative{Acount,2};
                    A(:,1) = x.derivative{Acount,2}(:,1) + repIcount.*FMrow;
                    A(:,2) = x.derivative{Acount,2}(:,2) + repJcount.*FNcol;
                    indices((1:nz)+(repCount.*nz),:) = A;
                    repCount = repCount + 1;
                end
            end
            [derivative, indices]  = cadasort(derivative, indices);
            y.derivative{Acount,1} = derivative;
            y.derivative{Acount,2} = indices;
        end
    end
else
    error('Too many input arguments.');
end
y = class(y,'cada');