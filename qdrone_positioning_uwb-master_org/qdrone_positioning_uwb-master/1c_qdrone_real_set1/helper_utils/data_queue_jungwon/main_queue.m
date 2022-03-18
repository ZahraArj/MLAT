% 2019/10/14
% Jungwon Kang


clc;
clear all;
close all;

ins_mydq = CLS_MyDataQueue;


%%%%
for i=1:7,
    fprintf('------------------------------------------------------------\n');
    fprintf('  <push-in>\n');
    stt_temp = struct;
    res = ins_mydq.push_in_one_element(stt_temp);
    ins_mydq.print_state_queue();
    fprintf('  push_in_one_element - res: %f\n', res);
end



%%%%
for i=1:15,
    %%%% <push>
    fprintf('------------------------------------------------------------\n');    
    fprintf('  <push-in>\n');
    stt_temp = struct;
    res = ins_mydq.push_in_one_element(stt_temp);
    ins_mydq.print_state_queue();
    fprintf('  push_in_one_element - res: %f\n', res);
    
    %%%% <pop>
    fprintf('------------------------------------------------------------\n');    
    fprintf('  <pop-out>\n');
    [res, cell_out] = ins_mydq.pop_out_one_element();
    ins_mydq.print_state_queue();
    fprintf('  pop_out_one_element - res: %f\n', res);
end



%%%%
fprintf('------------------------------------------------------------\n');    
fprintf('  <get-all-elements>\n');
[res, totnum_element, cell_out] = ins_mydq.get_all_elements();
ins_mydq.print_state_queue();



%%%%
fprintf('------------------------------------------------------------\n');    
fprintf('  <pop-out-all-elements>\n');
[res, cell_out] = ins_mydq.pop_out_all_elements();
ins_mydq.print_state_queue();

% 
% %%%%
% for i=1:15,    
%     %%%% <pop>
%     fprintf('------------------------------------------------------------\n');    
%     fprintf('  <pop-out>\n');
%     [res, cell_out] = ins_mydq.pop_out_one_element();
%     ins_mydq.print_state_queue();
%     fprintf('  pop_out_one_element - res: %f\n', res);
%     
%     %%%% <push>
%     fprintf('------------------------------------------------------------\n');    
%     fprintf('  <push-in>\n');
%     stt_temp = struct;
%     res = ins_mydq.push_in_one_element(stt_temp);
%     ins_mydq.print_state_queue();
%     fprintf('  push_in_one_element - res: %f\n', res);    
% end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%% 
% disp('push');
% for i=1:7,
%     stt_temp = struct;
%     res = ins_mydq.push_in_one_element(stt_temp);
%     ins_mydq.print_state_queue();
%     fprintf('  push_in_one - res: %f\n', res);
% end
% 
% % %%%% 
% % disp('pop-one');
% % for i=1:10,
% %     [res, cell_out] = ins_mydq.pop_out_one_element();
% %     ins_mydq.print_state_queue();
% % end
% 
% 
% %%%% 
% disp('get-all');
% [res, cell_out] = ins_mydq.get_all_elements();
% ins_mydq.print_state_queue();



% %%%% 
% disp('pop-all');
% for i=1:1,
%     [res, cell_out] = ins_mydq.pop_out_all_elements();
%     ins_mydq.print_state_queue();
% end
























