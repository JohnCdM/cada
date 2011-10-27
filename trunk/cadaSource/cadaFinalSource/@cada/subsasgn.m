function y = subsasgn(x,s,b)
%CADA overloaded operation for subsasgn
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;

ssize = length(s);
if ssize > 1 || ~strcmp(s(1).type,'()')
    error('Inncorrect subsasgn method for type cada');
end

if isa(b,'cada')
    if isnumeric(x.function{1}) && isnumeric(b.function{1})
        y.variable = x.variable;
        y.function = cell(1,3);
        y.function{1} = subsasgn(x.function{1},s,b.function{1});
        y.function{2} = size(y.function{1});
        y.function{3} = x.function{3};
        y.derivative = x.derivative;
        y = class(y,'cada');
        return
    elseif isnumeric(b.function{1})
        b = b.function{1};
    else
        xMrow = x.function{2}(1);
        xNcol = x.function{2}(2);
        bMrow = b.function{2}(1);
        bNcol = b.function{2}(2);
        
        %check if b is scalar
        if bMrow == 1 && bNcol == 1 && (length(s.subs{1,1}) > 1 || (size(s.subs,2)==2 && length(s.subs{1,2}) > 1))
            b = repmat(b,length(s.subs{1,1}),length(s.subs{1,2}));
            OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        end
        NUMvar = size(b.variable,1);
        y.variable = b.variable;
        
        if isnumeric(x.function{1})
            %x is numeric cada, b is non-numeric---------------------------------------
            if size(s.subs,2) == 1
                if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':'
                    if bMrow == 1 && bNcol == 1
                        y = repmat(b,xMrow,xNcol);
                    else
                        y = reshape(b,xMrow,xNcol);
                        return
                    end
                end
            end
            if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':'
                if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':'
                    y = b;
                    return
                end
            end
            %print numerical values of x
            fprintf(fid,['cadaf',OPstr,'f = zeros(',int2str(xMrow),',',int2str(xNcol),',cadaunit);\n']);
            GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
            if x.function{1} ~= zeros(xMrow,xNcol);
                fprintf(fid,['cadaf',OPstr,'f(:) = [']);
                for Jcount = 1:xNcol
                    for Icount = 1:xMrow
                        fprintf(fid,[num2str(x.function{1}(Icount,Jcount),16),' ']);
                    end
                end
                fprintf(fid,'];\n');
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
            end
            
            %print function
            if size(s.subs,2) == 1
                fprintf(fid,['cadaf',OPstr,'f(']);
                cadaindprint(s.subs{1,1},fid);
                fprintf(fid,[') = ',b.function{1},';\n']);
            else
                if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':';
                    fprintf(fid,['cadaf',OPstr,'f(:,']);
                    cadaindprint(s.subs{1,2},fid);
                    fprintf(fid,[') = ',b.function{1},';\n']);
                else
                    if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':';
                        fprintf(fid,['cadaf',OPstr,'f(']);
                        cadaindprint(s.subs{1,1},fid);
                        fprintf(fid,[',:) = ',b.function{1},';\n']);
                    else
                        fprintf(fid,['cadaf',OPstr,'f(']);
                        cadaindprint(s.subs{1,1},fid);
                        fprintf(fid,',');
                        cadaindprint(s.subs{1,2},fid);
                        fprintf(fid,[') = ',b.function{1},';\n']);
                    end
                end
            end
            GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        else
            %x and b are non-numeric cada----------------------------------
            %print function
            if size(s.subs,2) == 1
                if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':'
                    y = repmat(b,x.function{2});
                    return
                else
                    fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
                    fprintf(fid,['cadaf',OPstr,'f(']);
                    cadaindprint(s.subs{1,1},fid);
                    fprintf(fid,[') = ',b.function{1},';\n']);
                end
            else
                if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':';
                    if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':';
                        y = b;
                        return
                    else
                        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
                        fprintf(fid,['cadaf',OPstr,'f(:,']);
                        cadaindprint(s.subs{1,2},fid);
                        fprintf(fid,[') = ',b.function{1},';\n']);
                    end
                else
                    if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':';
                        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
                        fprintf(fid,['cadaf',OPstr,'f(']);
                        cadaindprint(s.subs{1,1},fid);
                        fprintf(fid,[',:) = ',b.function{1},';\n']);
                    else
                        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
                        fprintf(fid,['cadaf',OPstr,'f(']);
                        cadaindprint(s.subs{1,1},fid);
                        fprintf(fid,',');
                        cadaindprint(s.subs{1,2},fid);
                        fprintf(fid,[') = ',b.function{1},';\n']);
                    end
                end
            end
            GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
        end
        %build function property
        ytemp = zeros(x.function{2});
        btemp = zeros(b.function{2});
        ytemp(s.subs{:}) = btemp;
        [FMrow, FNcol] = size(ytemp);
        ytemp = zeros(x.function{2});
        ytemp(:) = (1:FMrow*FNcol)';
        ytemp = ytemp(s.subs{:});
        isubs = ytemp(:);
        insubs = 1:FMrow*FNcol;
        insubs(isubs) = 0;
        insubs = nonzeros(insubs);
        y.function = cell(1,3);
        y.function{1} = ['cadaf',OPstr,'f'];
        y.function{2} = [FMrow,FNcol];
        y.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT-1;
        
        %build derivative property
        y.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1}) && ~isempty(b.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                y.derivative{Vcount,1} = derivstr;
                nzx = size(x.derivative{Vcount,2},1);
                nzb = size(b.derivative{Vcount,2},1);
                nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                xrows = x.derivative{Vcount,2}(:,1);
                xcols = x.derivative{Vcount,2}(:,2);
                brows = b.derivative{Vcount,2}(:,1);
                bcols = b.derivative{Vcount,2}(:,2);
                brows = isubs(brows);
                if size(brows,2) > 1
                    brows = brows';
                end
                dx = sparse(xrows,xcols,(1:nzx)',FMrow*FNcol,nv);
                xindin = nonzeros(dx(insubs,:));
                if ~isempty(xindin)
                    dy = sparse([xrows;brows],[xcols;bcols],ones(nzx+nzb,1),FMrow*FNcol,nv);
                    diffref = nonzeros(dx(isubs,:));
                    xdiffr = xrows(diffref);
                    xdiffc = xcols(diffref);
                    xdiff = sparse(xdiffr,xdiffc,ones(numel(xdiffr),1),FMrow*FNcol,nv);
                    dy = dy-xdiff;
                    nzy = nnz(dy);
                    [yrows,ycols] = find(dy);
                    if size(yrows,2) > 1
                        yrows = yrows';
                        ycols = ycols';
                    end
                    y.derivative{Vcount,2} = [yrows,ycols];
                    dy = sparse(yrows,ycols,(1:nzy)',FMrow*FNcol,nv);
                    xindout = nonzeros(dy(insubs,:));
                    bindout = nonzeros(dy(isubs,:));
                    fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                    fprintf(fid,[derivstr,'(']);
                    cadaindprint(xindout,fid);
                    fprintf(fid,[') = ',x.derivative{Vcount,1},'(']);
                    cadaindprint(xindin,fid);
                    fprintf(fid,[');\n',derivstr,'(']);
                    cadaindprint(bindout,fid);
                    fprintf(fid,[') = ',b.derivative{Vcount,1},';\n']);
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT + 3;
                else
                    dy = sparse(brows,bcols,ones(nzb,1),FMrow*FNcol,nv);
                    [yrows,ycols] = find(dy);
                    if size(yrows,2) > 1
                        yrows = yrows';
                        ycols = ycols';
                    end
                    y.derivative{Vcount,2} = [yrows,ycols];
                    fprintf(fid,[derivstr,' = ',b.derivative{Vcount,1},';\n']);
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT + 1;
                end
            elseif ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                y.derivative{Vcount,1} = derivstr;
                nzx = size(x.derivative{Vcount,2},1);
                nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                xrows = x.derivative{Vcount,2}(:,1);
                xcols = x.derivative{Vcount,2}(:,2);
                dx = sparse(xrows,xcols,(1:nzx)',FMrow*FNcol,nv);
                diffref = nonzeros(dx(isubs,:));
                if ~isempty(diffref)
                    xdiffr = xrows(diffref);
                    xdiffc = xcols(diffref);
                    dy = sparse([xrows;xdiffr],[xcols;xdiffc],[ones(nzx,1);-ones(numel(xdiffr),1)],FMrow*FNcol,nv);
                    xind = nonzeros(dy(insubs,:));
                    [yrows,ycols] = find(dy);
                    if size(yrows,2) > 1
                        yrows = yrows';
                        ycols = ycols';
                    end
                    y.derivative{Vcount,2} = [yrows,ycols];
                    fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},'(']);
                    cadaindprint(xind,fid);
                    fprintf(fid,');\n');
                else
                    y.derivative{Vcount,2} = x.derivative{Vcount,2};
                    fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},';\n']);
                end
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT + 1;
            elseif ~isempty(b.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'d',x.variable{Vcount,1}];
                y.derivative{Vcount,1} = derivstr;
                brows = b.derivative{Vcount,2}(:,1);
                bcols = b.derivative{Vcount,2}(:,2);
                brows = isubs(brows);
                if size(brows,2) > 1
                    brows = brows';
                end
                y.derivative{Vcount,2} = [brows,bcols];
                fprintf(fid,[derivstr,' = ',b.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
            end
        end
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.FUNCTIONLOCATION(b.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
        y = class(y,'cada');
        return
    end
end

% x is cada, b is numeric -------------------------------------------------
xMrow = x.function{2}(1);
xNcol = x.function{2}(2);
bMrow = size(b,1);
bNcol = size(b,2);
if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,3);
    y.function{1} = subsasgn(x.function{1},s,b);
    y.function{2} = size(y.function{1});
    y.function{3} = x.function{3};
    y.derivative = x.derivative;
    y = class(y,'cada');
    return
end

NUMvar = size(x.variable,1);
y.variable = x.variable;
if s.subs{1,1} == ':'
    if size(s.subs,2) == 1
        y.function = cell(1,3);
        if bMrow == 1 && bNcol == 1
            y.function{1} = repmat(b,xMrow,xNcol);
        else
            y.function{1} = reshape(b,x.function{2});
        end
        y.function{2} = size(y.function{1});
        y.function{3} = x.function{3};
        y.derivative = cell(size(y.variable,1),3);
        y = class(y,'cada');
        return
    elseif s.subs{1,2} == ':'
        y.function = cell(1,3);
        y.function{1} = b;
        y.function{2} = size(y.function{1});
        y.function{3} = x.function{3};
        y.derivative = cell(size(y.variable,1),3);
        y = class(y,'cada');
        return
    end
end

%print out b
if bMrow == 1 && bNcol == 1
    fprintf(fid,['cadatf1 =',num2str(b,16),';\n']);
    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
else
    cadamatprint(fid,b,'cadatf1')
end

if size(s.subs,2) == 1
    fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
    fprintf(fid,['cadaf',OPstr,'f(']);
    cadaindprint(s.subs{1,1},fid);
    fprintf(fid,') = cadatf1;\n');
else
    if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':';
        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
        fprintf(fid,['cadaf',OPstr,'f(:,']);
        cadaindprint(s.subs{1,2},fid);
        fprintf(fid,') = cadatf1;\n');
    else
        if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':';
            fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
            fprintf(fid,['cadaf',OPstr,'f(']);
            cadaindprint(s.subs{1,1},fid);
            fprintf(fid,',:) = cadatf1;\n');
        else
            fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},';\n']);
            fprintf(fid,['cadaf',OPstr,'f(']);
            cadaindprint(s.subs{1,1},fid);
            fprintf(fid,',');
            cadaindprint(s.subs{1,2},fid);
            fprintf(fid,') = cadatf1;\n');
        end
    end
end
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;

%build function property
ytemp = zeros(x.function{2});
ytemp(s.subs{:}) = b;
[FMrow, FNcol] = size(ytemp);
ytemp = zeros(x.function{2});
ytemp(:) = (1:FMrow*FNcol)';
ytemp = ytemp(s.subs{:});
isubs = ytemp(:);
insubs = 1:FMrow*FNcol;
insubs(isubs) = 0;
insubs = nonzeros(insubs);
y.function = cell(1,3);
y.function{1} = ['cadaf',OPstr,'f'];
y.function{2} = [FMrow,FNcol];
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT-1;

%build derivative property
y.derivative = cell(NUMvar,2);
for Vcount = 1:NUMvar;
    if ~isempty(x.derivative{Vcount,1})
        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
        y.derivative{Vcount,1} = derivstr;
        nzx = size(x.derivative{Vcount,2},1);
        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
        xrows = x.derivative{Vcount,2}(:,1);
        xcols = x.derivative{Vcount,2}(:,2);
        dx = sparse(xrows,xcols,(1:nzx)',FMrow*FNcol,nv);
        diffref = nonzeros(dx(isubs,:));
        if ~isempty(diffref)
            xdiffr = xrows(diffref);
            xdiffc = xcols(diffref);
            dy = sparse([xrows;xdiffr],[xcols;xdiffc],[ones(nzx,1);-ones(numel(xdiffr),1)],FMrow*FNcol,nv);
            xind = nonzeros(dy(insubs,:));
            [yrows,ycols] = find(dy);
            if size(yrows,2) > 1
                yrows = yrows';
                ycols = ycols';
            end
            y.derivative{Vcount,2} = [yrows,ycols];
            fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},'(']);
            cadaindprint(xind,fid);
            fprintf(fid,');\n');
        else
            y.derivative{Vcount,2} = x.derivative{Vcount,2};
            fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},';\n']);
        end
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT + 1;
    end
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');