% 2020/02/27
% Jungwon Kang


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% [user setting] choose dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataset_ori = 4;
    % set1(ori) = set2(new)
    % set2(ori) = set3(new)
    % set3(ori) = set4(new)
    % set4(ori) = set1(new)
    % set5(ori) = set5(new)
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% selecting dataset & load it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
fname_in = '';

if dataset_ori == 1
    fname_in = '../all_vars_set1.mat';
elseif dataset_ori == 2
    fname_in = '../all_vars_set2.mat';
elseif dataset_ori == 3
    fname_in = '../all_vars_set3.mat';
elseif dataset_ori == 4
    fname_in = '../all_vars_set4.mat';
elseif dataset_ori == 5
    fname_in = '../all_vars_set5.mat';
end


%%%
load(fname_in)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% current_graph: using range factor only
% delayed_graph: using range factor + MLAT factor

traj_now_EST_graph_current_this = traj_now_EST_graph_current(2:end, [10, 11, 12]);
traj_now_GT_graph_current_this = stt_var_runtime_current.set_xyz_current_GT_for_EST;

traj_now_EST_graph_delayed_this = traj_now_EST_graph_delayed(2:end, [10, 11, 12]);
traj_now_GT_graph_delayed_this = stt_var_runtime_delayed.set_xyz_current_GT_for_EST;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualize_traj_est(IDX_data_packet, ...
%                    stt_var_runtime_delayed, ...
%                    stt_fixed_value_uwb_station, ...
%                    traj_now_EST_graph_current);


visualize_traj_est_v1(IDX_data_packet, ...
                      stt_var_runtime_delayed, ...
                      stt_fixed_value_uwb_station, ...
                      traj_now_EST_graph_delayed_this, ...
                      traj_now_GT_graph_delayed_this);





               