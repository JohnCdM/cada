function y = ones(varargin)
% CADA ones function
% created by Michael Patterson

varargSize = length(varargin);
if varargSize == 1
    if size(varargin{1}.function,2) > 2
        error('input must be a scaler or vector.');
    end
    if size(varargin{1}.function,1) > 1
        error('cada can only be used with 2 dimentions.');
    end
    if size(varargin{1}.function,2) == 1
        Mrow = str2double(varargin{1}.function{1,1});
        Ncol = Mrow;
    else
        Mrow = str2double(varargin{1}.function{1,1});
        Ncol = str2double(varargin{1}.function{1,2});
    end
    y.variable = varargin{1}.variable;
    y.function = cadanum2str(ones(Mrow,Ncol));
    y.derivative = cell(size(y.variable));
    y = class(y,'cada');
elseif varargSize == 2
    if isa(varargin{1},'cada') && isa(varargin{2},'cada')
        if size(varargin{1}.function,1) > 1 && size(varargin{1}.function,2) > 1
            error('input must be a scaler or vector.');
        end
        Mrow = str2double(varargin{1}.function{1,1});
        if size(varargin{2}.function,1) > 1 && size(varargin{2}.function,2) > 1
            error('input must be a scaler or vector.');
        end
        Ncol = str2double(varargin{2}.function{1,1});
        NUMarg1 = size(varargin{1}.variable,1);
        NUMarg2 = size(varargin{2}.variable,1);
        NUMvar  = max(NUMarg1, NUMarg2);
        y.variable = cell(NUMvar,2);
        if NUMarg1 > NUMarg2
            varargin{2}.variable{NUMvar,2} = [];
        elseif NUMarg1 < NUMarg2
            varargin{1}.variable{NUMvar,2} = [];
        end
        for Acount = 1:NUMvar;
            if ~isempty(varargin{1}.variable{Acount,1}) && ~isempty(varargin{2}.variable{Acount,1})
                y.variable(Acount,:) = varargin{1}.variable(Acount,:);
            elseif ~isempty(varargin{1}.variable{Acount,1})
                y.variable(Acount,:) = varargin{1}.variable(Acount,:);
            elseif ~isempty(varargin{2}.variable{Acount,1})
                y.variable(Acount,:) = varargin{2}.variable(Acount,:);
            end
        end
        y.function = cadanum2str(ones(Mrow,Ncol));
        y.derivative = cell(size(y.variable));
        y = class(y,'cada');
    elseif isa(varargin{1},'cada')
        if size(varargin{1}.function,1) > 1 && size(varargin{1}.function,2) > 1
            error('input must be a scaler or vector.');
        end
        Mrow = str2double(varargin{1}.function{1,1});
        Ncol = varargin{2};
        y.variable = varargin{1}.variable;
        y.function = cadanum2str(ones(Mrow,Ncol));
        y.derivative = cell(size(y.variable));
        y = class(y,'cada');
    elseif isa(varargin{2},'cada')
        if size(varargin{2}.function,1) > 1 && size(varargin{2}.function,2) > 1
            error('input must be a scaler or vector.');
        end
        Ncol = str2double(varargin{2}.function{1,1});
        Mrow = varargin{1};
        y.variable = varargin{2}.variable;
        y.function = cadanum2str(ones(Mrow,Ncol));
        y.derivative = cell(size(y.variable));
        y = class(y,'cada');
    end
else
    error('cada can only be used with 2 dimentions.');
end