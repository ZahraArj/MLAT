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
exp_num = 1; % select data set  1~5
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
        fname_exp_csv = './csv_exp20180530_gt/2018-05-30-11-15-17_exp1_groundtruth_added.csv';
    case 2
        fname_exp_csv = './csv_exp20180530_gt/2018-05-30-11-31-47_exp2_groundtruth_added.csv';
    case 3
        fname_exp_csv = './csv_exp20180530_gt/2018-05-30-13-13-21_exp3_big_circle_groundtruth_added.csv';
    case 4
        fname_exp_csv = './csv_exp20180530_gt/2018-05-30-13-26-45_exp4_up_down_groundtruth_added.csv';
    case 5
        fname_exp_csv = './csv_exp20180530_gt/2018-05-30-13-32-30_exp5_left_right_groundtruth_added.csv';
end
%%%%


raw_data_loaded = csvread(fname_exp_csv);
num_data_packet = size(raw_data_loaded, 1)/3;   % /3: one packet consists of three rows.
    % completed to set
    %       raw_data_loaded
    %       num_data_packet

data_UWB = zeros(1,4);
    % c1: time(s), c2: module id, c3: range(m), c4: range error(m)
data_imu = zeros(1,11);
    % c1: time(s)
    % c2, c3, c4: angular vel - x,y,z
    % c5, c6, c7: linear acc - x,y,z
    % c8, c9, c10, c11: ori quaternion - x,y,z,w
data_height = 0;
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
set_imu_raw     = [];
set_height_raw  = [];
set_UWB100_raw = [];
set_UWB101_raw = [];
set_UWB102_raw = [];
set_UWB103_raw = [];

HDOP=0;
VDOP=0;

%memory pre-allocation
x_all=zeros(ceil(size(raw_data_loaded,1)/4),21);
x_all_index=0;

%%%% state vector   

% *velocity: V, *biases of accelerometers: A_b, *biases of gyroscopes: W_b
% *position: B, *orientation: q (Tait bryan angle)
% x=[V,A_b,W_b,B,q]' 15 state

% control of pose state 
% A_S Accelerometer measurements 
% W_S Gyroscope measurements

V=[0,0,0]';
A_b=[0,0,0]';
W_b=[0,0,0]';
B=raw_data_loaded(3,1:3)'; % initial position 
q=[0,0,0]';  

acc_x_this=0;
acc_y_this=0;
acc_z_this=0;%A_S_control=[0,0,0];

ang_vel_x_this=0;
ang_vel_y_this=0;
ang_vel_z_this=0;%W_S_control=-[0,0,0];


% initial state vector
x=[V;A_b;W_b;B;q];

% initial system covariance matrix
P=diag(ones(1,15))*1; 

% Noise Model
std_V_vec=[0.02,0.02,0.02]; %velocity random walk
std_A_b_vec=[0.003,0.003,0.003]; % accelerometer random walk
std_W_b_vec=[0.005,0.005,0.005]/180*pi(); %gyroscope random walk
std_q_vec=[1,1,1]/180*pi(); % orientation random walk

% process covariance matrix
Q=diag([std_V_vec.^2,std_A_b_vec.^2,std_W_b_vec.^2,std_q_vec.^2]);

std_UWB=max(0.05,synthetic_noise_std); % set minimum error for UWB measurement when I use synthetic data

time_previous = 0;

% offset 
x_offset=0.00;
y_offset=0.21;  %0.21 
z_offset=0.095; %0.095


%%%% loop
for idx_data_packet = 1:num_data_packet,    
    
    
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
                    

    
    if data_type == DATA_IMU,
              
        
        time_this       = data_imu(1);        
        dt = time_this - time_previous;
        
        x_gt_this       = data_xyz_GT(1)+x_offset;
        y_gt_this       = data_xyz_GT(2)+y_offset;
        z_gt_this       = data_xyz_GT(3)+z_offset;
                
        ang_vel_x_this  = data_imu(3) *(-1);  %axis change
        ang_vel_y_this  = data_imu(2);        %axis change
        ang_vel_z_this  = data_imu(4);
        
        acc_x_this      = data_imu(5) / 9.81;  % devide by gravity constant
        acc_y_this      = data_imu(6) / 9.81;  % devide by gravity constant
        acc_z_this      = data_imu(7) / (-9.81);  % devide by gravity constant, axis change

        quat_x_this    = data_imu(8);
        quat_y_this    = data_imu(9);
        quat_z_this    = data_imu(10);
        quat_w_this    = data_imu(11);
        
        % calculate DOP
        DOP_Q_gt = cal_DOP([x_gt_this,y_gt_this,z_gt_this],[UWB_100;UWB_101;UWB_102;UWB_103]);
        HDOP_gt_this =sqrt(DOP_Q_gt(1,1)+ DOP_Q_gt(2,2));
        VDOP_gt_this =sqrt( DOP_Q_gt(3,3));
        
        A_S_control=[acc_x_this;acc_y_this;acc_z_this]; %IMU accelerometer
        W_S_control=-[ang_vel_x_this;ang_vel_y_this;ang_vel_z_this]; %IMU gyroscope
        
        % calculate numerical Jacobian
        A=NumJacob(@transition_function,x,A_S_control,W_S_control,dt,zeros(12,1));
        W=NumJacob(@transition_function2,zeros(12,1),A_S_control,W_S_control,dt,x);

        %%%%% using VDOP to determine process covariance matrix
        %%%%% if VDOP is high(low accuracy height of UWB positioning), give less error to IMU 
        if VDOP>0.5
        Q=diag([[std_V_vec(1) std_V_vec(2) std_V_vec(3)*0.1].^2,std_A_b_vec.^2,std_W_b_vec.^2,std_q_vec.^2]);
        else
        Q=diag([std_V_vec.^2,std_A_b_vec.^2,std_W_b_vec.^2,std_q_vec.^2]);
        end
        %%%%%
        
        
         %prediction
        P=A*P*A'+W*Q*W';
        x=transition_function(x,A_S_control,W_S_control,dt,zeros(12,1)); 
        
        x(7:9,1)=[0;0;0];x(13:15,1)=[0;0;0]; %% ignore orientation factor
        
        % save current state
        x_all_index=x_all_index+1;
        x_all(x_all_index,:) = [time_this x_gt_this y_gt_this z_gt_this x' HDOP_gt_this VDOP_gt_this];
        % c1: time
        % c2:4 position_gt
        % c5:7 velocity
        % c8:10 acceleration bias
        % c11:13 gyroscope bias
        % c14:16 position
        % c17:19 orientation
        % c20 HDOP
        % c21 VDOP
        
        
        %accumulate IMU data
        temp_row    = [time_this, ...                                                   % c1
                        x_gt_this, y_gt_this, z_gt_this, ...                            % c2, c3, c4
                        acc_x_this, acc_y_this, acc_z_this, ...                         % c5, c6, c7
                        ang_vel_x_this, ang_vel_y_this, ang_vel_z_this, ...             % c8, c9, c10
                        quat_x_this, quat_y_this, quat_z_this, quat_w_this, ...     % c11, c12, c13, c14
                        ];
        set_imu_raw = [set_imu_raw; temp_row];
        
        
       time_previous = time_this;
    end
    
    
    
        
    if data_type == DATA_UWB,
               
        time_this = data_UWB(1);
        dt = time_this - time_previous;
        
        x_gt_this   = data_xyz_GT(1)+x_offset; %%%%%%%%%%%%%%%%% offset
        y_gt_this   = data_xyz_GT(2)+y_offset; %%%%%%%%%%%%%%%%% offset
        z_gt_this   = data_xyz_GT(3)+z_offset; %%%%%%%%%%%%%%%%% offset
        
      
        UWB_id_this = data_UWB(2);
        UWB_range_this = data_UWB(3);
        UWB_error_this = data_UWB(4);
        
        
         A_S_control=[acc_x_this;acc_y_this;acc_z_this];
        W_S_control=-[ang_vel_x_this;ang_vel_y_this;ang_vel_z_this];
        
        A=NumJacob(@transition_function,x,A_S_control,W_S_control,dt,zeros(12,1));
        W=NumJacob(@transition_function2,zeros(12,1),A_S_control,W_S_control,dt,x);
        
        if VDOP>0.5
        Q=diag([[std_V_vec(1) std_V_vec(2) std_V_vec(3)*0.1].^2,std_A_b_vec.^2,std_W_b_vec.^2,std_q_vec.^2]);
        end
        P=A*P*A'+W*Q*W';
        Q=diag([std_V_vec.^2,std_A_b_vec.^2,std_W_b_vec.^2,std_q_vec.^2]);
        
        x=transition_function(x,A_S_control,W_S_control,dt,zeros(12,1));
        
        x(7:9,1)=[0;0;0];x(13:15,1)=[0;0;0]; %% ignore orientation factor
        
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
        
        
        
        %%%%%%%%%%%%%%%
        if 1==use_synthetic 
        UWB_range_this = range_gt_this+randn(1)*synthetic_noise_std; 
        end
        %%%%%%%%%%%%%%%
        
        
        if abs(UWB_range_this-range_gt_this)>0.5
            continue;
        end
        %%%% correction
        expectated_range = norm(x(10:12) - anchor_position');
        H=1/expectated_range*[zeros(1,9), x(10:12)' - anchor_position, zeros(1,3) ];
        
        P12=P*H';                   %cross covariance
        K=P12/(H*P12+std_UWB);       %Kalman filter gain


        x=x+K*(UWB_range_this-expectated_range);            %state estimate
        P=P-K*P12';               %state covariance matrix
        
        x(7:9,1)=[0;0;0];x(13:15,1)=[0;0;0]; %% ignore orientation factor
        
        DOP_Q_gt = cal_DOP([x_gt_this,y_gt_this,z_gt_this],[UWB_100;UWB_101;UWB_102;UWB_103]);
        HDOP_gt_this =sqrt(DOP_Q_gt(1,1)+ DOP_Q_gt(2,2));
        VDOP_gt_this =sqrt( DOP_Q_gt(3,3));
        
        x_all_index=x_all_index+1;
        x_all(x_all_index,:) = [time_this x_gt_this y_gt_this z_gt_this x' HDOP_gt_this VDOP_gt_this];
              % c1: time
        % c2:4 position_gt
        % c5:7 velocity
        % c8:10 acceleration bias
        % c11:13 gyroscope bias
        % c14:16 position
        % c17:19 orientation
        % c20 HDOP
        % c21 VDOP  
        
        
        
        
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
        
        
        
        time_previous = time_this;        
    end
    
        
    %%%%
    if data_type == DATA_HEIGHT,
        x_gt_this   = data_xyz_GT(1);
        y_gt_this   = data_xyz_GT(2)+y_offset;
        z_gt_this   = data_xyz_GT(3)+z_offset;

        height_this = data_height;
        
        %%%% accumulate
        temp_row    = [time_this, ...                           % c1
                        x_gt_this, y_gt_this, z_gt_this, ...    % c2, c3, c4            
                        height_this, ...                        % c5
                        ];

        set_height_raw = [set_height_raw; temp_row];
    end
        
end

% remove remaining prespace
time0ind = find(x_all(:,1)==0);
if 1==time0ind(1)
    valid_data_index=time0ind(2)-1;
else
    valid_data_index=time0ind(1)-1;
end
x_all = x_all(1:valid_data_index,:);


% ##### flip

Aap=[UWB_100;UWB_101;UWB_102;UWB_103];
Bap=-[1;1;1;1];
Pap=Aap\Bap;


Nap=size(x_all,1);
for i=1:Nap
    if x_all(i,16)<0
        v=(Pap(1)*x_all(i,14)+Pap(2)*x_all(i,15)+Pap(3)*x_all(i,16)+1)/norm(Pap);
        x_all(i,14:16)= x_all(i,14:16)-2*Pap'/norm(Pap)*v;
    end
end


% drawing 

fig_handle_1=figure(1);


set(fig_handle_1,'Position',[0 0 450 300]);

hold on;

plot3(x_all(:,2),x_all(:,3),x_all(:,4),'r-', 'LineWidth',2.0);  
plot3(x_all(:,14),x_all(:,15),x_all(:,16),'b-', 'LineWidth',2.0);
%legend({'ground truth','estimated position'},'fontsize',12,'Location','southoutside');%legend boxoff;
axis equal;
exp_num_str=strcat('Exp',num2str(exp_num));
savename_str=strcat('Set',num2str(exp_num));
title(savename_str,'fontsize',17,'fontname','arial');
grid on




xlabel('x(m)','fontsize',12,'fontname','arial');
ylabel('y(m)','fontsize',12,'fontname','arial');
zlabel('z(m)','fontsize',12,'fontname','arial');


view([45,20]);
savefig(strcat('./figures\',exp_num_str,'\',exp_num_str,'_synthetic_noise_',syn_noise_str,'_all'));

view([0,90]);
        if 1==use_synthetic 
            saveas(1,strcat('./figures\',exp_num_str,'\',exp_num_str,'_synthetic_noise_',syn_noise_str,'_top'),'jpg');
        elseif 0==use_synthetic 
            saveas(1,strcat('./figures\',exp_num_str,'\',exp_num_str,'_real_top'),'jpg');
        end

view([0,0]);
        if 1==use_synthetic 
            saveas(1,strcat('./figures\',exp_num_str,'\',exp_num_str,'_synthetic_noise_',syn_noise_str,'_side'),'jpg');
        elseif 0==use_synthetic 
            saveas(1,strcat('./figures\',exp_num_str,'\',exp_num_str,'_real_side'),'jpg');
        end

rmse_horizontal = mean((x_all(:,2) - x_all(:,14)).^2+ (x_all(:,3) - x_all(:,15)).^2)
rmse_vertical = mean((x_all(:,4) - x_all(:,16)).^2)
rmse_total = sqrt(rmse_horizontal^2+rmse_vertical^2)

        if 1==use_synthetic 
            save(strcat('./figures\',exp_num_str,'\',exp_num_str,'_synthetic_noise_',syn_noise_str,'.txt'),'rmse_horizontal','rmse_vertical','rmse_total','-ascii');
        elseif 0==use_synthetic
            save(strcat('./figures\',exp_num_str,'\',exp_num_str,'_real.txt'),'rmse_horizontal','rmse_vertical','rmse_total','-ascii');
        end
        
        figure
        plot(x_all(:,20),sqrt((x_all(:,2) - x_all(:,14)).^2+ (x_all(:,3) - x_all(:,15)).^2),'.')
        
        figure
        plot(x_all(:,21),sqrt((x_all(:,4) - x_all(:,16)).^2),'.')

        figure
        plot(x_all(:,4),sqrt((x_all(:,4) - x_all(:,16)).^2),'.')
        title('Height vs vertical error');
xlabel('Height (m)');
ylabel('Vertical error (m)');