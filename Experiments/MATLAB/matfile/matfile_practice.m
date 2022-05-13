
clear all
tic

% Using matfile
% Define filename of matfile
filename = 'test.mat';

%% Define size and chunk for creating large array
N = 10^6; % Desired size of array
unit = 10^5; % Chunk size

%% Append chunk until matfile has array of desired size
for j=1:N/unit
    % Write array of unit chunk
    for i=1:unit
        sub_mat = randi([0,1],1,2);
        sub_mat = 2*sub_mat - 1;
        chunk(i,:) = sub_mat;
    end
    %% If matfile does not exist in workspace
    %  newly create .mat file
    if exist('matObj','var') == 0
        % Define matfile
        matObj = matfile(filename,'Writable',true);
        matObj.tx_data = chunk;
    %% If matfile already exists,
    %  append chunk to .mat file
    else
        matObj.tx_data = [matObj.tx_data; chunk];
    end
    fprintf('%d-th iteration among %d, current length = %d\n', j, N/unit, j*unit);
    % delete used chunk to make room of memory
    clear chunk
end
toc