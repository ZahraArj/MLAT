% 2018/6/14
% compute axis
%   vec_X_axis_current: axis for displaying current axis
%   vec_X_axis_past: axis for displaying past axis


function [Vec_x_axis_current, Vec_y_axis_current, Vec_z_axis_current, ...
          Vec_x_axis_past, Vec_y_axis_past, Vec_z_axis_past] = compute_axis(Length_current, Length_past, Mat_body_rot, Mat_body_trans)

% Mat_body_trans: (1 x 3)

      
%%%% set seed axis vectors
seed_vec_x_axis_current_ = [Length_current, 0.0, 0.0];
seed_vec_y_axis_current_ = [0.0, Length_current, 0.0];
seed_vec_z_axis_current_ = [0.0, 0.0, Length_current];

seed_vec_x_axis_past_ = [Length_past, 0.0, 0.0];
seed_vec_y_axis_past_ = [0.0, Length_past, 0.0];
seed_vec_z_axis_past_ = [0.0, 0.0, Length_past];


%%%% rotate it by mat_rot
seed_vec_x_axis_current = Mat_body_rot*seed_vec_x_axis_current_';
seed_vec_y_axis_current = Mat_body_rot*seed_vec_y_axis_current_';
seed_vec_z_axis_current = Mat_body_rot*seed_vec_z_axis_current_';

seed_vec_x_axis_past = Mat_body_rot*seed_vec_x_axis_past_';
seed_vec_y_axis_past = Mat_body_rot*seed_vec_y_axis_past_';
seed_vec_z_axis_past = Mat_body_rot*seed_vec_z_axis_past_';


%%%% translate vectors to camera position. Make the vectors for plotting    
Vec_x_axis_current(1,1:3) = Mat_body_trans;
Vec_y_axis_current(1,1:3) = Mat_body_trans;
Vec_z_axis_current(1,1:3) = Mat_body_trans;

Vec_x_axis_current(2,:) = Mat_body_trans + seed_vec_x_axis_current';
Vec_y_axis_current(2,:) = Mat_body_trans + seed_vec_y_axis_current';
Vec_z_axis_current(2,:) = Mat_body_trans + seed_vec_z_axis_current';

Vec_x_axis_past(2,:) = Mat_body_trans + seed_vec_x_axis_past';
Vec_y_axis_past(2,:) = Mat_body_trans + seed_vec_y_axis_past';
Vec_z_axis_past(2,:) = Mat_body_trans + seed_vec_z_axis_past';



