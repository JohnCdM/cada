function makeJacobian(X)
NumCon = size(X.function,1);
% Make Jacobian -----------------------------------------------------------

% create file for Jacobian
fid = fopen('cada_Jac.m','w');
fprintf(fid,['function Jac = cada_Jac(',X.variable{1,1},')\n']);
fprintf(fid,'%% This function was generated using CADA\n\n');

% initialize zeros for size of G
fprintf(fid,['Jac = sparse(zeros(',num2str(NumCon),',size(',X.variable{1,1},',1)));\n']);

nz = size(X.derivative{1,1});
% print nonzero elements
for Icount = 1:nz;
    fprintf(fid,['Jac(',num2str(X.derivative{1,2}(Icount,1)),',',num2str(X.derivative{1,2}(Icount,3)),') = ',X.derivative{1,1}{Icount},';\n']);
end
fclose(fid);

% Make Jacobian structure -------------------------------------------------
% create file for Jacobian Structure
fid = fopen('cada_JacStruc.m','w');
fprintf(fid,'function JacS = cada_JacStruc()\n');
fprintf(fid,'%% This function was generated using CADA\n\n');

% initialize zeros for size of Jacobian
fprintf(fid,['JacS = sparse(zeros(',num2str(NumCon),',',num2str(size(X.function,1)),'));\n']);

% print nonzero elements
for Icount = 1:nz;
    fprintf(fid,['JacS(',num2str(X.derivative{1,2}(Icount,1)),',',num2str(X.derivative{1,2}(Icount,3)),') = 1;\n']);
end
fclose(fid);

filelist = ls;
iscadaJacEmpty = findstr(filelist,'cada_Jac');
while isempty(iscadaJacEmpty),
    iscadaJacEmpty = findstr(filelist,'cada_Jac');
end;

filelist = ls;
iscadaJacStrucEmpty = findstr(filelist,'cada_JacStruc');
while isempty(iscadaJacStrucEmpty),
    iscadaJacStrucEmpty = findstr(filelist,'cada_JacStruc');
end;
