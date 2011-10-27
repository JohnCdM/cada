function [derivative, indices] = cadasort(derivativein, indicesin)
% cadasort function
% sorts the derivative with the indices
% created by Michael Patterson

[indices, Index] = sortrows(indicesin);
derivative = derivativein(Index,:);