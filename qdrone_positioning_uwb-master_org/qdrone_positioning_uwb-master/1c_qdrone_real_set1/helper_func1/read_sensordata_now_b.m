% 2018/8/30
% Jungwon Kang

function [stt_out, Mat_body_trans_GT_out] = read_sensordata_now_b(stt_sensordata_now, Mat_body_rot_FC_raw0, stt_fixed_macro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [input]
%   stt_sensordata_now  : 
%   Mat_body_rot_FC_raw0: 
% [output]
%   stt_out
%   (1) UWB
%       time_out
%   (2) IMU
%       time_out
%       mat_body_rot_FC_now
%       mat_body_rot_FC_raw0 (if a condition is met)
%   (3) HEIGHT
%       height_from_FC_now
%   Mat_body_trans_GT_out
%
%   stt_out
%       - time_now
%       - mat_body_rot_FC_raw0
%       - mat_body_rot_FC_now
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%% init
stt_out = struct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% parse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (stt_sensordata_now.data_type) == (stt_fixed_macro.DATA_UWB),              % DATA_UWB(0)
    stt_out.time_now   = stt_sensordata_now.data_sensor_uwb(1);
        % completed to set
        %   stt_out.time_now
    
elseif (stt_sensordata_now.data_type) == (stt_fixed_macro.DATA_IMU),          % DATA_IMU(2)
    stt_out.time_now   = stt_sensordata_now.data_sensor_imu(1);

    %%%% set rot (GT)
    mat_body_rot_FC_raw = stt_sensordata_now.mat_body_rot_FC_raw;

    if isempty(Mat_body_rot_FC_raw0),
        % Note that it is done only once over the entire run
        Mat_body_rot_FC_raw0         = mat_body_rot_FC_raw;
        stt_out.mat_body_rot_FC_raw0 = mat_body_rot_FC_raw;
    end

    stt_out.mat_body_rot_FC_now = Mat_body_rot_FC_raw0'*mat_body_rot_FC_raw;
        % completed to set
        %   stt_out.time_now
        %   stt_out.mat_body_rot_FC_raw0
        %   stt_out.mat_body_rot_FC_now

elseif (stt_sensordata_now.data_type) == (stt_fixed_macro.DATA_HEIGHT),     % DATA_HEIGHT(3)
    stt_out.height_from_FC_now  = stt_sensordata_now.data_sensor_height(1);
        % completed to set
        %   stt_out.height_from_FC_now
        
elseif (stt_sensordata_now.data_type) == (stt_fixed_macro.DATA_MLAT),       % DATA_MLAT(4)
    stt_out.time_now   = stt_sensordata_now.data_sensor_MLAT(1);
        % completed to set
        %   stt_out.time_now
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set trans (GT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mat_body_trans_GT_out = stt_sensordata_now.data_xyz_GT';
    % completed to set
    %   mat_body_trans_GT: (3 x 1)
    %   [Note that mat_body_trans_GT is updated all the times, while mat_body_rot_FC is updated only when data_type == DATA_IMU.]

end

