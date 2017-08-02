function [ ] = getSource_new( folder_name )
%getSource_new searches and stores the information of the available snippets

% read out all files in the folder "folder_name"
A = dir(folder_name);

% create cell array
source = cell(1,2);

for i=3:length(A)
    
    % get the ID out of the file name
    temp1 = strsplit(A(i).name,'_');
    temp2 = strsplit(temp1{end},'.');
    ID = str2num(temp2{1});
    
    % get the Filename without the ending
    temp4 = strsplit(A(i).name,'.');
    Filename_without_ending = temp4{1};
    
    % save them into "source"
    source{1,i-2} = ID;
    source{2,i-2} = Filename_without_ending;
    
end    

% save "source"
save('data/source.mat','source');

end

