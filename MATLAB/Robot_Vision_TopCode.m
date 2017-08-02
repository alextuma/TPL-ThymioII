% Robot Vision - Tangible Programming Language for Thymio II
% 
% by Alexander Tuma & Stefan Teller
%
% If a program is created with the tangible blocks, and it is photographed, 
% this script can download it to a Thymio II.


% reset
clear all
close all
clc

% Name of the Picture with the tangible blocks
Picture_Name = 'Fotox.jpg';
% Name of the generated File with the Aseba Code
File_Name = 'MATLAB_TO_THYMIO.aesl';


addpath('snippets');
addpath('functions');
addpath('data');

DEBUG_INFO = 0; % set 1 for more Information in the Command Window


%% Part One - get the right IDs, from START to END

% START-ID & END-ID Definition
def.startID = 31;
def.endID = 47;

% add Path of Java Classes to MATLAB
javaaddpath(pwd, '-end');

% create a instance of the class Scanner
o = topcodes.Scanner;

% scan for TopCodes in the image
found_codes = toArray(o.scan(Picture_Name));

% number of found codes
num_fc = found_codes.size(1);

% get the x position of all codes
x_pos_temp = zeros(1,num_fc);
code_id = zeros(1,num_fc);
for i=1:num_fc;
    x_pos_temp(i) = found_codes(i).getCenterX();
    code_id(i) = found_codes(i).getCode();
end

% sort the x positions
[~, index] = sort(x_pos_temp);

% sort the classes and IDs
sorted_codes = found_codes(index);
sorted_ids = code_id(index);

% find START & END
index_start = find(sorted_ids==def.startID);
index_end = find(sorted_ids==def.endID);

% check if both were found
if isempty(index_start) || isempty(index_end)
    fprintf('START or END not detected\n');
    return;
end

% remove the wrong codes
sorted_ids = sorted_ids(index_start:index_end);
sorted_codes = sorted_codes(index_start:index_end);

% number of remaining top codes
num_rem_tc = 1+index_end-index_start;

if num_rem_tc == 0
    fprintf('No Blocks between Start and End\n');
    return;
elseif num_rem_tc < 0
    fprintf('Start is further to the right in the picture than End.\n');
    fprintf('But the blocks have to be aligned from Left to Right.\n');
    return;
end

% get the new/sorted x position of all codes
x_pos = zeros(1,num_rem_tc);
y_pos = zeros(1,num_rem_tc);
diameter = zeros(1,num_rem_tc);
for i=1:num_rem_tc;
    x_pos(i) = sorted_codes(i).getCenterX();
    y_pos(i) = sorted_codes(i).getCenterY();
    diameter(i) = sorted_codes(i).getDiameter();
end

% To discard TopCodes that are not in a row between START and END,
% the distance of all TopCodes to the straight line between START and END is calculated.
% Then all topcodes are discarded whose distance is greater than the Threshold.

% write coordinates of START and END into a matrix
M = [x_pos(1),y_pos(1);...
        x_pos(end),y_pos(end)];
    
% average diameter of START and END
av_dia = 1/2 * (diameter(1)+diameter(end));
    
% get the parameters for the equation -> a*x + b*y + c = 0 with c=-1;
c = -1;
par_vec = M\(-c*ones(2,1));
par_vec_norm = norm(par_vec);

% write all datapoints into a matrix
p = [x_pos;y_pos];

% calculate distance of all top codes
d = (p' * par_vec + c*ones(num_rem_tc,1))/par_vec_norm;

% check if distance is greater than the treshold
thres = 1.5 * av_dia;
too_far = abs(d) > thres;

% store the valid IDs
final_ids = sorted_ids(~too_far);


fprintf('The valid IDs are: ');
fprintf('\t %d', final_ids);
fprintf('\n');


%% Part One and a Half - replace the IDs from a higher abstraction level
%                      - and little syntax

load('IDreplace.mat')

% check how much loop-IDs are in the final IDs
[~,num_loop_5_start] = find(final_ids==61);
[~,num_loop_forever_start] = find(final_ids==79);
[~,num_loop_end] = find(final_ids==87);

num_loop_start = (length(num_loop_5_start)+length(num_loop_forever_start));
num_loop_end = length(num_loop_end);

% check if the number of loop-starts is equal to the number of loop-ends
if num_loop_start ~= num_loop_end
    if num_loop_start > num_loop_end
        fprintf('ERROR: You forgot to close %d loop(s)', (num_loop_start-num_loop_end));
    else
        fprintf('ERROR: You forgot to start %d loop(s)', -(num_loop_start-num_loop_end));
    end 
    return;
end

% check the final IDs for IDs from abstracted blocks
for i=1:size(IDreplace,2)

    % search for the to replaced IDs
    [~,pos] = find(final_ids==IDreplace{1,i});
    
    % check if at least one is found
    if ~isempty(pos)
        for j=1:length(pos)
            % insert the ID-sequence
            final_ids = [final_ids(1:pos(j)-1),IDreplace{2,i},final_ids(pos(j)+1:end)];
            
            % correct the position of the found IDs
            if j~=length(pos)
                pos(j+1:end) = pos(j+1:end) + length(IDreplace{2,i}) - 1;
            end
        end
    end
end


%% Part Two - generate the source code for the Thymio II based on the scanned IDs

% check the available snippets and save the information into the file "source"
getSource_new('snippets');

% number of function calls - used for debug-info
num_fc = 0;

LineFeed = '\n';

% initialize the variables for the code generation
state=0;
loop.depth = 0;

% number of IDs
remaining_ids = length(final_ids);

% represents the status of the code generation - used for debug-info
status_sum = 0;

% iterate over all remaining IDs
for i=1:remaining_ids

    current_ID = final_ids(i);
    
    % write code
    [status, loop] = write_snippet(def,File_Name,state,current_ID,LineFeed,loop);
    
    % increase num_fc
    num_fc = num_fc + 1;
    
    if DEBUG_INFO
        % display information of the current status
        fprintf('Status: %d/%d\n',status, num_fc);
    end
    
    % increase state
    state = state+1;
    
    % add current status to status_sum
    status_sum = status_sum + status;
end

if status_sum==0
    fprintf('Compiling successfully finished\n');
else
    fprintf('Something went wrong during compiling\n');
    fprintf('Status: x/y\n');
    fprintf('x...indicates where the error occured\n');
    fprintf('y...indicates at which iteration of the for-loop the error occured\n');
end
    

%% Part Three - Flash to Thymio II


fprintf('Start downloading to Thymio II ...\n');

% start the download program of the Aseba Studio
system('START "FLASH TO THYMIO" "C:\Program Files (x86)\AsebaStudio\asebamassloader"  MATLAB_TO_THYMIO.aesl "ser:name=Thymio-II" ');

% wait until the code is downloaded
pause(5);

% kill the program (there is no auto-exit)
system('taskkill /F /IM asebamassloader.exe');

fprintf('Code downloaded\n');


%%
fprintf('Script finished\n');


