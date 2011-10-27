function [timefunc, timeJacfile, timeJacfunc, timeHesfile, timeJaceval, timeHeseval] = cada_speelpenning_test(n)

tic
x = cada6setup('x',n,1,1);
y = speelpenning4sym(x, n);
timefunc = toc;

tic
cadajacobian(y,'speelpenningJacobian')
timeJacfile = toc;

clear x y

rehash

tic
x = cada6setup('x',n,1,1);
y = speelpenningJacobian(x);
%y = speelpenning4sym(x, n);
timeJacfunc = toc;

tic
cadajacobian(y,'speelpenningHessian')
timeHesfile = toc;

xx = rand(n,1);

tic
[yy, dyy] = speelpenningJacobian(xx);
timeJaceval = toc;

tic
[Jy, Hyy] = speelpenningHessian(xx);
timeHeseval = toc;

delete speelpenningJacobian.m speelpenningHessian.m
