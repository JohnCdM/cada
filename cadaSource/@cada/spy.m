function spy(x)
%CADA overloaded operation for spy
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao
% will spy for each derivative location

NUMvar = size(x.variable,1);
fsize = x.function{2}(1)*x.function{2}(2);
Dcount = 0;
for Vcount = 1:NUMvar
    if ~isempty(x.derivative{Vcount,1})
        Dcount = Dcount+1;
    end
end

figure(1)
D2count = 0;
for Vcount = 1:NUMvar
    if ~isempty(x.derivative{Vcount,1})
        nz = size(x.derivative{Vcount,2},1);
        nv = x.variable{Vcount,2}(1)*x.variable{Vcount,2}(2);
        dx = sparse(x.derivative{Vcount,2}(:,1),x.derivative{Vcount,2}(:,2),(1:nz)',fsize,nv);
        D2count = D2count+1;
        subplot(Dcount,1,D2count);
        spy(dx);
        xlabel(x.variable{Vcount,1});
        ylabel(x.function{1})
    end
end
    