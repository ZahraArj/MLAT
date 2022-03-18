% 2019/10/15
% Jungwon Kang


function [cell_graph_out] = func_init_gtsam_graph(stt_fixed_param_gtsam_in, stt_fixed_value_uwb_station_in, stt_fixed_value_drone_init_in)



import gtsam.*;


%%%% init output
cell_graph_out = cell(4, 1);
    % cell_graph{1, 1} = stt_imu_pre
    % cell_graph{2, 1} = initialFactors
    % cell_graph{3, 1} = initialValues
    % cell_graph{4, 1} = isam


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% step 1: init IMU preintegration module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stt_imu_pre = struct;

%%%% IMU preintegration
stt_imu_pre.setting_imu_preintegration_init = gtsam.ImuFactorPreintegratedMeasurements( ...
                                                        stt_fixed_param_gtsam_in.param_f_imu_preintegration_bias_mean, ...
                                                        stt_fixed_param_gtsam_in.param_f_imu_preintegration_mea_cov1, ...
                                                        stt_fixed_param_gtsam_in.param_f_imu_preintegration_mea_cov2, ...
                                                        stt_fixed_param_gtsam_in.param_f_imu_preintegration_mea_cov3);

stt_imu_pre.currentSummarizedMeasurement = ImuFactorPreintegratedMeasurements(stt_imu_pre.setting_imu_preintegration_init);


cell_graph_out{1,1} = stt_imu_pre;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% step 2: init graph by factors and values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% create
initialFactors = NonlinearFactorGraph;
initialValues  = Values;

%%%% key
key_x0 = symbol('x', 0);
key_v0 = symbol('v', 0);
key_b0 = symbol('b', 0);


%%%% initial factor
initialFactors.add( PriorFactorPose3(           key_x0, ...
                                                stt_fixed_param_gtsam_in.param_f_prior_drone_t0_pose_mean, ...
                                                stt_fixed_param_gtsam_in.param_f_prior_drone_t0_pose_cov) );
initialFactors.add( PriorFactorLieVector(       key_v0, ...
                                                stt_fixed_param_gtsam_in.param_f_prior_drone_t0_vel_mean, ...
                                                stt_fixed_param_gtsam_in.param_f_prior_drone_t0_vel_cov ) );
initialFactors.add( PriorFactorConstantBias(    key_b0, ...
                                                stt_fixed_param_gtsam_in.param_f_prior_drone_t0_bias_mean, ... 
                                                stt_fixed_param_gtsam_in.param_f_prior_drone_t0_bias_cov) );

initialFactors.add( PriorFactorPoint3(  stt_fixed_value_uwb_station_in.key_station_uwb100, ...
                                        stt_fixed_value_uwb_station_in.s100, ...
                                        stt_fixed_param_gtsam_in.param_f_prior_uwb_position_cov ) );
initialFactors.add( PriorFactorPoint3(  stt_fixed_value_uwb_station_in.key_station_uwb101, ...
                                        stt_fixed_value_uwb_station_in.s101, ...
                                        stt_fixed_param_gtsam_in.param_f_prior_uwb_position_cov ) );
initialFactors.add( PriorFactorPoint3(  stt_fixed_value_uwb_station_in.key_station_uwb102, ...
                                        stt_fixed_value_uwb_station_in.s102, ...
                                        stt_fixed_param_gtsam_in.param_f_prior_uwb_position_cov ) );
initialFactors.add( PriorFactorPoint3(  stt_fixed_value_uwb_station_in.key_station_uwb103, ...
                                        stt_fixed_value_uwb_station_in.s103, ...
                                        stt_fixed_param_gtsam_in.param_f_prior_uwb_position_cov ) );


%%%% initial value
initialValues.insert( key_x0, stt_fixed_value_drone_init_in.val_init_drone_pose );
initialValues.insert( key_v0, stt_fixed_value_drone_init_in.val_init_drone_vel  );
initialValues.insert( key_b0, stt_fixed_value_drone_init_in.val_init_drone_bias );

initialValues.insert( stt_fixed_value_uwb_station_in.key_station_uwb100, stt_fixed_value_uwb_station_in.s100 );
initialValues.insert( stt_fixed_value_uwb_station_in.key_station_uwb101, stt_fixed_value_uwb_station_in.s101 );
initialValues.insert( stt_fixed_value_uwb_station_in.key_station_uwb102, stt_fixed_value_uwb_station_in.s102 );
initialValues.insert( stt_fixed_value_uwb_station_in.key_station_uwb103, stt_fixed_value_uwb_station_in.s103 );


%%%% put in the cell
cell_graph_out{2, 1} = initialFactors;
cell_graph_out{3, 1} = initialValues;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% step 3: solver object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isamParams  = ISAM2Params;
isamParams.setRelinearizeSkip(1);
isam        = gtsam.ISAM2(isamParams);


%%%% put in the cell
cell_graph_out{4, 1} = isam;


end