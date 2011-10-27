function y = sinh(x)
% CADA sinh function
% created by Michael Patterson

y.variable     = x.variable;
[FMrow, FNcol] = size(x.function);
NUMvar         = size(x.variable,1);

y.function = cell(FMrow,FNcol);
for FIcount = 1:FMrow;
    for FJcount = 1:FNcol;
        % cell array for function
        y.function{FIcount,FJcount} = ['sinh(',x.function{FIcount,FJcount},')'];
    end
end

y.derivative = cell(NUMvar,2);
for Acount = 1:NUMvar;
    if ~isempty(x.derivative{Acount,1})
        nz = size(x.derivative{Acount,1},1);
        y.derivative{Acount,1} = cell(nz,1);
        for Dcount = 1:nz;
            FI = x.derivative{Acount,2}(Dcount,1);
            FJ = x.derivative{Acount,2}(Dcount,2);
            if strcmp(x.derivative{Acount,1}{Dcount,1},'1')
                y.derivative{Acount,1}{Dcount,1} = ['cosh(',x.function{FI,FJ},')'];
            elseif strcmp(x.derivative{Acount,1}{Dcount,1},'-1')
                y.derivative{Acount,1}{Dcount,1} = ['-cosh(',x.function{FI,FJ},')'];
            else
                y.derivative{Acount,1}{Dcount,1} = ['cosh(',x.function{FI,FJ},').*(',x.derivative{Acount,1}{Dcount,1},')'];
            end
        end
        y.derivative{Acount,2} = x.derivative{Acount,2};
    end
end
y = class(y,'cada');