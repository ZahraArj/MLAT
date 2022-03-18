% 2019/10/15
% Jungwon Kang


function [stt_fixed_macro_out, ...
          stt_fixed_operation_out, ...
          stt_fixed_info_dataset_out, ...
          stt_fixed_dataset_out, ...
          stt_fixed_value_uwb_station_out, ...
          stt_fixed_value_drone_init_out, ...
          stt_fixed_param_gtsam_out] = func_set_fixed_user_setting()
      
      
import gtsam.*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stt_fixed_macro_out
% stt_fixed_operation_out
% stt_fixed_info_dataset_out
% stt_fixed_dataset_out
% stt_fixed_value_uwb_station_out
% stt_fixed_value_drone_init_out
% stt_fixed_param_gtsam_out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% MACRO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% DO NOT EDIT
stt_fixed_macro_out = struct;

    stt_fixed_macro_out.DATA_UWB    = 0;
    stt_fixed_macro_out.DATA_IMU    = 2;
    stt_fixed_macro_out.DATA_HEIGHT = 3;
    stt_fixed_macro_out.DATA_MLAT   = 4;
    
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [USER setting] operation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_fixed_operation_out = struct;

    stt_fixed_operation_out.b_setting_use_uwb_gt_like       = 0;
    stt_fixed_operation_out.b_setting_use_trilateration     = 1;
    stt_fixed_operation_out.b_setting_run_gtsam_EST         = 1;
    stt_fixed_operation_out.setting_step_visualize          = 100000;    % -1(no visualize), 1(visualize all frames), M(visualize every M steps)
    stt_fixed_operation_out.b_setting_save_res_as_file      = 1;
    stt_fixed_operation_out.setting_dataset_in_use          = 1;
    % Note that stt_fixed_operation_out.setting_dataset_in_use is ori dataset index.
    %   set 1 (ori) = set 2 (new)
    %   set 2 (ori) = set 3 (new)
    %   set 3 (ori) = set 4 (new)
    %   set 4 (ori) = set 1 (new)
    %   set 5 (ori) = set 5 (new)
    
    %stt_fixed_operation.b_setting_use_selected_dataset = 1;
    %stt_fixed_operation.b_setting_save_screenshot      = true;

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get dataset information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Fname_exp_csv, ...
 x0, y0, ...
 IDX_data_packet_start, ...
 IDX_data_packet_end, ...
 Fname_res, ...
 Fname_res_allvar] = load_info_dataset4(stt_fixed_operation_out.setting_dataset_in_use);
    % completed to set
    %   Fname_exp_csv
    %   x0, y0
    %   IDX_data_packet_start, IDX_data_packet_end
    %   Fname_res
    %   Fname_res_allvar

%%%% copy it to stt
stt_fixed_info_dataset_out = struct;
    stt_fixed_info_dataset_out.Fname_exp_csv           = Fname_exp_csv;
    stt_fixed_info_dataset_out.x0                      = x0;
    stt_fixed_info_dataset_out.y0                      = y0;
    stt_fixed_info_dataset_out.IDX_data_packet_start   = IDX_data_packet_start;
    stt_fixed_info_dataset_out.IDX_data_packet_end     = IDX_data_packet_end;
    stt_fixed_info_dataset_out.Fname_res               = Fname_res;
    stt_fixed_info_dataset_out.Fname_res_allvar        = Fname_res_allvar;

    %stt_fixed_info_dataset.IDX_data_packet_end     = 10000;
    %stt_fixed_info_dataset.IDX_data_packet_end     = 7050;
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% read dataset (from file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_fixed_dataset_out = struct;

    stt_fixed_dataset_out.set_raw_data_loaded = csvread(stt_fixed_info_dataset_out.Fname_exp_csv);
    stt_fixed_dataset_out.totnum_data_packet  = (stt_fixed_info_dataset_out.IDX_data_packet_end) - (stt_fixed_info_dataset_out.IDX_data_packet_start) + 1;
        % completed to set
        %       set_raw_data_loaded
        %       totnum_data_packet
        
        % One data packet consists of three rows.
        %   (1) data_type
        %   (2) sensor data (data_sensor_uwb / data_sensor_imu / data_sensor_height)
        %   (3) xyz_GT



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [USER setting] Drone init pose & UWB station
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% position
pos_station_uwb100 = [-0.0029,   0.0026, 0.6152];
pos_station_uwb101 = [ 8.5121,  -0.0001, 0.9582];
pos_station_uwb102 = [-0.2599,  10.7664, 1.3207];
pos_station_uwb103 = [ 8.2461,  10.8352, 1.5786];

%%%% key for UWB station node
key_station_uwb100 = symbol('s', 100);
key_station_uwb101 = symbol('s', 101);
key_station_uwb102 = symbol('s', 102);
key_station_uwb103 = symbol('s', 103);

%%%% UWB station position
s100 = Point3( pos_station_uwb100(1), pos_station_uwb100(2), pos_station_uwb100(3) );
s101 = Point3( pos_station_uwb101(1), pos_station_uwb101(2), pos_station_uwb101(3) );
s102 = Point3( pos_station_uwb102(1), pos_station_uwb102(2), pos_station_uwb102(3) );
s103 = Point3( pos_station_uwb103(1), pos_station_uwb103(2), pos_station_uwb103(3) );


%%%% DO NOT EDIT BELOW
pos_station_uwb100_ground = pos_station_uwb100;     pos_station_uwb100_ground(3) = 0.0;     % make z value 0.0
pos_station_uwb101_ground = pos_station_uwb101;     pos_station_uwb101_ground(3) = 0.0;
pos_station_uwb102_ground = pos_station_uwb102;     pos_station_uwb102_ground(3) = 0.0;
pos_station_uwb103_ground = pos_station_uwb103;     pos_station_uwb103_ground(3) = 0.0;
    % completed to set
    %   pos_station_uwbOOO
    %   pos_station_uwbOOO_ground

set_pos_station_uwb         = [ pos_station_uwb100;         pos_station_uwb101;         pos_station_uwb102;         pos_station_uwb103];
set_pos_station_uwb_ground  = [ pos_station_uwb100_ground;  pos_station_uwb101_ground;  pos_station_uwb102_ground;  pos_station_uwb103_ground];


%%%% copy it to stt
stt_fixed_value_uwb_station_out = struct;

    stt_fixed_value_uwb_station_out.pos_station_uwb100           = pos_station_uwb100;
    stt_fixed_value_uwb_station_out.pos_station_uwb101           = pos_station_uwb101;
    stt_fixed_value_uwb_station_out.pos_station_uwb102           = pos_station_uwb102;
    stt_fixed_value_uwb_station_out.pos_station_uwb103           = pos_station_uwb103;
    
    stt_fixed_value_uwb_station_out.set_pos_station_uwb          = set_pos_station_uwb;
    stt_fixed_value_uwb_station_out.set_pos_station_uwb_ground   = set_pos_station_uwb_ground;

    stt_fixed_value_uwb_station_out.s100                         = s100;
    stt_fixed_value_uwb_station_out.s101                         = s101;
    stt_fixed_value_uwb_station_out.s102                         = s102;
    stt_fixed_value_uwb_station_out.s103                         = s103;

    stt_fixed_value_uwb_station_out.key_station_uwb100           = key_station_uwb100;
    stt_fixed_value_uwb_station_out.key_station_uwb101           = key_station_uwb101;
    stt_fixed_value_uwb_station_out.key_station_uwb102           = key_station_uwb102;
    stt_fixed_value_uwb_station_out.key_station_uwb103           = key_station_uwb103;
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [USER setting] init value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Pose, velocity of drone (global, GT)
Pose_drone_est_init = Pose3.Expmap([0.0; 0.0; 0.0; x0; y0; 0.095]);
    % rx,ry,rz,tx,ty,tz

%%%%     
stt_fixed_value_drone_init_out = struct;

    stt_fixed_value_drone_init_out.val_init_drone_pose = Pose_drone_est_init;
    stt_fixed_value_drone_init_out.val_init_drone_vel  = LieVector([0; 0; 0]);
    stt_fixed_value_drone_init_out.val_init_drone_bias = imuBias.ConstantBias([0; 0; 0], [0; 0; 0]);

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [USER setting] factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_fixed_param_gtsam_out = struct;

    %%%% f_prior_drone (Pose3 / Lie vector / Constant bias)
    stt_fixed_param_gtsam_out.param_f_prior_drone_t0_pose_mean = Pose_drone_est_init;
    stt_fixed_param_gtsam_out.param_f_prior_drone_t0_pose_cov  = noiseModel.Isotropic.Sigma(6, 1.0);
    %stt_fixed_param_gtsam_out.param_f_prior_drone_t0_pose_cov  = noiseModel.Isotropic.Sigma(6, 0.01);

    stt_fixed_param_gtsam_out.param_f_prior_drone_t0_vel_mean  = LieVector([0; 0; 0]);
    stt_fixed_param_gtsam_out.param_f_prior_drone_t0_vel_cov   = noiseModel.Isotropic.Sigma(3, 3.0);
    %stt_fixed_param_gtsam_out.param_f_prior_drone_t0_vel_cov   = noiseModel.Isotropic.Sigma(3, 0.1);

    stt_fixed_param_gtsam_out.param_f_prior_drone_t0_bias_mean = imuBias.ConstantBias([0; 0; 0], [0; 0; 0]);
    stt_fixed_param_gtsam_out.param_f_prior_drone_t0_bias_cov  = noiseModel.Isotropic.Sigma(6, 1.0);
    %stt_fixed_param_gtsam_out.param_f_prior_drone_t0_bias_cov  = noiseModel.Isotropic.Sigma(6, 0.1);

    
    %%%% f_range
    stt_fixed_param_gtsam_out.param_f_range_mean_cov = noiseModel.Isotropic.Sigma(1, 0.3);

    %%%% f_prior_uwb (Point3)
    % Note that rather than 'param_f_prior_uwb_position_mean', it is set in PriorFactorPoint3().
    stt_fixed_param_gtsam_out.param_f_prior_uwb_position_cov = noiseModel.Diagonal.Sigmas([0.01, 0.01, 0.01]');

    %%%% f_betweenbias_bias_mean
    stt_fixed_param_gtsam_out.param_f_betweenbias_bias_mean = imuBias.ConstantBias(zeros(3,1), zeros(3,1));

    %%%% f_betweenbias_bias_cov
    sigma_bias_acc  = 1.0*10^-5;
    sigma_bias_gyro = 1.0*10^-5;
    stt_fixed_param_gtsam_out.param_f_betweenbias_bias_cov = [ sigma_bias_acc * ones(3,1); sigma_bias_gyro * ones(3,1) ];

    %%%% f_imu_preintegration
    stt_fixed_param_gtsam_out.param_f_imu_preintegration_bias_mean = gtsam.imuBias.ConstantBias([0; 0; 0], [0; 0; 0]);
    stt_fixed_param_gtsam_out.param_f_imu_preintegration_mea_cov1  = 1e-1*eye(3);
    stt_fixed_param_gtsam_out.param_f_imu_preintegration_mea_cov2  = 1e-1*eye(3);
    stt_fixed_param_gtsam_out.param_f_imu_preintegration_mea_cov3  = 1e-1*eye(3);


end