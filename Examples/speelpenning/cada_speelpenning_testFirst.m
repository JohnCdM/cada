function [timefunc, timeJacfile, timeJaceval] = cada_speelpenning_testFirst(n)

tic
x = cadasetup('x',n,1,1);
y = speelpenning4sym(x, n);
timefunc = toc;

tic
cadajacobian(y,'speelpenningJacobian')
timeJacfile = toc;

rehash

xx = rand(n,1)+1;

tic
[yy, dyy] = speelpenningJacobian(xx);
timeJaceval = toc;

delete speelpenningJacobian.m
