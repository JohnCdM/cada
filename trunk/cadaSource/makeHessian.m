function makeHessian(Lag, X, sig, lam)

% make Hessian ------------------------------------------------------------

% create file for Gradient
fid = fopen('cada_Temp.m','w');
fprintf(fid,['function GL = cada_Temp(',Lag.variable{1,1},', sig, lam)\n']);
fprintf(fid,'%% This function was generated using CADA\n\n');

% initialize zeros for size of G
fprintf(fid,['GL = zeros(1,size(',Lag.variable{1,1},',1));\n']);

nz = size(X.derivative{1,1});
% print nonzero elements
for Icount = 1:nz;
    fprintf(fid,['GL(',num2str(Lag.derivative{1,2}(Icount,1)),',',num2str(Lag.derivative{1,2}(Icount,3)),') = ',Lag.derivative{1,1}{Icount},';\n']);
end
fclose(fid);

% Get Hessian
GL = feval('cada_Temp',X, sig, lam);


fid = fopen('cada_Hes.m','w');
fprintf(fid,['function H = cada_Hes(',X.variable{1,1},', sig, lam)\n']);
fprintf(fid,'%% This function was generated using CADA\n\n');

% initialize zeros for size of G
fprintf(fid,['H = sparse(zeros(size(',X.variable{1,1},',1)));\n']);

nz = size(GL.derivative{1,1});
% print nonzero elements
for Icount = 1:nz;
    if GL.derivative{1,2}(Icount,2) >= GL.derivative{1,2}(Icount,3)
        fprintf(fid,['H(',num2str(GL.derivative{1,2}(Icount,2)),',',num2str(GL.derivative{1,2}(Icount,3)),') = ',GL.derivative{1,1}{Icount},';\n']);
    end
end
fclose(fid);

fid = fopen('cada_HesStruc.m','w');
fprintf(fid,['function HS = cada_HesStruc()\n']);
fprintf(fid,'%% This function was generated using CADA\n\n');

% initialize zeros for size of G
fprintf(fid,['HS = sparse(zeros(',num2str(size(GL.function,2)),'));\n']);

nz = size(GL.derivative{1,1});
% print nonzero elements
for Icount = 1:nz;
    if GL.derivative{1,2}(Icount,2) >= GL.derivative{1,2}(Icount,3)
        fprintf(fid,['HS(',num2str(GL.derivative{1,2}(Icount,2)),',',num2str(GL.derivative{1,2}(Icount,3)),') = 1;\n']);
    end
end
fclose(fid);

filelist = ls;
iscadaHessEmpty = findstr(filelist,'cada_Hes');
while isempty(iscadaHessEmpty),
    iscadaHessEmpty = findstr(filelist,'cada_Hes');
end;

filelist = ls;
iscadaHessStrucEmpty = findstr(filelist,'cada_HesStruc');
while isempty(iscadaHessStrucEmpty),
    iscadaHessStrucEmpty = findstr(filelist,'cada_HesStruc');
end;
