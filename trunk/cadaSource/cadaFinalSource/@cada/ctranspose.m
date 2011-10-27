function y = ctranspose(x)
%CADA overloaded operation for ctranspose
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;
if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,3);
    y.function{1} = ctranspose(x.function{1});
    y.function{2}(1) = x.function{2}(2);
    y.function{2}(2) = x.function{2}(1);
    y.derivative = x.derivative;
    y = class(y,'cada');
    return
end
if x.function{2}(1) == 1 && x.function{2}(2) == 1
    y = x;
    return
end

NUMvar     = size(x.variable,1);
y.variable = x.variable;

fprintf(fid,['cadaf',OPstr,'f = ctranspose(',x.function{1},');\n']);
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;

y.function = cell(1,3);
y.function{1} = ['cadaf',OPstr,'f'];
FMrow = x.function{2}(2);
FNcol = x.function{2}(1);
y.function{2} = [FMrow, FNcol];
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;
findices = zeros(FNcol,FMrow);
findices(:) = 1:FMrow*FNcol;
findices = findices';

y.derivative = cell(NUMvar,3);
for Vcount = 1:NUMvar;
    if ~isempty(x.derivative{Vcount,1})
        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
        y.derivative{Vcount,1} = derivstr;
        if FMrow == 1 || FNcol == 1
            fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},';\n']);
            y.derivative{Vcount,2} = x.derivative{Vcount,2};
        else
            nzx = size(x.derivative{Vcount,2},1);
            nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
            dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),(1:nzx)',FMrow*FNcol,nv);
            [yrows,ycols,yind] = find(dx(findices(:)',:));
            if size(yrows,2) > 1
                yrows = yrows';
                ycols = ycols';
            end
            y.derivative{Vcount,2} = [yrows,ycols];
            fprintf(fid,[derivstr,' = ',x.derivative{Vcount,1},'(']);
            cadaindprint(yind,fid);
            fprintf(fid,');\n');
        end
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
    end
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');