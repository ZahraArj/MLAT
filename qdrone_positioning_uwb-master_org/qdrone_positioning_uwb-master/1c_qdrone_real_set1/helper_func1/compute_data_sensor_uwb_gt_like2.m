% 2018/08/14
% 2018/09/06
% Jungwon Kang

function [Data_sensor_uwb_gt_like] = compute_data_sensor_uwb_gt_like2(Data_sensor_uwb, Data_xyz_GT, Set_pos_station_uwb)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [INPUT]
%   Data_sensor_uwb
%       c1: time(s)
%       c2: module id, c3: range(m), c4: range error(m)
%
%   Data_xyz_GT
%       c1, c2, c3: x, y, z
%
%   Set_pos_station_uwb
%       r1: x,y,z for uwb 100
%       r2: x,y,z for uwb 101
%       r3: x,y,z for uwb 102
%       r4: x,y,z for uwb 103
%
% [Output]
%   Data_sensor_uwb_gt_like
%       c1: time(s)
%       c2: module id, c3: range(m), c4: -1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% init
Data_sensor_uwb_gt_like = Data_sensor_uwb;

%%%% get uwb id
id_uwb = Data_sensor_uwb(2);

%%%% get pos_station_uwb
pos_station_uwb = zeros(1,3);

if id_uwb == 100,   pos_station_uwb = Set_pos_station_uwb(1,:);     end
if id_uwb == 101,   pos_station_uwb = Set_pos_station_uwb(2,:);     end
if id_uwb == 102,   pos_station_uwb = Set_pos_station_uwb(3,:);     end
if id_uwb == 103,   pos_station_uwb = Set_pos_station_uwb(4,:);     end

%%%% compute distance
data_xyz_gt_x = Data_xyz_GT(1);
data_xyz_gt_y = Data_xyz_GT(2) + 0.21;
data_xyz_gt_z = Data_xyz_GT(3) + 0.095;

dx = data_xyz_gt_x - pos_station_uwb(1);
dy = data_xyz_gt_y - pos_station_uwb(2);
dz = data_xyz_gt_z - pos_station_uwb(3);

range_gt_like = sqrt(dx^2 + dy^2 + dz^2);

%if id_uwb == 101, range_gt_like = range_gt_like + 0.2;  end


%%%% set
Data_sensor_uwb_gt_like(3) = range_gt_like;
Data_sensor_uwb_gt_like(4) = -1;

