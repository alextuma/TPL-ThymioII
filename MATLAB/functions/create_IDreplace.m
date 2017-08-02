% File with the Information of advanced/abstracted IDs/tangible blocks

% the ID in the first row will be replaced by the IDs in the second row of the same column

% initialize the cell array
IDreplace = cell(2,1);
n=0;


n=n+1;
% Flash RED LED
IDreplace{1,n} = 143;
IDreplace{2,n} = [61,107,171,121,171,87]

n=n+1;
% Flash BLUE LED
IDreplace{1,n} = 151;
IDreplace{2,n} = [61,109,171,121,171,87]

n=n+1;
% Flash YELLOW LED
IDreplace{1,n} = 155;
IDreplace{2,n} = [61,115,171,121,171,87]

n=n+1;
% Flash GREEN LED
IDreplace{1,n} = 157;
IDreplace{2,n} = [61,117,171,121,171,87]


save('data\IDreplace','IDreplace');