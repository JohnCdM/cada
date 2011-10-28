function [z,xind,yind] = cadaunion(x,y,m,n)
%CADA derivative union function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

xrows = x(:,1);
xcols = x(:,2);
nzx = size(x,1);
yrows = y(:,1);
ycols = y(:,2);
nzy = size(y,1);

x = sparse(xrows,xcols,-ones(nzx,1),m,n);
y = sparse(yrows,ycols,2*ones(nzy,1),m,n);

z = x+y;

[zrows,zcols,zind] = find(z);
if size(zrows,2) > 1
    zrows = zrows';
    zcols = zcols';
    zind = zind';
end
z = [zrows,zcols];

xind = find(zind<2);
yind = find(zind>0);