function cadahessian(x,filename,varargin)
%CADA hessian function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao
%creates final derivative file (name given)

global GLOBALCADA
fidt = GLOBALCADA.FID;

if ~isa(filename,'char')
    error('filename must be a string');
end
if max(x.function{2}) > 1
    error('cadahessian may only be used for a scalar function of a vector.')
end
NUMvars = size(x.variable,1);
CVcount = 0;
for Vcount = 1:NUMvars
    if x.variable{Vcount,3} == 1
        if min(x.variable{Vcount,2}) > 1
            error('cadahessian may only be used for a scalar function of a vector.')
        end
        CVcount = CVcount+1;
        cvloc = Vcount;
    end
end
if CVcount > 1
    error('cadahessian may only be used with a single constructor variable')
end

%create file, create variables and derivatives
fid = fopen([filename,'.m'],'w+');
fprintf(fid,['function [jac,func] = ',filename,'(']);
for Vcount = 1:NUMvars
    if Vcount == NUMvars
        fprintf(fid,[x.variable{Vcount,1},')\n']);
    else
        fprintf(fid,[x.variable{Vcount,1},',']);
    end
end
for Vcount = 1:NUMvars
    if x.variable{Vcount,3} == 1
        fprintf(fid,['cadad',x.variable{Vcount,1},'d',x.variable{Vcount,1},' = ones(',int2str(x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2)),',1);\n']);
    end
end
fprintf(fid,['cadaunit = size(',x.variable{1,1},'(1),1);\n']);
%read from temp file, write to new file while clearing unused functions
%and derivatives after last found instance

N = size(GLOBALCADA.FUNCTIONLOCATION,1);
LC = zeros(N,4);
LC(:,1:2) = repmat((1:N)',1,2);
LC(:,3:4) = GLOBALCADA.FUNCTIONLOCATION;
LC = sortrows(LC,4);

J = 1;
for I = 2:N
    if LC(I,3) > LC(J,4)
        LC(I,2) = LC(J,2);
        J = J+1;
    end
end
LC = sortrows(LC,1);
LC(x.function{3},2) = LC(x.function{3},1);

frewind(fidt);
str = fgets(fidt);
while str ~= -1
    
    s = regexp(str,'cadaf(\w*)+f','tokens');
    if ~isempty(s)
        ops = zeros(length(s),2);
        for I = 1:length(s)
            ops(I,1) = str2double(s{I}{1});
        end
        ops(:,2) = LC(ops(:,1),2);
        for I = 1:length(s)
            if ops(I,1) ~= ops(I,2)
                str = strrep(str,['cadaf',s{I}{1},'f'],['cadaf',int2str(ops(I,2)),'f']);
            end
        end
        fprintf(fid,str);
    else
        fprintf(fid,str);
    end
    str = fgets(fidt);
end
fprintf(fid,['jac = ',x.derivative{cvloc,1},';\n']);
fprintf(fid,['func = ',x.function{1},';\n']);
fclose(fid);
%Jacobian created without projecting derivatives into sparse matrix
%Create cada objects and evaluate Jacobian using eval
rehash
if NUMvars > 1
    evalstr = '[';
    for Vcount = 1:NUMvars-1
        evalstr = sprintf([evalstr,'v',int2str(Vcount),',']);
    end
    evalstr = sprintf([evalstr,'v',int2str(NUMvars),'] = cadasetup(']);
    for Vcount = 1:NUMvars-1
        if Vcount == cvloc
            evalstr = sprintf([evalstr,'''',x.variable{Vcount,1},''',',int2str(x.variable{Vcount,2}(1)),',',int2str(x.variable{Vcount,2}(2)),',1,']);
        else
            evalstr = sprintf([evalstr,'''',x.variable{Vcount,1},''',',int2str(x.variable{Vcount,2}(1)),',',int2str(x.variable{Vcount,2}(2)),',0,']);
        end
    end
    if NUMvars == cvloc
        evalstr = sprintf([evalstr,'''',x.variable{NUMvars,1},''',',int2str(x.variable{NUMvars,2}(1)),',',int2str(x.variable{NUMvars,2}(2)),',1);']);
    else
        evalstr = sprintf([evalstr,'''',x.variable{NUMvars,1},''',',int2str(x.variable{NUMvars,2}(1)),',',int2str(x.variable{NUMvars,2}(2)),',0);']);
    end
    eval(evalstr);
    evalstr = ['[jac, func] = ',filename,'('];
    for Vcount = 1:NUMvars-1
        evalstr = sprintf([evalstr,'v',int2str(Vcount),',']);
    end
    evalstr = sprintf([evalstr,'v',int2str(NUMvars),');']);
    eval(evalstr);
else
    evalstr = ['v1 = cada6setup(''',x.variable{1,1},''',',int2str(x.variable{1,2}(1)),',',int2str(x.variable{1,2}(2)),');'];
    eval(evalstr);
    evalstr = ['[jac, func] = ',filename,'(v1);'];
    eval(evalstr);
end
delete([filename,'.m']);
rehash


%create file, create variables and derivatives
fid = fopen([filename,'.m'],'w+');
fprintf(fid,['function [Hes,Grd,Fun] = ',filename,'(']);
for Vcount = 1:NUMvars
    if Vcount == NUMvars
        fprintf(fid,[x.variable{Vcount,1},')\n']);
    else
        fprintf(fid,[x.variable{Vcount,1},',']);
    end
end
for Vcount = 1:NUMvars
    if x.variable{Vcount,3} == 1
        fprintf(fid,['cadad',x.variable{Vcount,1},'d',x.variable{Vcount,1},' = ones(',int2str(x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2)),',1);\n']);
    end
end
fprintf(fid,['cadaunit = size(',x.variable{1,1},'(1),1);\n']);
%read from temp file, write to new file while clearing unused functions
%and derivatives after last found instance
fidt = GLOBALCADA.FID;
N = size(GLOBALCADA.FUNCTIONLOCATION,1);
LC = zeros(N,4);
LC(:,1:2) = repmat((1:N)',1,2);
LC(:,3:4) = GLOBALCADA.FUNCTIONLOCATION;

LC = sortrows(LC,4);

J = 1;
for I = 2:N
    if LC(I,3) > LC(J,4)
        LC(I,2) = LC(J,2);
        J = J+1;
    end
end

LC = sortrows(LC,1);
LC(func.function{3},2) = LC(func.function{3},1);
LC(jac.function{3},2) = LC(jac.function{3},1);


frewind(fidt);
str = fgets(fidt);
while str ~= -1
    
    s = regexp(str,'cadaf(\w*)+f','tokens');
    if ~isempty(s)
        ops = zeros(length(s),2);
        for I = 1:length(s)
            ops(I,1) = str2double(s{I}{1});
        end
        ops(:,2) = LC(ops(:,1),2);
        for I = 1:length(s)
            if ops(I,1) ~= ops(I,2)
                str = strrep(str,['cadaf',s{I}{1},'f'],['cadaf',int2str(ops(I,2)),'f']);
            end
        end
        fprintf(fid,str);
    else
        fprintf(fid,str);
    end
    str = fgets(fidt);
end

%define function output
hessind = sub2ind([x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)],...
    x.derivative{cvloc,2}(jac.derivative{cvloc,2}(:,1),2),jac.derivative{cvloc,2}(:,2));
fprintf(fid,'cadadind1 = ');
cadaindprint(hessind,fid);
fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)),',',...
    int2str(x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)),'],cadadind1);\n']);
fprintf(fid,['Hes = sparse(cadadind1,cadadind2,',jac.derivative{cvloc,1},',%1.0f,%1.0f);\n']...
    ,x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2));
nzj = size(x.derivative{cvloc,2},1);
fprintf(fid,'cadadind1 = ');
cadaindprint(x.derivative{cvloc,2}(:,2),fid);
fprintf(fid,[';\nGrd = sparse(ones(1,%1.0f),cadadind1,',jac.function{1},',%1.0f,%1.0f);\n'],nzj,...
    x.function{2}(1)*x.function{2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2));
fprintf(fid,['Fun = ',func.function{1},';\n']);

if length(varargin) == 1
    if ~isa(varargin{1},'char')
        error('filename must be a string');
    end
    fid2 = fopen([varargin{1},'.m'],'w+');
    fprintf(fid2,['function [HesPat,GrdPat] = ',varargin{1},'\n']);
    nzh = size(jac.derivative{cvloc,2},1);
    fprintf(fid2,'cadadind1 = ');
    cadaindprint(hessind,fid2);
    fprintf(fid2,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)),',',...
        int2str(x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)),'],cadadind1);\n']);
    fprintf(fid2,'HesPat = sparse(cadadind1,cadadind2,ones(%1.0f,1),%1.0f,%1.0f);\n',nzh...
        ,x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2));
    fprintf(fid2,'cadadind1 = ');
    cadaindprint(x.derivative{cvloc,2}(:,2),fid2);
    fprintf(fid2,';\nGrdPat = sparse(ones(1,%1.0f),cadadind1,ones(%1.0f,1),%1.0f,%1.0f);\n',nzj,nzj,...
        x.function{2}(1)*x.function{2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2));
elseif length(varargin) > 1
    error('too many input arguments');
end

fclose('all');
delete('cada.$#$#$temp@derivfile.m');