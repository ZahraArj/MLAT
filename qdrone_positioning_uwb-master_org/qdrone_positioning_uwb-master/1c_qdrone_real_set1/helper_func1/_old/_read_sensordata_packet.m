% 2018/08/14
% Jungwon Kang

function [Data_type, Data_sensor, Data_xyz_GT] = read_sensordata_packet(IDX_data_packet, Set_raw_data_loaded)

% Read sensor data (corresponding to IDX_data_packet) from the whole data
% Each packet consists of three data
%   (1) data type
%   (2) sensor data (UWB/IMU/HEIGHT)
%   (3) xyz (GT)

%%%% DO NOT EDIT
DATA_UWB    = 0;
DATA_IMU    = 2;
DATA_HEIGHT = 3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get row idx & row
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_r1  = 3*IDX_data_packet - 2;     % idx for row1
idx_r2  = idx_r1 + 1;                % idx for row2
idx_r3  = idx_r1 + 2;                % idx for row3

data_r1 = Set_raw_data_loaded(idx_r1, :);   % data_type
data_r2 = Set_raw_data_loaded(idx_r2, :);   % sensor data
data_r3 = Set_raw_data_loaded(idx_r3, :);   % xyz_GT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% (1) data type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data_type = data_r1(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% (2) sensor_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Data_type == DATA_UWB,           % DATA_UWB(0)
    Data_sensor = data_r2(1:4);
elseif Data_type == DATA_IMU,       % DATA_IMU(2)
    Data_sensor = data_r2(1:11);
elseif Data_type == DATA_HEIGHT,    % DATA_HEIGHT(3)
    Data_sensor = data_r2(1);
else
    fprintf('Invalid data packet...\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% (3) xyz_GT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data_xyz_GT = data_r3(1:3);


% At this moment, completed to set
%   (1) Data_type: DATA_UWB(0) / DATA_IMU(2) / DATA_HEIGHT(3)
%   (2) Data_sensor
%       data__uwb     (if Data_type == DATA_UWB(0))
%           c1: time(s)
%           c2: module id, c3: range(m), c4: range error(m)
%       data_imu     (if Data_type == DATA_IMU(2))
%           c1: time(s)
%           c2, c3, c4: angular vel - x,y,z
%           c5, c6, c7: linear acc - x,y,z
%           c8, c9, c10, c11: ori quaternion - x,y,z,w        
%       data_height  (if Data_type == DATA_HEIGHT(3))
%           c1: height(m)
%   (3) Data_xyz_GT
%           c1, c2, c3: x, y, z


