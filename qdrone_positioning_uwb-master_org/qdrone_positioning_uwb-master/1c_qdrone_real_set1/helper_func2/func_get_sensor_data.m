% 2019/10/16
% Jungwon Kang


function [stt_var_runtime_inout, ...
          stt_sensordata_now_a_out, ...
          ret_out] = func_get_sensor_data(IDX_data_packet_in, ...
                                          stt_fixed_dataset_in, ...
                                          stt_fixed_value_uwb_station_in, ...
                                          stt_fixed_operation_in, ...
                                          stt_fixed_macro_in, ...
                                          stt_var_runtime_inout)

                                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ret_out = -1: indicates that this sensor data is uwb and it is outlier
%
% The following var_runtime is updated:
%   stt_var_runtime_inout.mat_body_trans_GT           (all the cases)
%   stt_var_runtime_inout.traj_origin_GT              (all the cases)
%
%   stt_var_runtime_inout.time_now                    (only if available)
%   stt_var_runtime_inout.mat_body_rot_FC_raw0        (only if available)
%   stt_var_runtime_inout.mat_body_rot_FC_most_recent (only if available)
%   stt_var_runtime_inout.height_from_FC_most_recent  (only if available)
%
%   stt_var_runtime_inout.set_data_uwb1XX_for_filter  (only if available)
%   stt_var_runtime_inout.pivot_uwb1XX_for_filter     (only if available)
%
%   stt_var_runtime_inout.set_data_sensor_uwb_real    (only if available)
%   stt_var_runtime_inout.set_data_sensor_uwb_gt_like (only if available)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% read sensor data (raw)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_sensordata_now_a_out = read_sensordata_now_a(   IDX_data_packet_in, ...
                                                    stt_fixed_dataset_in.set_raw_data_loaded, ...
                                                    stt_fixed_macro_in);
    % completed to set
    %   stt_sensordata_a has the following elements:
    %       - IDX_data_packet       (common)
    %       - data_type             (common)
    %       - data_xyz_GT           (common)
    %       - data_sensor_uwb       (only when DATA_UWB)
    %       - data_sensor_imu       (only when DATA_IMU)
    %       - mat_body_rot_FC_raw   (only when DATA_IMU)
    %       - data_sensor_height    (only when DATA_HEIGHT)
    %
    %   stt_sensordata_now_a_out has the following elements:
    %       (1) IDX_data_packet_in
    %       (2) data_type - DATA_UWB(0) / DATA_IMU(2) / DATA_HEIGHT(3)
    %       (3) data_sensor_uwb       - c1: time(s), c2: module id, c3: range(m), c4: range error(m)
    %           or data_sensor_imu    - c1: time(s), [c2, c3, c4]: angular vel - x,y,z, [c5, c6, c7]: linear acc - x,y,z, [c8, c9, c10, c11]: ori quaternion - x,y,z,w
    %           or data_sensor_height - c1: height(m)
    %       (4) data_xyz_GT - [c1, c2, c3]: x, y, z
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% read sensor data (pre-processed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stt_sensordata_now_b, ...
 stt_var_runtime_inout.mat_body_trans_GT] = read_sensordata_now_b(  stt_sensordata_now_a_out, ...
                                                                    stt_var_runtime_inout.mat_body_rot_FC_raw0, ...
                                                                    stt_fixed_macro_in);
    % completed to set
    %   mat_body_trans_GT          (common)
    %   stt_sensordata_now_b has the following elements:
    %       - time_now             (for DATA_UWB and DATA_IMU)
    %       - mat_body_rot_FC_now  (only when DATA_IMU)
    %       - mat_body_rot_FC_raw0 (only when DATA_IMU) (-> only done once over the entire run.)
    %       - height_from_FC_now   (only when DATA_HEIGHT)
    %
    % In summary,
    %   stt_sensordata_now_b
    %       (1) UWB    - time_now
    %       (2) IMU    - time_now
    %                  - mat_body_rot_FC_now
    %                  - mat_body_rot_FC_raw0 (-> only done once over the entire run.)
    %       (3) HEIGHT - height_from_FC_now
    %
    % Note that stt_sensordata_now_b is used to update some variables in stt_var_runtime_inout including
    %       stt_var_runtime_inout.time_now
    %       stt_var_runtime_inout.mat_body_rot_FC_raw0
    %       stt_var_runtime_inout.mat_body_rot_FC_now
    %       stt_var_runtime_inout.height_from_FC_now
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% update var_runtime from stt_sensordata_now_b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% update var_runtime (from stt_sensordata_now_b)
if isfield(stt_sensordata_now_b, 'time_now'),               stt_var_runtime_inout.time_now                    = stt_sensordata_now_b.time_now;                end
if isfield(stt_sensordata_now_b, 'mat_body_rot_FC_raw0'),   stt_var_runtime_inout.mat_body_rot_FC_raw0        = stt_sensordata_now_b.mat_body_rot_FC_raw0;    end
if isfield(stt_sensordata_now_b, 'mat_body_rot_FC_now'),    stt_var_runtime_inout.mat_body_rot_FC_most_recent = stt_sensordata_now_b.mat_body_rot_FC_now;     end
if isfield(stt_sensordata_now_b, 'height_from_FC_now'),     stt_var_runtime_inout.height_from_FC_most_recent  = stt_sensordata_now_b.height_from_FC_now;      end


%%%% store traj
temp = [stt_var_runtime_inout.time_now, stt_var_runtime_inout.mat_body_trans_GT'];
stt_var_runtime_inout.traj_origin_GT = [stt_var_runtime_inout.traj_origin_GT; temp];

% Note that stt_sensordata_now_b is never used from the below.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% uwb range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret_out = 1;

if (stt_sensordata_now_a_out.data_type) == (stt_fixed_macro_in.DATA_UWB),

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% determine if uwb range is inlier/outlier
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    id_uwb = stt_sensordata_now_a_out.data_sensor_uwb(2);

    res_inlier_outlier = 0;     % inlier(1)/outlier(0)

    if id_uwb == 100,
        [res_inlier_outlier, ...
         stt_var_runtime_inout.set_data_uwb100_for_filter, ...
         stt_var_runtime_inout.pivot_uwb100_for_filter] = filter_uwb_range_outlier( stt_sensordata_now_a_out.data_sensor_uwb, ...
                                                                                    stt_var_runtime_inout.set_data_uwb100_for_filter, ...
                                                                                    stt_var_runtime_inout.pivot_uwb100_for_filter);
    elseif id_uwb == 101,
        [res_inlier_outlier, ...
         stt_var_runtime_inout.set_data_uwb101_for_filter, ...
         stt_var_runtime_inout.pivot_uwb101_for_filter] = filter_uwb_range_outlier( stt_sensordata_now_a_out.data_sensor_uwb, ...
                                                                                    stt_var_runtime_inout.set_data_uwb101_for_filter, ...
                                                                                    stt_var_runtime_inout.pivot_uwb101_for_filter);
    elseif id_uwb == 102,
        [res_inlier_outlier, ...
         stt_var_runtime_inout.set_data_uwb102_for_filter, ...
         stt_var_runtime_inout.pivot_uwb102_for_filter] = filter_uwb_range_outlier( stt_sensordata_now_a_out.data_sensor_uwb, ...
                                                                                    stt_var_runtime_inout.set_data_uwb102_for_filter,...
                                                                                    stt_var_runtime_inout.pivot_uwb102_for_filter);
    elseif id_uwb == 103,
        [res_inlier_outlier, ...
         stt_var_runtime_inout.set_data_uwb103_for_filter, ...
         stt_var_runtime_inout.pivot_uwb103_for_filter] = filter_uwb_range_outlier( stt_sensordata_now_a_out.data_sensor_uwb, ...
                                                                                    stt_var_runtime_inout.set_data_uwb103_for_filter, ...
                                                                                    stt_var_runtime_inout.pivot_uwb103_for_filter);
    end
        % completed to set
        %   res_inlier_outlier          : inlier(1)/outlier(0)
        %   set_data_uwb10X_for_filter  : c1: time(s), c2: range, c3: dr, c4: inlier(1)/outlier(0)

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% compute gt-like uwb range
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data_sensor_uwb_gt_like = compute_data_sensor_uwb_gt_like2(stt_sensordata_now_a_out.data_sensor_uwb, stt_var_runtime_inout.mat_body_trans_GT, stt_fixed_value_uwb_station_in.set_pos_station_uwb);
        % completed to set
        %   data_sensor_uwb_gt_like
        %       c1: time(s), c2: module id, c3: range(m), c4: -1

    if stt_fixed_operation_in.b_setting_use_uwb_gt_like,
        stt_sensordata_now_a_out.data_sensor_uwb = data_sensor_uwb_gt_like;
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% store
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    stt_var_runtime_inout.set_data_sensor_uwb_real    = [stt_var_runtime_inout.set_data_sensor_uwb_real;    
                                                         stt_sensordata_now_a_out.data_sensor_uwb];

    stt_var_runtime_inout.set_data_sensor_uwb_gt_like = [stt_var_runtime_inout.set_data_sensor_uwb_gt_like; 
                                                         data_sensor_uwb_gt_like];


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% return if this is outlier
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (stt_fixed_operation_in.b_setting_use_uwb_gt_like) == false,  % if real uwb is used
        %%%% outlier by variation over time
        if res_inlier_outlier < 0.5,
            ret_out = -1;
        end
        
        %%%% outlier by self-error
        if stt_sensordata_now_a_out.data_sensor_uwb(4) > 0.1,
            ret_out = -1;
        end
    end
    
    
end
