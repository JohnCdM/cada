function y = sum(x,varargin)
%CADA overloaded operation for sum
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA;
OPstr = num2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;

if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,3);
    y.function{1} = sum(x.function{1},varargin{:});
    y.function{2} = size(y.function{1});
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
        % sum the first row/col
        fprintf(fid,['cadaf',OPstr,'f = sum(',x.function{1},');\n']);
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
                dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                dxind = find(dx(:));
                dy = sum(dx);
                [yrows,ycols] = find(dy);
                if size(yrows,2) > 1
                    yrows = yrows';
                    ycols = ycols';
                end
                dyind = find(dy(:));
                y.derivative{Vcount,2} = [yrows,ycols];
                nzy = numel(dyind);
                fprintf(fid,'cadadind1 = ');
                cadaindprint(dxind,fid);
                if xMrow*xNcol*nv > 250
                    fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xMrow*xNcol),',',int2str(nv),'],cadadind1);\n']);
                    fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},',',int2str(xMrow*xNcol),',',int2str(nv),');\n']);
                else
                    fprintf(fid,[';\ncadatd1 = zeros(',int2str(xMrow*xNcol),',',int2str(nv),',cadaunit);\n']);
                    fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},';\n']);
                end
                fprintf(fid,'cadatd1 = sum(cadatd1);\n');
                fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                fprintf(fid,[derivstr,'(:) = cadatd1(']);
                cadaindprint(dyind,fid);
                fprintf(fid,');\n');
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
            end
        end
        
    else
        %create row vector of sum of column vectors
        fprintf(fid,['cadaf',OPstr,'f = sum(',x.function{1},');\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
        
        y.function = cell(1,3);
        y.function{1} = ['cadaf',OPstr,'f'];
        y.function{2} = [1,xNcol];
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
                dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                dx = reshape(dx,xMrow,xNcol*nv);
                dxind = find(dx(:));
                dy = reshape(sum(dx),xNcol,nv);
                dyind = find(dy(:));
                [yrows,ycols] = find(dy);
                if size(yrows,2) > 1
                    yrows = yrows';
                    ycols = ycols';
                end
                nzy = numel(dyind);
                y.derivative{Vcount,2} = [yrows,ycols];
                fprintf(fid,'cadadind1 = ');
                cadaindprint(dxind,fid);
                if xMrow*xNcol*nv > 250
                    fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xMrow),',',int2str(xNcol*nv),'],cadadind1);\n']);
                    fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},',',int2str(xMrow),',',int2str(xNcol*nv),');\n']);
                else
                    fprintf(fid,[';\ncadatd1 = zeros(',int2str(xMrow),',',int2str(nv*xNcol),',cadaunit);\n']);
                    fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},';\n']);
                end
                fprintf(fid,'cadatd1 = sum(cadatd1);\n');
                fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                fprintf(fid,[derivstr,'(:) = cadatd1(']);
                cadaindprint(dyind,fid);
                fprintf(fid,');\n');
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
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
                %sum first col
                fprintf(fid,['cadaf',OPstr,'f = sum(',x.function{1},');\n']);
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
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        dxind = find(dx(:));
                        dy = sum(dx);
                        [yrows,ycols] = find(dy);
                        if size(yrows,2) > 1
                            yrows = yrows';
                            ycols = ycols';
                        end
                        dyind = find(dy(:));
                        y.derivative{Vcount,2} = [yrows,ycols];
                        nzy = numel(dyind);
                        fprintf(fid,'cadadind1 = ');
                        cadaindprint(dxind,fid);
                        if xMrow*xNcol*nv > 250
                            fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xMrow*xNcol),',',int2str(nv),'],cadadind1);\n']);
                            fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},',',int2str(xMrow*xNcol),',',int2str(nv),');\n']);
                        else
                            fprintf(fid,[';\ncadatd1 = zeros(',int2str(xMrow*xNcol),',',int2str(nv),',cadaunit);\n']);
                            fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},';\n']);
                        end
                        fprintf(fid,'cadatd1 = sum(cadatd1);\n');
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        fprintf(fid,[derivstr,'(:) = cadatd1(']);
                        cadaindprint(dyind,fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
                    end
                end
            else
                %create row vector of sum of column vectors
                fprintf(fid,['cadaf',OPstr,'f = sum(',x.function{1},',1);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                
                y.function = cell(1,3);
                y.function{1} = ['cadaf',OPstr,'f'];
                y.function{2} = [1,xNcol];
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
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        dx = reshape(dx,xMrow,xNcol*nv);
                        dxind = find(dx(:));
                        dy = reshape(sum(dx),xNcol,nv);
                        dyind = find(dy(:));
                        [yrows,ycols] = find(dy);
                        if size(yrows,2) > 1
                            yrows = yrows';
                            ycols = ycols';
                        end
                        nzy = numel(dyind);
                        y.derivative{Vcount,2} = [yrows,ycols];
                        fprintf(fid,'cadadind1 = ');
                        cadaindprint(dxind,fid);
                        if xMrow*xNcol*nv > 250
                            fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xMrow),',',int2str(xNcol*nv),'],cadadind1);\n']);
                            fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},',',int2str(xMrow),',',int2str(xNcol*nv),');\n']);
                        else
                            fprintf(fid,[';\ncadatd1 = zeros(',int2str(xMrow),',',int2str(nv*xNcol),',cadaunit);\n']);
                            fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},';\n']);
                        end
                        fprintf(fid,'cadatd1 = sum(cadatd1);\n');
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        fprintf(fid,[derivstr,'(:) = cadatd1(']);
                        cadaindprint(dyind,fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
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
                %sum first row
                fprintf(fid,['cadaf',OPstr,'f = sum(',x.function{1},');\n']);
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
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        dxind = find(dx(:));
                        dy = sum(dx);
                        [yrows,ycols] = find(dy);
                        if size(yrows,2) > 1
                            yrows = yrows';
                            ycols = ycols';
                        end
                        dyind = find(dy(:));
                        y.derivative{Vcount,2} = [yrows,ycols];
                        nzy = numel(dyind);
                        fprintf(fid,'cadadind1 = ');
                        cadaindprint(dxind,fid);
                        if xMrow*xNcol*nv > 250
                            fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xMrow*xNcol),',',int2str(nv),'],cadadind1);\n']);
                            fprintf(fid,['cadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},',',int2str(xMrow*xNcol),',',int2str(nv),');\n']);
                        else
                            fprintf(fid,[';\ncadatd1 = zeros(',int2str(xMrow*xNcol),',',int2str(nv),',cadaunit);\n']);
                            fprintf(fid,['cadatd1(cadadind1) = ',x.derivative{Vcount,1},';\n']);
                        end
                        fprintf(fid,'cadatd1 = sum(cadatd1);\n');
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        fprintf(fid,[derivstr,'(:) = cadatd1(']);
                        cadaindprint(dyind,fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+6;
                    end
                end
            else
                %create column vector of sum of row vectors
                fprintf(fid,['cadaf',OPstr,'f = sum(',x.function{1},',1);\n']);
                GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
                
                y.function = cell(1,3);
                y.function{1} = ['cadaf',OPstr,'f'];
                y.function{2} = [xMrow,1];
                y.function{3} = GLOBALCADA.OPERATIONCOUNT;
                GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;
                xtemp = zeros(xMrow,xNcol);
                xtemp(:) = 1:xMrow*xNcol;
                xtemp = xtemp';
                
                y.derivative = cell(NUMvar,2);
                for Vcount = 1:NUMvar;
                    if ~isempty(x.derivative{Vcount,1})
                        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
                        y.derivative{Vcount,1} = derivstr;
                        xrows = x.derivative{Vcount,2}(:,1);
                        xcols = x.derivative{Vcount,2}(:,2);
                        nzx = length(xrows);
                        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
                        dx = sparse(xrows,xcols,(1:nzx)',xMrow*xNcol,nv);
                        dxind = zeros(nzx,2);
                        [xrows,xcols,dxind(:,1)] = find(dx(xtemp(:)',:));
                        dx = sparse(xrows,xcols,ones(nzx,1),xMrow*xNcol,nv);
                        dx = reshape(dx,xNcol,xMrow*nv);
                        dxind(:,2) = find(dx(:));
                        dy = reshape(sum(dx),xMrow,nv);
                        dyind = find(dy(:));
                        [yrows,ycols] = find(dy);
                        if size(yrows,2) > 1
                            yrows = yrows';
                            ycols = ycols';
                        end
                        nzy = numel(dyind);
                        y.derivative{Vcount,2} = [yrows,ycols];
                        fprintf(fid,'cadadind1 = ');
                        cadaindprint(dxind,fid);
                        if xMrow*xNcol*nv > 250
                            fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(xNcol),',',int2str(xMrow*nv),'],cadadind1);\n']);
                            fprintf(fid,'cadadind3 = ');
                            cadaindprint(dxind(:,1),fid);
                            fprintf(fid,[';\ncadatd1 = sparse(cadadind1,cadadind2,',x.derivative{Vcount,1},'(cadadind3),',int2str(xNcol),',',int2str(xMrow*nv),');\n']);
                        else
                            fprintf(fid,[';\ncadatd1 = zeros(',int2str(xNcol),',',int2str(xMrow*nv),',cadaunit);\n']);
                            fprintf(fid,'cadadind2 = ');
                            cadaindprint(dxind(:,1),fid);
                            fprintf(fid,[';\ncadatd1(cadadind1) = ',x.derivative{Vcount,1},'(cadadind2);\n']);
                        end
                        fprintf(fid,'cadatd1 = sum(cadatd1);\n');
                        fprintf(fid,[derivstr,' = zeros(',int2str(nzy),',cadaunit);\n']);
                        fprintf(fid,[derivstr,'(:) = cadatd1(']);
                        cadaindprint(dyind,fid);
                        fprintf(fid,');\n');
                        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+7;
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