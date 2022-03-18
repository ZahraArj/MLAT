% 2018/08/14
% Jungwon Kang

function draw_graph_range(Set_data_sensor_uwb_real, Set_data_sensor_uwb_gt_like)

% Set_data_sensor_uwb_real
%   c1: time(s)
%   c2: module id, c3: range(m), c4: range error(m)
% Set_data_sensor_uwb_gt_like
%   c1: time(s)
%   c2: module id, c3: range(m), c4: -1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% draw overall graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set_data_sensor_uwb100_real    = [];
set_data_sensor_uwb101_real    = [];
set_data_sensor_uwb102_real    = [];
set_data_sensor_uwb103_real    = [];

set_data_sensor_uwb100_gt_like = [];
set_data_sensor_uwb101_gt_like = [];
set_data_sensor_uwb102_gt_like = [];
set_data_sensor_uwb103_gt_like = [];

for idx = 1:size(Set_data_sensor_uwb_real, 1),            
    id_uwb = Set_data_sensor_uwb_real(idx, 2);
        
    if id_uwb == 100,
        set_data_sensor_uwb100_real     = [set_data_sensor_uwb100_real;     Set_data_sensor_uwb_real(idx, :)];
        set_data_sensor_uwb100_gt_like  = [set_data_sensor_uwb100_gt_like;  Set_data_sensor_uwb_gt_like(idx, :)];
    end
    
    if id_uwb == 101,
        set_data_sensor_uwb101_real     = [set_data_sensor_uwb101_real;     Set_data_sensor_uwb_real(idx, :)];
        set_data_sensor_uwb101_gt_like  = [set_data_sensor_uwb101_gt_like;  Set_data_sensor_uwb_gt_like(idx, :)];
    end

    if id_uwb == 102,
        set_data_sensor_uwb102_real     = [set_data_sensor_uwb102_real;     Set_data_sensor_uwb_real(idx, :)];
        set_data_sensor_uwb102_gt_like  = [set_data_sensor_uwb102_gt_like;  Set_data_sensor_uwb_gt_like(idx, :)];
    end

    if id_uwb == 103,
        set_data_sensor_uwb103_real     = [set_data_sensor_uwb103_real;     Set_data_sensor_uwb_real(idx, :)];
        set_data_sensor_uwb103_gt_like  = [set_data_sensor_uwb103_gt_like;  Set_data_sensor_uwb_gt_like(idx, :)];
    end    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% draw graph for each uwb (1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,
    figure(20),
        hold on,
        plot(set_data_sensor_uwb100_real(:,1), set_data_sensor_uwb100_real(:,3), 'r.');
        plot(set_data_sensor_uwb100_gt_like(:,1), set_data_sensor_uwb100_gt_like(:,3), 'b.');
        title('uwb 100');

    figure(21),
        hold on,
        plot(set_data_sensor_uwb101_real(:,1), set_data_sensor_uwb101_real(:,3), 'r.');
        plot(set_data_sensor_uwb101_gt_like(:,1), set_data_sensor_uwb101_gt_like(:,3), 'b.');
        title('uwb 101');

    figure(22),
        hold on,
        plot(set_data_sensor_uwb102_real(:,1), set_data_sensor_uwb102_real(:,3), 'r.');
        plot(set_data_sensor_uwb102_gt_like(:,1), set_data_sensor_uwb102_gt_like(:,3), 'b.');
        title('uwb 102');

    figure(23),
        hold on,
        plot(set_data_sensor_uwb103_real(:,1), set_data_sensor_uwb103_real(:,3), 'r.');
        plot(set_data_sensor_uwb103_gt_like(:,1), set_data_sensor_uwb103_gt_like(:,3), 'b.');
        title('uwb 103');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% draw graph for each uwb (2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1,
    figure(20),
        hold on,
        plot(set_data_sensor_uwb100_real(:,1), set_data_sensor_uwb100_real(:,3), 'r-');
        plot(set_data_sensor_uwb100_gt_like(:,1), set_data_sensor_uwb100_gt_like(:,3), 'b-');
        title('uwb 100');

    figure(21),
        hold on,
        plot(set_data_sensor_uwb101_real(:,1), set_data_sensor_uwb101_real(:,3), 'r-');
        plot(set_data_sensor_uwb101_gt_like(:,1), set_data_sensor_uwb101_gt_like(:,3), 'b-');
        title('uwb 101');

    figure(22),
        hold on,
        plot(set_data_sensor_uwb102_real(:,1), set_data_sensor_uwb102_real(:,3), 'r-');
        plot(set_data_sensor_uwb102_gt_like(:,1), set_data_sensor_uwb102_gt_like(:,3), 'b-');
        title('uwb 102');

    figure(23),
        hold on,
        plot(set_data_sensor_uwb103_real(:,1), set_data_sensor_uwb103_real(:,3), 'r-');
        plot(set_data_sensor_uwb103_gt_like(:,1), set_data_sensor_uwb103_gt_like(:,3), 'b-');
        title('uwb 103');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% draw overall graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false,
    set_time_real       = Set_data_sensor_uwb_real(:,1);
    set_range_real      = Set_data_sensor_uwb_real(:,3);

    set_time_gt_like    = Set_data_sensor_uwb_gt_like(:,1);
    set_range_gt_like   = Set_data_sensor_uwb_gt_like(:,3);


    figure(10),
        hold on;
        plot(set_time_real, set_range_real, 'r.');
        plot(set_time_gt_like, set_range_gt_like, 'b.');
        %plot(set_time_real, set_range_real, 'r-');
        %plot(set_time_gt_like, set_range_gt_like, 'b-');
end



