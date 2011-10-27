function z = times(x,y)
% CADA times function
% created by Michael Patterson

if isa(x,'cada') && isa(y,'cada') % x and y are cada -------------
    NUMargx = size(x.variable,1);
    NUMargy = size(y.variable,1);
    NUMvar  = max(NUMargx, NUMargy);
    z.variable = cell(NUMvar,2);
    if NUMargx > NUMargy
        y.variable{NUMvar,2}   = [];
        y.derivative{NUMvar,2} = [];
    elseif NUMargx < NUMargy
        x.variable{NUMvar,2}   = [];
        x.derivative{NUMvar,2} = [];
    end
    
    [xNrow, xMcol] = size(x.function);
    [yNrow, yMcol] = size(y.function);
    if (xNrow == yNrow && xMcol == yMcol)
        FNrow = yNrow;
        FMcol = yMcol;
    elseif (xNrow == 1 && xMcol == 1)
        FNrow = yNrow;
        FMcol = yMcol;
        x     = repmat(x,yNrow,yMcol);
    elseif (yNrow == 1 && yMcol == 1)
        FNrow = xNrow;
        FMcol = xMcol;
        y     = repmat(y,xNrow,xMcol);
    else
        error('Inputs are not of compatible sizes');
    end
    
    % build function property
    z.function = cell(FNrow,FMcol);
    for FIcount = 1:FNrow
        for FJcount = 1:FMcol;
            z.function{FIcount,FJcount} = ['(',x.function{FIcount,FJcount},').*(',y.function{FIcount,FJcount},')'];
        end
    end
    
    % build derivative property
    z.derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(x.variable{Acount,1}) && ~isempty(y.variable{Acount,1})
            z.variable(Acount,:) = x.variable(Acount,:);
        elseif ~isempty(x.variable{Acount,1})
            z.variable(Acount,:) = x.variable(Acount,:);
        elseif ~isempty(y.variable{Acount,1})
            z.variable(Acount,:) = y.variable(Acount,:);
        end
        if ~isempty(x.derivative{Acount,1}) && ~isempty(y.derivative{Acount,1})
            [uderivative, uindices]  = cadaunion(x.derivative{Acount,1}, x.derivative{Acount,2}, y.derivative{Acount,1}, y.derivative{Acount,2});
            unz = size(uderivative,1);
            z.derivative{Acount,1} = cell(unz,1);
            for Dcount = 1:unz;
                FI = uindices(Dcount,1);
                FJ = uindices(Dcount,2);
                if ~isempty(uderivative{Dcount,1}) && ~isempty(uderivative{Dcount,2})
                    % rep x, y
                    if strcmp(uderivative{Dcount,1},'1')
                        LS = y.function{FI,FJ};
                    elseif strcmp(uderivative{Dcount,1},'-1')
                        LS = ['-(',y.function{FI,FJ},')'];
                    else
                        LS = ['(',uderivative{Dcount,1},').*(',y.function{FI,FJ},')'];
                    end
                    if strcmp(uderivative{Dcount,2},'1') || strcmp(uderivative{Dcount,2},'-1')
                        RS = x.function{FI,FJ};
                    else
                        RS = ['(',x.function{FI,FJ},').*(',uderivative{Dcount,2},')'];
                    end
                    if strcmp(uderivative{Dcount,2},'-1')
                        z.derivative{Acount,1}{Dcount,1} = [LS,' - (',RS,')'];
                    else
                        z.derivative{Acount,1}{Dcount,1} = [LS,' + ',RS];
                    end
                elseif ~isempty(uderivative{Dcount,1})
                    % rep x
                    if strcmp(uderivative{Dcount,1},'1')
                        z.derivative{Acount,1}{Dcount,1} = y.function{FI,FJ};
                    elseif strcmp(uderivative{Dcount,1},'-1')
                        z.derivative{Acount,1}{Dcount,1} = ['-(',y.function{FI,FJ},')'];
                    else
                        z.derivative{Acount,1}{Dcount,1} = ['(',uderivative{Dcount,1},').*(',y.function{FI,FJ},')'];
                    end
                elseif ~isempty(uderivative{Dcount,2})
                    % rep y
                    if strcmp(uderivative{Dcount,2},'1')
                        z.derivative{Acount,1}{Dcount,1} = x.function{FI,FJ};
                    elseif strcmp(uderivative{Dcount,2},'-1')
                        z.derivative{Acount,1}{Dcount,1} = ['-(',x.function{FI,FJ},')'];
                    else
                        z.derivative{Acount,1}{Dcount,1} = ['(',x.function{FI,FJ},').*(',uderivative{Dcount,2},')'];
                    end
                end
            end
            z.derivative{Acount,2} = uindices;
        elseif ~isempty(x.derivative{Acount,1})
            nz = size(x.derivative{Acount,1},1);
            z.derivative{Acount,1} = cell(nz,1);
            for Dcount = 1:nz;
                % rep x
                FI = x.derivative{Acount,2}(Dcount,1);
                FJ = x.derivative{Acount,2}(Dcount,2);
                if strcmp(x.derivative{Acount,1}{Dcount,1},'1')
                    z.derivative{Acount,1}{Dcount,1} = y.function{FI,FJ};
                elseif strcmp(x.derivative{Acount,1}{Dcount,1},'-1')
                    z.derivative{Acount,1}{Dcount,1} = ['-(',y.function{FI,FJ},')'];
                else
                    z.derivative{Acount,1}{Dcount,1} = ['(',x.derivative{Acount,1}{Dcount,1},').*(',y.function{FI,FJ},')'];
                end
            end
            z.derivative{Acount,2} = x.derivative{Acount,2};
        elseif ~isempty(y.derivative{Acount,1})
            nz = size(y.derivative{Acount,1},1);
            z.derivative{Acount,1} = cell(nz,1);
            for Dcount = 1:nz;
                % rep y
                FI = y.derivative{Acount,2}(Dcount,1);
                FJ = y.derivative{Acount,2}(Dcount,2);
                if strcmp(y.derivative{Acount,1}{Dcount,1},'1')
                    z.derivative{Acount,1}{Dcount,1} = x.function{FI,FJ};
                elseif strcmp(y.derivative{Acount,1}{Dcount,1},'-1')
                    z.derivative{Acount,1}{Dcount,1} = ['-(',x.function{FI,FJ},')'];
                else
                    z.derivative{Acount,1}{Dcount,1} = ['(',x.function{FI,FJ},').*(',y.derivative{Acount,1}{Dcount,1},')'];
                end
            end
            z.derivative{Acount,2} = y.derivative{Acount,2};
        end
    end
    
elseif isa(x,'cada') % x is cada ------------------------------------
    z.variable = x.variable;
    NUMvar     = size(x.variable,1);
    [xNrow, xMcol] = size(x.function);
    [yNrow, yMcol] = size(y);
    if (xNrow == yNrow && xMcol == yMcol)
        FNrow = yNrow;
        FMcol = yMcol;
    elseif (xNrow == 1 && xMcol == 1)
        FNrow = yNrow;
        FMcol = yMcol;
        x     = repmat(x,yNrow,yMcol);
    elseif (yNrow == 1 && yMcol == 1)
        FNrow = xNrow;
        FMcol = xMcol;
        y     = y.*ones(xNrow,xMcol);
    else
        error('Inputs are not of compatible sizes');
    end
    ystr = cadanum2str(y);
    
    % build function property
    z.function = cell(FNrow,FMcol);
    for FIcount = 1:FNrow
        for FJcount = 1:FMcol;
            z.function{FIcount,FJcount} = ['(',x.function{FIcount,FJcount},').*(',ystr{FIcount,FJcount},')'];
        end
    end
    
    % build derivative property
    z.derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(x.derivative{Acount,1})
            z.variable(Acount,:) = x.variable(Acount,:);
            nz = size(x.derivative{Acount,1},1);
            z.derivative{Acount,1} = cell(nz,1);
            for Dcount = 1:nz;
                % rep x
                FI = x.derivative{Acount,2}(Dcount,1);
                FJ = x.derivative{Acount,2}(Dcount,2);
                if strcmp(x.derivative{Acount,1}{Dcount,1},'1')
                    z.derivative{Acount,1}{Dcount,1} = ystr{FI,FJ};
                elseif strcmp(x.derivative{Acount,1}{Dcount,1},'-1')
                    z.derivative{Acount,1}{Dcount,1} = ['-(',ystr{FI,FJ},')'];
                else
                    z.derivative{Acount,1}{Dcount,1} = ['(',x.derivative{Acount,1}{Dcount,1},').*(',ystr{FI,FJ},')'];
                end
            end
            z.derivative{Acount,2} = x.derivative{Acount,2};
        end
    end
    
elseif isa(y,'cada') % y is cada ------------------------------------
    z.variable = y.variable;
    NUMvar     = size(y.variable,1);
    [xNrow, xMcol] = size(x);
    [yNrow, yMcol] = size(y.function);
    if (xNrow == yNrow && xMcol == yMcol)
        FNrow = yNrow;
        FMcol = yMcol;
    elseif (xNrow == 1 && xMcol == 1)
        FNrow = yNrow;
        FMcol = yMcol;
        x     = x.*ones(yNrow,yMcol);
    elseif (yNrow == 1 && yMcol == 1)
        FNrow = xNrow;
        FMcol = xMcol;
        y     = repmat(y,xNrow,xMcol);
    else
        error('Inputs are not of compatible sizes');
    end
    xstr = cadanum2str(x);
    
    % build function property
    z.function = cell(FNrow,FMcol);
    for FIcount = 1:FNrow
        for FJcount = 1:FMcol;
            z.function{FIcount,FJcount} = ['(',xstr{FIcount,FJcount},').*(',y.function{FIcount,FJcount},')'];
        end
    end
    
    % build derivative property
    z.derivative = cell(NUMvar,2);
    for Acount = 1:NUMvar;
        if ~isempty(y.derivative{Acount,1})
            z.variable(Acount,:) = y.variable(Acount,:);
            nz = size(y.derivative{Acount,1},1);
            z.derivative{Acount,1} = cell(nz,1);
            for Dcount = 1:nz;
                % rep y
                FI = y.derivative{Acount,2}(Dcount,1);
                FJ = y.derivative{Acount,2}(Dcount,2);
                if strcmp(y.derivative{Acount,1}{Dcount,1},'1')
                    z.derivative{Acount,1}{Dcount,1} = xstr{FI,FJ};
                elseif strcmp(y.derivative{Acount,1}{Dcount,1},'-1')
                    z.derivative{Acount,1}{Dcount,1} = ['-(',xstr{FI,FJ},')'];
                else
                    z.derivative{Acount,1}{Dcount,1} = ['(',xstr{FI,FJ},').*(',y.derivative{Acount,1}{Dcount,1},')'];
                end
            end
            z.derivative{Acount,2} = y.derivative{Acount,2};
        end
    end
end
z = class(z,'cada');