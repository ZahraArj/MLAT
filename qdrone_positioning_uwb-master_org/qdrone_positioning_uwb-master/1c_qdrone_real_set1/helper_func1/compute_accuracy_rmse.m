% 2018/8/17
% Jungwon Kang

function [rmse_xyz_out, rmse_xy_out, rmse_x_out, rmse_y_out, rmse_z_out] = compute_accuracy_rmse(Traj_GT, Traj_EST)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Traj_GT : xyz, (n x 4), 4:time,x,y,z
% Traj_EST: xyz, (n x 4), 4:time,x,y,z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

totnum_steps = size(Traj_GT, 1);

sum_err2_xyz  = 0.0;
sum_err2_xy   = 0.0;
sum_err2_x    = 0.0;
sum_err2_y    = 0.0;
sum_err2_z    = 0.0;


for i = 1:totnum_steps,
    dx = Traj_GT(i,2) - Traj_EST(i,2);
    dy = Traj_GT(i,3) - Traj_EST(i,3);
    dz = Traj_GT(i,4) - Traj_EST(i,4);

    %%%% compute err2
    err2_xyz        = (dx*dx) + (dy*dy) + (dz*dz);
    err2_xy         = (dx*dx) + (dy*dy);
    err2_x          = (dx*dx);
    err2_y          = (dy*dy);
    err2_z          = (dz*dz);
    
    %%%% accumulate in sum_err2
    sum_err2_xyz    = sum_err2_xyz  + err2_xyz;
    sum_err2_xy     = sum_err2_xy   + err2_xy;
    sum_err2_x      = sum_err2_x    + err2_x;
    sum_err2_y      = sum_err2_y    + err2_y;
    sum_err2_z      = sum_err2_z    + err2_z;
end

rmse_xyz_out = sqrt( sum_err2_xyz/totnum_steps );
rmse_xy_out  = sqrt( sum_err2_xy/totnum_steps  );
rmse_x_out   = sqrt( sum_err2_x/totnum_steps   );
rmse_y_out   = sqrt( sum_err2_y/totnum_steps   );
rmse_z_out   = sqrt( sum_err2_z/totnum_steps   );

end
