% 2018/8/28

function [Fname_exp_csv_out, x0, y0, IDX_s, IDX_e, Fname_res_out, Fname_res_all_var] = load_info_dataset4(IDX_dataset)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDX_s: starting index of selected frames
% IDX_e: ending   index of selected frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fname_exp_csv_out = '';
x0 = 0;
y0 = 0;

if IDX_dataset == 1
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-11-15-17_exp1_groundtruth_added.csv';
    x0    = 4.743500;
    y0    = 4.984100;
    IDX_s = 7000;
    IDX_e = 47000;
    Fname_res_out       = './mat_res/res_mat_set1.mat';
    Fname_res_all_var   = './res_mat_allvar/all_vars_set1.mat';

elseif IDX_dataset == 2
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-11-31-47_exp2_groundtruth_added.csv';
    x0    = 4.100000;
    y0    = 4.187000;
    IDX_s = 9400;
    IDX_e = 55000;
    Fname_res_out       = './mat_res/res_mat_set2.mat';
    Fname_res_all_var   = './res_mat_allvar/all_vars_set2.mat';

elseif IDX_dataset == 3
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-13-13-21_exp3_big_circle_groundtruth_added.csv';
    x0    = 4.720200;
    y0    = 5.432400;
    IDX_s = 11500;
    IDX_e = 80000;
    Fname_res_out       = './mat_res/res_mat_set3.mat';
    Fname_res_all_var   = './res_mat_allvar/all_vars_set3.mat';
    
elseif IDX_dataset == 4
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-13-26-45_exp4_up_down_groundtruth_added.csv';
    x0    = 3.624000;
    y0    = 6.115400;
    IDX_s = 6500;
    IDX_e = 39500;
    Fname_res_out       = './mat_res/res_mat_set4.mat';
    Fname_res_all_var   = './res_mat_allvar/all_vars_set4.mat';
    
elseif IDX_dataset == 5
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-13-32-30_exp5_left_right_groundtruth_added.csv';
    x0    = 4.326400;
    y0    = 4.378700;
    IDX_s = 6500;
    IDX_e = 80500;
    Fname_res_out       = './mat_res/res_mat_set5.mat';
    Fname_res_all_var   = './res_mat_allvar/all_vars_set5.mat';
end


%%%% offset (prism to uwb module)
y0 = y0 + 0.21;

end
