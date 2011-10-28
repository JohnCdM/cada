function y = horzcat(varargin)
%CADA overloaded operation for horzcat
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao
global GLOBALCADA
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;

NUMinput = size(varargin,2);
xNcols = zeros(1,NUMinput);
Fstr = cell(1,NUMinput);
nzd = cell(1,NUMinput);
if isa(varargin{1},'cada')
    xMrow = varargin{1}.function{2}(1);
    xNcols(1) = varargin{1}.function{2}(2);
    y.variable = varargin{1}.variable;
    y.function = cell(1,3);
    y.function{3} = varargin{1}.function{3};
    NUMvar = size(y.variable,1);
    Fstr{1} = varargin{1}.function{1};
    if ~isnumeric(varargin{1}.function{1})
        nzd{1} = zeros(NUMvar,1);
        nzt = zeros(NUMvar,1);
        for Vcount = 1:NUMvar
            if ~isempty(varargin{1}.derivative{Vcount,1})
                nzt(Vcount) = size(varargin{1}.derivative{Vcount,2},1);
                nzd{1}(Vcount) = nzt(Vcount);
            end
        end
    end
else
    xMrow = size(varargin{1},1);
    xNcols(1) = size(varargin{1},2);
    Fstr{1,1} = varargin{1};
    y.variable = [ ];
    y.function = cell(1,3);
end
%find cada objects, for non-cada objects, write out a temp variable
for incount = 2:NUMinput
    if isa(varargin{incount},'cada')
        if varargin{incount}.function{2}(1) ~= xMrow
            error('CAT arguments dimensions are not consistent.');
        end
        xNcols(incount) = varargin{incount}.function{2}(2);
        y.variable = varargin{incount}.variable;
        NUMvar = size(y.variable,1);
        Fstr{1,incount} = varargin{incount}.function{1};
        if ~isnumeric(varargin{incount}.function{1})
            nzd{incount} = zeros(NUMvar,1);
            if ~exist('nzt','var')
                nzt = zeros(NUMvar,1);
            end
            for Vcount = 1:NUMvar
                if ~isempty(varargin{incount}.derivative{Vcount,1})
                    nzd{incount}(Vcount) = size(varargin{incount}.derivative{Vcount,2},1);
                    nzt(Vcount) = nzt(Vcount,1) + nzd{incount}(Vcount);
                end
            end
        end
    else
        if size(varargin{incount},1) ~= xMrow
            error('CAT arguments dimensions are not consistent.');
        end
        xNcols(incount) = size(varargin{incount},2);
        Fstr{1,incount} = varargin{incount};
    end
end

%if all numeric
if ~exist('nzt','var')
    y.function = cell(1,3);
    y.function{1} = horzcat(Fstr{:});
    y.function{2} = size(y.function{1});
    y.derivative = cell(NUMvar,2);
    y = class(y,'cada');
    return
end
% check for numeric entries, create temporary variable
TVcount = 1;
for incount = 1:NUMinput
    if isempty(nzd{1,incount})
        cadamatprint(fid,Fstr{incount},['cadatf',int2str(TVcount)])
        Fstr{1,incount} = ['cadatf',int2str(TVcount)];
        TVcount = TVcount+1;
    end
end
% print out function
fprintf(fid,['cadaf',OPstr,'f = horzcat(']);
for incount = 1:NUMinput
    if incount ~= NUMinput
        fprintf(fid,[Fstr{1,incount},',']);
    else
        fprintf(fid,[Fstr{1,incount},');\n']);
    end
end
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
FMrow = xMrow;
FNcol = sum(xNcols);
y.function{1} = ['cadaf',OPstr,'f'];
y.function{2} = [FMrow,FNcol];
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;

% define derivative property
y.derivative = cell(NUMvar,2);
for Vcount = 1:NUMvar;
    if nzt(Vcount) ~= 0
        derivstr = ['dcadaf',OPstr,'fd',y.variable{Vcount,1}];
        y.derivative{Vcount,1} = derivstr;
        yrows = zeros(nzt(Vcount),1);
        ycols = zeros(nzt(Vcount),1);
        fprintf(fid,[derivstr,' = zeros(',int2str(nzt(Vcount,1)),',cadaunit);\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        for incount = 1:NUMinput
            if ~isempty(nzd{incount})
                if nzd{incount}(Vcount) ~= 0
                    nzy = nnz(yrows);
                    if incount == 1
                        yrows(nzy+1:nzy+nzd{incount}(Vcount)) = varargin{incount}.derivative{Vcount,2}(:,1);
                    else
                        yrows(nzy+1:nzy+nzd{incount}(Vcount)) = varargin{incount}.derivative{Vcount,2}(:,1)+sum(xNcols(1:incount-1))*xMrow;
                    end
                    ycols(nzy+1:nzy+nzd{incount}(Vcount)) = varargin{incount}.derivative{Vcount,2}(:,2);
                end
            end
        end
        nv = y.variable{Vcount,2}(1)*y.variable{Vcount,2}(2);
        dy = sparse(yrows,ycols,(1:nzt(Vcount))',FMrow*FNcol,nv);
        [yrows,ycols] = find(dy);
        if size(yrows,2) > 1
            yrows = yrows';
            ycols = ycols';
        end
        dy = sparse(yrows,ycols,(1:nzt(Vcount))',FMrow*FNcol,nv);
        y.derivative{Vcount,2} = [yrows,ycols];
        for incount = 1:NUMinput
            if ~isempty(nzd{1,incount})
                if nzd{1,incount}(Vcount,1) ~= 0
                    if incount == 1
                        rind = 1:xNcols(1)*xMrow;
                    else
                        rind = (1:xNcols(incount)*xMrow)+sum(xNcols(1:incount-1))*xMrow;
                    end
                    xind = nonzeros(dy(rind(:),:));
                    fprintf(fid,[derivstr,'(']);
                    cadaindprint(xind,fid);
                    fprintf(fid,[') = ',varargin{incount}.derivative{Vcount,1},';\n']);
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                end
            end
        end
    end
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
for incount = 1:NUMinput
    if isa(varargin{incount},'cada')
        GLOBALCADA.FUNCTIONLOCATION(varargin{incount}.function{3},2) = GLOBALCADA.LINECOUNT;
    end
end
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');