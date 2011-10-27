function yJac = speelpenningJacAnal(x, n)

yJac = zeros(1,n);
for Icount = 1:n;
    prodval = 1;
    for Jcount = 1:Icount-1;
        prodval = prodval.*x(Jcount);
    end
    for Jcount = Icount+1:n;
        prodval = prodval.*x(Jcount);
    end
    yJac(Icount) = prodval;
end