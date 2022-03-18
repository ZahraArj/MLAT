% 2018/8/17
% Jungwon Kang

function [avg_err_xyz_out, ... 
          avg_err_xy_out, ...
          avg_err_x_out, ...
          avg_err_y_out, ...
          avg_err_z_out] = compute_accuracy_ae(Traj_GT, Traj_EST)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Traj_GT : xyz, (n x 4), 4:time,x,y,z
% Traj_EST: xyz, (n x 4), 4:time,x,y,z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

totnum_steps = size(Traj_GT, 1);

set_err_xyz  = zeros(totnum_steps, 1);
set_err_xy   = zeros(totnum_steps, 1);
set_err_x    = zeros(totnum_steps, 1);
set_err_y    = zeros(totnum_steps, 1);
set_err_z    = zeros(totnum_steps, 1);


for i = 1:totnum_steps
    dx = Traj_GT(i,2) - Traj_EST(i,2);
    dy = Traj_GT(i,3) - Traj_EST(i,3);
    dz = Traj_GT(i,4) - Traj_EST(i,4);

    err_xyz    = sqrt( (dx*dx) + (dy*dy) + (dz*dz) );
    err_xy     = sqrt( (dx*dx) + (dy*dy) );
    err_x      = sqrt( (dx*dx) );
    err_y      = sqrt( (dy*dy) );
    err_z      = sqrt( (dz*dz) );
    
    set_err_xyz(i) = err_xyz;
    set_err_xy (i) = err_xy;
    set_err_x  (i) = err_x;
    set_err_y  (i) = err_y;
    set_err_z  (i) = err_z;
end

avg_err_xyz_out = mean(set_err_xyz);
avg_err_xy_out  = mean(set_err_xy);
avg_err_x_out   = mean(set_err_x);
avg_err_y_out   = mean(set_err_y);
avg_err_z_out   = mean(set_err_z);


end
