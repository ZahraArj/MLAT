% 2019/10/14
% Jungwon Kang

% https://www.mathworks.com/matlabcentral/answers/183246-updating-property-of-an-object-without-creating-new-object

% idx_end가 idx_start를 역적하는 상황 다루기 (m_cnt_element가 m_size_max_queue를 넘는 상황)
% idx_end < idx_start 상황이 있을 수 있는데, 이 상황 check하기
% element가 없으면 어떻게 되는지 확실히 check하기

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <functions>
%   print_state_queue()
%   push_in_one_element()
%   pop_out_one_element()
%   pop_out_all_elements()
%   get_all_elements()
%   get_cnt_element()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef CLS_MyDataQueue < handle
    properties
        m_idx_element_start = -1;
        m_idx_element_end   = -1;
        m_cnt_element       =  0;
        m_size_max_queue    = -1;
        m_cell_queue        = -1;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function obj = CLS_MyDataQueue(val)
            % <description>
            %   Constructor
            
            %%%% set obj.m_size_max_queue
            if nargin == 1,
                obj.m_size_max_queue = val;
            else                
                obj.m_size_max_queue = 10;
            end
                
            %%%% set obj.m_cell_queue
            obj.m_cell_queue = cell(1, obj.m_size_max_queue);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function print_state_queue(obj)
            % <description>
            %   print state pf queue            
            fprintf('  m_size_max_queue:    %f\n', obj.m_size_max_queue);
            fprintf('  m_idx_element_start: %f\n', obj.m_idx_element_start);
            fprintf('  m_idx_element_end:   %f\n', obj.m_idx_element_end);
            fprintf('  m_cnt_element:       %f\n', obj.m_cnt_element);
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function res = get_cnt_element(obj)
            res = obj.m_cnt_element;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function res = push_in_one_element(obj, stt_in)
            % ------------------------------------------------------------------------------------------------
            % <description>
            %   push in one element at back of the queue
            %   -> putting new one element into cell at newly updated idx_element_end            
            % <input>
            %   obj
            %   stt_in:      input struct
            % <output>
            %   res:         1 (sucessfully pushed)
            %               -1 (failed to push)
            % ------------------------------------------------------------------------------------------------
            
            %%%% set res
            if (obj.m_cnt_element) == (obj.m_size_max_queue),
                %==%  queue full case
                res = -1;
                return;
            else
                res = 1;
            end
            
            
            %%%% update obj.m_idx_element_end
            if (obj.m_idx_element_start) == -1 && (obj.m_idx_element_end) == -1,
                %==% first insertion case
                obj.m_idx_element_start = 1;
                obj.m_idx_element_end   = 1;
            else
                %==% non-first insertion case
                idx_element_end_new = (obj.m_idx_element_end) + 1;

                if idx_element_end_new > (obj.m_size_max_queue),
                    idx_element_end_new = 1;
                end

                obj.m_idx_element_end   = idx_element_end_new;
            end

            
            %%%% udpate obj.m_cnt_element
            obj.m_cnt_element = obj.m_cnt_element + 1;
            
            
            %%%% insert stt_in into m_cell_queue
            obj.m_cell_queue{1, (obj.m_idx_element_end)} = stt_in;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [res, cell_out] = pop_out_one_element(obj)
            % ------------------------------------------------------------------------------------------------
            % <description>
            %   pop out one element from the front of queue
            % <output>
            %   succesfully pop
            %       res: 1
            %       cell_out: non-empty (1 x 1) cells
            %   fails to pop (-> means the queue has no elements to be poped)
            %       res: -1
            %       cell_out: empty cell
            % ------------------------------------------------------------------------------------------------
            
            if (obj.m_cnt_element) == 0,
                %==% no-element case
                cell_out        = {};
                res             = -1;
            else
                %==% non no-element case
                cell_out = cell(1, 1);
                cell_out{1,1} = obj.m_cell_queue{1, (obj.m_idx_element_start)};
                
                %%%% update obj.m_idx_element_start
                idx_element_start_new = (obj.m_idx_element_start) + 1;
                
                if idx_element_start_new > (obj.m_size_max_queue),
                    idx_element_start_new = 1;
                end
                
                obj.m_idx_element_start   = idx_element_start_new;
                
                %%%% udpate obj.m_cnt_element
                obj.m_cnt_element = obj.m_cnt_element - 1;
                
                %%%% set res
                res      = 1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [res, cell_out] = pop_out_all_elements(obj)
            % ------------------------------------------------------------------------------------------------
            % <description>
            %   pop out all elements
            % <output>
            %   succesfully pop
            %       res: 1
            %       cell_out: non-empty (1 x n) cells
            %   fails to pop (-> means the queue has no elements to be poped)
            %       res: -1
            %       cell_out: empty cell
            % ------------------------------------------------------------------------------------------------
            
            if (obj.m_cnt_element) == 0,
                %==% no-element case
                
                %%%% set cell_out & res                
                cell_out = {};
                res      = -1;
            else
                %==% non no-element case
                cell_out = cell(1, (obj.m_cnt_element));
                res      = 1;
               
                %%%% set cell_out & res
                % idx_element: idx for obj.m_cell_queue
                % idx_cnt:     idx for cell_out
                idx_cnt  = 1;
                
                if (obj.m_idx_element_start) <= (obj.m_idx_element_end),
                    %==% case 1
                    for idx_element = (obj.m_idx_element_start):(obj.m_idx_element_end),
                        
                        cell_out{1, idx_cnt} = obj.m_cell_queue{1, idx_element};
                        idx_cnt = idx_cnt + 1;
                    end
                else
                    %==% case 2
                    for idx_element = (obj.m_idx_element_start):(obj.m_size_max_queue),
                        cell_out{1, idx_cnt} = obj.m_cell_queue{1, idx_element};
                        idx_cnt = idx_cnt + 1;
                    end
                    
                    for idx_element = 1:(obj.m_idx_element_end),
                        cell_out{1, idx_cnt} = obj.m_cell_queue{1, idx_element};
                        idx_cnt = idx_cnt + 1;
                    end
                end
                
                
                %%%% check
                if (obj.m_cnt_element) ~= (idx_cnt - 1),
                    fprintf('CLS_MyDataQueue::pop_out_all_elements - error..\n');
                end


                %%%% update obj.m_idx_element_start
                idx_element_start_new = (obj.m_idx_element_end) + 1;
                
                if idx_element_start_new > (obj.m_size_max_queue),
                    idx_element_start_new = 1;
                end
                
                obj.m_idx_element_start = idx_element_start_new;
                
                
                %%%% update obj.m_cnt_element
                obj.m_cnt_element = 0;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [res, cell_out] = pop_out_all_elements_obsolete(obj)
            % ------------------------------------------------------------------------------------------------
            % <description>
            %   pop out all elements
            % <output>
            %   succesfully pop
            %       res: 1
            %       cell_out: non-empty (1 x n) cells
            %   fails to pop (-> means the queue has no elements to be poped)
            %       res: -1
            %       cell_out: empty cell
            % ------------------------------------------------------------------------------------------------
            
            %%%% form cell_out
            b_keep_pop_out_one = true;
            idx = 1;
            
            cell_out = {};
            
            while b_keep_pop_out_one,
                [res_one, cell_one_out] = pop_out_one_element(obj);
                
                if res_one < 0,
                    b_keep_pop_out_one = false;
                else
                    cell_out{1, idx} = cell_one_out{1,1};
                    idx = idx + 1;
                end
            end

            %%%% set res
            [size_cell, dum] = size(cell_out);
            
            if size_cell == 0,
                res = -1;
            else
                res = 1;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [res, totnum_element, cell_out] = get_all_elements(obj)
            % ------------------------------------------------------------------------------------------------
            % <description>
            %   get all elements from the queue (without poping out)
            %   Note that 
            %       pop_out_all_elements(): includes update of obj.m_idx_element_start & obj.m_cnt_element
            %       get_all_elements(): no update of obj.m_idx_element_start & obj.m_cnt_element
            % <output>
            %   succesfully get
            %       res: 1
            %       cell_out: non-empty (1 x n) cells
            %   fails to get (-> means the queue has no elements to be got)
            %       res: -1
            %       cell_out: empty cell
            % ------------------------------------------------------------------------------------------------
                                   
            if (obj.m_cnt_element) == 0,
                %==% no-element case
                
                %%%% set cell_out & res
                cell_out        = {};
                totnum_element  = 0;
                res             = -1;
            else
                %==% non no-element case
                cell_out        = cell(1, (obj.m_cnt_element));
                totnum_element  = (obj.m_cnt_element);
                res             = 1;
               
                %%%% set cell_out & res
                % idx_element: idx for obj.m_cell_queue
                % idx_cnt:     idx for cell_out
                idx_cnt  = 1;
                
                if (obj.m_idx_element_start) <= (obj.m_idx_element_end),
                    %==% case 1
                    for idx_element = (obj.m_idx_element_start):(obj.m_idx_element_end),
                        
                        cell_out{1, idx_cnt} = obj.m_cell_queue{1, idx_element};
                        idx_cnt = idx_cnt + 1;
                    end
                else
                    %==% case 2
                    for idx_element = (obj.m_idx_element_start):(obj.m_size_max_queue),
                        cell_out{1, idx_cnt} = obj.m_cell_queue{1, idx_element};
                        idx_cnt = idx_cnt + 1;
                    end
                    
                    for idx_element = 1:(obj.m_idx_element_end),
                        cell_out{1, idx_cnt} = obj.m_cell_queue{1, idx_element};
                        idx_cnt = idx_cnt + 1;
                    end
                end
                
                
                %%%% check
                if (obj.m_cnt_element) ~= (idx_cnt - 1),
                    fprintf('CLS_MyDataQueue::get_all_elements - error..\n');
                end
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end

