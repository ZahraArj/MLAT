% 2018/8/28

function [Fname_exp_csv_out, x0, y0] = load_info_dataset2(IDX_dataset)

Fname_exp_csv_out = '';
x0 = 0;
y0 = 0;

if IDX_dataset == 1,
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-11-15-17_exp1_groundtruth_added.csv';
    x0 = 4.743500;
    y0 = 4.984100;
elseif IDX_dataset == 2,
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-11-31-47_exp2_groundtruth_added.csv';
    x0 = 4.100000;
    y0 = 4.187000;    
elseif IDX_dataset == 3,
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-13-13-21_exp3_big_circle_groundtruth_added.csv';
    x0 = 4.720200;
    y0 = 5.432400;
elseif IDX_dataset == 4,
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-13-26-45_exp4_up_down_groundtruth_added.csv';
    x0 = 3.624000;
    y0 = 6.115400;
elseif IDX_dataset == 5,
    Fname_exp_csv_out   = './csv_exp20180530_gt_ver2/2018-05-30-13-32-30_exp5_left_right_groundtruth_added.csv';
    x0 = 4.326400;
    y0 = 4.378700;
end

y0 = y0 + 0.21;

end