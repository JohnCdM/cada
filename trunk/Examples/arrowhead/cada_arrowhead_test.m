function [timefunc, timefile, timeeval] = cada_arrowhead_test(n)

tic
x = cadasetup('x',n,1,1);
y = arrowhead4cada(x);
timefunc = toc;

tic
cadajacobian(y,'arrowheadJacobian')
timefile = toc;

rehash

xx = rand(n,1);

tic
[yy, dyy] = arrowheadJacobian(xx);
timeeval = toc;

%delete arrowhead_der.m
