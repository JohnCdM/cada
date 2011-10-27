function y = arrowhead4cada(x)

y = zeros(size(x));
y(1) = 2*x(1).^2+sum(x.^2);
y(2:end) = x(1).^2+x(2:end).^2;


