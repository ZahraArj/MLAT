% 2018/9/7
% Jungwon Kang

function draw_uwb_range_inlier_outlier(H_fig, Str_title, Set_time_real, Set_range_real, Set_dr, Set_type)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set_time_real    : (N x 1)
% Set_range_real   : (N x 1)
% Set_type_range_GT: (N x 1)
% Set_time_gt_like : (N x 1) -> should be the same as Time_real
% Set_range_gt_like: (N x 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pos_fig_left   = 50;
pos_fig_bottom = 50;
pos_fig_width  = 2000;
pos_fig_height = 300;


h_fig = figure(H_fig);
set(h_fig, 'Position', [pos_fig_left, pos_fig_bottom, pos_fig_width, pos_fig_height]);


hold on,
%plot(Set_time_real, Set_range_real, 'b-');
plot(Set_time_real,     Set_range_real,    'b-', 'LineWidth', 1);
%plot(Set_time_gt_like,  Set_range_gt_like, 'k-', 'LineWidth', 1);

plot(Set_time_real,     Set_dr, 'r-', 'LineWidth', 1);
%plot(Set_time_real,    Set_ddr, 'b-', 'LineWidth', 1);


num_data  = size(Set_time_real, 1);
val_color = [0, 0, 0];

for i = 1:num_data,

    if Set_type(i) > 0.5,
        % inlier
        val_color = [0.0, 0.8, 0.0];
    else
        % outlier
        val_color = [1.0, 0.0, 0.0];
    end
    
    plot( Set_time_real(i), Set_range_real(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', val_color, 'MarkerEdgeColor', val_color);
    %plot( Set_time_real(i), Set_range_real(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', val_color);
    %plot( Set_time_real(i), Set_range_real(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', val_color, 'MarkerEdgeColor', 'k');
    %plot( Set_time_real(i), Set_dr(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    %plot( Set_time_real(i), Set_ddr(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');

    %plot( Set_time_gt_like(i), Set_range_gt_like(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'k');
    %plot( Set_time_gt_like(i), Set_range_gt_like(i), 'o', 'MarkerSize', 3, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
    %plot( Set_time_real(i),    Set_range_real(i),    'o', 'MarkerSize', 3, 'MarkerFaceColor', val_color, 'MarkerEdgeColor', val_color);
    
end

title(Str_title);

