function AUTOspeelpenningSecond

% cada test
test = [10 20 40 80 160 250 500 600 700 800 900 1000];
ntrial = 5;
speelpenning_cada_timesSecond{11,length(test)+1} = []; % 5 by how many test +1
speelpenning_cada_timesSecond{1,1} = 'n = ';
speelpenning_cada_timesSecond{2,1} = 'trial times func';
speelpenning_cada_timesSecond{3,1} = 'trial times Jac file';
speelpenning_cada_timesSecond{4,1} = 'trial times Jac func';
speelpenning_cada_timesSecond{5,1} = 'trial times Hes file';
speelpenning_cada_timesSecond{6,1} = 'trial times Hes eval';
speelpenning_cada_timesSecond{7,1} = 'average time func';
speelpenning_cada_timesSecond{8,1} = 'average time Jac file';
speelpenning_cada_timesSecond{9,1} = 'average time Jac func';
speelpenning_cada_timesSecond{10,1} = 'average time Hes file';
speelpenning_cada_timesSecond{11,1} = 'average time Hes eval';
index = 2;

[timefunc, timeJacfile, timeJacfunc, timeHesfile, timeHeseval] = cada_speelpenning_testSecond(5); %fixes first time jitter
for n = test;
    timetrial_func = zeros(ntrial,1);
    timetrial_Jacfile = zeros(ntrial,1);
    timetrial_Jacfunc = zeros(ntrial,1);
    timetrial_Hesfile = zeros(ntrial,1);
    timetrial_Heseval = zeros(ntrial,1);
    rehash
    for trial = 1:ntrial;
        [timefunc, timeJacfile, timeJacfunc, timeHesfile, timeHeseval] = cada_speelpenning_testSecond(n);
        timetrial_func(trial) = timefunc;
        timetrial_Jacfile(trial) = timeJacfile;
        timetrial_Jacfunc(trial) = timeJacfunc;
        timetrial_Hesfile(trial) = timeHesfile;
        timetrial_Heseval(trial) = timeHeseval;
        
        
        disp(['cada finished trial ',num2str(trial),' for N = ',num2str(n)]);
        disp(['    total time = ',num2str(timefunc + timeJacfile + timeJacfunc + timeHesfile + timeHeseval)]);
        disp(' ');
    end
    speelpenning_cada_timesSecond{1,index} = n;
    speelpenning_cada_timesSecond{2,index} = timetrial_func;
    speelpenning_cada_timesSecond{3,index} = timetrial_Jacfile;
    speelpenning_cada_timesSecond{4,index} = timetrial_Jacfunc;
    speelpenning_cada_timesSecond{5,index} = timetrial_Hesfile;
    speelpenning_cada_timesSecond{6,index} = timetrial_Heseval;
    speelpenning_cada_timesSecond{7,index} = sum(timetrial_func)./ntrial;
    speelpenning_cada_timesSecond{8,index} = sum(timetrial_Jacfile)./ntrial;
    speelpenning_cada_timesSecond{9,index} = sum(timetrial_Jacfunc)./ntrial;
    speelpenning_cada_timesSecond{10,index} = sum(timetrial_Hesfile)./ntrial;
    speelpenning_cada_timesSecond{11,index} = sum(timetrial_Heseval)./ntrial;
    index = index + 1;
    save speelpenning_cada_timesSecond speelpenning_cada_timesSecond
end
