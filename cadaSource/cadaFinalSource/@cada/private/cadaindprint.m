function cadaindprint(x,fid)
%CADA index printing function
%Algorithm created by Michael Patterson, Matt Weinstein and Anil V. Rao

if size(x,1) ~= 1 && size(x,2) ~= 1
    error('cada index print only used with vectors');
elseif size(x,1) == 1 && size(x,2) == 1
    fprintf(fid,'%1.0f',x);
    return
elseif size(x,1) ~= 1
    x = x';
end

%
firstflag = 1;
ONEcount = 1;
INCcount = 0;
INDcount=1;
nx = numel(x);

while INDcount <= nx
    if INDcount < nx
        while x(INDcount) == x(INDcount+1)
            ONEcount = ONEcount+1;
            INDcount = INDcount+1;
            if INDcount == nx
                break
            end
        end
    end
    if ONEcount > 1
        if firstflag == 1 && INDcount == nx
            fprintf(fid,'%1.0f*ones(%1.0f,1)',x(INDcount),ONEcount);
            return
        elseif firstflag == 1
            fprintf(fid,'[%1.0f*ones(1,%1.0f) ',x(INDcount),ONEcount);
            firstflag = 0;
        elseif INDcount == nx
            fprintf(fid,'%1.0f*ones(1,%1.0f)]',x(INDcount),ONEcount);
            return
        else
            fprintf(fid,'%1.0f*ones(1,%1.0f) ',x(INDcount),ONEcount);
        end
        INDcount = INDcount+1;
    end
    if ONEcount == 1 && INDcount < nx
        while x(INDcount)+1 == x(INDcount+1)
            INCcount = INCcount+1;
            if INCcount == 1
                INC1 = x(INDcount);
            end
            INDcount = INDcount+1;
            INC2 = x(INDcount);
            if INDcount == nx
                break
            end
        end
    end
    if INCcount > 0
        if firstflag == 1 && INDcount == nx
            fprintf(fid,'(%1.0f:%1.0f)',INC1,INC2);
            return
        elseif firstflag == 1
            fprintf(fid,'[%1.0f:%1.0f ',INC1,INC2);
            firstflag = 0;
        elseif INDcount == nx
            fprintf(fid,'%1.0f:%1.0f]',INC1,INC2);
            return
        else
            fprintf(fid,'%1.0f:%1.0f ',INC1,INC2);
        end
        INDcount = INDcount+1;
    end
    if INCcount == 0 && ONEcount == 1
        if firstflag == 1 && INDcount == nx
            fprintf(fid,'%1.0f',x(INDcount));
            return
        elseif firstflag == 1
            fprintf(fid,'[%1.0f ',x(INDcount));
            firstflag = 0;
        elseif INDcount == nx
            fprintf(fid,'%1.0f]',x(INDcount));
            return
        else
            fprintf(fid,'%1.0f ',x(INDcount));
        end
        INDcount = INDcount+1;
    end
    ONEcount = 1;
    INCcount = 0;
end
%}


%{
fprintf(fid,'[');
for I = 1:numel(x)
    fprintf(fid,'%1.0f ',x(I));
end
fprintf(fid,']');
%}
