
1. functions

EKFIMU_main.m - main function

NumJacob.m - calculate numerical Jacobian

Rotation_e2i.m - get rotation matrix using omega, phi and kappa

transition_function.m - transition funtion for prediction
		   (x,A_S_control,W_S_control,dt,errors)

transition_function2.m - same function with transition_function.m, different order of input (errors,A_S_control,W_S_control,dt,x)
(this function is used to calculate Jacobian)

cal_DOP.m - calculate DOP

2. File path

csv_exp20180530_gt - collected data

Figures - Exp1,Exp2...Exp5 - saving figures and RMSE

3. Collected data file format

1st row : file type ( 0-UWB, 2-IMU 3-Height) (1 element)
2nd row : if file type is 0(UWB) - Time(nano sec), Module ID, Range, Range error (4 element)
             if file type is 2(IMU) - Time(s), ang_vel_x, ang_vel_y, ang_vel_z, linear acc_x, linear acc_y, linear acc_z, quaternion_x, quaternion_y, quaternion_z, quaternion_w  (11 element)
             if file type is 3(Height) - height value (1 element), note that there is no time stamp on height from flight controller.
3rd row : ground truth x , ground truth y , ground truth z (3 element) 


%%%%Note: 
1. The code was originally build to handle IMU data with respect to UAV body frame. However, our acceleration data is based on ground frame (UWB frame) so I didn't use angural rate and didn't estimate orientation.

In order to do that I initialize with code below every step.
 x(7:9,1)=[0;0;0];x(13:15,1)=[0;0;0]; 

2.  an offset is to adjust discrepancy between UWB antenna and a prism. we assume that UAV orientation isn't changing while UAV is flying, so we simply add offset to the position of the prism.

