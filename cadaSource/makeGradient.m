function makeGradient(X)

% Make Gradient to objective ----------------------------------------------

% create file for Gradient
fid = fopen('cada_Grd.m','w');
fprintf(fid,['function G = cada_Grd(',X.variable{1,1},')\n']);
fprintf(fid,'%% This function was generated using CADA\n\n');

% initialize zeros for size of G
fprintf(fid,['G = zeros(1,size(',X.variable{1,1},',1));\n']);

nz = size(X.derivative{1,1});
% print nonzero elements
for Icount = 1:nz;
    fprintf(fid,['G(',num2str(X.derivative{1,2}(Icount,1)),',',num2str(X.derivative{1,2}(Icount,3)),') = ',X.derivative{1,1}{Icount},';\n']);
end
fclose(fid);
filelist = ls;
iscadaJacEmpty = findstr(filelist,'cada_Grd');
while isempty(iscadaJacEmpty),
    iscadaJacEmpty = findstr(filelist,'cada_Grd');
end;
