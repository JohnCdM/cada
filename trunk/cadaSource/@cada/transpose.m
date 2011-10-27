function y = transpose(x)
% CADA transpose function
% created by Michael Patterson

NUMvar     = size(x.variable,1);
y.variable = x.variable;
y.function = x.function.';

y.derivative = cell(NUMvar,2);
for Acount = 1:NUMvar;
    if ~isempty(x.derivative{Acount,1})
        [y.derivative{Acount,1}, y.derivative{Acount,2}] = cadasort(x.derivative{Acount,1}, x.derivative{Acount,2}(:,[2 1 3 4]));
    end
end
y = class(y,'cada');