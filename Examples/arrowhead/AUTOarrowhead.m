function AUTOarrowhead
% This function performs a computation time test on the generation of first 
% derivatives for the Arrowhead function.  The Arrowhead function is defined
% as follows:
% f = zeros(size(x));
% f(1) = 2*x(1).^2+sum(x.^2);
% f(2:end) = x(1).^2+x(2:end).^2;
%
% Test of Computation Times Using CADA
ntrial = 5;
% The vector "test" below can be truncated to any value desired.  
% It is set up by default to run from 10 to 500000 to show that CADA
% can generate derivatives for a large number of variables.
% test = [10 20 40 80 160 320 640 1280 2500 5000 10000 50000 100000 250000 500000];
test = [10 20 40 80 160 320 640 1280 2500];
arrowhead_cada_times{5,length(test)+1} = []; % 5 by how many test +1
arrowhead_cada_times{1,1} = 'n = ';
arrowhead_cada_times{2,1} = 'trial times func';
arrowhead_cada_times{3,1} = 'trial times file';
arrowhead_cada_times{4,1} = 'trial times eval';
arrowhead_cada_times{5,1} = 'average time eval';
arrowhead_cada_times{6,1} = 'average time file';
arrowhead_cada_times{7,1} = 'average time eval';
index = 2;
[timefunc, timefile, timeeval] = cada_arrowhead_test(5); %fixes first time jitter
for n = test;
    timetrial_func = zeros(ntrial,1);
    timetrial_file = zeros(ntrial,1);
    timetrial_eval = zeros(ntrial,1);
    for trial = 1:ntrial;
        [timefunc, timefile, timeeval] = cada_arrowhead_test(n);
        timetrial_func(trial) = timefunc;
        timetrial_file(trial) = timefile;
        timetrial_eval(trial) = timeeval;
        disp(['Cada finished trial ',num2str(trial),' for N = ',num2str(n)]);
        disp(['file total time = ',num2str(timefunc+timefile+timeeval)]);
        disp(' ');
    end
    arrowhead_cada_times{1,index} = n;
    arrowhead_cada_times{2,index} = timetrial_func;
    arrowhead_cada_times{3,index} = timetrial_file;
    arrowhead_cada_times{4,index} = timetrial_eval;
    arrowhead_cada_times{5,index} = sum(timetrial_func)./5;
    arrowhead_cada_times{6,index} = sum(timetrial_file)./5;
    arrowhead_cada_times{7,index} = sum(timetrial_eval)./5;
    index = index + 1;
    save arrowhead_cada_times arrowhead_cada_times
end
clear arrowhead_cada_times
