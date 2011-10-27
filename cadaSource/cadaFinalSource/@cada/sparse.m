function y = sparse(varargin)
%CADA overloaded operation for sparse
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;
if nargin == 1
    y = varargin{1};
    return
elseif nargin == 3
    FMrow = max(varargin{1});
    FNcol = max(varargin{2});
elseif nargin == 5
    x = varargin{3};
    FMrow = varargin{4};
    FNcol = varargin{5};
    if isa(FMrow,'cada')
        if isnumeric(FMrow.function{1}) && numel(FMrow.function{1})==1
            FMrow = FMrow.function{1};
        else
            error('Sparse row size must be scalar numeric CADA object.')
        end
    end
    if isa(FNcol,'cada')
        if isnumeric(FNcol.function{1}) && numel(FNcol.function{1})==1
            FNcol = FNcol.function{1};
        else
            error('Sparse col size must be scalar numeric CADA object.')
        end
    end
    if ~isa(x,'cada')
        y.variable = x.variable;
        y.function = cell(1,3);
        y.function{1} = sparse(varargin{1},varargin{2},x,FMrow,FNcol);
        y.function{2} = [FMrow,FNcol];
        y.derivative = cell(size(y.variable,1),2);
        y = class(y,'cada');
        return
    end
elseif nargin == 6
    x = varargin{3};
    FMrow = varargin{4};
    FNcol = varargin{5};
    NZ = varargin{6};
    if isa(FMrow,'cada')
        if isnumeric(FMrow.function{1}) && numel(FMrow.function{1})==1
            FMrow = FMrow.function{1};
        else
            error('Sparse row size must be scalar numeric CADA object.')
        end
    end
    if isa(FNcol,'cada')
        if isnumeric(FNcol.function{1}) && numel(FNcol.function{1})==1
            FNcol = FNcol.function{1};
        else
            error('Sparse col size must be scalar numeric CADA object.')
        end
    end
    if isa(NZ,'cada')
        if isnumeric(NZ.function{1}) && numel(NZ.function{1})==1
            NZ = NZ.function{1};
        else
            error('Sparse nz input must be scalar numeric CADA object.')
        end
    end
    if ~isa(x,'cada')
        y.variable = x.variable;
        fprintf(fid,'cadatfind1 = ');
        fprintf(sub2ind([FMrow,FNcol],varargin{1},varargin{2}),fid);
        fprintf(fid,[';\n[cadatfind1,cadatfind2] = ind2sub([',int2str(FMrow),',',int2str(FNcol),'],cadatfind1);\n']);
        cadamatprint(fid,x,'cadatf1');
        fprintf(fid,['cadaf',OPstr,'f = sparse(cadatfind1,cadatfind2,cadatf1,',int2str(FMrow),',',int2str(FNcol),',',int2str(NZ),');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+3;
        y.function = cell(1,3);
        y.function{1} = ['cadaf',OPstr,'f'];
        y.function{2} = [FMrow,FNcol];
        y.derivative = cell(size(y.variable,1),2);
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},1:2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
        y = class(y,'cada');
        return
    end
else
    error('Invalid number of inputs.')
end

if isa(x,'cada')
    OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
    yrows = varargin{1};
    ycols = varargin{2};
    nsubs = length(yrows);
    if nsubs ~= length(ycols) || nsubs ~= x.function{2}(1)*x.function{2}(2)
        error('Vectors must be the same lengths.')
    end
    isubs = sub2ind([FMrow,FNcol],yrows,ycols);
    if size(isubs,2) > 1
        isubs = isubs';
    end
    NUMvar = size(x.variable,1);
    y.variable = x.variable;
    if isnumeric(x.function{1})
        y.function = cell(1,3);
        y.function{1} = sparse(varargin{1},varargin{2},x.function{1},FMrow,FNcol);
        y.function{2} = [FMrow,FNcol];
        y.derivative = x.derivative;
        y = class(y,'cada');
        return
    end
    
    fprintf(fid,'cadatfind1 = ');
    cadaindprint(isubs,fid);
    fprintf(fid,[';\n[cadatfind1,cadatfind2] = ind2sub([',int2str(FMrow),',',int2str(FNcol),'],cadatfind1);\n']);
    if nargin == 6
         fprintf(fid,['cadaf',OPstr,'f = sparse(cadatfind1,cadatfind2,',x.function{1},',',int2str(FMrow),',',int2str(FNcol),',',int2str(NZ),');\n']);
    else
        fprintf(fid,['cadaf',OPstr,'f = sparse(cadatfind1,cadatfind2,',x.function{1},',',int2str(FMrow),',',int2str(FNcol),');\n']);
    end
    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT + 3;
    
    y.function = cell(1,3);
    y.function{1} = ['cadaf',OPstr,'f'];
    y.function{2} = [FMrow,FNcol];
    y.function{3} = GLOBALCADA.OPERATIONCOUNT;
    GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;
    
    
    y.derivative = cell(NUMvar,2);
    for Vcount = 1:NUMvar
        if ~isempty(x.derivative{Vcount,1})
            derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
            y.derivative{Vcount,1} = derivstr;
            xrows = x.derivative{Vcount,2}(:,1);
            xcols = x.derivative{Vcount,2}(:,2);
            xrows = isubs(xrows);
            dy = sparse(xrows,xcols,1:nnz(xrows),FMrow*FNcol,x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2));
            [yrows,ycols,yind] = find(dy);
            if size(yrows,2) > 1
                yrows = yrows';
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
    if ~isempty(x.function{3})
        GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
    end
    GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
    y = class(y,'cada');
else
    error('Third input to cada sparse must be cada object');
end
