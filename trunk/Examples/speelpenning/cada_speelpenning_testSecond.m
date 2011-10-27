function [timefunc, timeJacfile, timeJacfunc, timeHesfile, timeHeseval] = cada_speelpenning_testSecond(n)

tic
x = cadasetup('x',n,1,1);
y = speelpenning4sym(x, n);
timefunc = toc;

tic
cadajacobian(y,'speelpenningJacobian')
timeJacfile = toc;

clear x y

rehash

tic
x = cadasetup('x',n,1,1);
y = speelpenning_Jac(x);
timeJacfunc = toc;

tic
cadajacobian(y,'speelpenningHessian')
timeHesfile = toc;

clear x y

rehash

xx = rand(n,1);

tic
[Hyy, Jy] = speelpenningHessian(xx);
timeHeseval = toc;

delete speelpenningJacobian.m speelpenningHessian.m
