function y = length(x)
% CADA length function
% created by Michael Patterson

out = length(x.function);
y.variable = x.variable;
y.function = cadanum2str(out);
y.derivative = cell(size(x.variable));
y = class(y,'cada');