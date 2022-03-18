% 2019/10/16
% Jungwon Kang


function [stt_var_runtime, b_isam_update, cell_var_graph] = func_process(stt_fixed_operation, ...
                                                                         stt_fixed_macro, ...
                                                                         stt_fixed_param_gtsam, ...
                                                                         stt_fixed_value_uwb_station, ...
                                                                         stt_var_runtime, ...
                                                                         stt_sensordata_now_a, ...
                                                                         cell_var_graph, ...
                                                                         b_okay_MLAT, ...
                                                                         set_xyz_MLAT2)


import gtsam.*;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b_isam_update = false;

if stt_fixed_operation.b_setting_run_gtsam_EST == 0,
    % Note that stt_var_runtime and cell_var_graph are unchanged, and they are just returned.
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_imu_pre       = cell_var_graph{1,1};
initialFactors    = cell_var_graph{2,1};
initialValues     = cell_var_graph{3,1};
isam              = cell_var_graph{4,1};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% IMU preintegration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stt_sensordata_now_a.data_type == stt_fixed_macro.DATA_IMU,
    stt_var_runtime.time_imu_now = stt_sensordata_now_a.data_sensor_imu(1);

    if stt_var_runtime.time_imu_now >= 0.0,       
        if stt_var_runtime.time_imu_prev >= 0.0,    % process after 2nd imu data (because dt_imu is available after 2nd imu data)
            dt_imu       = stt_var_runtime.time_imu_now - stt_var_runtime.time_imu_prev;

            %%%% accumulate IMU preintegrated measurement
            stt_imu_pre.currentSummarizedMeasurement.integrateMeasurement(stt_sensordata_now_a.data_sensor_imu(5:7)', stt_sensordata_now_a.data_sensor_imu(2:4)', dt_imu);
            stt_var_runtime.cnt_imu_preintegrated = stt_var_runtime.cnt_imu_preintegrated + 1;
        end
    end

    %%%% time-shift
    stt_var_runtime.time_imu_prev = stt_var_runtime.time_imu_now;
end
% completed to set
%       cnt_imu_preintegrated
%       time_imu_now
%       time_imu_prev


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% determine whether update or not (depending on the UWB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b_isam_update = false;

if stt_sensordata_now_a.data_type == stt_fixed_macro.DATA_UWB,
    %time_uwb_now = stt_sensordata_now_a.data_sensor_uwb(1);

    %if stt_sensordata_now_a.data_sensor_uwb(4) > 0.1, % Thres_uwb_outlier,
        %%%% if outlier, just pass (do nothing)
    %else
        %%%% if non-outlier
        if stt_var_runtime.cnt_imu_preintegrated > 0.
            b_isam_update = true;
        else
            % if no preintegrated IMU, then just pass (do nothing)
        end
    %end
end
    % completed to set
    %       b_isam_update


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if b_isam_update,
    %%%% set key (the keys are corresponding to the uwb data)
    key_x_lastupdate = symbol('x', stt_var_runtime.idx_time_lastupdate);
    key_v_lastupdate = symbol('v', stt_var_runtime.idx_time_lastupdate);
    key_b_lastupdate = symbol('b', stt_var_runtime.idx_time_lastupdate);
    key_x_current    = symbol('x', stt_var_runtime.idx_time_now);
    key_v_current    = symbol('v', stt_var_runtime.idx_time_now);
    key_b_current    = symbol('b', stt_var_runtime.idx_time_now);

    %%%% get uwb data
    data_uwb_id     = stt_sensordata_now_a.data_sensor_uwb(2);
    data_uwb_range  = stt_sensordata_now_a.data_sensor_uwb(3);

    if data_uwb_id == 100,  initialFactors.add( RangeFactorPosePoint3( key_x_current, stt_fixed_value_uwb_station.key_station_uwb100, data_uwb_range, stt_fixed_param_gtsam.param_f_range_mean_cov ) );  end
    if data_uwb_id == 101,  initialFactors.add( RangeFactorPosePoint3( key_x_current, stt_fixed_value_uwb_station.key_station_uwb101, data_uwb_range, stt_fixed_param_gtsam.param_f_range_mean_cov ) );  end
    if data_uwb_id == 102,  initialFactors.add( RangeFactorPosePoint3( key_x_current, stt_fixed_value_uwb_station.key_station_uwb102, data_uwb_range, stt_fixed_param_gtsam.param_f_range_mean_cov ) );  end
    if data_uwb_id == 103,  initialFactors.add( RangeFactorPosePoint3( key_x_current, stt_fixed_value_uwb_station.key_station_uwb103, data_uwb_range, stt_fixed_param_gtsam.param_f_range_mean_cov ) );  end

    %%%% set factor
    initialFactors.add( ImuFactor( key_x_lastupdate, key_v_lastupdate, ...
                                   key_x_current,    key_v_current, ...
                                   key_b_current,    stt_imu_pre.currentSummarizedMeasurement, [0; 0; 0], [0; 0; 0]));  % 0s: gravity, omegaCoriolis

    initialFactors.add( BetweenFactorConstantBias(  key_b_lastupdate, key_b_current, ...
                                                    stt_fixed_param_gtsam.param_f_betweenbias_bias_mean, ...
                                                    noiseModel.Diagonal.Sigmas(sqrt(stt_var_runtime.cnt_imu_preintegrated) * stt_fixed_param_gtsam.param_f_betweenbias_bias_cov)) );

    %%%% adding my prior 1 (by all GT)
    %if b_setting_use_trilateration == true,
    %    mat_rot_temp   = Rot3(mat_body_rot_FC_most_recent);
    %    mat_trans_temp = Point3(mat_body_trans_GT);
    %    pose_this_mean = Pose3(mat_rot_temp, mat_trans_temp);
    %    pose_this_cov  = noiseModel.Isotropic.Sigma(6, 1.0);
    %    
    %    initialFactors.add( PriorFactorPose3(key_x_current, pose_this_mean, pose_this_cov) );
    %end

    %%%% adding my prior 2 (trans by MLAT, rot by GT)
    if b_okay_MLAT == true,
        mat_rot_temp   = Rot3(stt_var_runtime.mat_body_rot_FC_most_recent);
        mat_trans_temp = Point3(set_xyz_MLAT2');
        pose_this_mean = Pose3(mat_rot_temp, mat_trans_temp);
        pose_this_cov  = noiseModel.Isotropic.Sigma(6, 1.0);

        initialFactors.add( PriorFactorPose3(key_x_current, pose_this_mean, pose_this_cov) );
    end


    %%%% set init value
    initialPose = Pose3;
    initialVel  = LieVector( [0; 0; 0] );
    initialBias = imuBias.ConstantBias(zeros(3,1), zeros(3,1));

    if stt_var_runtime.idx_time_lastupdate > 0,
        initialPose = isam.calculateEstimate( key_x_lastupdate );
        initialVel  = isam.calculateEstimate( key_v_lastupdate );
        initialBias = isam.calculateEstimate( key_b_lastupdate );
    end

    initialValues.insert(key_x_current, initialPose);
    initialValues.insert(key_v_current, initialVel);
    initialValues.insert(key_b_current, initialBias);


    %%%% update solver
    isam.update(initialFactors, initialValues);


    %%%% get estimated values
    mat_body_EST_       = isam.calculateEstimate(key_x_current);
    mat_body_EST        = mat_body_EST_.matrix();

    stt_var_runtime.mat_body_rot_EST    = mat_body_EST(1:3, 1:3);   % (3 x 3)
    stt_var_runtime.mat_body_trans_EST  = mat_body_EST(1:3, 4);     % (3 x 1)

    % correct (-)z
    if stt_var_runtime.mat_body_trans_EST(3) < 0.0,
        stt_var_runtime.mat_body_trans_EST(3) = 0.0;
    end


    %%%% reset (for next-step use)
    initialFactors = NonlinearFactorGraph;
    initialValues  = Values;

    stt_imu_pre.currentSummarizedMeasurement = ImuFactorPreintegratedMeasurements(stt_imu_pre.setting_imu_preintegration_init);
    stt_var_runtime.cnt_imu_preintegrated = 0;


    %%%% save EST & GT results as file
    % EST: mat_body_rot_EST, mat_body_trans_EST
    % GT : mat_body_rot_FC_most_recent, mat_body_trans_GT
    %save_output_as_file(fid2_out, time_now, mat_body_rot_EST, mat_body_trans_EST, mat_body_rot_FC, mat_body_trans_GT);


    %%%% shift idx
    stt_var_runtime.idx_time_lastupdate = stt_var_runtime.idx_time_now; 
end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cell_var_graph{1,1} = stt_imu_pre;
cell_var_graph{2,1} = initialFactors;
cell_var_graph{3,1} = initialValues;
cell_var_graph{4,1} = isam;
    
    
