% 2018/8/27
% Jungwon Kang

function [set_range_uwb_MLAT_out, set_time_uwb_MLAT_out] = store_sensor_data_MLAT(set_range_uwb_MLAT, set_time_uwb_MLAT, data_sensor_uwb)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update uwb-related variables & determine if MLAT is possible.
%
% [Input]
%   set_range_uwb_MLAT : uwb-related variable
%                        (1 x 4), 4: uwb100(1), uwb101(2), uwb102(3), uwb103(4)
%   set_time_uwb_MLAT  : uwb-related variable
%                        (1 x 4), 4: uwb100(1), uwb101(2), uwb102(3), uwb103(4)
%   data_sensor_uwb    : current uwb data
%                        (1 x 4), c1: time(s), c2: module id, c3: range(m), c4: range error(m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% get current data
time_this       = data_sensor_uwb(1);
id_module_this  = data_sensor_uwb(2);
range_this      = data_sensor_uwb(3);

idx_module_this = mod(id_module_this, 99);  % 100 -> 1, 101 -> 2, 102 -> 3, 103 -> 4
    % completed to set idx_module_this
    %       id_module_this: 100 -> idx_module_this: 1
    %       id_module_this: 101 -> idx_module_this: 2
    %       id_module_this: 102 -> idx_module_this: 3
    %       id_module_this: 103 -> idx_module_this: 4
    

%%%% update current data into array
set_range_uwb_MLAT(idx_module_this) = range_this;
set_time_uwb_MLAT (idx_module_this) = time_this;


%%%% set output
set_range_uwb_MLAT_out = set_range_uwb_MLAT;
set_time_uwb_MLAT_out  = set_time_uwb_MLAT;

end

