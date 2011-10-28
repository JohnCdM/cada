function cadagenderiv(varargin)
%CADA general derivative function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao
%creates final derivative file (name given)

global GLOBALCADA
fidt = GLOBALCADA.FID;
NUMvarargin = length(varargin);
if NUMvarargin <= 1
    error('invalid number of inputs');
end
filename = varargin{NUMvarargin};
if ~isa(filename,'char')
    error('filename must be a string');
end
NUMevalfuncs = NUMvarargin-1;
numops = zeros(1,NUMevalfuncs);
for efcount = 1:NUMevalfuncs
    if ~isa(varargin{efcount},'cada')
        error('invalid input');
    else
        numops(efcount) = length(varargin{efcount}.function{3});
    end
end

%create file, create variables and derivatives
fid = fopen([filename,'.m'],'w+');
fprintf(fid,['function output = ',filename,'(input)\n']);

NUMvars = size(varargin{1}.variable,1);
for Vcount = 1:NUMvars
    cvarstr = varargin{1}.variable{Vcount,1};
    fprintf(fid,[cvarstr,' = input.',cvarstr,';\n']);
end
for Vcount = 1:NUMvars
    if varargin{1}.variable{Vcount,3} == 1
        fprintf(fid,['cadad',varargin{1}.variable{Vcount,1},'d',varargin{1}.variable{Vcount,1},' = ones(',int2str(varargin{1}.variable{Vcount,2}(1)*varargin{1}.variable{Vcount,2}(2)),',1);\n']);
    end
end
fprintf(fid,['cadaunit = size(',varargin{1}.variable{1,1},'(1),1);\n']);
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
for efcount = 1:NUMevalfuncs
    LC(varargin{efcount}.function{3},2) = LC(varargin{efcount}.function{3},1);
end

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
for efcount = 1:NUMevalfuncs
    fprintf(fid,['output.f',int2str(efcount),'.value = ',varargin{efcount}.function{1},';\n']);
    for Vcount = 1:NUMvars
        if ~isempty(varargin{efcount}.derivative{Vcount,1})
            fprintf(fid,['output.f',int2str(efcount),'.d',varargin{1}.variable{Vcount,1},'.value = ',varargin{efcount}.derivative{Vcount,1},';\n']);
            nz = size(varargin{efcount}.derivative{Vcount,2},1);
            fprintf(fid,['output.f',int2str(efcount),'.d',varargin{1}.variable{Vcount,1},'.location = zeros(',int2str(nz),',2);\n']);
            fprintf(fid,['output.f',int2str(efcount),'.d',varargin{1}.variable{Vcount,1},'.location(:,1) = ']);
            cadaindprint(varargin{efcount}.derivative{Vcount,2}(:,1),fid);
            fprintf(fid,[';\noutput.f',int2str(efcount),'.d',varargin{1}.variable{Vcount,1},'.location(:,2) = ']);
            cadaindprint(varargin{efcount}.derivative{Vcount,2}(:,2),fid);
            fprintf(fid,';\n');
        end
    end
end
fclose('all');
delete('cada.$#$#$temp@derivfile.m');