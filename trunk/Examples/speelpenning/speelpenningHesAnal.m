function yHes = speelpenningHesAnal(x, n)

%not done

yHes = zeros(n,n);
for Icount = 1:n;
    for Jcount = 1:n;
        prodval = 1;
        for Jcount = 1:Icount-1;
            prodval = prodval.*x(Jcount);
        end
        for Jcount = Icount+1:n;
            prodval = prodval.*x(Jcount);
        end
        yHes(Icount,Jcount) = prodval;
    end
end