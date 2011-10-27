function showFunction(x)
% CADA showfunction function
% displays all function(s) of the
% CADA object function property
% created by Michael Patterson

[FMrow, FNcol] = size(x.function);

disp('Current CADA object function property:');
for Icount = 1:FMrow;
    for Jcount = 1:FNcol;
        disp(['   Function(',num2str(Icount),',',num2str(Jcount),') = ',x.function{Icount,Jcount}]);
    end
end
disp(' ');
