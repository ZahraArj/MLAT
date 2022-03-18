% 2019/10/19
% Jungwon Kang


function [queue_data, ...
          cell_pop_out_final] = func_pop_out_from_queue_data(queue_data, ...
                                                             time_now, ...
                                                             height_from_FC_most_recent, ...
                                                             set_pos_station_uwb, ...
                                                             stt_fixed_macro)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% func_pop_out_from_queue_data()
%   function_MLAT_yes()
%   function_MLAT_no
%   function_check_state_uwb_in_queue_data()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% create empty cell for output
cell_pop_out_final = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [step 1] gather initial pop-out data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial pop-out data: data before the last valid uwb data

%%%%--------------------------------------------------------------------------------------------------------------------
%%%% get all elements in queue_data
%%%%--------------------------------------------------------------------------------------------------------------------
[ret_alldata_aaa, totnum_element_aaa, cell_alldata_aaa] = queue_data.get_all_elements();

%%%% return if no element exist in queue_data
if ret_alldata_aaa < 0,
    return;
end

%%%% get current data type
stt_sensordata_a  = cell_alldata_aaa{1, totnum_element_aaa};
type_data_current = stt_sensordata_a.data_type;
    % completed to set
    %       type_data_current

    
%%%%--------------------------------------------------------------------------------------------------------------------
%%%% get num_required_popout_initial for pop-out
%%%%--------------------------------------------------------------------------------------------------------------------
num_required_popout_init = totnum_element_aaa;

for idx = 1:totnum_element_aaa,
    stt_sensordata_a = cell_alldata_aaa{1, idx};
       
    if (stt_sensordata_a.data_type) == (stt_fixed_macro.DATA_UWB),
        time_this = stt_sensordata_a.data_sensor_uwb(1);
        time_diff = time_now - time_this;
        
        if time_diff <= 0.1,
            num_required_popout_init = (idx - 1);
            break;
        end
    end
end
% completed to set
%   num_required_popout_initial: required number of pop-out for initial pop-out data


%%%%--------------------------------------------------------------------------------------------------------------------
%%%% pop-out for initial pop-out data
%%%%--------------------------------------------------------------------------------------------------------------------
for idx = 1:num_required_popout_init,
    [dum, cell_one_pop_out] = queue_data.pop_out_one_element();
    cell_pop_out_final{1, idx} = cell_one_pop_out{1, 1};
end
% completed to set
%       cell_pop_out_final: (1 x num_required_popout_init) cells


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [step 2] check return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%--------------------------------------------------------------------------------------------------------------------
%%%% return if all data were pop-out
%%%%--------------------------------------------------------------------------------------------------------------------
if num_required_popout_init == totnum_element_aaa,
    return;
end


%%%%--------------------------------------------------------------------------------------------------------------------
%%%% return if current input data is not uwb data
%%%%--------------------------------------------------------------------------------------------------------------------
if type_data_current ~= (stt_fixed_macro.DATA_UWB),
    return;
end

% Note that we can reach here when
%   (1) queue is not empty, and 
%   (2) current input data is UWB.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% [step 3] MLAT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%--------------------------------------------------------------------------------------------------------------------
%%%% check if non-overlapped 4 uwb data were acquired
%%%%--------------------------------------------------------------------------------------------------------------------
[cnt_data_uwb, ...
 set_cnt_id_uwb, ...
 set_range_uwb] = function_check_state_uwb_in_queue_data(queue_data, stt_fixed_macro);

%%%% return if totnum of uwb data is below 4.
if cnt_data_uwb < 4,
    return;
end


% Note that we can reach here when
%   (1) queue is not empty, and 
%   (2) current input data is UWB.
%   (3) there are 4 uwb data in data_queue.


%%%%--------------------------------------------------------------------------------------------------------------------
%%%% check if MLAT can be ran
%%%%--------------------------------------------------------------------------------------------------------------------
b_can_run_MLAT = false;

if (set_cnt_id_uwb(1) == 1) && (set_cnt_id_uwb(2) == 1) && (set_cnt_id_uwb(3) == 1) && (set_cnt_id_uwb(4) == 1),
    b_can_run_MLAT = true;
end


%%%%--------------------------------------------------------------------------------------------------------------------
%%%% action
%%%%--------------------------------------------------------------------------------------------------------------------
if b_can_run_MLAT == true,
    %%%% case: MLAT yes
    [queue_data, ...
     cell_pop_out_final] = function_MLAT_yes(   queue_data, ...
                                                cell_pop_out_final, ...
                                                set_range_uwb', ...
                                                set_pos_station_uwb, ...
                                                height_from_FC_most_recent, ...
                                                stt_fixed_macro);
else
    %%%% case: MLAT no
    [queue_data, ...
     cell_pop_out_final] = function_MLAT_no(    queue_data, ...
                                                cell_pop_out_final, ...
                                                stt_fixed_macro);
end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SUB-FUNCTION 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [queue_data, ...
          cell_pop_out_final] = function_MLAT_yes(  queue_data, ...
                                                    cell_pop_out_final, ... 
                                                    set_range_uwb, ...
                                                    set_pos_station_uwb, ...
                                                    height, ...
                                                    stt_fixed_macro)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set_range_uwb: (4 x 1)
    % set_pos_station_uwb: (4 x 3)
    % height
    %
    % MLAT 수행(z값 필요)
    % 데이터 변환
    % queue_data에서 모든 데이터 pop-out
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
    %%%% run MLAT
    [set_xyz_MLAT1, ...
     set_xyz_MLAT2] = solve_mlat_jungwon(   set_pos_station_uwb, ...
                                            set_range_uwb, ...
                                            true, ...
                                            height);

    %%%% get all elements in queue_data
    [ret_alldata, totnum_element, cell_alldata] = queue_data.get_all_elements();

    
    %%%% transfer
    [dum, size_init] = size(cell_pop_out_final);    % size_init: size before update

    cnt = 1;
    
    for idx = 1:totnum_element,
        stt_sensordata_a = cell_alldata{1, idx};

        if stt_sensordata_a.data_type == (stt_fixed_macro.DATA_UWB),
            if idx == totnum_element,   % if it is last data, i.e. 4th data
                %%%% define new data
                % data_type         -> DATA_MLAT(4)
                % data_sensor_MLAT  -> c1: time(s), c2, c3, c4: x,y, z
                % data_xyz_GT       -> c1, c2, c3: x, y, z       
                stt_sensordata_MLAT = struct;
                    stt_sensordata_MLAT.IDX_data_packet  = stt_sensordata_a.IDX_data_packet;
                    stt_sensordata_MLAT.data_type        = stt_fixed_macro.DATA_MLAT;
                    stt_sensordata_MLAT.data_sensor_MLAT = [stt_sensordata_a.data_sensor_uwb(1), set_xyz_MLAT2(1), set_xyz_MLAT2(2), set_xyz_MLAT2(3)];
                    stt_sensordata_MLAT.data_xyz_GT      = stt_sensordata_a.data_xyz_GT;
                    
                stt_sensordata_a = stt_sensordata_MLAT;
            else
                continue;       % for intermediate uwb data in four data
            end
        else
            % just transfer
        end
        
        cell_pop_out_final{1, size_init + cnt} = stt_sensordata_a;
        cnt = cnt + 1;
    end

    
    %%%% pop-out all
    [dum1, dum2] = queue_data.pop_out_all_elements();
    
       
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SUB-FUNCTION 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [queue_data, ...
          cell_pop_out_final] = function_MLAT_no(   queue_data, ...
                                                    cell_pop_out_final, ...
                                                    stt_fixed_macro)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pop-out data before the next valid uwb
    % (-> 다음 valid UWB 데이터 앞의 모든 데이터 pop-out)
    %
    % Note that at this moment, 
    % the first data in queue_data would be UWB data.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
    %%%% get all elements in queue_data
    [ret_alldata, totnum_element, cell_alldata] = queue_data.get_all_elements();

    
    %%%% get num_required_popout
    num_required_popout_MLAT = 0;
    
    for idx = 2:totnum_element,
        stt_sensordata_a = cell_alldata{1, idx};

        if (stt_sensordata_a.data_type) == (stt_fixed_macro.DATA_UWB),       
            num_required_popout_MLAT = (idx - 1);
            break;
        end
    end
    % completed to set
    %       num_required_popout_MLAT
    
    
    %%%% pop-out
    [dum, size_init] = size(cell_pop_out_final);
    
    for idx = 1:num_required_popout_MLAT,
        [dum, cell_one_pop_out] = queue_data.pop_out_one_element();
        cell_pop_out_final{1, size_init + idx} = cell_one_pop_out{1, 1};
    end
    % completed to set
    %       cell_pop_out_final: (1 x num_required_popout_init + num_required_popout_MLAT) cells

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SUB-FUNCTION 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cnt_data_uwb, ...
          set_cnt_id_uwb, ...
          set_range_uwb] = function_check_state_uwb_in_queue_data(  queue_data, ...
                                                                    stt_fixed_macro)


%%%% get all elements in queue_data
[ret_alldata, totnum_element, cell_alldata] = queue_data.get_all_elements();


% init
cnt_data_uwb    = 0;
set_cnt_id_uwb  =    zeros(1,4);     % c1:100, c2:101, c3:102, c4:103
set_range_uwb   = -1.*ones(1,4);     % valid only when all set_cnt_id_uwb(i) = 1


for idx = 1:totnum_element,
    stt_sensordata_a = cell_alldata{1, idx};

    if (stt_sensordata_a.data_type) == (stt_fixed_macro.DATA_UWB),
        cnt_data_uwb = cnt_data_uwb + 1;
        
        id_uwb       = stt_sensordata_a.data_sensor_uwb(2);
        range_uwb    = stt_sensordata_a.data_sensor_uwb(3);

        if id_uwb == 100,   
            set_cnt_id_uwb(1) = set_cnt_id_uwb(1) + 1;
            set_range_uwb (1) = range_uwb;
        end
        
        if id_uwb == 101,   
            set_cnt_id_uwb(2) = set_cnt_id_uwb(2) + 1;
            set_range_uwb (2) = range_uwb;
        end
        
        if id_uwb == 102,   
            set_cnt_id_uwb(3) = set_cnt_id_uwb(3) + 1;
            set_range_uwb (3) = range_uwb;
        end
        
        if id_uwb == 103,
            set_cnt_id_uwb(4) = set_cnt_id_uwb(4) + 1;
            set_range_uwb (4) = range_uwb;
        end
    end
end
% completed to set
%       cnt_data_uwb   : a scalar
%       set_cnt_id_uwb : (1 x 4)
%       set_range_uwb  : (1 x 4)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

