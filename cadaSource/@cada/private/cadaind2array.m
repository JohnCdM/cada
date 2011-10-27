function arrayderivative = cadaind2array(derivative, indices, arraysize)
% cadaind2array function
% converts indices and derivatives into array
% created by Michael Patterson

FM = arraysize(1);
FN = arraysize(2);
DM = arraysize(3);
DN = arraysize(4);

nz = size(derivative,1);

arrayderivative = cell(FM, FN, DM, DN);
for Dcount = 1:nz;
    FI = indices(Dcount,1);
    FJ = indices(Dcount,2);
    DK = indices(Dcount,3);
    DL = indices(Dcount,4);
    arrayderivative{FI, FJ, DK, DL} = derivative{Dcount};
end