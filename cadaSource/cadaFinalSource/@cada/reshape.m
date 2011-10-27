function y = reshape(x,varargin)
%CADA overloaded operation for reshape
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;
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
    
elseif varargSize == 2
    repMrow = varargin{1};
    repNcol = varargin{2};
    if repMrow == 1 && repNcol == 1
        y = x;
        return
    end
else
    error('Too many input arguments.');
end
if repMrow*repNcol ~= x.function{2}(1)*x.function{2}(2)
    error('To RESHAPE the number of elements must not change.')
end
if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,2);
    y.function{1} = reshape(x.function{1},[repMrow,repNcol]);
    y.function{2} = size(y.function{1});
    y.derivative = x.derivative;
    y = class(y,'cada');
    return
end
y.variable = x.variable;
NUMvar = size(x.variable,1);

% build y function
fprintf(fid,['cadaf',OPstr,'f = reshape(',x.function{1},',',int2str(repMrow),',',int2str(repNcol),');\n']);
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;

y.function = cell(1,3);
y.function{1} = ['cadaf',OPstr,'f'];
y.function{2} = [repMrow, repNcol];
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;

%build y deriv
y.derivative = cell(NUMvar,2);
for Vcount = 1:NUMvar;
    if ~isempty(x.derivative{Vcount,1})
        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
        fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},';\n']);
        y.derivative{Vcount,1} = derivstr;
        y.derivative{Vcount,2} = x.derivative{Vcount,2};
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
    end
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');