% 2018/08/12
% Jungwon Kang


function visualize_set_xyz_current( IDX_data_packet, ...
                                    stt_var_runtime, ...
                                    stt_fixed_value_uwb_station)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% copy to local
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
Time_now                    = stt_var_runtime.time_now;
Traj_origin_GT              = stt_var_runtime.traj_origin_GT;
Mat_body_rot_GT             = stt_var_runtime.mat_body_rot_FC_most_recent;
Mat_body_trans_GT           = stt_var_runtime.mat_body_trans_GT;
%Traj_origin_EST             = stt_var_runtime.traj_origin_EST;
Set_xyz_current_EST         = stt_var_runtime.set_xyz_current_EST;
Mat_body_rot_EST            = stt_var_runtime.mat_body_rot_EST;
Mat_body_trans_EST          = stt_var_runtime.mat_body_trans_EST;
Set_pos_station_uwb         = stt_fixed_value_uwb_station.set_pos_station_uwb;
Set_pos_station_uwb_ground  = stt_fixed_value_uwb_station.set_pos_station_uwb_ground;
    % completed to set
    %   Traj_origin_GT            : (A x 4), 4: time, x,y,z
    %   Traj_origin_EST           : (B x 4), 4: time, x,y,z
    %   Mat_body_rot_GT & EST     : (3 x 3)
    %   Mat_body_trans_GT & EST   : (3 x 1)
    %   Set_pos_station_uwb       : (C x 3), 3: x,y,z
    %   Set_pos_station_uwb_ground: (C x 3), 3: x,y,z

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% pos of fig
pos_fig_left    = 100;
pos_fig_bottom  = 100;
pos_fig_width   = 600;
pos_fig_height  = 600;

%%%%
view_az = 20;
view_el = 30;

x_axis_min = -2;
x_axis_max = 10;
y_axis_min = -2;
y_axis_max = 14;
z_axis_min = 0;
z_axis_max = 8;

%%%% visualization style (for uwb)
option_arrow_station_uwb   = 'e-2';
style_arrow_station_uwb_w  = 0;
style_arrow_station_uwb_h  = 0;
style_arrow_station_uwb_ip = 1;     % initial point marker

%%%% visualization style (for current axis)
option_arrow_current_axis_x = 'r-2';
option_arrow_current_axis_y = 'g-2';
option_arrow_current_axis_z = 'b-2';

style_arrow_current_axis_w  = 0.5;
style_arrow_current_axis_h  = 0.5;
style_arrow_current_axis_ip = 0.1;

%%%% visualization style (for current body)
option_arrow_current_body_x = 'b-0';
style_arrow_current_body_ip = 0.7;

%%%% visualization length (for current & past axis)
length_current  = 1.0;
length_past     = 0.05;


format_fname_img_res = './screenshot/img_res_%d.png';
fname_img_res        = sprintf(format_fname_img_res, IDX_data_packet);

format_str_title = 'Time: %fs';
str_title = sprintf(format_str_title, Time_now);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% parse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos_station_uwb100 = Set_pos_station_uwb(1,:);
pos_station_uwb101 = Set_pos_station_uwb(2,:);
pos_station_uwb102 = Set_pos_station_uwb(3,:);
pos_station_uwb103 = Set_pos_station_uwb(4,:);

pos_station_uwb100_ground = Set_pos_station_uwb_ground(1,:);
pos_station_uwb101_ground = Set_pos_station_uwb_ground(2,:);
pos_station_uwb102_ground = Set_pos_station_uwb_ground(3,:);
pos_station_uwb103_ground = Set_pos_station_uwb_ground(4,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% compute axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% GT
[vec_x_axis_current_GT, ...
 vec_y_axis_current_GT, ...
 vec_z_axis_current_GT] = compute_axis2(length_current, Mat_body_rot_GT, Mat_body_trans_GT');

%%%% EST
[vec_x_axis_current_EST, ...
 vec_y_axis_current_EST, ...
 vec_z_axis_current_EST] = compute_axis2(length_current, Mat_body_rot_EST, Mat_body_trans_EST');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% draw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
h_fig = figure(1);
    set(h_fig, 'Position', [pos_fig_left, pos_fig_bottom, pos_fig_width, pos_fig_height]);
    set(h_fig, 'Color', [1 1 1]);


daspect([1 1 1])    % for arrow3
view(view_az, view_el);
axis equal;
axis tight;


grid on;
hold on;

xlabel('x', 'fontsize',16);
ylabel('y', 'fontsize',16);
zlabel('z', 'fontsize',16);
title(str_title, 'fontsize',16);

axis equal;
axis([x_axis_min, x_axis_max, y_axis_min, y_axis_max, z_axis_min, z_axis_max]);
camlight left;
zticks([0 2 4 6 8])


%%%% draw UWB stations
arrow3(pos_station_uwb100, pos_station_uwb100_ground, option_arrow_station_uwb, style_arrow_station_uwb_w, style_arrow_station_uwb_h, style_arrow_station_uwb_ip);
arrow3(pos_station_uwb101, pos_station_uwb101_ground, option_arrow_station_uwb, style_arrow_station_uwb_w, style_arrow_station_uwb_h, style_arrow_station_uwb_ip);
arrow3(pos_station_uwb102, pos_station_uwb102_ground, option_arrow_station_uwb, style_arrow_station_uwb_w, style_arrow_station_uwb_h, style_arrow_station_uwb_ip);
arrow3(pos_station_uwb103, pos_station_uwb103_ground, option_arrow_station_uwb, style_arrow_station_uwb_w, style_arrow_station_uwb_h, style_arrow_station_uwb_ip);

%%%% draw traj(GT)
if size(Traj_origin_GT, 1) >= 1
    x_traj = Traj_origin_GT(:, 2);
    y_traj = Traj_origin_GT(:, 3);
    z_traj = Traj_origin_GT(:, 4);

    plot3(x_traj, y_traj, z_traj, 'o', 'MarkerSize', 2, 'Color', 'r', 'MarkerFaceColor', 'r');
    %plot3(x_traj, y_traj, z_traj, '.', 'Color', [1.0, 0.0, 0.0], 'LineWidth', 1.5);
    %plot3(x_traj, y_traj, z_traj, 'g-', 'LineWidth', 1.5);
end

%%%% draw set of current estimated xyz
if size(Set_xyz_current_EST, 1) >= 1
    x_traj = Set_xyz_current_EST(:, 2);
    y_traj = Set_xyz_current_EST(:, 3);
    z_traj = Set_xyz_current_EST(:, 4);
    
    plot3(x_traj, y_traj, z_traj, 'o', 'MarkerSize', 2, 'Color', 'b', 'MarkerFaceColor', 'b');
    %plot3(x_traj, y_traj, z_traj, 'b-', 'LineWidth', 1.5);
end


%%%% draw axis(GT)
arrow3(vec_x_axis_current_GT(1,:), vec_x_axis_current_GT(2,:), option_arrow_current_axis_x, style_arrow_current_axis_w, style_arrow_current_axis_h, style_arrow_current_axis_ip);
arrow3(vec_y_axis_current_GT(1,:), vec_y_axis_current_GT(2,:), option_arrow_current_axis_y, style_arrow_current_axis_w, style_arrow_current_axis_h, style_arrow_current_axis_ip);
arrow3(vec_z_axis_current_GT(1,:), vec_z_axis_current_GT(2,:), option_arrow_current_axis_z, style_arrow_current_axis_w, style_arrow_current_axis_h, style_arrow_current_axis_ip);


%%%% draw axis(EST)
arrow3(vec_x_axis_current_EST(1,:), vec_x_axis_current_EST(2,:), option_arrow_current_axis_x, style_arrow_current_axis_w, style_arrow_current_axis_h, style_arrow_current_axis_ip);
arrow3(vec_y_axis_current_EST(1,:), vec_y_axis_current_EST(2,:), option_arrow_current_axis_y, style_arrow_current_axis_w, style_arrow_current_axis_h, style_arrow_current_axis_ip);
arrow3(vec_z_axis_current_EST(1,:), vec_z_axis_current_EST(2,:), option_arrow_current_axis_z, style_arrow_current_axis_w, style_arrow_current_axis_h, style_arrow_current_axis_ip);



drawnow;
pause(0.01);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% save as img
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    f = getframe(h_fig);
    colormap(f.colormap);
    imwrite(f.cdata, fname_img_res);
    pause(0.01);
end

if 0
    saveas(gcf, fname_img_res);
    pause(0.001);
end


