function y = vertcat(varargin)
% CADA vertcat function
% created by Michael Patterson

NUMinput = size(varargin,2);
% find cada objects
LOCsim = find(cellfun('isclass',varargin,'cada'));
NUMsimdiff = length(LOCsim);
MAXarg = 0;
% find the highest variable of all cada objects
% find the output function size
NcolMAP = zeros(1,NUMinput);
if isa(varargin{1},'cada')
    yfun = varargin{1}.function;
    NUMvar = size(varargin{1}.variable,1);
    if NUMvar > MAXarg
        MAXarg = NUMvar;
    end
else
    yfun = cadanum2str(varargin{1});
end
NcolMAP(1,1) = size(yfun,1);
for Inputcount = 2:NUMinput;
    if isa(varargin{Inputcount},'cada')
        yfun = [yfun; varargin{Inputcount}.function];
        NUMvar = size(varargin{Inputcount}.variable,1);
        if NUMvar > MAXarg
            MAXarg = NUMvar;
        end
    else
        yfun = [yfun; cadanum2str(varargin{Inputcount})];
    end
    NcolMAP(1,Inputcount) = size(yfun,1);
end
% define variable property
y.variable = cell(MAXarg,2);
y.function = yfun;
y.derivative = cell(MAXarg,2);
for Scount = 1:NUMsimdiff;
    if size(varargin{LOCsim(Scount)}.variable,1) < MAXarg
        varargin{LOCsim(Scount)}.variable{MAXarg,2} = [];
        varargin{LOCsim(Scount)}.derivative{MAXarg,2} = [];
    end;
    for Acount = 1:MAXarg;
        if ~isempty(varargin{LOCsim(Scount)}.variable{Acount,1})
            y.variable(Acount,:) = varargin{LOCsim(Scount)}.variable(Acount,:);
        end
    end
end
% define derivative property
for Acount = 1:MAXarg;
    if isa(varargin{1},'cada')
        if ~isempty(varargin{1}.derivative{Acount,1}) && ~isempty(y.variable{Acount,1})
            y.derivative(Acount,:) = varargin{1}.derivative(Acount,:);
        else
            y.derivative{Acount,1} = [];
            y.derivative{Acount,2} = [];
        end
    end
    for Inputcount = 2:NUMinput;
        if isa(varargin{Inputcount},'cada')
            if ~isempty(varargin{Inputcount}.derivative{Acount,1}) && ~isempty(y.variable{Acount,1})
                varargin{Inputcount}.derivative{Acount,2}(:,1) = varargin{Inputcount}.derivative{Acount,2}(:,1) + NcolMAP(Inputcount-1);
                y.derivative{Acount,1} = [y.derivative{Acount,1}; varargin{Inputcount}.derivative{Acount,1}];
                y.derivative{Acount,2} = [y.derivative{Acount,2}; varargin{Inputcount}.derivative{Acount,2}];
            end
        end
    end
    [y.derivative{Acount,1}, y.derivative{Acount,2}] = cadasort(y.derivative{Acount,1}, y.derivative{Acount,2});
end
y = class(y,'cada');