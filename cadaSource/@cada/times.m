function z = times(x,y)
%CADA overloaded operation for times
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
fid = GLOBALCADA.FID;
if isa(x,'cada') && isa(y,'cada')% x and y are cada objects-------------
    if isnumeric(x.function{1}) && isnumeric(y.function{1})
        z.variable = x.variable;
        z.function{1} = x.function{1}.*y.function{1};
        z.function{2} = size(z.function{1});
        z.function{3} = cadalineunion(x.function{3},y.function{3});
        z.derivative = x.derivative;
        z = class(z,'cada');
        return
    elseif isnumeric(x.function{1})
        x = x.function{1};
    elseif isnumeric(y.function{1})
        y = y.function{1};
    else
        z.variable = x.variable;
        NUMvar = size(x.variable,1);
        
        xMrow = x.function{2}(1);
        xNcol = x.function{2}(2);
        yMrow = y.function{2}(1);
        yNcol = y.function{2}(2);
        if (xMrow == yMrow && xNcol == yNcol)
            FMrow = yMrow;
            FNcol = yNcol;
        elseif (xMrow == 1 && xNcol == 1)
            FMrow = yMrow;
            FNcol = yNcol;
            x = repmat(x,yMrow,yNcol);
        elseif (yMrow == 1 && yNcol == 1)
            FMrow = xMrow;
            FNcol = xNcol;
            y     = repmat(y,xMrow,xNcol);
        else
            error('Inputs are not of compatible sizes');
        end
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        
        
        % build function property
        z.function = cell(1,3);
        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},' .* ',y.function{1},';\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow, FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative property
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1}) && ~isempty(y.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                [z.derivative{Vcount,2},xind,yind] = cadaunion(x.derivative{Vcount,2},y.derivative{Vcount,2},...
                    FMrow*FNcol,z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2));
                nz = size(z.derivative{Vcount,2},1);
                fprintf(fid,[derivstr,' = zeros(',int2str(nz),',cadaunit);\n']);
                fprintf(fid,'cadadind1 = ');
                cadaindprint(xind,fid);
                fprintf(fid,';\ncadadind2 = ');
                cadaindprint(yind,fid);
                fprintf(fid,[';\ncadatf1 = ',x.function{1},'(']);
                cadaindprint(y.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,');\n');
                fprintf(fid,['cadatf2 = ',y.function{1},'(']);
                cadaindprint(x.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,');\n');
                if length(yind) > length(xind)
                    fprintf(fid,[derivstr,'(cadadind2) = cadatf1(:).*',y.derivative{Vcount,1},';\n']);
                    fprintf(fid,[derivstr,'(cadadind1) = ',derivstr,'(cadadind1) + cadatf2(:).*',x.derivative{Vcount,1},';\n']);
                else
                    fprintf(fid,[derivstr,'(cadadind1) = cadatf2(:).*',x.derivative{Vcount,1},';\n']);
                    fprintf(fid,[derivstr,'(cadadind2) = ',derivstr,'(cadadind2) + cadatf1(:).*',y.derivative{Vcount,1},';\n']);
                end
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+7;
            elseif ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,['cadatf1 = ',y.function{1},'(']);
                cadaindprint(x.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,');\n');
                fprintf(fid,[derivstr,' = cadatf1(:).*',x.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
                z.derivative{Vcount,2} = x.derivative{Vcount,2};
            elseif ~isempty(y.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,['cadatf1 = ',x.function{1},'(']);
                cadaindprint(y.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,');\n');
                fprintf(fid,[derivstr,' = cadatf1(:).*',y.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
                z.derivative{Vcount,2} = y.derivative{Vcount,2};
            end
        end
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
        z = class(z,'cada');
        GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
        return
    end
end
if isa(x,'cada') % x is cada ---------------------------------------------
    if isnumeric(x.function{1})
        z.variable = x.variable;
        z.function = cell(1,3);
        z.function{1} = x.function{1}.*y;
        z.function{2} = size(z.function{1});
        z.function{3} = x.function{3};
        z.derivative = cell(size(z.variable,1),3);
        z = class(z,'cada');
        return
    end
    z.variable = x.variable;
    NUMvar     = size(x.variable,1);
    xMrow = x.function{2}(1);
    xNcol = x.function{2}(2);
    [yMrow, yNcol] = size(y);
    if (xMrow == yMrow && xNcol == yNcol)
        FMrow = yMrow;
        FNcol = yNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        if yMrow == 1 && yNcol == 1
            scalarflag = 1;
        else
            scalarflag = 0;
        end
    elseif (xMrow == 1 && xNcol == 1)
        FMrow = yMrow;
        FNcol = yNcol;
        x = repmat(x,yMrow,yNcol);
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 0;
    elseif (yMrow == 1 && yNcol == 1)
        % y is 1x1
        FMrow = xMrow;
        FNcol = xNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 1;
    else
        error('Inputs are not of compatible sizes');
    end
    
    if scalarflag == 1%y is scalar
        if y == 0
            z.function = cell(1,3);
            z.function{1} = zeros(FMrow,FNcol);
            z.function{2} = [FMrow,FNcol];
            z.derivative = cell(NUMvar,2);
            z = class(z,'cada');
            return
        end
        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},' .* ',num2str(y,16),';\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        % build function property
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,[derivstr,' = ',num2str(y,16),' .* ',x.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                z.derivative{Vcount,2} = x.derivative{Vcount,2};
            end
        end
    else
        cadamatprint(fid,y,'cadatf1')
        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},' .* cadatf1;\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        % build function property
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative property
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1})
                dxind = x.derivative{Vcount,2};
                fy = y(dxind(:,1));
                nzlocs = logical(fy(:).*dxind(:,1));
                dxind = dxind(nzlocs,:);
                if ~isempty(dxind)
                    derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                    z.derivative{Vcount,1} = derivstr;
                    fprintf(fid,'cadatf2 = cadatf1(');
                    cadaindprint(dxind(:,1),fid);
                    fprintf(fid,');\n');
                    fprintf(fid,[derivstr,' = cadatf2(:).*',x.derivative{Vcount,1},';\n']);
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
                    z.derivative{Vcount,2} = dxind;
                end
            end
        end
    end
    GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
    GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
elseif isa(y,'cada') % y is cada -----------------------------------------
    if isnumeric(y.function{1})
        z.variable = y.variable;
        z.function = cell(1,3);
        z.function{1} = y.function{1}.*x;
        z.function{2} = size(z.function{1});
        z.function{3} = y.function{3};
        z.derivative = cell(size(z.variable,1),3);
        z = class(z,'cada');
        return
    end
    z.variable = y.variable;
    NUMvar     = size(y.variable,1);
    
    [xMrow, xNcol] = size(x);
    yMrow = y.function{2}(1);
    yNcol = y.function{2}(2);
    if (xMrow == yMrow && xNcol == yNcol)
        FMrow = yMrow;
        FNcol = yNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        if xMrow == 1 && xNcol == 1
            scalarflag = 1;
        else
            scalarflag = 0;
        end
    elseif (xMrow == 1 && xNcol == 1)
        FMrow = yMrow;
        FNcol = yNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 1;
    elseif (yMrow == 1 && yNcol == 1)
        FMrow = xMrow;
        FNcol = xNcol;
        y     = repmat(y,xMrow,xNcol);
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 0;
    else
        error('Inputs are not of compatible sizes');
    end
    
    if scalarflag == 1
        if x == 0
            z.function = cell(1,3);
            z.function{1} = zeros(FMrow,FNcol);
            z.function{2} = [FMrow,FNcol];
            z.derivative = cell(NUMvar,2);
            z = class(z,'cada');
            return
        end
        % build function property
        fprintf(fid,['cadaf',OPstr,'f = ',y.function{1},' .* ',num2str(x,16),';\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative property
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(y.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,[derivstr,' = ',num2str(x,16),' .* ',y.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                z.derivative{Vcount,2} = y.derivative{Vcount,2};
            end
        end
    else
        % build function property
        cadamatprint(fid,x,'cadatf1')
        fprintf(fid,['cadaf',OPstr,'f = ',y.function{1},' .* cadatf1;\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative property
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(y.derivative{Vcount,1})
                dyind = y.derivative{Vcount,2};
                fx = x(dyind(:,1));
                nzlocs = logical(fx(:).*dyind(:,1));
                dyind = dyind(nzlocs,:);
                if ~isempty(dyind)
                    derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                    z.derivative{Vcount,1} = derivstr;
                    fprintf(fid,'cadatf2 = cadatf1(');
                    cadaindprint(dyind(:,1),fid);
                    fprintf(fid,');\n');
                    fprintf(fid,[derivstr,' = cadatf2(:).*',y.derivative{Vcount,1},';\n']);
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
                    z.derivative{Vcount,2} = dyind;
                end
            end
        end
    end
    GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
    GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
end
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
z = class(z,'cada');