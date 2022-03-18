% 2018/8/30
% Jungwon Kang


function [stt_sensordata_out] = read_sensordata_now_a(  IDX_data_packet, ...
                                                        Set_raw_data_loaded, ...
                                                        stt_fixed_macro)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Input]
%   IDX_data_packet
%   Set_raw_data_loaded
% [Output]
%   stt_sensordata_out
%       (1) IDX_data_packet
%       (2) data_type: DATA_UWB(0) / DATA_IMU(2) / DATA_HEIGHT(3)
%       (3) data_sensor_uwb         (if data_type == DATA_UWB(0))
%               c1: time(s), c2: module id, c3: range(m), c4: range error(m)
%           or data_sensor_imu      (if data_type == DATA_IMU(2))
%               c1: time(s), [c2, c3, c4]: angular vel - x,y,z, [c5, c6, c7]: linear acc - x,y,z, [c8, c9, c10, c11]: ori quaternion - x,y,z,w        
%           or data_sensor_height   (if data_type == DATA_HEIGHT(3))
%               c1: height(m)
%       (4) data_xyz_GT
%               c1, c2, c3: x, y, z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get raw data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_r1      = 3*IDX_data_packet - 2;            % idx for row1
idx_r2      = idx_r1 + 1;                       % idx for row2
idx_r3      = idx_r1 + 2;                       % idx for row3

data_type   = Set_raw_data_loaded(idx_r1, :);   % data_type
data_sensor = Set_raw_data_loaded(idx_r2, :);   % sensor data
data_xyz_GT = Set_raw_data_loaded(idx_r3, :);   % xyz_GT
    % completed to set
    %   (1) IDX_data_packet
    %   (2) data_type: DATA_UWB(0) / DATA_IMU(2) / DATA_HEIGHT(3)
    %   (3) data_sensor
    %       uwb     (if Data_type == DATA_UWB(0))
    %           c1: time(s), c2: module id, c3: range(m), c4: range error(m)
    %       imu     (if Data_type == DATA_IMU(2))
    %           c1: time(s), [c2, c3, c4]: angular vel - x,y,z, [c5, c6, c7]: linear acc - x,y,z, [c8, c9, c10, c11]: ori quaternion - x,y,z,w        
    %       height  (if Data_type == DATA_HEIGHT(3))
    %           c1: height(m)
    %   (4) Data_xyz_GT
    %           c1, c2, c3: x, y, z

   
    
%%%% init
stt_out = struct;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set output - (1) IDX_data_packet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_out.IDX_data_packet = IDX_data_packet;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set output - (2) data_type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_out.data_type = data_type(1);
    % completed to set
    %       stt_out.data_type

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set output - (3) data_sensor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stt_out.data_type == (stt_fixed_macro.DATA_UWB),
    %stt_out.data_sensor_uwb     = data_sensor(1:4);
    
    %%%% calib range
    id_uwb  = data_sensor(2);
    r_raw   = data_sensor(3);   % raw range
    r_calib = -1;               % calibrated range
    
    if id_uwb == 100,       r_calib = r_raw - 0.20;
    elseif id_uwb == 101,   r_calib = r_raw - 0.20;
    elseif id_uwb == 102,   r_calib = r_raw - 0.20;
    elseif id_uwb == 103,   r_calib = r_raw - 0.15;
    end
    
    if r_calib > 20.0,      r_calib = 20.0;     end
    
    data_sensor(3) = r_calib;
    
    stt_out.data_sensor_uwb     = data_sensor(1:4);

elseif stt_out.data_type == (stt_fixed_macro.DATA_IMU),
    %%%% set data_sensor_imu
    data_sensor_imu_raw         = data_sensor(1:11);
    data_sensor_imu             = correct_data_sensor_imu2(data_sensor_imu_raw);
    stt_out.data_sensor_imu     = data_sensor_imu;

    %%%% set mat_body_rot_FC_raw
    qx          = data_sensor_imu(8);
    qy          = data_sensor_imu(9);
    qz          = data_sensor_imu(10);
    qw          = data_sensor_imu(11);
    quat_this   = UnitQuaternion([qw, qx, qy, qz]);     % by Peter Corke's robotics toolbox 10.2
    stt_out.mat_body_rot_FC_raw = quat_this.R;
    
elseif stt_out.data_type == (stt_fixed_macro.DATA_HEIGHT),
    height_raw   = data_sensor(1);
    height_calib = height_raw + 0.11;
    
    stt_out.data_sensor_height = height_calib;
    
else
    fprintf('Invalid data packet...\n');
end
    % completed to set
    %       stt_out.data_sensor_uwb
    %       or stt_out.data_sensor_imu & stt_out.mat_body_rot_FC_raw
    %       or stt_out.data_sensor_height

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set output - (4) data_xyz_GT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_GT_raw    = data_xyz_GT(1);
y_GT_raw    = data_xyz_GT(2);
z_GT_raw    = data_xyz_GT(3);

x_GT_calib  = x_GT_raw;
y_GT_calib  = y_GT_raw + 0.21;
z_GT_calib  = z_GT_raw + 0.095;

stt_out.data_xyz_GT = [x_GT_calib, y_GT_calib, z_GT_calib];
    % completed to set
    %       stt_out.data_xyz_GT

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set final
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stt_sensordata_out = stt_out;


end
