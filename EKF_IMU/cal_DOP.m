function DOP_Q = cal_DOP(p_receive,p_transmit)

%%% input format
% p_receive: [1,3] 
% p_transmit: [n,3]

num_transmitter = size(p_transmit,1);

direc_v = p_transmit - repmat(p_receive,num_transmitter,1);
ranges = sqrt(sum(direc_v.^2,2));

A = [direc_v./repmat(ranges ,1,3), -ones(num_transmitter,1)];
DOP_Q = inv(A'*A);
        
end