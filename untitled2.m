% Using matfile
fileName = 'test.mat';
matObj = matfile(filename);
matObj.Properties.Writable = true;

% Define size and chunk for creating large array
size = 10^6;
chunk = 5 * 10^4;
nrz = [-1,1];

for i=1:size/chunk
    % Random data generation
    sub_mat  = nrz(randperm(length(nrz))); % random seed generation
    write_mat
end
