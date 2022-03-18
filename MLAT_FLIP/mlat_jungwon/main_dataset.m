clc;
clear all;
close all;

%%%% Do not edit
DATA_UWB    = 0;
DATA_IMU    = 2;
DATA_HEIGHT = 3;
%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [USER setting] exp data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exp_num = 2; % select data set  1~5
using_uwb_data = 'real'; % Choose what data to use: 'real'  or  'synthetic' UWB data - synthetic UWB data is retrived with totalstation

switch using_uwb_data
    case 'real'
        use_synthetic = 0;
    case 'synthetic'
        use_synthetic = 1;
        synthetic_noise_std = 0.20;    % set syntheic zero mean gausian noise magnitude(std),  e.g. 0 or  0.05 or 0.20  (m)

        
%%%% string for savefile name %%%%%%%%%%%%%%
        if 0==synthetic_noise_std
            syn_noise_str = '0';
        elseif 0.05==synthetic_noise_std
            syn_noise_str = '005';
        elseif 0.20==synthetic_noise_std
            syn_noise_str = '020';
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
end
synthetic_noise_std = 0.20;
syn_noise_str = 0;

%%%% file path and name
switch exp_num
    case 1
        fname_exp_csv = 'csv_exp20180530_gt/2018-05-30-11-15-17_exp1_groundtruth_added.csv';
    case 2
        fname_exp_csv = 'csv_exp20180530_gt/2018-05-30-11-31-47_exp2_groundtruth_added.csv';
    case 3
        fname_exp_csv = 'csv_exp20180530_gt/2018-05-30-13-13-21_exp3_big_circle_groundtruth_added.csv';
    case 4
        fname_exp_csv = 'csv_exp20180530_gt/2018-05-30-13-26-45_exp4_up_down_groundtruth_added.csv';
    case 5
        fname_exp_csv = 'csv_exp20180530_gt/2018-05-30-13-32-30_exp5_left_right_groundtruth_added.csv';
end
%%%%


raw_data_loaded = csvread(fname_exp_csv);
num_data_packet = size(raw_data_loaded, 1)/3;   % /3: one packet consists of three rows.
    % completed to set
    %       raw_data_loaded
    %       num_data_packet

data_UWB = zeros(1,4);
    % c1: time(s), c2: module id, c3: range(m), c4: range error(m)

data_xyz_GT = zeros(1,3);
    % All the data packets(data_packet_UWB/data_packet_imu/data_packet_height) are accompanied with data_packet_xyz_GT.
   
% [one packet]
%   row1: data_type (DATA_UWB(0)/DATA_IMU(2)/DATA_HEIGHT(3))
%   row2: data_UWB / data_imu / data_height (depending on data_type)
%   row3: data_xyz_GT

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% initializing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UWB anchor positions
UWB_100 = [-0.0029,0.0026,0.5946];
UWB_101 = [8.5121,-0.0001,0.9376];
UWB_102 = [-0.2599,10.7664,1.3001];
UWB_103 = [8.2461,10.8352,1.5580];

%%%% parse
set_UWB100_raw = [];
set_UWB101_raw = [];
set_UWB102_raw = [];
set_UWB103_raw = [];
xyz_all_MLAT=[];
xyz_all_flipped=[];
xyz_all_optimized=[];
xyz_gt=[];

time_previous = 0;

% offset 
x_offset=0.00;
y_offset=0.21;  %0.21 
z_offset=0.095; %0.095

%%%% loop
for idx_data_packet = 1:num_data_packet 
% for idx_data_packet = 30000:40000 

    idx_data_packet
    
    %%%%============================================================================================================================
    %%%% Reading raw sensor data (Starting here)
    %%%%============================================================================================================================

    %%%% get row idx & row
    idx_r1 = 3*idx_data_packet - 2;
    idx_r2 = 3*idx_data_packet - 1;
    idx_r3 = 3*idx_data_packet;
    
    data_r1 = raw_data_loaded(idx_r1, :);   % data_type
    data_r2 = raw_data_loaded(idx_r2, :);   % sensor data
    data_r3 = raw_data_loaded(idx_r3, :);   % xyz_GT
    
    %%%% parse
    data_type = data_r1(1);
    
    if data_type == DATA_UWB,           % DATA_UWB(0)
        data_UWB = data_r2(1:4);
    elseif data_type == DATA_IMU,       % DATA_IMU(2)
        data_imu = data_r2(1:11);
    elseif data_type == DATA_HEIGHT,    % DATA_HEIGHT(3)
        data_height = data_r2(1);
    else
        fprintf('Invalid data packet...\n');
    end
    
    data_xyz_GT = data_r3(1:3);

        %   row1: data_type (DATA_UWB(0)/DATA_IMU(2)/DATA_HEIGHT(3))
        %
        %   row2: data_UWB / data_imu / data_height (depending on data_type)
        %           data_UWB
        %               c1: time(s), c2: module id, c3: range(m), c4: range error(m)
        %           data_imu
        %               c1: time(s)
        %               c2, c3, c4: angular vel - x,y,z
        %               c5, c6, c7: linear acc - x,y,z
        %               c8, c9, c10, c11: ori quaternion - x,y,z,w
        %           data_height
        %
        %   row3: data_xyz_GT


     if data_type == DATA_HEIGHT,
        x_gt_this   = data_xyz_GT(1);
        y_gt_this   = data_xyz_GT(2)+y_offset;
        z_gt_this   = data_xyz_GT(3)+z_offset;

        height_this = data_height;
        
    end

    if data_type == DATA_UWB
               
        time_this = data_UWB(1);
        dt = time_this - time_previous;
        
        x_gt_this   = data_xyz_GT(1)+x_offset; %%%%%%%%%%%%%%%%% offset
        y_gt_this   = data_xyz_GT(2)+y_offset; %%%%%%%%%%%%%%%%% offset
        z_gt_this   = data_xyz_GT(3)+z_offset; %%%%%%%%%%%%%%%%% offset
        
        xyz_gt = [xyz_gt;x_gt_this,y_gt_this,z_gt_this];

        UWB_id_this = data_UWB(2);
        UWB_range_this = data_UWB(3);
        UWB_error_this = data_UWB(4);
        

        switch UWB_id_this
            case 100                        
                         anchor_position = UWB_100;
            case 101
                         anchor_position = UWB_101;
            case 102
                         anchor_position = UWB_102;
            case 103
                         anchor_position = UWB_103;
        end
        
        range_gt_this= norm(anchor_position- [x_gt_this,y_gt_this,z_gt_this],2);
        
        if abs(UWB_range_this-range_gt_this)>0.5
            continue;
        end

        %%%% accumulate
        temp_row    = [time_this, ...                           % c1
                            x_gt_this, y_gt_this, z_gt_this, ...        % c2, c3, c4
                            range_gt_this, ...                         % c5
                            UWB_range_this, ...                        % c6
                            UWB_error_this, ...                        % c7
                                            ];
        switch UWB_id_this
            case 100                        
                        set_UWB100_raw = [set_UWB100_raw; temp_row];
            case 101
                        set_UWB101_raw = [set_UWB101_raw; temp_row];
            case 102
                        set_UWB102_raw = [set_UWB102_raw; temp_row];
            case 103
                        set_UWB103_raw = [set_UWB103_raw; temp_row];
        end
        

    end


        if isempty(set_UWB100_raw) || isempty(set_UWB101_raw) || isempty(set_UWB102_raw) || isempty(set_UWB103_raw) || isempty(height_this)
            continue;           
        end
        
       
        set_pos_uwb   = [UWB_100; UWB_101; UWB_102; UWB_103];
        set_range_uwb = [set_UWB100_raw(size(set_UWB100_raw,1),6);
                         set_UWB101_raw(size(set_UWB101_raw,1),6);
                         set_UWB102_raw(size(set_UWB102_raw,1),6); 
                         set_UWB103_raw(size(set_UWB103_raw,1),6)];
        
        %_____________________________________________________________ MLAT
        [set_xyz_stage1_out] = solve_mlat_stage1(false, set_pos_uwb', set_range_uwb', eye(4));
        xyz_all_MLAT=[xyz_all_MLAT;set_xyz_stage1_out];
        
        %_____________________________________________________________ FLIP
        set_xyz_stage1_flipped_out = solve_flip([set_xyz_stage1_out(1),set_xyz_stage1_out(2),set_xyz_stage1_out(3)], set_pos_uwb);
        xyz_all_flipped=[xyz_all_flipped;set_xyz_stage1_flipped_out];
        
        %__________________________________________________________OPTIMIZE
        set_xyz0    = set_xyz_stage1_flipped_out;
        options = optimoptions('lsqnonlin', 'FunctionTolerance', 1e-10);
        %%%% declare
        global g_mlat_pos_uwb_x1    g_mlat_pos_uwb_y1   g_mlat_pos_uwb_z1   g_mlat_range_uwb1;
        global g_mlat_pos_uwb_x2    g_mlat_pos_uwb_y2   g_mlat_pos_uwb_z2   g_mlat_range_uwb2;
        global g_mlat_pos_uwb_x3    g_mlat_pos_uwb_y3   g_mlat_pos_uwb_z3   g_mlat_range_uwb3;
        global g_mlat_pos_uwb_x4    g_mlat_pos_uwb_y4   g_mlat_pos_uwb_z4   g_mlat_range_uwb4;
        global g_mlat_z_height;
        
        
        %%%% set
        g_mlat_pos_uwb_x1 = set_pos_uwb(1,1);    g_mlat_pos_uwb_y1 = set_pos_uwb(1,2);    g_mlat_pos_uwb_z1 = set_pos_uwb(1,3);
        g_mlat_range_uwb1 = set_range_uwb(1);
        
        g_mlat_pos_uwb_x2 = set_pos_uwb(2,1);    g_mlat_pos_uwb_y2 = set_pos_uwb(2,2);    g_mlat_pos_uwb_z2 = set_pos_uwb(2,3);
        g_mlat_range_uwb2 = set_range_uwb(2);
        
        g_mlat_pos_uwb_x3 = set_pos_uwb(3,1);    g_mlat_pos_uwb_y3 = set_pos_uwb(3,2);    g_mlat_pos_uwb_z3 = set_pos_uwb(3,3);
        g_mlat_range_uwb3 = set_range_uwb(3);
        
        g_mlat_pos_uwb_x4 = set_pos_uwb(4,1);    g_mlat_pos_uwb_y4 = set_pos_uwb(4,2);    g_mlat_pos_uwb_z4 = set_pos_uwb(4,3);
        g_mlat_range_uwb4 = set_range_uwb(4);

        g_mlat_z_height   = height_this;
        
        set_xyz_optimized_out = lsqnonlin(@my_objfunc_mlat_stage1, set_xyz0,[],[],options);
        xyz_all_optimized=[xyz_all_optimized;set_xyz_optimized_out];


        time_previous = time_this;        
end

plot3(xyz_all_flipped(:,1),xyz_all_flipped(:,2),xyz_all_flipped(:,3),'r-', 'LineWidth',2.0);
hold on
% plot3(xyz_all_MLAT(:,1),xyz_all_MLAT(:,2),xyz_all_MLAT(:,3),'b-', 'LineWidth',2.0);
plot3(xyz_all_optimized(:,1),xyz_all_optimized(:,2),xyz_all_optimized(:,3),'b-', 'LineWidth',5.0);

% plot3(xyz_gt(:,1),xyz_gt(:,2),xyz_gt(:,3),'g-', 'LineWidth',5.0);
plot3(xyz_gt(:,1),xyz_gt(:,2),xyz_gt(:,3),'g-', 'MarkerSize',0.5);
