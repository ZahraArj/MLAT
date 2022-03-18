% 2018/6/14
% compute axis
%   vec_X_axis_current: axis for displaying current axis
%   vec_X_axis_past: axis for displaying past axis


function [Vec_x_axis_current, Vec_y_axis_current, Vec_z_axis_current] = compute_axis2(Length_current, Mat_body_rot, Mat_body_trans)

% Mat_body_trans: (1 x 3)

      
%%%% set seed axis vectors
seed_vec_x_axis_current_ = [Length_current, 0.0, 0.0];
seed_vec_y_axis_current_ = [0.0, Length_current, 0.0];
seed_vec_z_axis_current_ = [0.0, 0.0, Length_current];


%%%% rotate it by mat_rot
seed_vec_x_axis_current = Mat_body_rot*seed_vec_x_axis_current_';
seed_vec_y_axis_current = Mat_body_rot*seed_vec_y_axis_current_';
seed_vec_z_axis_current = Mat_body_rot*seed_vec_z_axis_current_';


%%%% translate vectors to camera position. Make the vectors for plotting    
Vec_x_axis_current(1,1:3) = Mat_body_trans;
Vec_y_axis_current(1,1:3) = Mat_body_trans;
Vec_z_axis_current(1,1:3) = Mat_body_trans;

Vec_x_axis_current(2,:) = Mat_body_trans + seed_vec_x_axis_current';
Vec_y_axis_current(2,:) = Mat_body_trans + seed_vec_y_axis_current';
Vec_z_axis_current(2,:) = Mat_body_trans + seed_vec_z_axis_current';




