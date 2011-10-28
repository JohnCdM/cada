function display(x)
%CADA overloaded operation for display
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

FMrow = x.function{1,2}(1);
FNcol = x.function{1,2}(2);

NUMvar         = size(x.variable,1);
if isnumeric(x.function{1})
    disp('Current numeric CADA object property information:');
    disp('Current numerical values of CADA function:');
    disp(x.function{1});
    disp('Member of CADA session tracking variables:')
    for Vcount = 1:NUMvar
        disp(['     ''',x.variable{Vcount,1},'''      size: ',int2str(x.variable{Vcount,2}(1)),' x ',int2str(x.variable{Vcount,2}(2))]);
    end
    disp(' ');
else
    disp('Current CADA object property information:');
    disp('CADA function identifier:');
    disp(['     ''',x.function{1},'''     size: ',int2str(FMrow),' x ',int2str(FNcol)]);
    disp('Member of CADA session tracking variables:')
    for Vcount = 1:NUMvar
        disp(['     ''',x.variable{Vcount,1},'''      size: ',int2str(x.variable{Vcount,2}(1)),' x ',int2str(x.variable{Vcount,2}(2))]);
    end
    
    disp('Number of nonzero derivatives with respect to each variable:');
    for Vcount = 1:NUMvar;
        if ~isempty(x.variable{Vcount,1})
            disp(['     ',int2str(size(x.derivative{Vcount,2},1)),' nonzero derivatives with respect to ''',x.variable{Vcount,1},'''']);
        end
    end
    disp(' ');
end