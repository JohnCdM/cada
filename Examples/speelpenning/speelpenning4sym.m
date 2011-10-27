function y = speelpenning4sym(x, n)

y = x(1);
for Icount = 2:n;
   y = y.*x(Icount); 
end