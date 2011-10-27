function y = cada(varnumber, varname, Mrow, Ncol)
% CADA object creation function
% created by Michael Patterson

n = varnumber;
if ~ischar(varname)
    error('The variable name must be a string');
end
y.variable      = cell(n,2);
y.variable{n,1} = varname;
y.variable{n,2} = [Mrow, Ncol];

y.function = cell(Mrow,Ncol);
derivative = cell(Mrow.*Ncol,1);
indices    = zeros(Mrow.*Ncol,4);
indRow     = 1;
for Icount = 1:Mrow;
    for Jcount = 1:Ncol;
        % cell array for function
        y.function{Icount,Jcount} = [varname,'(',num2str(Icount),',',num2str(Jcount),')'];
        % cell array for derivative
        derivative{indRow,1} = '1';
        % numeric array for indices
        indices(indRow,:) = [Icount,Jcount,Icount,Jcount];
        indRow = indRow + 1;
    end
end

y.derivative      = cell(n,1);
y.derivative{n,1} = derivative;
y.derivative{n,2} = indices;

y = class(y,'cada');