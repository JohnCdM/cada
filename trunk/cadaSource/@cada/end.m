function out = end(x, Dim ,NumDim)
%CADA overloaded operation for end
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

if NumDim == 1,
    out = x.function{1,2}(1).*x.function{1,2}(2);
else
    out = x.function{1,2}(Dim);
end
