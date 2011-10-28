function y = sind(x)
%CADA overloaded operation for sind
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

global GLOBALCADA
OPstr = int2str(GLOBALCADA.OPERATIONCOUNT);
fid = GLOBALCADA.FID;
if isnumeric(x.function{1})
    y.variable = x.variable;
    y.function = cell(1,2);
    y.function{1} = sind(x.function{1});
    y.function{2} = x.function{2};
    y.derivative = x.derivative;
    y = class(y,'cada');
    return
end

y.variable = x.variable;
NUMvar = size(x.variable,1);

% build y function
y.function = cell(1,3);
fprintf(fid,['cadaf',OPstr,'f = sind(',x.function{1},');\n']);
GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+1;
y.function{1} = ['cadaf',OPstr,'f'];
y.function{2} = x.function{2};
y.function{3} = GLOBALCADA.OPERATIONCOUNT;
GLOBALCADA.FUNCTIONLOCATION(y.function{3},1) = GLOBALCADA.LINECOUNT;

% build y derivative
y.derivative = cell(NUMvar,2);
for Vcount = 1:NUMvar
    if ~isempty(x.derivative{Vcount,1})
        derivstr = ['dcadaf',OPstr,'fd',x.variable{Vcount,1}];
        y.derivative{Vcount,1} = derivstr;
        fprintf(fid,['cadatf1 = ',x.function{1},'(']);
        cadaindprint(x.derivative{Vcount,2}(:,1),fid);
        fprintf(fid,');\n');
        fprintf(fid,[derivstr,' = (180/pi)*cosd(cadatf1(:)).*',x.derivative{Vcount,1},';\n']);
        GLOBALCADA.LINECOUNT = GLOBALCADA.LINECOUNT+2;
        y.derivative{Vcount,2} = x.derivative{Vcount,2};
    end
end
GLOBALCADA.FUNCTIONLOCATION(y.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.FUNCTIONLOCATION(x.function{3},2) = GLOBALCADA.LINECOUNT;
GLOBALCADA.OPERATIONCOUNT = GLOBALCADA.OPERATIONCOUNT+1;
y = class(y,'cada');