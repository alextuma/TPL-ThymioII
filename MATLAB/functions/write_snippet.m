function [ status, loop ] = write_snippet( def, file_name, state, ID, LineFeed, loop )
%write_snippet write the code of the snippet into the file

status = 0;

% load the information, where the code for each ID is stored
load('source.mat');

% find the index of the ID
list_ids = cell2mat(source(1,:));
index = find(list_ids==ID);

if isempty(index)
    status = status-3;
    return
end


try
    
    % open filestream (append data)
    fileB = fopen(file_name,'a');
    
    % END-ID
    if def.endID == ID
        % the program comes here when the end is reached
        status = status + write_if_state(fileB,-1,LineFeed);
        
    % START-ID
    elseif def.startID == ID
        % close filestream
        fclose(fileB);
        
        % open filestream (create file)
        fileB = fopen(file_name,'w');
    else
        % write the statemachine
        status = status + write_if_state(fileB,state,LineFeed);
    end
    
    % open the filestream for the source-code-file (only read)
    fileA = fopen(strcat(source{2,index},'.txt'),'r');
        
    % check if the block is part of a loop
    if strncmp('Loop_end',source{2,index},8)
        % loop-end
        
        fprintf(fileB,LineFeed);
        fprintf(fileB,'		loop_cnt[');
        fprintf(fileB,'%d',loop.depth);
        fprintf(fileB,'] = loop_cnt[');
        fprintf(fileB,'%d',loop.depth);
        fprintf(fileB,']+1');
        fprintf(fileB,LineFeed);
        
        if loop.type(loop.depth) == 0
            % current loop is 5-times repeat loop
            fprintf(fileB,'		if loop_cnt[');
            fprintf(fileB,'%d',loop.depth);
            fprintf(fileB,'] >= 5 then');
            fprintf(fileB,LineFeed);
            fprintf(fileB,'			state = state+1');
            fprintf(fileB,LineFeed);
            fprintf(fileB,'		else ');
            fprintf(fileB,LineFeed);
            fprintf(fileB,'			state = ');
            fprintf(fileB,'%d',loop.state(loop.depth)+1);  % added +1 (Stefan)
            fprintf(fileB,LineFeed);
            fprintf(fileB,'		end');
            fprintf(fileB,LineFeed);
        else
            % current loop is endless loop
            fprintf(fileB,'		state = ');
            fprintf(fileB,'%d',loop.state(loop.depth));
        end
        
        % decrease the loop depth
        loop.depth = loop.depth-1;
        % remove the last entries
        loop.type(end) = [];
        loop.state(end) = [];
        
    elseif strncmp('Loop',source{2,index},4)
        % loop-start
        
        % increase the loop depth
        loop.depth = loop.depth+1;
       
        fprintf(fileB,LineFeed);
        fprintf(fileB,'# start loop');
        fprintf(fileB,LineFeed);
        fprintf(fileB,'		loop_cnt[');
        fprintf(fileB,'%d',loop.depth);
        fprintf(fileB,'] = 0');
        fprintf(fileB,LineFeed);
        fprintf(fileB,'\t\tstate = state + 1');
        fprintf(fileB,LineFeed);
        
        loop.state(loop.depth) = state;
        
        if ID==61
            % 5-times repeat loop
            loop.type(loop.depth) = 0;
        else
            % endless loop
            loop.type(loop.depth) = 1;
        end
    else
        % non loop ID
        
        while 1
            % read a line from the source-code-file
            input_string = fgetl(fileA);

            % check if the end of the file is reached
            if input_string == -1
                break;
            end

            % write the data
            if ID ~= def.startID && ID ~=def.endID
                fprintf(fileB,'\t\t');
            end
            fprintf(fileB,input_string);
            fprintf(fileB,LineFeed);

        end
        
        % close filestream
        fclose(fileA);
    end
    
    % close filestream
    fclose(fileB);   
catch % error hanlding
    status = status-1;
    fclose('all');
end

end

