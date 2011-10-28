function varargout = cadasetup(varargin)
%CADA constructor variable setup function
%Algorithm reated by Michael Patterson, Matt Weinstein and Anil V. Rao
varargSize = length(varargin);
if varargSize < 3
    error('insufficient number of inputs')
end

global GLOBALCADA
GLOBALCADA.OPERATIONCOUNT = 1;
GLOBALCADA.LINECOUNT = 0;
GLOBALCADA.FUNCTIONLOCATION = [0 0];
GLOBALCADA.FID = fopen('cada.$#$#$temp@derivfile.m','w+');
%find number of variables
incount = 1;
NUMvars = 0;
while incount <= varargSize
    if ~ischar(varargin{incount})
        error('CADA variable name must be character')
    elseif ~isempty(strfind(varargin{incount},'CADAd'))
        error('CADA variable name must not include ''CADAd''')
    elseif ~isempty(strfind(varargin{incount},'CADAf'))
        error('CADA variable name must not include ''CADAf''')
        elseif isempty(strcmp(varargin{incount},'CADAunit'))
        error('invalid cada variable name ''CADAunit''')
    end
    incount = incount+1;
    if ~isnumeric(varargin{incount}) || floor(varargin{incount}) ~= varargin{incount}
        error('CADA row size must be integer')
    end
    incount = incount+1;
    if ~isnumeric(varargin{incount}) || floor(varargin{incount}) ~= varargin{incount}
        error('CADA column size must be integer')
    end
    incount = incount+1;
    NUMvars = NUMvars+1;
    if incount <= varargSize && (varargin{incount} == 0 || varargin{incount} == 1)
        incount = incount+1;
    end
end


varname = cell(NUMvars,1);
s = zeros(NUMvars,2);
dflag = ones(NUMvars,1);
Vcount = 1;
incount = 1;
while incount <= varargSize
    varname{Vcount,1} = varargin{incount};
    incount = incount+1;
    s(Vcount,1) = varargin{incount};
    incount = incount+1;
    s(Vcount,2) = varargin{incount};
    incount = incount+1;
    if incount <= varargSize
        if varargin{incount} == 0
            dflag(Vcount) = 0;
            incount = incount+1;
        elseif varargin{incount} == 1
            incount = incount+1;
        end
    end
    Vcount = Vcount+1;
end


for Vcount = 1:NUMvars
    varargout{Vcount} = cada(varname,Vcount,s,dflag); 
end