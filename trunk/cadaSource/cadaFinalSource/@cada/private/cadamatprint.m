function cadamatprint(fid,A,varname)
%CADA numerical matrix printing function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA

[M,N] = size(A);
if issparse(A)
    [rows,~,vals] = find(A(:));
    nv = length(vals);
    fprintf(fid,[varname,' = spalloc(',int2str(M),',',int2str(N),',',int2str(nv),');\n']);
    
    fprintf(fid,'cadatfind1 = ');
    cadaindprint(rows,fid);
    if nv == 1
         fprintf(fid,[';\n',varname,'(cadatfind1) = ',num2str(vals,16),';\n']);
    else
        fprintf(fid,[';\n',varname,'(cadatfind1) = [']);
        for I = 1:length(vals)
            fprintf(fid,[num2str(vals(I),16),' ']);
        end
        fprintf(fid,'];\n');
    end
    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+3;
else
    fprintf(fid,[varname,' = zeros(',int2str(M),',',int2str(N),');\n']);
    fprintf(fid,[varname,'(:) = [']);
    for J = 1:N
        for I = 1:M
            fprintf(fid,[num2str(A(I,J),16),' ']);
        end
    end
    fprintf(fid,'];\n');
    GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
end