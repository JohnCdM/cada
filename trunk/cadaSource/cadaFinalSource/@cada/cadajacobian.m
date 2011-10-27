function cadajacobian(x,filename,varargin)
%CADA jacobian function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao
%creates final derivative file (name given)

global GLOBALCADA
fidt = GLOBALCADA.FID;

if ~isa(filename,'char')
    error('filename must be a string');
end
if min(x.function{2}) > 1
    error('cadajacobian may only be used for a vector function of a vector.')
end
NUMvars = size(x.variable,1);
CVcount = 0;
for Vcount = 1:NUMvars
    if x.variable{Vcount,3} == 1
        if min(x.variable{Vcount,2}) > 1
            error('cadajacobian may only be used for a vector function of a vector.')
        end
        CVcount = CVcount+1;
        cvloc = Vcount;
    end
end
if CVcount > 1
    error('cadajacobian may only be used with a single constructor variable')
end

%create file, create variables and derivatives
fid = fopen([filename,'.m'],'w+');
fprintf(fid,['function [Jac,Fun] = ',filename,'(']);
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
jacind = sub2ind([x.function{2}(1)*x.function{2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)],...
    x.derivative{cvloc,2}(:,1),x.derivative{cvloc,2}(:,2));
fprintf(fid,'cadadind1 = ');
cadaindprint(jacind,fid);
fprintf(fid,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(x.function{2}(1)*x.function{2}(2)),',',...
    int2str(x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)),'],cadadind1);\n']);
fprintf(fid,['Jac = sparse(cadadind1,cadadind2,',x.derivative{cvloc,1},',%1.0f,%1.0f);\n'],...
    x.function{2}(1)*x.function{2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2));
fprintf(fid,['Fun = ',x.function{1},';']);

if length(varargin) == 1
    if ~isa(varargin{1},'char')
        error('filename must be a string');
    end
    fid2 = fopen([varargin{1},'.m'],'w+');
    nz = size(x.derivative{cvloc,2},1);
    fprintf(fid2,['function JacPat = ',varargin{1},'\n']);
    fprintf(fid2,'cadadind1 = ');
    cadaindprint(jacind,fid2);
    fprintf(fid2,[';\n[cadadind1,cadadind2] = ind2sub([',int2str(x.function{2}(1)*x.function{2}(2)),',',...
        int2str(x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2)),'],cadadind1);\n']);
    fprintf(fid2,'JacPat = sparse(cadadind1,cadadind2,ones(%1.0f,1),%1.0f,%1.0f);',nz,...
        x.function{2}(1)*x.function{2}(2),x.variable{cvloc,2}(1)*x.variable{cvloc,2}(2));
elseif length(varargin) > 1
    error('too many input arguments');
end

fclose('all');
delete('cada.$#$#$temp@derivfile.m');