function y = subsref(x,s)
%CADA overloaded operation for subsref
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA;
ssize = length(s);
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;

for scount = 1:ssize;
    if strcmp(s(scount).type,'()')
        if scount == 1
            if isnumeric(x.function{1}) %x is numeric cada
                y.variable = x.variable;
                y.function = cell(1,3);
                y.function{1} = subsref(x.function{1},s);
                y.function{2} = size(y.function{1});
                y.derivative = x.derivative;
                y = class(y,'cada');
                return
            end
            NUMvar = size(x.variable,1);
            y.variable = x.variable;
            if size(s.subs,2) == 1 % x is non-numeric index referencing
                if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':'
                    if x.function{2}(2) == 1
                        y = x;
                        return
                    else
                        y = reshape(x,x.function{2}(1)*x.function{2}(2),1);
                        return
                    end
                else
                    fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},'(']);
                    cadaindprint(s.subs{1,1},fid);
                    fprintf(fid,');\n');
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                end
                
            else
                % x is non-numeric, subs indexing
                if ~isnumeric(s.subs{1,1}) && s.subs{1,1} == ':';
                    if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':';
                        y = x;
                        return
                    else
                        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},'(:,']);
                        cadaindprint(s.subs{1,2},fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                    end
                else
                    if ~isnumeric(s.subs{1,2}) && s.subs{1,2} == ':';
                        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},'(']);
                        cadaindprint(s.subs{1,1},fid);
                        fprintf(fid,',:);\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                    else
                        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},'(']);
                        cadaindprint(s.subs{1,1},fid);
                        fprintf(fid,',');
                        cadaindprint(s.subs{1,2},fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                    end
                end
            end
            
            ytemp = zeros(x.function{2});
            ytemp(:) = 1:(x.function{2}(1)*x.function{2}(2));
            ytemp = ytemp(s(scount).subs{:});
            isubs = ytemp(:);
            [FMrow, FNcol] = size(ytemp);
            
            y.function = cell(1,3);
            y.function{1} = ['cadaf',OPstr,'f'];
            y.function{2} = [FMrow,FNcol];
            y.function{3} = GLOBALCADA.OPERATIONCOUNT;
            GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;
            
            y.derivative = cell(NUMvar,3);
            for Vcount = 1:NUMvar;
                if ~isempty(x.derivative{Vcount,1})
                    derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                    y.derivative{Vcount,1} = derivstr;
                    nzx = size(x.derivative{Vcount,2},1);
                    dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),(1:nzx)',...
                        x.function{2}(1)*x.function{2}(2),x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2));
                    [yrows,ycols,yind] = find(dx(isubs,:));
                    if size(yrows,2) > 1
                        yrows = yrows';
                        ycols = ycols';
                    end
                    y.derivative{Vcount,2} = [yrows,ycols];
                    if ~isempty(yind)
                        fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},'(']);
                        cadaindprint(yind,fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                    else
                        y.derivative{Vcount,1} = [];
                    end
                end
            end
            GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
            if ~isempty(x.function{3})
                GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
            end
            GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
            y = class(y,'cada');
        else
            y =  y(s(scount).subs{:});
        end
    elseif strcmp(s(scount).type,'.')
        if strcmp(s(scount).subs,'variable')
            y = x.variable;
        elseif strcmp(s(scount).subs,'function')
            y = x.function;
        elseif strcmp(s(scount).subs,'derivative')
            y = x.derivative;
        else
            error('invalid subscript reference for CADA')
        end
    elseif strcmp(s(scount).type,'{}')
        if scount == 1
            error('invalid index reference for CADA')
        else
            y = y{s(scount).subs{:}};
        end
    else
        error('invalid index reference for CADA')
    end
end