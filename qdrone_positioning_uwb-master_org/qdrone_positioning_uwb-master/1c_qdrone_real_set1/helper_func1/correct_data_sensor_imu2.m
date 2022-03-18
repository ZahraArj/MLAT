% 2018/08/14
% Jungwon Kang

function [Data_sensor_imu_out] = correct_data_sensor_imu2(Data_sensor_imu_in)

% Data_sensor_imu_in
%   c1: time(s)
%   c2, c3, c4: angular vel - x,y,z
%   c5, c6, c7: linear acc - x,y,z
%   c8, c9, c10, c11: ori quaternion - x,y,z,w

Data_sensor_imu_out = Data_sensor_imu_in;

lamda = 1/9.8;

Data_sensor_imu_out(2) = -1.0*Data_sensor_imu_in(3);
Data_sensor_imu_out(3) =  1.0*Data_sensor_imu_in(2);
Data_sensor_imu_out(4) =  1.0*Data_sensor_imu_in(4);

Data_sensor_imu_out(5) = lamda*Data_sensor_imu_in(5);
Data_sensor_imu_out(6) = lamda*Data_sensor_imu_in(6);
Data_sensor_imu_out(7) = -1.0*lamda*Data_sensor_imu_in(7);


