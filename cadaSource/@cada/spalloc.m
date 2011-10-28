function y = spalloc(m,n,nzmax)
%CADA overloaded operation for spalloc
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
fid = GLOBALCADA.FID;
if isa(m,'cada')
    y.variable = m.variable;
    NUMvar = size(y.variable,1);
    if isnumeric(m.function{1})
        m = m.function{1};
    else
        error('Spalloc may only be used with numeric CADA objects.')
    end
    if isa(n,'cada')
        if isnumeric(n.function{1})
            n = n.function{1};
        else
            error('Spalloc may only be used with numeric CADA objects.')
        end
        if isa(nzmax,'cada')
            if isnumeric(nzmax.function{1})
                nzmax = nzmax.function{1};
            else
                error('Spalloc may only be used with numeric CADA objects.')
            end
        end
    elseif isa(nzmax,'cada')
        if isnumeric(nzmax.function{1})
            nzmax = nzmax.function{1};
        else
            error('Spalloc may only be used with numeric CADA objects.')
        end
    end
elseif isa(n,'cada')
    y.variable = n.variable;
    NUMvar = size(y.variable,1);
    if isnumeric(n.function{1})
        n = n.function{1};
    else
        error('Spalloc may only be used with numeric CADA objects.')
    end
    if isa(nzmax,'cada')
        if isnumeric(nzmax.function{1})
            nzmax = nzmax.function{1};
        else
            error('Spalloc may only be used with numeric CADA objects.')
        end
    end
elseif isa(nzmax,'cada')
    y.variable = nzmax.variable;
    NUMvar = size(y.variable,1);
    if isnumeric(nzmax.function{1})
        nzmax = nzmax.function{1};
    else
        error('Spalloc may only be used with numeric CADA objects.')
    end
end

if numel(m) > 1 || numel(n) > 1 || numel(nzmax) > 1
    error('Sparse matrix sizes must be non-negative integers less than MAXSIZE as defined by COMPUTER.')
end
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);

fprintf(fid,['cadaf',OPstr,'f = spalloc(',int2str(m),',',int2str(n),',',int2str(nzmax),');\n']);
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;

y.function = cell(1,3);
y.function{1} = ['cadaf',OPstr,'f'];
y.function{2} = [m,n];
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1:2) = GLOBALCADA.LINECOUNT;

y.derivative = cell(NUMvar,2);

GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');