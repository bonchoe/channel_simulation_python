tic
%%% Testbench

clear all;

load ir_Microstrip4inch_fext_10Gbps;
load ir_Microstrip4inch_10Gbps;

%%% variable
N=10^6; % total # of data symbol
sps = 64; % #of samples in one symbol(1UI)
SNR_db= 1000 ; % power ratio between signal and noise
nrz=[-1,1];

%%% channel data generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:N
    sub_mat=nrz(randperm(length(nrz))); % random seed generation
    writematrix(sub_mat,'tx_data_digital.csv','WriteMode','append')
%     Tx_data_digital(:,i)=sub_mat; % digital bit ( first row= channel 1 Tx, second row = channel 2 Tx)
    writematrix(repmat(sub_mat,1,sps),'tx_data_analog.csv','WriteMode','append')
%     Tx_data_analog(:,sps*i-sps+1 : i*sps)=repmat(sub_mat,1,sps);
    % time domain pulse of Tx digital bit   ( first row= channel 1 Tx, second row = channel 2 Tx)
end