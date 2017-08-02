function [ status ] = write_top( file_name, LineFeed )
%write_top write the header of the aseba file

% load text
load('text_top.mat');

[a b] = size(text_to_write);

status = 0;

try
    % open filestream
    fileA = fopen(file_name,'w');    
    
    % write each row of the text
    for i=1:a
        fprintf(fileA,text_to_write{i});
      	fprintf(fileA,LineFeed); 
    end 
    
    % close filestream
    fclose(fileA);
catch % error handling
    status = -1;
    fclose(fileA);
end

end

