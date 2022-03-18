% 2019/10/16
% Jungwon Kang

function [stt_var_runtime_out] = func_init_var_runtime(stt_fixed_value_drone_init)

stt_var_runtime_out = struct;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_var_runtime_out.traj_origin_GT  = [];
% stt_var_runtime_out.traj_axis_x_GT  = [];
% stt_var_runtime_out.traj_axis_y_GT  = [];
% stt_var_runtime_out.traj_axis_z_GT  = [];


stt_var_runtime_out.set_xyz_current_EST = [];
% stt_var_runtime_out.traj_origin_EST = [];   
% stt_var_runtime_out.traj_axis_x_EST = [];   
% stt_var_runtime_out.traj_axis_y_EST = [];   
% stt_var_runtime_out.traj_axis_z_EST = [];


stt_var_runtime_out.set_xyz_current_GT_for_EST = [];
%stt_var_runtime_out.traj_origin_GT_for_EST   = [];       % traj_origin_GT matched with traj_origin_EST

% stt_var_runtime_out.traj_origin_MLAT1        = [];
% stt_var_runtime_out.traj_origin_MLAT2        = [];
% stt_var_runtime_out.traj_origin_GT_for_MLAT2 = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
stt_var_runtime_out.idx_time_lastupdate         = 0;
stt_var_runtime_out.idx_time_now                = 0;        % keep it

stt_var_runtime_out.mat_body_rot_FC_raw0        = [];       % 3 x 3 matrix
stt_var_runtime_out.mat_body_rot_FC_most_recent = eye(3);
stt_var_runtime_out.mat_body_trans_GT           = zeros(3,1);

stt_var_runtime_out.mat_body_rot_EST            = eye(3);
stt_var_runtime_out.mat_body_trans_EST          = [stt_fixed_value_drone_init.val_init_drone_pose.x; 
                                                   stt_fixed_value_drone_init.val_init_drone_pose.y; 
                                                   stt_fixed_value_drone_init.val_init_drone_pose.z];


stt_var_runtime_out.cnt_imu_preintegrated       =  0;       % number of preintegrated imu data
stt_var_runtime_out.time_imu_prev               = -1.0;
stt_var_runtime_out.time_imu_now                = -1.0;
stt_var_runtime_out.time_now                    =  0.0;


stt_var_runtime_out.height_from_FC_most_recent  = [];       % a scalar

stt_var_runtime_out.set_range_uwb_MLAT          = -1.*ones(1,4);    % for MLAT
stt_var_runtime_out.set_time_uwb_MLAT           = -1.*ones(1,4);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% just for storing (not used for processing)
stt_var_runtime_out.set_data_sensor_uwb_real    = [];
stt_var_runtime_out.set_data_sensor_uwb_gt_like = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% used for filtering outliers
stt_var_runtime_out.set_data_uwb100_for_filter  = [];   % c1: time, c2: range, c3: dr, c4: inlier(1)/outlier(0)
stt_var_runtime_out.set_data_uwb101_for_filter  = [];
stt_var_runtime_out.set_data_uwb102_for_filter  = [];
stt_var_runtime_out.set_data_uwb103_for_filter  = [];

stt_var_runtime_out.pivot_uwb100_for_filter     = zeros(1, 2);   % c1: range, c2: index in [set_data_uwb100_for_filter]
stt_var_runtime_out.pivot_uwb101_for_filter     = zeros(1, 2);
stt_var_runtime_out.pivot_uwb102_for_filter     = zeros(1, 2);
stt_var_runtime_out.pivot_uwb103_for_filter     = zeros(1, 2);



end