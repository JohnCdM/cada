function y = length(x)
%CADA overloaded operation for length
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

y.variable = x.variable;
y.function = cell(1,3);
y.function{1} = max(x.function{2});
y.function{2} = [1,1];
y.derivative = cell(size(x.variable,1));
y = class(y,'cada');