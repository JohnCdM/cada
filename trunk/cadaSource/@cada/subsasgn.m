function y = subsasgn(x,s,b)
% CADA subsasgn function
% created by Michael Patterson

ssize = length(s);
if ssize > 1 || ~strcmp(s(1).type,'()')
    error('Inncorrect subsasgn method for type cada');
end

if isa(b,'cada')
    NUMargx = size(x.variable,1);
    NUMargb = size(b.variable,1);
    NUMvar  = max(NUMargx, NUMargb);
    y.variable = cell(NUMvar,2);
    if NUMargx > NUMargb
        b.variable{NUMvar,2}   = [];
        b.derivative{NUMvar,2} = [];
    elseif NUMargx < NUMargb
        x.variable{NUMvar,2}   = [];
        x.derivative{NUMvar,2} = [];
    end
    xarraysize = size(x.function);
    barraysize = size(b.function);
    derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(x.variable{Acount,1}) && ~isempty(b.variable{Acount,1})
            y.variable(Acount,:) = x.variable(Acount,:);
        elseif ~isempty(x.variable{Acount,1})
            y.variable(Acount,:) = x.variable(Acount,:);
        elseif ~isempty(b.variable{Acount,1})
            y.variable(Acount,:) = b.variable(Acount,:);
        end
        if ~isempty(x.derivative{Acount,1}) && ~isempty(b.derivative{Acount,1})
            xarraysize(3) = x.variable{Acount,2}(1);
            xarraysize(4) = x.variable{Acount,2}(2);
            barraysize(3) = xarraysize(3);
            barraysize(4) = xarraysize(4);
            xarrayderivative = cadaind2array(x.derivative{Acount,1}, x.derivative{Acount,2}, xarraysize);
            barrayderivative = cadaind2array(b.derivative{Acount,1}, b.derivative{Acount,2}, barraysize);
            xarrayderivative(s.subs{:},:,:) = barrayderivative;
            [derivative{Acount,1}, derivative{Acount,2}] = cadaarray2ind(xarrayderivative);
        elseif ~isempty(x.derivative{Acount,1})
            xarraysize(3) = x.variable{Acount,2}(1);
            xarraysize(4) = x.variable{Acount,2}(2);
            barraysize(3) = xarraysize(3);
            barraysize(4) = xarraysize(4);
            xarrayderivative = cadaind2array(x.derivative{Acount,1}, x.derivative{Acount,2}, xarraysize);
            barrayderivative = cell(barraysize);
            xarrayderivative(s.subs{:},:,:) = barrayderivative;
            [derivative{Acount,1}, derivative{Acount,2}] = cadaarray2ind(xarrayderivative);
        elseif ~isempty(b.derivative{Acount,1})
            barraysize(3) = b.variable{Acount,2}(1);
            barraysize(4) = b.variable{Acount,2}(2);
            xarraysize(3) = barraysize(3);
            xarraysize(4) = barraysize(4);
            barrayderivative = cadaind2array(b.derivative{Acount,1}, b.derivative{Acount,2}, barraysize);
            xarrayderivative = cell(xarraysize);
            xarrayderivative(s.subs{:},:,:) = barrayderivative;
            [derivative{Acount,1}, derivative{Acount,2}] = cadaarray2ind(xarrayderivative);
        end
    end
    x.function(s.subs{:}) = b.function;
    [FMrow, FNcol] = size(x.function);
    for Mcount = 1: FMrow;
        for Ncount = 1:FNcol;
            if isempty(x.function{Mcount, Ncount})
                x.function{Mcount, Ncount} = '0';
            end
        end
    end
    y.function = x.function;
    y.derivative = derivative;
else
    NUMvar = size(x.variable,1);
    y.variable = x.variable;
    xarraysize = size(x.function);
    barraysize = size(b);
    b = cadanum2str(b); % Convert b to array of converted strings
    derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(x.derivative{Acount,1})
            xarraysize(3) = x.variable{Acount,2}(1);
            xarraysize(4) = x.variable{Acount,2}(2);
            barraysize(3) = xarraysize(3);
            barraysize(4) = xarraysize(4);
            xarrayderivative = cadaind2array(x.derivative{Acount,1}, x.derivative{Acount,2}, xarraysize);
            barrayderivative = cell(barraysize);
            xarrayderivative(s.subs{:},:,:) = barrayderivative;
            [derivative{Acount,1}, derivative{Acount,2}] = cadaarray2ind(xarrayderivative);
        end
    end
    x.function(s.subs{:}) = b;
    [FMrow, FNcol] = size(x.function);
    for Mcount = 1: FMrow;
        for Ncount = 1:FNcol;
            if isempty(x.function{Mcount, Ncount})
                x.function{Mcount, Ncount} = '0';
            end
        end
    end
    y.function = x.function;
    y.derivative = derivative;
end
y = class(y,'cada');