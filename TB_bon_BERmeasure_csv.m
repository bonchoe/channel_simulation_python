tic
%%% Testbench

clear all;

load ir_Microstrip4inch_fext_10Gbps;
load ir_Microstrip4inch_10Gbps;

%%% variable
N=10^5; % total # of data symbol
sps = 64; % #of samples in one symbol(1UI)
SNR_db= 1000 ; % power ratio between signal and noise
nrz=[-1,1];

%%% channel data generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:N
    sub_mat=nrz(randperm(length(nrz))); % random seed generation
    writematrix(sub_mat,'tx_data_digital.csv','WriteMode','append')
%     Tx_data_digital(:,i)=sub_mat; % digital bit ( first row= channel 1 Tx, second row = channel 2 Tx)
    writematrix(repmat(sub_mat,sps,1),'tx_data_analog.csv','WriteMode','append')
%     Tx_data_analog(:,sps*i-sps+1 : i*sps)=repmat(sub_mat,1,sps);
    % time domain pulse of Tx digital bit   ( first row= channel 1 Tx, second row = channel 2 Tx)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{

%%%%%%%%channel response%%%%%%%%%%%%%%%%%%%%%%
Rx_insertion_loss=convnfft(ir(:,1),Tx_data_analog(1,:)); % signal through lossy tr line
Rx_insertion_loss=awgn(Rx_insertion_loss,SNR_db,'measured'); % AWGN noise is added by (SNR_db) decibels.

Rx_fext=convnfft(ir_fext(:,1),Tx_data_analog(2,:)); % coupling between two channel ( channel2 affect to channel1)

Rx_signal=Rx_fext+Rx_insertion_loss; % channel 1 response with AWGN, FEXT noise (%%In practice SNR might be worse because of fext))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% without CDR we have to know delay of the signal 
%%% delay is 461 samples under 4inch 10Gbps simulation 

%%%%%%% Rx signal sampling %%%%%%%%%%%%
Rx_sample_data_wofext = Rx_insertion_loss( 461:64:461+64*(N-1)); %%%% sample N datas with considering delay ( with out FEXT)
Rx_data_digital_wofext =sign(Rx_sample_data_wofext); %%%% comparator  e.g) -0.006  ->  -1 , 0.8  ->  1


Rx_sample_data_wfext = Rx_signal( 461:64:461+64*(N-1));  %%%% sample N datas with considering delay ( with FEXT)
Rx_data_digital_wfext =sign(Rx_sample_data_wfext); %%%% comparator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%BER measure%%%%%%%%%%%%%%%%%%%%%%
Tx_channel1_sub=Tx_data_digital(1,:);

%%% 1. without FEXT
error_position_wofext=abs(Tx_channel1_sub-Rx_data_digital_wofext)./2; %%if error occured, value is 1. if not, value is 0
error_number_wofext=sum(error_position_wofext,'all'); %% add all errors

BER_wofext=error_number_wofext/N % ber measure

%%% 2. with FEXT
error_position_wfext=abs(Tx_channel1_sub-Rx_data_digital_wfext)./2;
error_number_wfext=sum(error_position_wfext,'all');

BER_wfext=error_number_wfext/N
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%% eye diagram %%%%%%%%%%%%%%%%%%%%%%%%%
%  
% %%% just cut 2UI per a window
% j=1;
% offset=0;
%  for  i=100:floor(length(Rx_insertion_loss)/sps)/2-300
%     eye_wofext(:,j) = Rx_insertion_loss(floor((sps*(2*i-2)))+1+offset: floor((sps*(2*i)))+offset);
%     j=j+1;
%  end 
% phase=[0:100/64:2*100-100/64];
% figure;
% plot(phase,eye_wofext);
% title('w/o FEXT')
% axis([0 200-100/64 -1.2 1.2])
% 
% j=1;
% offset=0;
% for  i=100:floor(length(Rx_signal)/sps)/2-300
%     eye_wfext(:,j) = Rx_signal(floor((sps*(2*i-2)))+1+offset: floor((sps*(2*i)))+offset);
%     j=j+1;
%  end 
% phase=[0:100/64:2*100-100/64];
% figure;
% plot(phase,eye_wfext);
% title('w/ FEXT')
% axis([0 200-100/64 -1.5 1.5])
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%}
toc