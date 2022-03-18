% 2018/8/28
% Jungwon Kang

function [b_okay_MLAT_out, time_diff_out] = check_MLAT_possible(set_time_uwb_MLAT, thres_time_diff, height_from_FC_most_recent)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if MLAT is possible
%
% [input]
%   Set_range_uwb_MLAT : uwb-related variable
%                        (1 x 4), 4: uwb100(1), uwb101(2), uwb102(3), uwb103(4)
%   Thres_time_diff
%   Height_from_FC_most_recent: a scalar, initially []
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% init
b_okay_MLAT_out = true;
time_diff_out   = -1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% check if MLAT is possible (based on time diff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_min = min( set_time_uwb_MLAT );
time_max = max( set_time_uwb_MLAT );

%%%% check
if time_min < 0.0,  b_okay_MLAT_out = false;    end
if time_max < 0.0,  b_okay_MLAT_out = false;    end

%%%% check
if b_okay_MLAT_out == true,
    time_diff     = time_max - time_min;
    time_diff_out = time_diff;
    
    if time_diff >= thres_time_diff,
        b_okay_MLAT_out = false;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% check if MLAT is possible (based on height data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(height_from_FC_most_recent),
    b_okay_MLAT_out = false;
end

end

