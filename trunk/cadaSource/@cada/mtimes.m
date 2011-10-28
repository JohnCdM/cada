function z = mtimes(x,y)
%CADA overloaded operation for minus
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
fid = GLOBALCADA.FID;
if isa(x,'cada') && isa(y,'cada') % x and y are cada -------------
    if isnumeric(x.function{1}) && isnumeric(y.function{1})
        z.variable = x.variable;
        z.function{1} = x.function{1}*y.function{1};
        z.function{2} = size(z.function{1});
        z.derivative = x.derivative;
        z = class(z,'cada');
        return
    elseif isnumeric(x.function{1})
        x = x.function{1};
    elseif isnumeric(y.function{1})
        y = y.function{1};
    else
        xMrow = x.function{2}(1);
        xNcol = x.function{2}(2);
        yMrow = y.function{2}(1);
        yNcol = y.function{2}(2);
        if (xMrow == 1 && xNcol == 1)
            z = x.*y;
            return
        elseif (yMrow == 1 && yNcol == 1)
            z = x.*y;
            return
        elseif xNcol == yMrow
            NUMvar = size(x.variable,1);
            FMrow = xMrow;
            FNcol = yNcol;
            
            z.variable = x.variable;
            OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
            
            
            % build function property
            z.function = cell(1,3);
            fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},'*',y.function{1},';\n']);
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
                    xtemp = zeros(xMrow,xNcol);
                    xtemp(:) = 1:xMrow*xNcol;
                    xtemp = xtemp';
                    ztrantemp = zeros(FNcol,FMrow);
                    ztrantemp(:) = 1:FMrow*FNcol;
                    ztrantemp = ztrantemp';                 
                    nzx = size(x.derivative{Vcount,2},1);
                    nv = z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2);
                    %make x derivative
                    dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),1:nzx,xMrow*xNcol,nv);
                    dxtind = zeros(nzx,2);
                    [xtrows,xtcols,dxtind(:,1)] = find(dx(xtemp(:)',:));
                    %xtranspose derivative
                    dxtran = sparse(xtrows,xtcols,ones(nzx,1),xMrow*xNcol,nv);
                    dxtran = reshape(dxtran,xNcol,nv*xMrow);
                    dxtind(:,2) = find(dxtran(:));
                    dztran = ones(yNcol,yMrow)*dxtran;
                    dztran = reshape(dztran,FMrow*FNcol,nv);
                    dzxind = zeros(nnz(dztran),2);
                    dzxind(:,1) = find(dztran(:));
                    [dzrows,dzcols] = find(dztran);
                    dztran = sparse(dzrows,dzcols,(1:nnz(dztran))',FMrow*FNcol,nv);
                    [dzrows,dzcols,dzind] = find(dztran(ztrantemp(:)',:));
                    dzx = sparse(dzrows,dzcols,dzind,FMrow*FNcol,nv);
                    [xrows,xcols] = find(dzx);
                    if size(xrows,2) > 1
                        xrows = xrows';
                        xcols = xcols';
                    end

                    nzy = size(y.derivative{Vcount,2},1);
                    nv = z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2);
                    dy = sparse(y.derivative{Vcount,2}(:,1),y.derivative{Vcount,2}(:,2),ones(nzy,1),yMrow*yNcol,nv);
                    dy = reshape(dy,yMrow,nv*yNcol);
                    dyind = find(dy(:));
                    dzy = ones(xMrow,xNcol)*dy;
                    dzy = reshape(dzy,FMrow*FNcol,nv);
                    dzyind = zeros(nnz(dzy),2);
                    dzyind(:,1) = find(dzy(:));
                    [yrows,ycols] = find(dzy);
                    if size(yrows,2) > 1
                        yrows = yrows';
                        ycols = ycols';
                    end
                    [z.derivative{Vcount,2},dzxind(:,2),dzyind(:,2)] = cadaunion([xrows,xcols],[yrows,ycols],FMrow*FNcol,nv);
                    nz = size(z.derivative{Vcount,2},1);
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dxtind(:,2),fid);
                    if xNcol*xMrow*nv > 250
                        fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xNcol),',',int2str(nv*xMrow),'],cadadind1);\n']);
                        fprintf(fid,'cadadind3 = ');
                        cadaindprint(dxtind(:,1),fid);
                        fprintf(fid,[';\ncadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},'(cadadind3),',int2str(xNcol),',',int2str(nv*xMrow),');\n']);
                    else
                        fprintf(fid,';\ncadadind2 = ');
                        cadaindprint(dxtind(:,1),fid);
                        fprintf(fid,[';\ncadatd1 = zeros(',int2str(xNcol),',',int2str(nv*xMrow),',cadaunit);\n']);
                        fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},'(cadadind2);\n']);
                    end
                    fprintf(fid,['cadatd1 = ',y.function{1},'''*cadatd1;\n']);
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dyind,fid);
                    if yMrow*yNcol*nv > 250
                        fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(yMrow),',',int2str(nv*yNcol),'],cadadind1);\n']);
                        fprintf(fid,['cadatd2 = sparse(cadadind1,cadadind2,',y.derivative{Vcount,1},',',int2str(yMrow),',',int2str(nv*yNcol),');\n']);
                    else
                        fprintf(fid,[';\ncadatd2 = zeros(',int2str(yMrow),',',int2str(nv*yNcol),',cadaunit);\n']);
                        fprintf(fid,['cadatd2(cadadind1) = ',y.derivative{Vcount,1},';\n']);
                    end
                    fprintf(fid,['cadatd2 = ',x.function{1},'*cadatd2;\n']);
                    fprintf(fid,[derivstr,' = zeros(',int2str(nz),',cadaunit);\n']);
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dzxind(:,1),fid);
                    fprintf(fid,';\ncadatd1 = cadatd1(cadadind1);\ncadadind1 = ');
                    cadaindprint(dzyind(:,1),fid);
                    fprintf(fid,';\ncadatd2 = cadatd2(cadadind1)');
                    fprintf(fid,';\ncadadind1 = ');
                    cadaindprint(dzxind(:,2),fid);
                    fprintf(fid,';\ncadadind2 = ');
                    cadaindprint(dzyind(:,2),fid);
                    fprintf(fid,';\n');
                    if size(dzyind,1) > size(dzxind,1)
                        fprintf(fid,[derivstr,'(cadadind2) = cadatd2(:);\n']);
                        fprintf(fid,[derivstr,'(cadadind1) = ',derivstr,'(cadadind1) + cadatd1(:);\n']);
                    else
                        fprintf(fid,[derivstr,'(cadadind1) = cadatd1(:);\n']);
                        fprintf(fid,[derivstr,'(cadadind2) = ',derivstr,'(cadadind2) + cadatd2(:);\n']);
                    end
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+18;
                elseif ~isempty(x.derivative{Vcount,1})
                    xtemp = zeros(xMrow,xNcol);
                    xtemp(:) = 1:xMrow*xNcol;
                    xtemp = xtemp';
                    ztrantemp = zeros(FNcol,FMrow);
                    ztrantemp(:) = 1:FMrow*FNcol;
                    ztrantemp = ztrantemp';
                    derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                    z.derivative{Vcount,1} = derivstr;
                    nzx = size(x.derivative{Vcount,2},1);
                    nv = z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2);
                    %make x derivative
                    dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),1:nzx,xMrow*xNcol,nv);
                    dxtind = zeros(nzx,2);
                    [xtrows,xtcols,dxtind(:,1)] = find(dx(xtemp(:)',:));
                    %xtranspose derivative
                    dxtran = sparse(xtrows,xtcols,ones(nzx,1),xMrow*xNcol,nv);
                    dxtran = reshape(dxtran,xNcol,nv*xMrow);
                    dxtind(:,2) = find(dxtran(:));
                    dztran = ones(yNcol,yMrow)*dxtran;
                    dztran = reshape(dztran,FMrow*FNcol,nv);
                    dxind = zeros(nnz(dztran),2);
                    dxind(:,1) = find(dztran(:));
                    [dzrows,dzcols] = find(dztran);
                    dztran = sparse(dzrows,dzcols,(1:nnz(dztran))',FMrow*FNcol,nv);
                    [dzrows,dzcols,dzind] = find(dztran(ztrantemp(:)',:));
                    dz = sparse(dzrows,dzcols,dzind,FMrow*FNcol,nv);
                    dxind(:,2) = nonzeros(dz(:));
                    [rows,cols] = find(dz);
                    if size(rows,2) > 1
                        rows = rows';
                        cols = cols';
                    end
                    nzz = nnz(dz);
                    z.derivative{Vcount,2} = [rows,cols];
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dxtind(:,2),fid);
                    if xNcol*xMrow*nv > 250
                        fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xNcol),',',int2str(nv*xMrow),'],cadadind1);\n']);
                        fprintf(fid,'cadadind3 = ');
                        cadaindprint(dxtind(:,1),fid);
                        fprintf(fid,[';\ncadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},'(cadadind3),',int2str(xNcol),',',int2str(nv*xMrow),');\n']);
                    else
                        fprintf(fid,';\ncadadind2 = ');
                        cadaindprint(dxtind(:,1),fid);
                        fprintf(fid,[';\ncadatd1 = zeros(',int2str(xNcol),',',int2str(nv*xMrow),',cadaunit);\n']);
                        fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},'(cadadind2);\n']);
                    end
                    fprintf(fid,['cadatd1 = ',y.function{1},'''*cadatd1;\n']);
                    fprintf(fid,[derivstr,' = zeros(',int2str(nzz),',cadaunit);\n']);
                    fprintf(fid,[derivstr,'(']);
                    cadaindprint(dxind(:,2),fid);
                    fprintf(fid,') = cadatd1(');
                    cadaindprint(dxind(:,1),fid);
                    fprintf(fid,');\n');
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+7;
                elseif ~isempty(y.derivative{Vcount,1})
                    derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                    z.derivative{Vcount,1} = derivstr;
                    nzy = size(y.derivative{Vcount,2},1);
                    nv = z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2);
                    dy = sparse(y.derivative{Vcount,2}(:,1),y.derivative{Vcount,2}(:,2),ones(nzy,1),yMrow*yNcol,nv);
                    dy = reshape(dy,yMrow,nv*yNcol);
                    dyind = find(dy(:));
                    dz = ones(xMrow,xNcol)*dy;
                    dzind = find(dz(:));
                    dz = reshape(dz,FMrow*FNcol,nv);
                    [rows,cols] = find(dz);
                    nzz = nnz(dz);
                    if size(rows,2) > 1
                        rows = rows';
                        cols = cols';
                    end
                    z.derivative{Vcount,2} = [rows,cols];
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dyind,fid);
                    if yMrow*yNcol*nv > 250
                        fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(yMrow),',',int2str(nv*yNcol),'],cadadind1);\n']);
                        fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',y.derivative{Vcount,1},',',int2str(yMrow),',',int2str(nv*yNcol),');\n']);
                    else
                        fprintf(fid,[';\ncadatd1 = zeros(',int2str(yMrow),',',int2str(nv*yNcol),',cadaunit);\n']);
                        fprintf(fid,['cadatd1(cadadind1) = ',y.derivative{Vcount,1},';\n']);
                    end
                    fprintf(fid,['cadatd1 = ',x.function{1},'*cadatd1;\n']);
                    fprintf(fid,[derivstr,' = zeros(',int2str(nzz),',cadaunit);\n']);
                    fprintf(fid,[derivstr,'(:) = cadatd1(']);
                    cadaindprint(dzind,fid);
                    fprintf(fid,');\n');
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
                end
            end
            GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
            if ~isempty(x.function{3})
                GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
            end
            if ~isempty(y.function{3})
                GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
            end
            z = class(z,'cada');
            GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
            return
        else
            error('Inputs are not of compatible sizes');
        end
    end
end
if isa(x,'cada') % x is cada ------------------------------------
    if isnumeric(x.function{1})
        z.variable = x.variable;
        z.function = cell(1,3);
        z.function{1} = x.function{1}*y;
        z.function{2} = size(z.function{1});
        z.derivative = cell(size(z.variable,1),3);
        z = class(z,'cada');
        return
    end
    xMrow = x.function{2}(1);
    xNcol = x.function{2}(2);
    [yMrow, yNcol] = size(y);
    if (xMrow == 1 && xNcol == 1)
        z = x.*y;
        return
    elseif (yMrow == 1 && yNcol == 1)
        z = x.*y;
        return
    elseif xNcol == yMrow
        FMrow = xMrow;
        FNcol = yNcol;
        z.variable = x.variable;
        NUMvar     = size(x.variable,1);
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        
        cadamatprint(fid,y,'cadatf1')
        fprintf(fid,['cadaf',OPstr,'f = ',x.function{1},'*cadatf1;\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        y = ceil(abs(y));
    
        %build derivative
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar
            if ~isempty(x.derivative{Vcount,1})
                xtemp = zeros(xMrow,xNcol);
                xtemp(:) = 1:xMrow*xNcol;
                xtemp = xtemp';
                ztrantemp = zeros(FNcol,FMrow);
                ztrantemp(:) = 1:FMrow*FNcol;
                ztrantemp = ztrantemp';
                nzx = size(x.derivative{Vcount,2},1);
                nv = z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2);
                %make x derivative
                dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),1:nzx,xMrow*xNcol,nv);
                dxtind = zeros(nzx,2);
                [xtrows,xtcols,dxtind(:,1)] = find(dx(xtemp(:)',:));
                %xtranspose derivative
                dxtran = sparse(xtrows,xtcols,ones(nzx,1),xMrow*xNcol,nv);
                dxtran = reshape(dxtran,xNcol,nv*xMrow);
                dxtind(:,2) = find(dxtran(:));
                dztran = y'*dxtran;
                dztran = reshape(dztran,FMrow*FNcol,nv);
                dxind = zeros(nnz(dztran),2);
                if ~isempty(dxind)
                    dxind(:,1) = find(dztran(:));
                    [dzrows,dzcols] = find(dztran);
                    dztran = sparse(dzrows,dzcols,(1:nnz(dztran))',FMrow*FNcol,nv);
                    [dzrows,dzcols,dzind] = find(dztran(ztrantemp(:)',:));
                    dz = sparse(dzrows,dzcols,dzind,FMrow*FNcol,nv);
                    dxind(:,2) = nonzeros(dz(:));
                    [rows,cols] = find(dz);
                    if size(rows,2) > 1
                        rows = rows';
                        cols = cols';
                    end
                    nzz = nnz(dz);
                    derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                    z.derivative{Vcount,1} = derivstr;
                    z.derivative{Vcount,2} = [rows,cols];
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dxtind(:,2),fid);
                    if xNcol*xMrow*nv > 250
                        fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xNcol),',',int2str(nv*xMrow),'],cadadind1);\n']);
                        fprintf(fid,'cadadind3 = ');
                        cadaindprint(dxtind(:,1),fid);
                        fprintf(fid,[';\ncadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},'(cadadind3),',int2str(xNcol),',',int2str(nv*xMrow),');\n']);
                    else
                        fprintf(fid,';\ncadadind2 = ');
                        cadaindprint(dxtind(:,1),fid);
                        fprintf(fid,[';\ncadatd1 = zeros(',int2str(xNcol),',',int2str(nv*xMrow),',cadaunit);\n']);
                        fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},'(cadadind2);\n']);
                    end
                    fprintf(fid,'cadatd1 = cadatf1''*cadatd1;\n');
                    fprintf(fid,[derivstr,' = zeros(',int2str(nzz),',cadaunit);\n']);
                    fprintf(fid,[derivstr,'(']);
                    cadaindprint(dxind(:,2),fid);
                    fprintf(fid,') = cadatd1(');
                    cadaindprint(dxind(:,1),fid);
                    fprintf(fid,');\n');
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+7;
                end
            end
        end
    else
        error('Inputs are not of compatible sizes');
    end
    GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
    if ~isempty(x.function{3})
        GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
    end
elseif isa(y,'cada') % y is cada ------------------------------------
    if isnumeric(y.function{1})
        z.variable = y.variable;
        z.function = cell(1,3);
        z.function{1} = x*y.function{1};
        z.function{2} = size(z.function{1});
        z.derivative = cell(size(z.variable,1),3);
        z = class(z,'cada');
        return
    end
    [xMrow, xNcol] = size(x);
    yMrow = y.function{2}(1);
    yNcol = y.function{2}(2);
    if (xMrow == 1 && xNcol == 1)
        z = x.*y;
        return
    elseif (yMrow == 1 && yNcol == 1)
        z = x.*y;
        return
    elseif xNcol == yMrow
        FMrow = xMrow;
        FNcol = yNcol;
        z.variable = y.variable;
        NUMvar     = size(y.variable,1);
        OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
        
        cadamatprint(fid,x,'cadatf1')
        fprintf(fid,['cadaf',OPstr,'f = cadatf1*',y.function{1},';\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        %build function
        z.function = cell(1,3);
        z.function{1} = ['cadaf',OPstr,'f'];
        z.function{2} = [FMrow,FNcol];
        z.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(z.function{3},1) = GLOBALCADA.LINECOUNT;
        x = ceil(abs(x));
        
        %build derivative
        z.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar
            if ~isempty(y.derivative{Vcount,1})
                
                nzy = size(y.derivative{Vcount,2},1);
                nv = z.variable{Vcount,2}(1)*z.variable{Vcount,2}(2);
                dy = sparse(y.derivative{Vcount,2}(:,1),y.derivative{Vcount,2}(:,2),ones(nzy,1),yMrow*yNcol,nv);
                dy = reshape(dy,yMrow,nv*yNcol);
                dyind = find(dy(:));
                dz = x*dy;
                dzind = find(dz(:));
                if ~isempty(dzind)
                    dz = reshape(dz,FMrow*FNcol,nv);
                    [rows,cols] = find(dz);
                    nzz = nnz(dz);
                    if size(rows,2) > 1
                        rows = rows';
                        cols = cols';
                    end
                    derivstr = ['dcadaf',OPstr,'fd',z.variable{Vcount,1}];
                    z.derivative{Vcount,1} = derivstr;
                    z.derivative{Vcount,2} = [rows,cols];
                    fprintf(fid,'cadadind1 = ');
                    cadaindprint(dyind,fid);
                    if yMrow*yNcol*nv > 250
                        fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(yMrow),',',int2str(nv*yNcol),'],cadadind1);\n']);
                        fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',y.derivative{Vcount,1},',',int2str(yMrow),',',int2str(nv*yNcol),');\n']);
                    else
                        fprintf(fid,[';\ncadatd1 = zeros(',int2str(yMrow),',',int2str(nv*yNcol),',cadaunit);\n']);
                        fprintf(fid,['cadatd1(cadadind1) = ',y.derivative{Vcount,1},';\n']);
                    end
                    fprintf(fid,['cadatd1(cadadind1) = ',y.derivative{Vcount,1},';\n']);
                    fprintf(fid,'cadatd1 = cadatf1*cadatd1;\n');
                    fprintf(fid,[derivstr,' = zeros(',int2str(nzz),',cadaunit);\n']);
                    fprintf(fid,[derivstr,'(:) = cadatd1(']);
                    cadaindprint(dzind,fid);
                    fprintf(fid,');\n');
                    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
                end
            end
        end
    else
        error('Inputs are not of compatible sizes');
    end
    GLOBALCADA.FUNCTIONLOCATION(z.function{3},2) = GLOBALCADA.LINECOUNT;
    if ~isempty(y.function{3})
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
    end
end
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
z = class(z,'cada');
