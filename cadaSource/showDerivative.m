function showDerivative(x)
% CADA showderivate function
% displays all th nonzero derivative(s)
% of the CADA object derivative property
% created by Michael Patterson

NUMarg = size(x.variable,1);
disp('Current CADA object derivative property:');

for Acount = 1:NUMarg;
    if ~isempty(x.variable{Acount,1})
        nz = size(x.derivative{Acount,1},1);
        disp(['  Showing nonzero derivatives with respect to variable ',num2str(Acount),': ''',x.variable{Acount,1},''' (',num2str(x.variable{Acount,2}(1)),' x ',num2str(x.variable{Acount,2}(2)),')']);
        for Dcount = 1:nz;
            disp(['     Derivative(',num2str(x.derivative{Acount,2}(Dcount,1)),',',num2str(x.derivative{Acount,2}(Dcount,2)),',',num2str(x.derivative{Acount,2}(Dcount,3)),',',num2str(x.derivative{Acount,2}(Dcount,4)),') = ',x.derivative{Acount,1}{Dcount}]);
        end
        disp(' ');
    end
end
