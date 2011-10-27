function y = cadasum(x,varargin)
% CADA sum function
% created by Michael Patterson

varargSize = length(varargin);
if varargSize == 0 ;
    % sum along longest dimention
    [xMrow, xNcol] = size(x.function);
    if xMrow == 1
        if xNcol == 1
            y = x;
            return
        end
        s.type = '()';
        s.subs = {':', 1};
        y = subsref(x,s);
        for xNcount = 2:xNcol;
            s.subs = {':', xNcount};
            y = y + subsref(x,s);
        end
    else
        if xMrow == 1
            y = x;
            return
        end
        s.type = '()';
        s.subs = {1, ':'};
        y = subsref(x,s);
        for xMcount = 2:xMrow;
            s.subs = {xMcount, ':'};
            y = y + subsref(x,s);
        end
    end
elseif varargSize == 1
    if length(varargin{1}) == 1
        Dim = varargin{1};
        if Dim > 2
            y = x;
            return
        elseif Dim == 1
            xMrow = size(x.function,1);
            if xMrow == 1
                y = x;
                return
            end
            s.type = '()';
            s.subs = {1, ':'};
            y = subsref(x,s);
            for xMcount = 2:xMrow;
                s.subs = {xMcount, ':'};
                y = y + subsref(x,s);
            end
        elseif Dim == 2
            xNcol = size(x.function,2);
            if xNcol == 1
                y = x;
                return
            end
            s.type = '()';
            s.subs = {':', 1};
            y = subsref(x,s);
            for xNcount = 2:xNcol;
                s.subs = {':', xNcount};
                y = y + subsref(x,s);
            end
        else
            error('Dimension value must be a integer.');
        end
    else
        error('Dimension value must be a scalar.');
    end
elseif varargSize == 2
    % and S = SUM(X,DIM,'double')    DEAL WITH THIS LATER !!!!
    % and S = SUM(X,DIM,'native')
else
    error('Too many input arguments.');
end
