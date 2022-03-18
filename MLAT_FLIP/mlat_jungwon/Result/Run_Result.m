%  1_ 50208    gt_10127

a=10000;b=30000;
A=ceil(a/5); B=ceil(b/5);

hold on
% plot3(xyz_all_optimized(a:b,1),xyz_all_optimized(a:b,2),xyz_all_optimized(a:b,3),'b-', 'LineWidth',9.0);
% plot3(xyz_all_optimized(a:b,1),xyz_all_optimized(a:b,2),xyz_all_optimized(a:b,3),'b.', 'MarkerSize',2);

% plot3(xyz_gt(A:B,1),xyz_gt(A:B,2),xyz_gt(A:B,3),'g-', 'LineWidth',7.0);
plot3(xyz_gt(A:B,1),xyz_gt(A:B,2),xyz_gt(A:B,3),'g-', 'LineWidth',7.0);

