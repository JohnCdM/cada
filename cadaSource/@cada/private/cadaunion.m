function [uderivative, uindices] = cadaunion(xderivative, xindices, yderivative, yindices)
% cadaunion function
% finds the union of the indices and derivatives 
% of 2 simdiff objects
% created by Michael Patterson

[uindices, Ix, Iy] = intersect(xindices,yindices,'rows');
% col 1 is ref x, col2 is ref y
uderivative(:,1:2) = [xderivative(Ix,1), yderivative(Iy,1)];

% remove intersecting cells and indices
xindices(Ix,:) = [];
yindices(Iy,:) = [];
xderivative(Ix,:) = [];
yderivative(Iy,:) = [];

% build union of x and y,
uindices = [uindices; xindices; yindices];
xsize = size(xderivative,1);
ysize = size(yderivative,1);
uderivative = [uderivative; [xderivative, cell(xsize,1)]; [cell(ysize,1), yderivative]];

% sort by rows
[uderivative, uindices] = cadasort(uderivative, uindices);