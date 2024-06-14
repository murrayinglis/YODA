# EEE4120F YODA Project - Smoothing Filter in Verilog for FPGA

This project implements a smoothing filter in verilog in 2 different methods - firstly a moving average filter, secondly a Savitsky-Golay filter. The filters are compared to a golden standard MATLAB and python version. Note the multiple branches of this repo for different versions of the implementation.

Gradient descent was attempted for the Savitsky-Golay filter. This was succesfully implemented in Verilog for fitting a curve, however was too slow for an entire signal. Instead, pre-calculated coefficients were used.

TODO: merge the branches neatly for presentation
