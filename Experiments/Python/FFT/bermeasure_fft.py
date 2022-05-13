# %%
# importing libraries
from time import *
import scipy.signal as signal
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
# %matplotlib inline


def bermeasure_fft(N):
    tic = time()

    # environmental settings
    np.set_printoptions(threshold=1000) # adjust numbers to print out

    # %%
    ir = sio.loadmat('../../ir_Microstrip4inch_10Gbps')
    ir_fext = sio.loadmat('../../ir_Microstrip4inch_fext_10Gbps')

    ir = np.array(ir['ir'])
    ir_fext = np.array(ir_fext['ir_fext'])

    ir = ir.reshape(-1)
    ir_fext = ir_fext.reshape(-1)

    # %%
    # variable definition
    # N = 10**6        # total number of symbol
    sps = 64        # number of samples in one symbol i.e. 1UI
    SNR_db = 1000   # power ratio b/w signal and noise

    # %%
    # channel data generation
    tx_data_digital = np.zeros((2,N))
    tx_data_analog = np.zeros((2,N*sps))

    # Generate two independent gaussian random signal
    for i in range(N):
        data = 2*np.random.randint(2, size=(2,1)) - 1 # random signal generation
        tx_data_digital[:, i] = data.flatten()
        tx_data_analog[:, (i)*sps : (i+1)*sps] = np.repeat(data,sps,axis=1)

    # %%
    # channel response with noise

    # signal thru lossy tr line i.e. insertion loss
    rx_ins_loss=signal.fftconvolve(ir,tx_data_analog[0,:])

    # %%
    # noise generation according to target SNR and dB
    sig_avg_pow = np.mean(np.square(rx_ins_loss))
    sig_avg_db = 10 * np.log10(sig_avg_pow)

    # calculate noise magnitude in dB and power
    noise_avg_db = sig_avg_db - SNR_db
    noise_avg_pow = 10 ** (noise_avg_db / 10)

    # generate a sample of white noise according to normal distribution
    # mean = 0; variation = noise_avg_pow
    noise = np.random.normal(0,np.sqrt(noise_avg_pow),len(rx_ins_loss))

    # %%
    print(rx_ins_loss)

    # %%
    # sum up noise with original rx signal
    rx_ins_loss += noise

    # %%
    # channel response with noise and FEXT
    rx_fext = signal.fftconvolve(ir_fext,tx_data_analog[1,:])

    rx_signal = rx_fext + rx_ins_loss

    # %%
    # without CDR we have to know delay of the signal 
    # delay is 461 samples under 4inch 10Gbps simulation 

    # Rx signal sampling
    rx_sample_data = rx_ins_loss[460:460+sps*N:sps]
    rx_data_digital = np.sign(rx_sample_data)

    rx_sample_data_fext = rx_signal[460:460+sps*N:sps]
    rx_data_digital_fext = np.sign(rx_sample_data_fext)

    # %%
    print(rx_data_digital)

    # %%
    # BER measurement
    tx_channel1_sub = tx_data_digital[0,:]
    print(f"N: {N}")
    # 1. w/o FEXT
    # position error: the index element is 1 if error occurred, 0 otherwise
    error_pos = np.divide(abs(tx_channel1_sub - rx_data_digital),2)
    error_num = sum(error_pos)

    BER = error_num / N
    print("BER w/o FEXT =", BER)
    print(f"# error: {error_num}")

    # 2. w/ FEXT
    error_pos_fext = np.divide(abs(tx_channel1_sub - rx_data_digital_fext),2)
    error_num_fext = sum(error_pos_fext)

    BER_fext = error_num_fext / N
    print("BER w/  FEXT =", BER_fext)
    print("# error: {}".format(error_num_fext))

    # %%
    toc = time()
    print(f'{toc-tic:.2f} sec for N = {N}')
    return toc-tic

