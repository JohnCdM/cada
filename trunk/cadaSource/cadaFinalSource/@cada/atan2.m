function z = atan2(y,x)
%CADA overloaded operation for atan2
%Algorithm created bx Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
fid = GLOBALCADA.FID;
% y and x are cada objects-------------------------------------------------
if isa(y,'cada') && isa(x,'cada')
    if isnumeric(y.function{1}) && isnumeric(x.function{1})
        z.variable = y.variable;
        z.function{1} = atan2(y.function{1},x.function{1});
        z.function{2} = size(z.function{1});
        z.function{3} = y.function{3};
        z.derivative = y.derivative;
        z = class(z,'cada');
        return
    elseif isnumeric(y.function{1})
        y = y.function{1};
    elseif isnumeric(x.function{1})
        x = x.function{1};
    else
        z.variable = y.variable;
        NUMvar = size(y.variable,1);
      
        yMrow = y.function{2}(1);
        yNcol = y.function{2}(2);
        xMrow = x.function{2}(1);
        xNcol = x.function{2}(2);
        if (yMrow == xMrow && yNcol == xNcol)
            FMrow = xMrow;
            FNcol = xNcol;
        elseif (yMrow == 1 && yNcol == 1)
            FMrow = xMrow;
            FNcol = xNcol;
            y = repmat(y,xMrow,xNcol);
        elseif (xMrow == 1 && xNcol == 1)
            FMrow = yMrow;
            FNcol = yNcol;
            x     = repmat(x,yMrow,yNcol);
        else
            error('Inputs are not of compatible sizes');
        end
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        
        
        % build function propertx
        z.function = cell(1,3);
        fprintf(fid,['cadaf',OPstr,'f = atan2(',y.function{1},',',x.function{1},');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow, FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        
        % build derivative propertx
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(y.derivative{Vcount,1}) && ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                [z.derivative{Vcount,2},yind,xind] = cadaunion(y.derivative{Vcount,2},x.derivative{Vcount,2},...
                    FMrow*FNcol,z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2));
                nz = size(z.derivative{Vcount,2},1);
                fprintf(fid,[derivstr,' = zeros(',int2str(nz),',cadaunit);\n']);
                fprintf(fid,'cadadind1 = ');
                cadaindprint(yind,fid);
                fprintf(fid,';\ncadadind2 = ');
                cadaindprint(xind,fid);
                fprintf(fid,';\ncadatfind1 = ');
                cadaindprint(y.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,';\ncadatfind2 = ');
                cadaindprint(x.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,[';\ncadatf1 = ',x.function{1},'(cadatfind1);\n']);
                fprintf(fid,['cadatf2 = ',y.function{1},'(cadatfind2);\n']);
                if length(xind) > length(yind)
                    fprintf(fid,[derivstr,'(cadadind2) = -cadatf2(:).*',x.derivative{Vcount,1},';\n']);
                    fprintf(fid,[derivstr,'(cadadind1) = ',derivstr,'(cadadind1) + cadatf1(:).*',y.derivative{Vcount,1},';\n']);
                else
                    fprintf(fid,[derivstr,'(cadadind1) = cadatf1(:).*',y.derivative{Vcount,1},';\n']);
                    fprintf(fid,[derivstr,'(cadadind2) = ',derivstr,'(cadadind2) - cadatf2(:).*',x.derivative{Vcount,1},';\n']);
                end
                fprintf(fid,'cadatfind1 = ');
                cadaindprint(z.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,[';\ncadatf1 = ',y.function{1},'(cadatfind1);\n']);
                fprintf(fid,['cadatf2 = ',x.function{1},'(cadatfind1);\n']);
                fprintf(fid,[derivstr,' = ',derivstr,'./(cadatf1(:).^2+cadatf2(:).^2);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+13;
            elseif ~isempty(y.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,'cadatfind1 = ');
                cadaindprint(y.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,[';\ncadatf1 = ',y.function{1},'(cadatfind1);\n']);
                fprintf(fid,['cadatf2 = ',x.function{1},'(cadatfind1);\n']);
                fprintf(fid,[derivstr,' = cadatf2(:)./(cadatf1(:).^2+cadatf2(:).^2).*',y.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+4;
                z.derivative{Vcount,2} = y.derivative{Vcount,2};
            elseif ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,'cadatfind1 = ');
                cadaindprint(x.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,[';\ncadatf1 = ',y.function{1},'(cadatfind1);\n']);
                fprintf(fid,['cadatf2 = ',x.function{1},'(cadatfind1);\n']);
                fprintf(fid,[derivstr,' = -cadatf1(:)./(cadatf1(:).^2+cadatf2(:).^2).*',x.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+4;
                z.derivative{Vcount,2} = x.derivative{Vcount,2};
            end
        end
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
        GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
        z = class(z,'cada');
        GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
        return
    end
end
if isa(y,'cada') % y is cada ---------------------------------------------
    if isnumeric(y.function{1})
        z.variable = y.variable;
        z.function = cell(1,3);
        z.function{1} = atan2(y.function{1},x);
        z.function{2} = size(z.function{1});
        z.function{3} = y.function{3};
        z.derivative = cell(size(z.variable,1),2);
        z = class(z,'cada');
        return
    end
    z.variable = y.variable;
    NUMvar     = size(y.variable,1);
    yMrow = y.function{2}(1);
    yNcol = y.function{2}(2);
    [xMrow, xNcol] = size(x);
    if (yMrow == xMrow && yNcol == xNcol)
        FMrow = xMrow;
        FNcol = xNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        if xMrow == 1 && xNcol == 1
            scalarflag = 1;
        else
            scalarflag = 0;
        end
    elseif (yMrow == 1 && yNcol == 1)
        FMrow = xMrow;
        FNcol = xNcol;
        y = repmat(y,xMrow,xNcol);
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 0;
    elseif (xMrow == 1 && xNcol == 1)
        % x is 1y1
        FMrow = yMrow;
        FNcol = yNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 1;
    else
        error('Inputs are not of compatible sizes');
    end
    
    if scalarflag == 1
        if x == 0
            z.function = cell(1,3);
            z.function{1} = ones(FMrow,FNcol);
            z.function{2} = [FMrow,FNcol];
            z.derivative = cell(NUMvar,2);
            z = class(z,'cada');
            return
        end
        % build function propertx
        fprintf(fid,['cadaf',OPstr,'f = atan2(',y.function{1},',',num2str(x,16),');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(y.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,['cadatf1 = ',y.function{1},'(']);
                cadaindprint(y.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,');\n');
                fprintf(fid,[derivstr,' = ',num2str(x,16),'./(cadatf1(:).^2+',num2str(x^2,16),').*',y.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
                z.derivative{Vcount,2} = y.derivative{Vcount,2};
            end
        end
    else

        cadamatprint(fid,x,'cadatf1')
        fprintf(fid,['cadaf',OPstr,'f = atan2(',y.function{1},',cadatf1);\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        % build function propertx
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative propertx
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
                    fprintf(fid,'cadatfind1 = ');
                    cadaindprint(dyind(:,1),fid);
                    fprintf(fid,';\n');
                    fprintf(fid,['cadatf2 = ',y.function{1},'(cadatfind1);\n']);
                    fprintf(fid,'cadatf3 = cadatf1(cadatfind1);\n');
                    fprintf(fid,[derivstr,' = cadatf3(:)./(cadatf2(:).^2+cadatf3(:).^2).*',y.derivative{Vcount,1},';\n']);
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+4;
                    z.derivative{Vcount,2} = dyind;
                end
            end
        end
    end
    GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
    GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
elseif isa(x,'cada') % x is cada -----------------------------------------
    if isnumeric(x.function{1})
        z.variable = x.variable;
        z.function = cell(1,3);
        z.function{1} = atan2(y,x.function{1});
        z.function{2} = size(z.function{1});
        z.function{3} = y.function{3};
        z.derivative = cell(size(z.variable,1),2);
        z = class(z,'cada');
        return
    end
    z.variable = x.variable;
    NUMvar     = size(x.variable,1);

    [yMrow, yNcol] = size(y);
    xMrow = x.function{2}(1);
    xNcol = x.function{2}(2);
    if (yMrow == xMrow && yNcol == xNcol)
        FMrow = xMrow;
        FNcol = xNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        if yMrow == 1 && yNcol == 1
            scalarflag = 1;
        else
            scalarflag = 0;
        end
    elseif (yMrow == 1 && yNcol == 1)
        FMrow = xMrow;
        FNcol = xNcol;
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 1;
    elseif (xMrow == 1 && xNcol == 1)
        FMrow = yMrow;
        FNcol = yNcol;
        x     = repmat(x,yMrow,yNcol);
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        scalarflag = 0;
    else
        error('Inputs are not of compatible sizes');
    end
    
    if scalarflag == 1
        % build function propertx
        fprintf(fid,['cadaf',OPstr,'f = atan2(',num2str(y,16),',',x.function{1},');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative propertx
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,['cadatf1 = ',x.function{1},'(']);
                cadaindprint(x.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,');\n');
                fprintf(fid,[derivstr,' = -',num2str(y,16),'./(',num2str(y^2,16),'+cadatf1(:).^2).*',x.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
                z.derivative{Vcount,2} = x.derivative{Vcount,2};
            end
        end
    else
        % build function propertx
        cadamatprint(fid,y,'cadatf1')
        fprintf(fid,['cadaf',OPstr,'f = atan2(cadatf1,',x.function{1},');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
    
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        
        % build derivative propertx
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                z.derivative{Vcount,1} = derivstr;
                fprintf(fid,'cadatfind1 = ');
                cadaindprint(x.derivative{Vcount,2}(:,1),fid);
                fprintf(fid,';\n');
                fprintf(fid,['cadatf2 = ',x.function{1},'(cadatfind1);\n']);
                fprintf(fid,'cadatf3 = cadatf1(cadatfind1);\n');
                fprintf(fid,[derivstr,' = -cadatf3(:)./(cadatf3(:).^2+cadatf2(:).^2).*',x.derivative{Vcount,1},';\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+4;
                z.derivative{Vcount,2} = x.derivative{Vcount,2};
            end
        end
    end
    GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
    GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
end
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
z = class(z,'cada');
