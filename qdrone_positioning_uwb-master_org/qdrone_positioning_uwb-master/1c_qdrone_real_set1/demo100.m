%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2019/10/15
% 2019/12/09 revised
% Jungwon Kang
% required: 
%       (1) Peter Corke's robotics toolbox (We used robot-10.2)
%       (2) arrow3 (ver 5.0)
%       (3) gtsam 3.2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% example of using pose3 based on matrix
%   mat_rot   = Rot3(eye(3));
%   mat_trans = Point3(zeros(3,1));
%   pose_this = Pose3(mat_rot, mat_trans);

% 따져볼 거
%   (time 정보가 없는) height data가 맨 처음에 들어오면, 별 문제가 없나?




clc;
close all;
clear all;

import gtsam.*;
addpath( genpath('./helper_func1') );
addpath( genpath('./helper_func2') );
addpath( genpath('./helper_utils') );

rng(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% init setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%
[stt_fixed_macro, ...
 stt_fixed_operation, ...
 stt_fixed_info_dataset, ...
 stt_fixed_dataset, ...
 stt_fixed_value_uwb_station, ... 
 stt_fixed_value_drone_init, ...
 stt_fixed_param_gtsam]     = func_set_fixed_user_setting();


%%%%
[cell_var_graph_current]    = func_init_gtsam_graph(stt_fixed_param_gtsam, stt_fixed_value_uwb_station, stt_fixed_value_drone_init);
[cell_var_graph_delayed]    = func_init_gtsam_graph(stt_fixed_param_gtsam, stt_fixed_value_uwb_station, stt_fixed_value_drone_init);
    % completed to set
    %   cell_var_graph_xxxxxx
    %       cell_graph{1, 1} = stt_imu_pre
    %       cell_graph{2, 1} = initialFactors
    %       cell_graph{3, 1} = initialValues
    %       cell_graph{4, 1} = isam


%%%%
[stt_var_runtime_current]   = func_init_var_runtime(stt_fixed_value_drone_init);
[stt_var_runtime_delayed]   = func_init_var_runtime(stt_fixed_value_drone_init);
    % completed to set
    %   stt_var_runtime_xxxxxx


%%%%
[stt_log]                   = func_init_log();
    % completed to set
    %   stt_log

%%%%
queue_data                  = CLS_MyDataQueue(1000);
    % completed to set
    %   queue_data


%%%%
traj_now_EST_graph_current = [];    % saving a traj of current graph at one time index
traj_now_EST_graph_delayed = [];    % saving a traj of delayed graph at one time index



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offset_idx = (stt_fixed_info_dataset.IDX_data_packet_start) - 1;
    % completed to set
    %       offset_idx: (for making 'stt_var_runtime_current.idx_time_now' start from 1)

    
for IDX_data_packet = (stt_fixed_info_dataset.IDX_data_packet_start):(stt_fixed_info_dataset.IDX_data_packet_end),
    % Note that 'IDX_data_packet': absolute index of data (which can start from an arbitrary number).
    %           'stt_var_runtime_current.idx_time_now': always start from 1
    
    
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% print progress prec
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    perc_progress = ((IDX_data_packet - stt_fixed_info_dataset.IDX_data_packet_start + 1)/(stt_fixed_dataset.totnum_data_packet))*100;
    
    fprintf('Getting data packet [%d / %d] (perc: %f)\n',   IDX_data_packet, ...
                                                            stt_fixed_info_dataset.IDX_data_packet_end, ...
                                                            perc_progress);

    %%%% update time idx
    stt_var_runtime_current.idx_time_now = IDX_data_packet - offset_idx;


    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% get sensor data
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    [stt_var_runtime_current, ...
     stt_sensordata_now_a, ...
     ret_sensor_data] = func_get_sensor_data(   IDX_data_packet, ...
                                                stt_fixed_dataset, ...
                                                stt_fixed_value_uwb_station, ...
                                                stt_fixed_operation, ...
                                                stt_fixed_macro, ...
                                                stt_var_runtime_current);

    %%%% if input data is UWB and it is an outlier
    if ret_sensor_data < 0
        continue;
    end

    % At this moment, the followings are set:
    %       stt_var_runtime_current
    %       stt_sensordata_now_a
    
    
    % Note that only non-outlier UWB data is passing below.
    [stt_log] = func_log_data_graph_current(stt_sensordata_now_a, stt_log);
    
    
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% push current data in queue_data
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    ret_push_in = queue_data.push_in_one_element(stt_sensordata_now_a);
        
    
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% pop-out data from queue_data (for updating graph_delayed)
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    [queue_data, ...
     cell_sensordata_for_graph_delayed] = func_pop_out_from_queue_data( queue_data, ...
                                                                        stt_var_runtime_current.time_now, ...
                                                                        stt_var_runtime_current.height_from_FC_most_recent, ...
                                                                        stt_fixed_value_uwb_station.set_pos_station_uwb, ...
                                                                        stt_fixed_macro);
    
    [stt_log] = func_log_data_graph_delayed(cell_sensordata_for_graph_delayed, stt_log);


    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% update graph_current
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    [stt_var_runtime_current, ...
     b_isam_update_current, ...
     cell_var_graph_current, ...
     traj_now_EST_graph_current_this] = func_update_graph_current_by_one_data(  stt_fixed_operation, ...
                                                                                stt_fixed_macro, ...
                                                                                stt_fixed_param_gtsam, ...
                                                                                stt_fixed_value_uwb_station, ...
                                                                                stt_var_runtime_current, ...
                                                                                stt_sensordata_now_a, ...
                                                                                cell_var_graph_current);

    %%%%
    if isempty(traj_now_EST_graph_current_this) == 0,
        traj_now_EST_graph_current = traj_now_EST_graph_current_this;
    end


    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% update graph_delayed
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    [stt_var_runtime_delayed, ...
     cell_var_graph_delayed, ...
     traj_now_EST_graph_delayed_this] = func_update_graph_delayed_by_popout_data(   stt_fixed_operation, ...
                                                                                    stt_fixed_macro, ...
                                                                                    stt_fixed_param_gtsam, ...
                                                                                    stt_fixed_value_uwb_station, ...
                                                                                    cell_sensordata_for_graph_delayed, ...
                                                                                    stt_var_runtime_delayed, ...
                                                                                    cell_var_graph_delayed, ...
                                                                                    offset_idx);

    %%%%
    if isempty(traj_now_EST_graph_delayed_this) == 0,
        traj_now_EST_graph_delayed = traj_now_EST_graph_delayed_this;
    end


    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% Visualization (set_xyz_current)
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    
    %%%% showing set_xyz_current from current-graph
    if 0
        if (stt_fixed_operation.setting_step_visualize) > 0
            % setting_step_visualize : -1(no visualize), 1(visualize all frames), M(visualize every M steps)
            if mod( IDX_data_packet, stt_fixed_operation.setting_step_visualize ) == 0
                visualize_set_xyz_current(  IDX_data_packet, ...
                                            stt_var_runtime_current, ...
                                            stt_fixed_value_uwb_station);
            end
        end
    end
    

    %%%% showing set_xyz_current from delayed-graph
    if 0
        if (stt_fixed_operation.setting_step_visualize) > 0
            % setting_step_visualize : -1(no visualize), 1(visualize all frames), M(visualize every M steps)
            if mod( IDX_data_packet, stt_fixed_operation.setting_step_visualize ) == 0
                visualize_set_xyz_current(  IDX_data_packet, ...
                                            stt_var_runtime_delayed, ...
                                            stt_fixed_value_uwb_station);
            end
        end
    end

    
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    %%%% Visualization (traj_estimated)
    %%%%--------------------------------------------------------------------------------------------------------------------------------
    
    %%%% showing traj_estimated from current-graph
    if 0
        if (stt_fixed_operation.setting_step_visualize) > 0
            if mod( IDX_data_packet, stt_fixed_operation.setting_step_visualize ) == 0
                visualize_traj_estimated(IDX_data_packet, ...
                                         stt_var_runtime_delayed, ...
                                         stt_fixed_value_uwb_station, ...
                                         traj_now_EST_graph_current);
            end
        end
    end
    
    
    %%%% showing traj_estimated from delayed-graph (for one-shot res img)
    if 0
        if (stt_fixed_operation.setting_step_visualize) > 0
            if mod( IDX_data_packet, stt_fixed_operation.setting_step_visualize ) == 0
                visualize_traj_estimated_v1(IDX_data_packet, ...
                                            stt_var_runtime_delayed, ...
                                            stt_fixed_value_uwb_station, ...
                                            traj_now_EST_graph_delayed);
            end
        end
    end

    
    %%%% showing traj_estimated from delayed-graph (for movie res img)
    if 1
        if (stt_fixed_operation.setting_step_visualize) > 0
            if mod( IDX_data_packet, stt_fixed_operation.setting_step_visualize ) == 0
                visualize_traj_estimated_v1_for_movie(  IDX_data_packet, ...
                                                        stt_var_runtime_delayed, ...
                                                        stt_fixed_value_uwb_station, ...
                                                        traj_now_EST_graph_delayed);
            end
        end
    end
    
    
end


%%% 
queue_data.print_state_queue();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% save allvars
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fname_res_allvar = stt_fixed_info_dataset.Fname_res_allvar;
save(fname_res_allvar);
fprintf('saved allvars in %s\n', fname_res_allvar);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% print err (traj_estimated)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% EST (current)
if 1,
    fprintf('=== EST(traj_estimated of current-graph) ===\n');
        
    traj_now_EST_graph_current_temp = traj_now_EST_graph_current(2:end, [10, 11, 12]);
    
    %%%% MAE
    [err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z] = compute_accuracy_ae_traj_estimated(stt_var_runtime_current.set_xyz_current_GT_for_EST, ...
                                                                                                    traj_now_EST_graph_current_temp);
    fprintf('  [MAE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z);

    %%%% RMSE
    %     [err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z] = compute_accuracy_rmse(stt_var_runtime_delayed.traj_origin_GT_for_EST, ...
    %                                                                                             stt_var_runtime_delayed.traj_origin_EST);
    %     fprintf('  [RMSE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z);
end


%%%% EST (delayed)
if 1,
    fprintf('=== EST(traj_estimated of delayed-graph) ===\n');
        
    traj_now_EST_graph_delayed_temp = traj_now_EST_graph_delayed(2:end, [10, 11, 12]);
    
    %%%% MAE
    [err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z] = compute_accuracy_ae_traj_estimated(stt_var_runtime_delayed.set_xyz_current_GT_for_EST, ...
                                                                                                    traj_now_EST_graph_delayed_temp);
    fprintf('  [MAE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z);

    %%%% RMSE
    %     [err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z] = compute_accuracy_rmse(stt_var_runtime_delayed.traj_origin_GT_for_EST, ...
    %                                                                                             stt_var_runtime_delayed.traj_origin_EST);
    %     fprintf('  [RMSE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% print err (set_xyz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% EST (current)
if 1,
    fprintf('=== EST(set_xyz_current of current-graph) ===\n');
    
    %%%% MAE
    [err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z] = compute_accuracy_ae(stt_var_runtime_current.set_xyz_current_GT_for_EST, ...
                                                                                     stt_var_runtime_current.set_xyz_current_EST);
    fprintf('  [MAE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z);

    %%%% RMSE
    %     [err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z] = compute_accuracy_rmse(stt_var_runtime_current.set_xyz_current_GT_for_EST, ...
    %                                                                                             stt_var_runtime_current.traj_origin_EST);
    %     fprintf('  [RMSE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z);
    %     fprintf('\n');
end


%%%% EST (delayed)
if 1,
    fprintf('=== EST(set_xyz_current of delayed-graph) ===\n');
    
    %%%% MAE
    [err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z] = compute_accuracy_ae(stt_var_runtime_delayed.set_xyz_current_GT_for_EST, ...
                                                                                     stt_var_runtime_delayed.set_xyz_current_EST);
    fprintf('  [MAE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z);

    %%%% RMSE
    %     [err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z] = compute_accuracy_rmse(stt_var_runtime_delayed.set_xyz_current_GT_for_EST, ...
    %                                                                                             stt_var_runtime_delayed.traj_origin_EST);
    %     fprintf('  [RMSE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z);
end


%%%% MLAT
if 0,
    fprintf('=== MLAT ===\n');
    
    %%%% MAE
    [err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z] = compute_accuracy_ae(stt_var_runtime_current.traj_origin_GT_for_MLAT2, stt_var_runtime_current.traj_origin_MLAT2);
    fprintf('  [MAE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_avg_xyz, err_avg_xy, err_avg_x, err_avg_y, err_avg_z);

    %%%% RMSE
    [err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z] = compute_accuracy_rmse(stt_var_runtime_current.traj_origin_GT_for_MLAT2, stt_var_runtime_current.traj_origin_MLAT2);
    fprintf('  [RMSE] (xyz: %f), (xy: %f), (x: %f), (y: %f), (z: %f)\n', err_rmse_xyz, err_rmse_xy, err_rmse_x, err_rmse_y, err_rmse_z);
end












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%     if 0,
%         if stt_fixed_operation.setting_step_visualize > 0,      % Setting_step_visualize : -1(no visualize), 1(visualize all frames), M(visualize every M steps)
%             if mod( IDX_data_packet, stt_fixed_operation.setting_step_visualize ) == 0,
%                 visualize_res_MLAT(IDX_data_packet, time_now, ...
%                                    traj_origin_GT, mat_body_rot_FC_most_recent, mat_body_trans_GT, ...
%                                    traj_origin_MLAT1, traj_origin_MLAT2, ...
%                                    set_pos_station_uwb, set_pos_station_uwb_ground);
%             end
%         end
%     end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% save
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %save('./mat_data_xyz_GT/data_xyz_GT_set5.mat', 'traj_origin_GT');
% 
% % traj_origin_MLAT2
% % traj_origin_GT_for_MLAT2
% % traj_origin_EST
% % traj_origin_GT_for_EST
% 
% if b_setting_save_res_as_file,
%     save(Fname_res, 'traj_origin_GT', ...
%                     'traj_origin_EST', 'traj_origin_GT_for_EST', ...
%                     'traj_origin_MLAT2', 'traj_origin_GT_for_MLAT2');
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% check avg error
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% check uwb ranges
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % draw_graph_range(set_data_sensor_uwb_real, set_data_sensor_uwb_gt_like);
% 
% if 0,
%     %%%% uwb100
%     set_time_temp   = set_data_uwb100_for_filter(:,1);
%     set_range_temp  = set_data_uwb100_for_filter(:,2);
%     set_dr_temp     = set_data_uwb100_for_filter(:,3);
%     set_type_temp   = set_data_uwb100_for_filter(:,4);
% 
%     draw_uwb_range_inlier_outlier(100, 'uwb100', set_time_temp, set_range_temp, set_dr_temp, set_type_temp);
% 
% 
%     %%%% uwb101
%     set_time_temp   = set_data_uwb101_for_filter(:,1);
%     set_range_temp  = set_data_uwb101_for_filter(:,2);
%     set_dr_temp     = set_data_uwb101_for_filter(:,3);
%     set_type_temp   = set_data_uwb101_for_filter(:,4);
% 
%     draw_uwb_range_inlier_outlier(101, 'uwb101', set_time_temp, set_range_temp, set_dr_temp, set_type_temp);
% 
% 
%     %%%% uwb102
%     set_time_temp   = set_data_uwb102_for_filter(:,1);
%     set_range_temp  = set_data_uwb102_for_filter(:,2);
%     set_dr_temp     = set_data_uwb102_for_filter(:,3);
%     set_type_temp   = set_data_uwb102_for_filter(:,4);
% 
%     draw_uwb_range_inlier_outlier(102, 'uwb102', set_time_temp, set_range_temp, set_dr_temp, set_type_temp);
% 
% 
%     %%%% uwb103
%     set_time_temp   = set_data_uwb103_for_filter(:,1);
%     set_range_temp  = set_data_uwb103_for_filter(:,2);
%     set_dr_temp     = set_data_uwb103_for_filter(:,3);
%     set_type_temp   = set_data_uwb103_for_filter(:,4);
% 
%     draw_uwb_range_inlier_outlier(103, 'uwb103', set_time_temp, set_range_temp, set_dr_temp, set_type_temp);
% end
% 
% 
% disp('finished...');





    %stt_var_runtime_current.idx_time_now = IDX_data_packet - (stt_fixed_info_dataset.IDX_data_packet_start) + 1;
    %stt_var_runtime_current.idx_time_now = stt_var_runtime_current.idx_time_now + 1;






