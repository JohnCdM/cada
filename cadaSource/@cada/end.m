function out = end(x, Dim ,NumDim)
% CADA end function
% created by Michael Patterson

if NumDim == 1,
    out = length(x.function(:));
else
    out = size(x.function,Dim);
end
