% 2019/10/20
% Jungwon Kang

function [stt_log] = func_log_data_graph_delayed(cell_sensordata, stt_log)

[dum, totnum_data] = size(cell_sensordata);

for idx = 1:totnum_data,
    stt_sensordata  = cell_sensordata{1, idx};
    
    IDX_data_packet = stt_sensordata.IDX_data_packet;
    data_type       = stt_sensordata.data_type;

    arr_this         = [IDX_data_packet, data_type];

    stt_log.sensordata_delayed = [stt_log.sensordata_delayed; arr_this];

end

end



