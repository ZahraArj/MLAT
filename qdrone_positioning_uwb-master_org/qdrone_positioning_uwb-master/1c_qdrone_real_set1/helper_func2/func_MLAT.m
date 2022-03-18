% 2019/10/16
% Jungwon Kang


function [  stt_var_runtime, ...
            b_okay_MLAT, ...
            set_xyz_MLAT2] = func_MLAT( stt_sensordata_now_a, ...
                                        stt_fixed_value_uwb_station, ...
                                        stt_fixed_operation, ...
                                        stt_fixed_macro, ...
                                        stt_var_runtime)

                                    
b_okay_MLAT     = false;
set_xyz_MLAT1   = zeros(1, 3);
set_xyz_MLAT2   = zeros(1, 3);


%%%% just return if trilateration is not used
if stt_fixed_operation.b_setting_use_trilateration == 0,
    return
end


%%%% just return if it is not DATA_UWB
if (stt_sensordata_now_a.data_type) ~= (stt_fixed_macro.DATA_UWB),
    return
end


%%%% store uwb data(range & time)
[stt_var_runtime.set_range_uwb_MLAT, ...
 stt_var_runtime.set_time_uwb_MLAT] = store_sensor_data_MLAT(stt_var_runtime.set_range_uwb_MLAT, ...
                                                             stt_var_runtime.set_time_uwb_MLAT, ...
                                                             stt_sensordata_now_a.data_sensor_uwb);
    % completed to set
    %       set_range_uwb_MLAT: (1 x 4)
    %       set_time_uwb_MLAT : (1 x 4)

    
%%%% check if MLAT is possible.
[b_okay_MLAT, time_diff_MLAT] = check_MLAT_possible(stt_var_runtime.set_time_uwb_MLAT, ...
                                                    0.1, ...
                                                    stt_var_runtime.height_from_FC_most_recent);
    % completed to set
    %       b_okay_MLAT
    %       time_diff_MLAT: for debugging

    
%%%% run MLAT
if b_okay_MLAT == true,
    %%%% run
    [set_xyz_MLAT1, set_xyz_MLAT2] = solve_mlat_jungwon(stt_fixed_value_uwb_station.set_pos_station_uwb, ...
                                                        stt_var_runtime.set_range_uwb_MLAT', ...
                                                        true, ...
                                                        stt_var_runtime.height_from_FC_most_recent);
        % completed to set
        %   set_xyz_MLAT1: (1 x 3), 3: x,y,z
        %   set_xyz_MLAT2: (1 x 3), 3: x,y,z

    %%%% store
    temp1 = [stt_var_runtime.time_now, set_xyz_MLAT1];                          % (1 x 4), 4: time,x,y,z
    temp2 = [stt_var_runtime.time_now, set_xyz_MLAT2];                          % (1 x 4), 4: time,x,y,z
    temp3 = [stt_var_runtime.time_now, stt_var_runtime.mat_body_trans_GT'];     % (1 x 4), 4: time,x,y,z

    stt_var_runtime.traj_origin_MLAT1        = [stt_var_runtime.traj_origin_MLAT1; temp1];
    stt_var_runtime.traj_origin_MLAT2        = [stt_var_runtime.traj_origin_MLAT2; temp2];
    stt_var_runtime.traj_origin_GT_for_MLAT2 = [stt_var_runtime.traj_origin_GT_for_MLAT2; temp3];
        % completed to set
        %   traj_origin_xxxx : (N x 4), 4: time,x,y,z
end





