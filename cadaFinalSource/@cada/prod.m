function y = prod(x,varargin)
%CADA overloaded operation for prod
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA;
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;
if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,3);
    y.function{1} = prod(x.function{1},varargin{:});
    y.function{2} = size(y.function{1});
    y.function{3} = x.function{3};
    y.derivative = x.derivative;
    y = class(y,'cada');
    return
end
y.variable = x.variable;
NUMvar = size(x.variable,1);

varargSize = length(varargin);
if varargSize == 0 ;
    xMrow = x.function{2}(1);
    xNcol = x.function{2}(2);
    if xMrow == 1 && xNcol == 1;
        y = x;
        return
    elseif xMrow == 1 || xNcol == 1;
        % prod the first row/col
        fprintf(fid,['cadaf',OPstr,'f = prod(',x.function{1},');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        y.function = cell(1,3);
        y.function{1} = ['cadaf',OPstr,'f'];
        y.function{2} = [1,1];
        y.function{3} = GLOBALCADA.OPERATIONCOUNT;
        GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;
        
        y.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                y.derivative{Vcount,1} = derivstr;
                xrows = x.derivative{Vcount,2}(:,1);
                xcols = x.derivative{Vcount,2}(:,2);
                nzx = length(xrows);
                nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                dxi = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                [yrows,ycols,ndy] = find(sum(dx));
                y.derivative{Vcount,2} = [yrows',ycols'];
                nzy = nnz(ndy);
                fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                for Dcount = 1:nzy
                    [xind,~,dxind] = find(dxi(:,ycols(Dcount)));
                    fprintf(fid,[derivstr,'(',int2str(Dcount),') = ']);
                    for D2count = 1:ndy(Dcount)
                        fprintf(fid,[x.derivative{Vcount,1},'(',int2str(dxind(D2count)),')']);
                        if xind(D2count) == 1
                            fprintf(fid,['.*prod(',x.function{1},'(2:',int2str(xMrow*xNcol),'))']);
                        elseif xind(D2count) == xMrow*xNcol
                            fprintf(fid,['.*prod(',x.function{1},'(1:',int2str(xMrow*xNcol-1),'))']);
                        else
                            fprintf(fid,['.*prod(',x.function{1},'([1:',int2str(xind(D2count)-1),' ',int2str(xind(D2count)+1),':',int2str(xMrow*xNcol),']))']);
                        end
                        if D2count == ndy(Dcount)
                            fprintf(fid,';\n');
                        else
                            fprintf(fid,' + ');
                        end
                    end
                end
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+nzy;
            end
        end
        
    else
        %create row vector of prod of column vectors
        fprintf(fid,['cadaf',OPstr,'f = prod(',x.function{1},');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        y.function = cell(1,3);
        y.function{1} = ['cadaf',OPstr,'f'];
        y.function{2} = [1,xNcol];
        xtemp = repmat((1:xMrow)',1,xNcol);
        
        y.derivative = cell(NUMvar,2);
        for Vcount = 1:NUMvar;
            if ~isempty(x.derivative{Vcount,1})
                derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                y.derivative{Vcount,1} = derivstr;
                xrows = x.derivative{Vcount,2}(:,1);
                xcols = x.derivative{Vcount,2}(:,2);
                nzx = length(xrows);
                nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                dxi = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                yrows = zeros(nzx,1);
                ycols = zeros(nzx,1);
                ndy = zeros(nzx,1);
                for Jcount = 1:xNcol
                    dyj = sum(dx((Jcount-1)*xMrow+1:Jcount*xMrow,:));
                    nzyj = nnz(dyj);
                    if nzyj > 0
                        [yjrows,yjcols,ndyj] = find(dyj);
                        nzyjp = nnz(yrows);
                        yrows(nzyjp+1:nzyjp+nzyj) = Jcount*yjrows;
                        ycols(nzyjp+1:nzyjp+nzyj) = yjcols;
                        ndy(nzyjp+1:nzyjp+nzyj) = ndyj;
                    end
                end
                nzy = nnz(ndy);
                dy = sparse(yrows(1:nzy),ycols(1:nzy),ndy(1:nzy),xNcol,nv);
                [yrows,ycols,ndy] = find(dy);
                y.derivative{Vcount,2} = [yrows,ycols];
                nzy = nnz(ndy);
                fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                for Dcount = 1:nzy
                    yi = yrows(Dcount);
                    yj = ycols(Dcount);
                    xi = (yi-1)*xNcol+1:yi*xNcol;
                    dxind = nonzeros(dxi(xi,yj));
                    [xrow,xcol] = ind2sub([xMrow,xNcol],xrows(dxind));
                    fprintf(fid,[derivstr,'(',int2str(Dcount),') = ']);
                    for D2count = 1:ndy(Dcount)
                        fprintf(fid,[x.derivative{Vcount,1},'(',int2str(dxind(D2count)),')']);
                        if xrow(D2count) == 1
                            fprintf(fid,['.*prod(',x.function{1},'(2:',int2str(xMrow),',',int2str(xcol(D2count)),'))']);
                        elseif xrow(D2count) == xMrow
                            fprintf(fid,['.*prod(',x.function{1},'(1:',int2str(xMrow-1),',',int2str(xcol(D2count)),'))']);
                        else
                            fprintf(fid,['.*prod(',x.function{1},'([1:',int2str(xrow(D2count)-1),' ',int2str(xrow(D2count)+1),':',int2str(xMrow),'],',int2str(xcol(D2count)),'))']);
                        end
                        if D2count == ndy(Dcount)
                            fprintf(fid,';\n');
                        else
                            fprintf(fid,' + ');
                        end
                    end
                end
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+nzy;
            end
        end
    end
    
elseif varargSize == 1
    if length(varargin{1}) == 1
        Dim = varargin{1};
        if Dim > 2
            y = x;
            return
        elseif Dim == 1
            xMrow = x.function{2}(1);
            xNcol = x.function{2}(2);
            if xMrow == 1
                y = x;
                return
            elseif xNcol == 1
                %prod first col
                fprintf(fid,['cadaf',OPstr,'f = prod(',x.function{1},');\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                
                y.function = cell(1,3);
                y.function{1} = ['cadaf',OPstr,'f'];
                y.function{2} = [1,1];
                if GLOBALCADA(3) == 1
                    y.function{3} = x.function{3};
                    y.function{3}(GLOBALCADA.OPERATIONCOUNT) = GLOBALCADA.LINECOUNT;
                    xOP = length(x.function{3});
                    if xOP ~= 0
                        y.function{3}(xOP) = GLOBALCADA.LINECOUNT;
                    end
                end
                
                y.derivative = cell(NUMvar,2);
                for Vcount = 1:NUMvar;
                    if ~isempty(x.derivative{Vcount,1})
                        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                        y.derivative{Vcount,1} = derivstr;
                        xrows = x.derivative{Vcount,2}(:,1);
                        xcols = x.derivative{Vcount,2}(:,2);
                        nzx = length(xrows);
                        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                        dxi = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        [yrows,ycols,ndy] = find(sum(dx));
                        y.derivative{Vcount,2} = [yrows',ycols'];
                        nzy = nnz(ndy);
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                        for Dcount = 1:nzy
                            [xind,~,dxind] = find(dxi(:,ycols(Dcount)));
                            fprintf(fid,[derivstr,'(',int2str(Dcount),') = ']);
                            for D2count = 1:ndy(Dcount)
                                fprintf(fid,[x.derivative{Vcount,1},'(',int2str(dxind(D2count)),')']);
                                if xind(D2count) == 1
                                    fprintf(fid,['.*prod(',x.function{1},'(2:end))']);
                                elseif xind(D2count) == xMrow*xNcol
                                    fprintf(fid,['.*prod(',x.function{1},'(1:end-1))']);
                                else
                                    fprintf(fid,['.*prod(',x.function{1},'([1:',int2str(xind(D2count)-1),' ',int2str(xind(D2count)+1),':end]))']);
                                end
                                if D2count == ndy(Dcount)
                                    fprintf(fid,';\n');
                                else
                                    fprintf(fid,' + ');
                                end
                            end
                        end
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+nzy;
                    end
                end
            else
                %create row vector of prod of column vectors
                fprintf(fid,['cadaf',OPstr,'f = prod(',x.function{1},',1);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                
                y.function = cell(1,3);
                y.function{1} = ['cadaf',OPstr,'f'];
                y.function{2} = [1,xNcol];
                if GLOBALCADA(3) == 1
                    y.function{3} = x.function{3};
                    y.function{3}(GLOBALCADA.OPERATIONCOUNT) = GLOBALCADA.LINECOUNT;
                    xOP = length(x.function{3});
                    if xOP ~= 0
                        y.function{3}(xOP) = GLOBALCADA.LINECOUNT;
                    end
                end
                xtemp = repmat((1:xMrow)',1,xNcol);
                
                
                y.derivative = cell(NUMvar,2);
                for Vcount = 1:NUMvar;
                    if ~isempty(x.derivative{Vcount,1})
                        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                        y.derivative{Vcount,1} = derivstr;
                        xrows = x.derivative{Vcount,2}(:,1);
                        xcols = x.derivative{Vcount,2}(:,2);
                        nzx = length(xrows);
                        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                        dxi = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        yrows = zeros(nzx,1);
                        ycols = zeros(nzx,1);
                        ndy = zeros(nzx,1);
                        for Jcount = 1:xNcol
                            dyj = sum(dx((Jcount-1)*xMrow+1:Jcount*xMrow,:));
                            nzyj = nnz(dyj);
                            if nzyj > 0
                                [yjrows,yjcols,ndyj] = find(dyj);
                                nzyjp = nnz(yrows);
                                yrows(nzyjp+1:nzyjp+nzyj) = Jcount*yjrows;
                                ycols(nzyjp+1:nzyjp+nzyj) = yjcols;
                                ndy(nzyjp+1:nzyjp+nzyj) = ndyj;
                            end
                        end
                        nzy = nnz(ndy);
                        dy = sparse(yrows(1:nzy),ycols(1:nzy),ndy(1:nzy),xNcol,nv);
                        [yrows,ycols,ndy] = find(dy);
                        y.derivative{Vcount,2} = [yrows,ycols];
                        nzy = nnz(ndy);
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                        for Dcount = 1:nzy
                            yi = yrows(Dcount);
                            yj = ycols(Dcount);
                            [xind,~,dxind] = find(dxi((yi-1)*xNcol+1:yi*xNcol,yj));
                            xrow = xtemp(xind);
                            fprintf(fid,[derivstr,'(',int2str(Dcount),') = ']);
                            for D2count = 1:ndy(Dcount)
                                fprintf(fid,[x.derivative{Vcount,1},'(',int2str(dxind(D2count)),')']);
                                if xrow(D2count) == 1
                                    fprintf(fid,['.*prod(',x.function{1},'(2:end,:))']);
                                elseif xrow(D2count) == xMrow*xNcol
                                    fprintf(fid,['.*prod(',x.function{1},'(1:end-1,:))']);
                                else
                                    fprintf(fid,['.*prod(',x.function{1},'([1:',int2str(xrow(D2count)-1),' ',int2str(xrow(D2count)+1),':end],:))']);
                                end
                                if D2count == ndy(Dcount)
                                    fprintf(fid,';\n');
                                else
                                    fprintf(fid,' + ');
                                end
                            end
                        end
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+nzy;
                    end
                end
            end
            
        elseif Dim == 2
            xMrow = x.function{2}(1);
            xNcol = x.function{2}(2);
            if xNcol == 1
                y = x;
                return
            elseif xMrow == 1
                %prod first row
                fprintf(fid,['cadaf',OPstr,'f = prod(',x.function{1},');\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                
                y.function = cell(1,3);
                y.function{1} = ['cadaf',OPstr,'f'];
                y.function{2} = [1,1];
                if GLOBALCADA(3) == 1
                    y.function{3} = x.function{3};
                    xOP = length(x.function{3});
                    y.function{3}(GLOBALCADA.OPERATIONCOUNT) = GLOBALCADA.LINECOUNT;
                    if xOP ~= 0
                        y.function{3}(xOP) = GLOBALCADA.LINECOUNT;
                    end
                end
                
                
                y.derivative = cell(NUMvar,2);
                for Vcount = 1:NUMvar;
                    if ~isempty(x.derivative{Vcount,1})
                        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                        y.derivative{Vcount,1} = derivstr;
                        xrows = x.derivative{Vcount,2}(:,1);
                        xcols = x.derivative{Vcount,2}(:,2);
                        nzx = length(xrows);
                        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                        dxi = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        [yrows,ycols,ndy] = find(sum(dx));
                        y.derivative{Vcount,2} = [yrows',ycols'];
                        nzy = nnz(ndy);
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                        for Dcount = 1:nzy
                            [xind,~,dxind] = find(dxi(:,ycols(Dcount)));
                            fprintf(fid,[derivstr,'(',int2str(Dcount),') = ']);
                            for D2count = 1:ndy(Dcount)
                                fprintf(fid,[x.derivative{Vcount,1},'(',int2str(dxind(D2count)),')']);
                                if xind(D2count) == 1
                                    fprintf(fid,['.*prod(',x.function{1},'(2:end))']);
                                elseif xind(D2count) == xMrow*xNcol
                                    fprintf(fid,['.*prod(',x.function{1},'(1:end-1))']);
                                else
                                    fprintf(fid,['.*prod(',x.function{1},'([1:',int2str(xind(D2count)-1),' ',int2str(xind(D2count)+1),':end]))']);
                                end
                                if D2count == ndy(Dcount)
                                    fprintf(fid,';\n');
                                else
                                    fprintf(fid,' + ');
                                end
                            end
                        end
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+nzy;
                    end
                end
            else
                %create column vector of prod of row vectors
                fprintf(fid,['cadaf',OPstr,'f = prod(',x.function{1},',1);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                
                y.function = cell(1,3);
                y.function{1} = ['cadaf',OPstr,'f'];
                y.function{2} = [xMrow,1];
                if GLOBALCADA(3) == 1
                    y.function{3} = x.function{3};
                    y.function{3}(GLOBALCADA.OPERATIONCOUNT) = GLOBALCADA.LINECOUNT;
                    xOP = length(x.function{3});
                    if xOP ~= 0
                        y.function{3}(xOP) = GLOBALCADA.LINECOUNT;
                    end
                end
                xtemp = zeros(xMrow,xNcol);
                xtemp(:) = 1:xMrow*xNcol;
                xtemp2 = repmat(1:xNcol,xMrow,1);
                
                
                y.derivative = cell(NUMvar,2);
                for Vcount = 1:NUMvar;
                    if ~isempty(x.derivative{Vcount,1})
                        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                        y.derivative{Vcount,1} = derivstr;
                        xrows = x.derivative{Vcount,2}(:,1);
                        xcols = x.derivative{Vcount,2}(:,2);
                        nzx = length(xrows);
                        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                        dxi = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        yrows = zeros(nzx,1);
                        ycols = zeros(nzx,1);
                        ndy = zeros(nzx,1);
                        for Icount = 1:xMrow
                            prodind = xtemp(Icount,:)';
                            dyj = sum(dx(prodind,:));
                            nzyj = nnz(dyj);
                            if nzyj > 0
                                [yjrows,yjcols,ndyj] = find(dyj);
                                nzyjp = nnz(yrows);
                                yrows(nzyjp+1:nzyjp+nzyj) = Icount*yjrows;
                                ycols(nzyjp+1:nzyjp+nzyj) = yjcols;
                                ndy(nzyjp+1:nzyjp+nzyj) = ndyj;
                            end
                        end
                        nzy = nnz(ndy);
                        dy = sparse(yrows(1:nzy),ycols(1:nzy),ndy(1:nzy),xMrow,nv);
                        [yrows,ycols,ndy] = find(dy);
                        y.derivative{Vcount,2} = [yrows,ycols];
                        nzy = nnz(ndy);
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                        for Dcount = 1:nzy
                            yi = yrows(Dcount);
                            yj = ycols(Dcount);
                            [xind,~,dxind] = dxi(xtemp(yi,:),yj);
                            xcol = xtemp2(xind);
                            fprintf(fid,[derivstr,'(',int2str(Dcount),') = ']);
                            for D2count = 1:ndy(Dcount)
                                fprintf(fid,[x.derivative{Vcount,1},'(',int2str(dxind(D2count)),')']);
                                if xcol(D2count) == 1
                                    fprintf(fid,['.*prod(',x.function{1},'(:,2:end))']);
                                elseif xcol(D2count) == xMrow*xNcol
                                    fprintf(fid,['.*prod(',x.function{1},'(:,1:end-1))']);
                                else
                                    fprintf(fid,['.*prod(',x.function{1},'(:,[1:',int2str(xcol(D2count)-1),' ',int2str(xcol(D2count)+1),':end]))']);
                                end
                                if D2count == ndy(Dcount)
                                    fprintf(fid,';\n');
                                else
                                    fprintf(fid,' + ');
                                end
                            end
                        end
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+nzy;
                    end
                end
            end
        else
            error('Dimension value must be a integer.');
        end
    else
        error('Dimension value must be a scalar.');
    end
elseif varargSize == 2
    % and S = SUM(X,DIM,'double')    DEAL WITH THIS LATER !!!!
    % and S = SUM(X,DIM,'native')
else
    error('Too many input arguments.');
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');