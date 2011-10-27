function [derivative, indices] = cadaarray2ind(arrayderivative)
% cadaarray2ind function
% converts derivative array into indices and derivatives
% created by Michael Patterson

FMrow = size(arrayderivative,1);
FNcol = size(arrayderivative,2);
DMrow = size(arrayderivative,3);
DNcol = size(arrayderivative,4);
indRow = 1;
% preallocate bigger then needed
derivative = cell(FMrow.*FNcol.*DMrow.*DNcol,1);
indices = zeros(FMrow.*FNcol.*DMrow.*DNcol,4);
for FIcount = 1:FMrow;
    for FJcount = 1:FNcol;
        for DIcount = 1:DMrow;
            for DJcount = 1:DNcol;
                if ~isempty(arrayderivative{FIcount,FJcount,DIcount,DJcount})
                    indices(indRow,:) = [FIcount,FJcount,DIcount,DJcount];
                    derivative{indRow,1} = arrayderivative{FIcount,FJcount,DIcount,DJcount};
                    indRow = indRow + 1;
                end
            end
        end
    end
end
if indRow == 1
    indices = [];
    derivative = [];
else
    % remove the unused portions
    indRow = indRow-1;
    indices = indices(1:indRow,:);
    derivative = derivative(1:indRow,:);
end
% sort by rows
[derivative, indices] = cadasort(derivative, indices);