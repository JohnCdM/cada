function x = cada(varnames,varloc,varsizes,dflag)
%CADA object creation function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

NUMvars = length(varnames);

x.variable = cell(NUMvars,3);
x.function = cell(1,3);
x.function{1,1} = varnames{varloc,:};
x.function{1,2} = [varsizes(varloc,1), varsizes(varloc,2)];
x.derivative = cell(NUMvars,2);


for Vcount = 1:NUMvars;
    x.variable{Vcount,1} = varnames{Vcount,:};
    x.variable{Vcount,2} = [varsizes(Vcount,1),varsizes(Vcount,2)];
    x.variable{Vcount,3} = dflag(Vcount);
end

if dflag(varloc) == 1
    dname = ['cadad',varnames{varloc,:},'d',varnames{varloc,:}];
    x.derivative{varloc,1} = dname;
    x.derivative{varloc,2}(:,1) = (1:varsizes(varloc,1)*varsizes(varloc,2))';
    x.derivative{varloc,2}(:,2) = (1:varsizes(varloc,1)*varsizes(varloc,2))';
end

x = class(x,'cada');