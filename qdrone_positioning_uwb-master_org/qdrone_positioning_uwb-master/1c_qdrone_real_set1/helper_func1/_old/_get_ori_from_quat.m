% 2018/8/27
% Jungwon Kang

% It needs Peter Corke's robotics toolbox (We used robot-10.2).

function [mat_ori_out] = get_ori_from_quat(qx, qy, qz, qw)

% get orientation from quaternion
quat_this   = UnitQuaternion([qw, qx, qy, qz]);
mat_ori_out = quat_this.R;
