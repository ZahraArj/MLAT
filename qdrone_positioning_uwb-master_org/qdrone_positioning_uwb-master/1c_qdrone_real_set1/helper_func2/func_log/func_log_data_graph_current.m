% 2019/10/20
% Jungwon Kang

function [stt_log] = func_log_data_graph_current(stt_sensordata, stt_log)

IDX_data_packet = stt_sensordata.IDX_data_packet;
data_type       = stt_sensordata.data_type;

arr_this        = [IDX_data_packet, data_type];

stt_log.sensordata_current = [stt_log.sensordata_current; arr_this];


end
