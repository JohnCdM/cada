function y = subsref(x,s)
% CADA subsref function
% created by Michael Patterson

ssize = length(s);
for scount = 1:ssize;
    if strcmp(s(scount).type,'()')
        if scount == 1
            NUMvar = size(x.variable,1);
            ytemp.variable = x.variable;
            arraysize = size(x.function);
            derivative = cell(NUMvar,2);
            for Acount = 1:NUMvar;
                if ~isempty(x.derivative{Acount,1})
                    arraysize(3) = x.variable{Acount,2}(1);
                    arraysize(4) = x.variable{Acount,2}(2);
                    arrayderivative = cadaind2array(x.derivative{Acount,1}, x.derivative{Acount,2}, arraysize);
                    arrayderivative = arrayderivative(s(scount).subs{:},:,:);
                    [derivative{Acount,1}, derivative{Acount,2}] = cadaarray2ind(arrayderivative);
                end
            end
            ytemp.function   = x.function(s(scount).subs{:});
            ytemp.derivative = derivative;
            ytemp            = class(ytemp,'cada');
            y = ytemp;
        else
            y = y(s(scount).subs{:});
        end
    elseif strcmp(s(scount).type,'.')
        if strcmp(s(scount).subs,'variable')
            y = x.variable;
        elseif strcmp(s(scount).subs,'function')
            y = x.function;
        elseif strcmp(s(scount).subs,'derivative')
            y = x.derivative;
        else
            error('invalid subscript reference for cada')
        end
    elseif strcmp(s(scount).type,'{}')
        if scount == 1
            error('invalid index reference for cada')
        else
            y = y{s(scount).subs{:}};
        end
    else
        error('invalid index reference for cada')
    end
end