function z = cadamtimes(x,y)
% cada cadamtimes function
% created by Michael Patterson

if isa(x,'cada') && isa(y,'cada') % x and y are cada -------------
    [xNrow, xMcol] = size(x.function);
    [yNrow, yMcol] = size(y.function);
    if (xNrow == 1 && xMcol == 1)
        z = x.*y;
    elseif (yNrow == 1 && yMcol == 1)
        z = x.*y;
    elseif xMcol == yNrow
        z = zeros(size(x,1), size(y,2));
        s1.type = '()';
        s2.type = '()';
        ss.type = '()';
        for FIcount = 1:xNrow;
            for FJcount = 1:yMcol;
                s1.subs = {FIcount, ':'};
                s2.subs = {':', FJcount};
                ss.subs = {FIcount, FJcount};
                b = sum(subsref(x,s1).*subsref(y,s2).',2);
                z = subsasgn(z,ss,b);
            end
        end
    else
        error('Inputs are not of compatible sizes');
    end    
elseif isa(x,'cada') % x is cada ------------------------------------
    [xNrow, xMcol] = size(x.function);
    [yNrow, yMcol] = size(y);
    if (xNrow == 1 && xMcol == 1)
        z = x.*y;
    elseif (yNrow == 1 && yMcol == 1)
        z = x.*y;
    elseif xMcol == yNrow
        z = zeros(size(x,1), size(y,2));
        s1.type = '()';
        ss.type = '()';
        for FIcount = 1:xNrow;
            for FJcount = 1:yMcol;
                s1.subs = {FIcount, ':'};
                ss.subs = {FIcount, FJcount};
                b = sum(subsref(x,s1).*y(:,FJcount).',2);
                z = subsasgn(z,ss,b);
            end
        end
    else
        error('Inputs are not of compatible sizes');
    end
elseif isa(y,'cada') % y is cada ------------------------------------
    [xNrow, xMcol] = size(x);
    [yNrow, yMcol] = size(y.function);
    if (xNrow == 1 && xMcol == 1)
        z = x.*y;
    elseif (yNrow == 1 && yMcol == 1)
        z = x.*y;
    elseif xMcol == yNrow
        z = zeros(size(x,1), size(y,2));
        s2.type = '()';
        ss.type = '()';
        for FIcount = 1:xNrow;
            for FJcount = 1:yMcol;
                s2.subs = {':', FJcount};
                ss.subs = {FIcount, FJcount};
                b = sum(x(FIcount,:).*subsref(y,s2).',2);
                z = subsasgn(z,ss,b);
            end
        end
    else
        error('Inputs are not of compatible sizes');
    end
end
