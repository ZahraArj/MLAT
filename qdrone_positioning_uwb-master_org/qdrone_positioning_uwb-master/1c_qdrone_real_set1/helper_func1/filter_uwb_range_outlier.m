% 2018/9/8
% Jungwon Kang

function [Res_in_out, Set_data_uwb_out, Pivot_out] = filter_uwb_range_outlier(Data_uwb, Set_data_uwb_in, Pivot_in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Input]
%   Data_uwb     : c1: time(s), c2: module id, c3: range(m), c4: range error(m)
%   Pivot_in     : c1: range, c2: row-index in [Set_data_uwb_in]
% [Input/Output]
%   Set_data_uwb : c1: time(s), c2: range, c3: dr, c4: inlier(1)/outlier(0)
%   Res_in_out   : inlier(1)/outlier(0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


thres_dr = 0.7;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get uwb data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_this    = Data_uwb(1);
range_this   = Data_uwb(3);
dr_this      = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% init for first data case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(Set_data_uwb_in),
    Set_data_uwb_out = [time_this, range_this, dr_this, 1];
    Pivot_out        = [range_this, 1];
    Res_in_out       = 1;
        % init as inlier
        %   ->  this assumes that the first data is inlier. this works good at the momemt.
        %       but it should be changed later for case that the first data is an outlier.
    return;
end


% Note that the code below is all for non-first data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% compute dr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_prev   = Set_data_uwb_in(end, 1);
range_prev  = Set_data_uwb_in(end, 2);

dr_this     = abs(range_this - range_prev);
    % completed to set
    %   dr_this

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% determine inlier/outlier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% get pivot
range_pivot = Pivot_in(1);
i_pivot     = Pivot_in(2);

%%%% get idx in [Set_data_uwb_in]
i_prev      = size(Set_data_uwb_in, 1);
i_this      = i_prev + 1;     % this data should be placed at i_this in Set_data_uwb_in.


b_is_inlier = 0;    % 1(inlier), 0(outlier)

if dr_this < thres_dr,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% inlier candidate by dr
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Set_data_uwb_in(end, 4) == 0,    % if prev data is outlier
        b_is_inlier = 0;    % 0(outlier) because it is close to prev outlier.
        
        %%%% check if it can be saved to inlier
        i_s = i_prev - 14;
        i_e = i_prev;

        if i_s >= 2,
            set_dr_temp  = Set_data_uwb_in(i_s:i_e, 3);
            num_large_dr = sum( set_dr_temp >= thres_dr );
            
            if num_large_dr < 1,
                %%%% save to inlier (because data over several frames has small dr.)
                b_is_inlier = 1;    % 1(inlier)
                range_pivot = range_this;
                i_pivot     = i_this;
            end
        end
    else
        b_is_inlier = 1;    % 1(inlier)
        range_pivot = range_this;
        i_pivot     = i_this;
    end
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% outlier candidate by dr
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (i_this - i_pivot) <= 5,
        %%%% check if it can be saved to inlier        
        dr_pivot = abs(range_this - range_pivot);
                
        if dr_pivot < thres_dr,
            %%%% save to inlier (because this large dr was prev outlier.)
            b_is_inlier = 1;    % 1(inlier)
            range_pivot = range_this;
            i_pivot     = i_this;
        else
            b_is_inlier = 0;    % 0(outlier)
        end
    else
        b_is_inlier = 0;    % 0(outlier)
    end
end
    % completed to set
    %   b_is_inlier
    %   range_pivot (if updated)
    %   i_pivot     (if updated)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% store in [Pivot_out]
Pivot_out = [range_pivot, i_pivot];

%%%% store in [Set_data_uwb_out]
data_this        = [time_this, range_this, dr_this, b_is_inlier];
Set_data_uwb_out = [Set_data_uwb_in; data_this];

%%%%
Res_in_out       = data_this(4);


end

