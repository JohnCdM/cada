function AUTOspeelpenningFirst

% cada test
test = [1000];
ntrial = 5;
speelpenning_cada_timesFirst2{7,length(test)+1} = []; % 5 by how many test +1
speelpenning_cada_timesFirst2{1,1} = 'n = ';
speelpenning_cada_timesFirst2{2,1} = 'trial times func';
speelpenning_cada_timesFirst2{3,1} = 'trial times Jac file';
speelpenning_cada_timesFirst2{4,1} = 'trial times Jac eval';
speelpenning_cada_timesFirst2{5,1} = 'average time func';
speelpenning_cada_timesFirst2{6,1} = 'average time Jac file';
speelpenning_cada_timesFirst2{7,1} = 'average time Jac eval';
index = 2;
[timefunc, timeJacfile, timeJaceval] = cada_speelpenning_testFirst(5); %fixes first time jitter
for n = test;
    timetrial_func = zeros(ntrial,1);
    timetrial_Jacfile = zeros(ntrial,1);
    timetrial_Jaceval = zeros(ntrial,1);
    rehash
    for trial = 1:ntrial;
        [timefunc, timeJacfile, timeJaceval] = cada_speelpenning_testFirst(n);
        timetrial_func(trial) = timefunc;
        timetrial_Jacfile(trial) = timeJacfile;
        timetrial_Jaceval(trial) = timeJaceval;
        disp(['cada finished trial ',num2str(trial),' for N = ',num2str(n)]);
        disp(['    total time = ',num2str(timefunc+timeJacfile+timeJaceval)]);
        disp(' ');
    end
    speelpenning_cada_timesFirst2{1,index} = n;
    speelpenning_cada_timesFirst2{2,index} = timetrial_func;
    speelpenning_cada_timesFirst2{3,index} = timetrial_Jacfile;
    speelpenning_cada_timesFirst2{4,index} = timetrial_Jaceval;
    speelpenning_cada_timesFirst2{5,index} = sum(timetrial_func)./ntrial;
    speelpenning_cada_timesFirst2{6,index} = sum(timetrial_Jacfile)./ntrial;
    speelpenning_cada_timesFirst2{7,index} = sum(timetrial_Jaceval)./ntrial;
    index = index + 1;
    save speelpenning_cada_timesFirst2 speelpenning_cada_timesFirst2
end
%clear speelpenning_cada_timesFirst2
