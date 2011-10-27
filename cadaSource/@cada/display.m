function display(x)
% CADA display function
% created by Michael Patterson

[FMrow, FNcol] = size(x.function);
NUMvar         = size(x.variable,1);

disp('Current CADA object property information:');
disp('Size of current CADA function array:');
disp(['     ',num2str(FMrow),' x ',num2str(FNcol)]);
disp(' ');
disp('Comprised of the following constructor variable(s):');
for Acount = 1:NUMvar;
    if ~isempty(x.variable{Acount,1})
        disp(['     variable ',num2str(Acount),': ''',x.variable{Acount,1},''' (',num2str(x.variable{Acount,2}(1)),' x ',num2str(x.variable{Acount,2}(2)),')']);
    end
end
disp(' ');
disp('Number of nonzero derivatives with respect to each variable');
for Acount = 1:NUMvar;
    if ~isempty(x.variable{Acount,1})
        disp(['     ',num2str(size(x.derivative{Acount,1},1)),' nonzero derivatives with respect to ''',x.variable{Acount,1},'''']);
    end
end
disp(' ');
