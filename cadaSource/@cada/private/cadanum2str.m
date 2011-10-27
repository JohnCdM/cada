function y = cadanum2str(A)
% simconstant function
% converts numeric array into cell array of strings
% created by Michael Patterson

[Nrow, Mcol] = size(A);
y = cell(Nrow,Mcol);
for FIcount = 1:Nrow;
    for FJcount = 1:Mcol;
        % cell array for function
        y{FIcount,FJcount} = num2str(A(FIcount,FJcount),16);
    end
end