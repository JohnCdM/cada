function y = colon(varargin)
%CADA overloaded operation for colon
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

if nargin == 2
    if isa(varargin{1},'cada')
        if isnumeric(varargin{1}.function{1})
            J = varargin{1}.function{1};
        else
            error('colon may only be used with numeric CADA objects')
        end
    else
        J = varargin{1};
    end
    if isa(varargin{2},'cada')
        if isnumeric(varargin{2}.function{1})
            K = varargin{2}.function{1};
        else
            error('colon may only be used with numeric CADA objects')
        end
    else
        K = varargin{2};
    end
    y = J:K;
elseif nargin == 3
    if isa(varargin{1},'cada')
        if isnumeric(varargin{1}.function{1})
            J = varargin{1}.function{1};
        else
            error('colon may only be used with numeric CADA objects')
        end
    else
        J = varargin{1};
    end
    if isa(varargin{2},'cada')
        if isnumeric(varargin{2}.function{1})
            D = varargin{2}.function{1};
        else
            error('colon may only be used with numeric CADA objects')
        end
    else
        D = varargin{2};
    end
    if isa(varargin{3},'cada')
        if isnumeric(varargin{3}.function{1})
            K = varargin{3}.function{1};
        else
            error('colon may only be used with numeric CADA objects')
        end
    else
        K = varargin{3};
    end
    y = J:D:K;
else
    error('Not enough input arguments.')
end