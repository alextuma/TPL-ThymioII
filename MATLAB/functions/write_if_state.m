function [ status ] = write_if_state( fileA, state, LineFeed )
% write_if_state write the beginning of each state-code-block

% fileA -> filestream
% state -> current state of the state machine (in the file)
% LineFeed -> terminator of a line

status = 0;

try
    
    % first state
    if state==1
        fprintf(fileA, '#state machine');
        fprintf(fileA,LineFeed);
        fprintf(fileA,LineFeed);
        fprintf(fileA, 'if  event==1 then');
        fprintf(fileA,LineFeed);
        fprintf(fileA, '	if state == 1 then');
    % last state, and write end-header to the file
    elseif state==-1 
        fprintf(fileA, '	end ');
        fprintf(fileA,LineFeed);
        fprintf(fileA, '	event = 0');
        fprintf(fileA,LineFeed);
        fprintf(fileA, 'end');
        fprintf(fileA,LineFeed);
    % every other state   
    else 
        fprintf(fileA, '	elseif state == ');
        fprintf(fileA, '%d',state);
        fprintf(fileA, ' then');
    end
    
    % write a linefeed
    fprintf(fileA,LineFeed);
    
catch % error handling
    status = status-2;
end
    
end

