function y = repmat(x,varargin)
%CADA overloaded operation for repmat
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
OPstr = num2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;
varargSize = length(varargin);
if varargSize == 0 ;
    error('Requires at least 2 inputs.');
elseif varargSize == 1
    if length(varargin{1}) > 2
        error('CADA can only be used with 2 dimensions.');
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
if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,2);
    y.function{1} = repmat(x.function{1},varargin{1});
    y.function{2} = size(y.function{1});
    y.derivative = x.derivative;
    y = class(y,'cada');
    return
end
y.variable = x.variable;
NUMvar = size(x.variable,1);
xMrow = x.function{2}(1);
xNcol = x.function{2}(2);
FMrow = xMrow*repMrow;
FNcol = xNcol*repNcol;
findices = zeros(xMrow,xNcol);
findices(:) = 1:xMrow*xNcol;
findices = repmat(findices,repMrow,repNcol);


% build y function
fprintf(fid,['cadaf',OPstr,'f = repmat(',x.function{1},',',int2str(repMrow),',',int2str(repNcol),');\n']);
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;

y.function = cell(1,3);
y.function{1} = ['cadaf',OPstr,'f'];
y.function{2} = [FMrow, FNcol];
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;

% build derivative
y.derivative = cell(NUMvar,2);
for Vcount = 1:NUMvar;
    if ~isempty(x.derivative{Vcount,1})
        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
        y.derivative{Vcount,1} = derivstr;
        nzx = size(x.derivative{Vcount,2},1);
        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
        dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),(1:nzx)',xMrow*xNcol,nv);
        [yrows,ycols,yind] = find(dx(findices(:)',:));
        if size(yrows,2) > 1
            yrows =  yrows';
            ycols = ycols';
        end
        y.derivative{Vcount,2} = [yrows,ycols];
        fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},'(']);
        cadaindprint(yind,fid);
        fprintf(fid,');\n');
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
    end
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');