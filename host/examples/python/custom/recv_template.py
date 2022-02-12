import uhd
import numpy as np
import matplotlib
from matplotlib import pyplot
import cmath
import scipy
from scipy import signal
from time import sleep


# Create graph
graph = uhd.rfnoc.RfnocGraph("addr=10.10.23.2")

# Create FIR Filter block controller and set the coefficients
# fir_control = uhd.rfnoc.FirFilterBlockControl(graph.get_block("0/FIR#0"))
# coefficients = [32767, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384, 16384]
# fir_control.set_coefficients(coefficients)

# Create rx streamer
sa = uhd.usrp.StreamArgs('fc32', 'sc16')
sa.args = "spp=128"
rx_streamer = graph.create_rx_streamer(1, sa)

# Connect graph
graph.connect("0/Radio#0", 0, "0/DDC#0", 0, False)
# graph.connect("0/DDC#0", 0, fir_control.get_unique_id(), 0, False)
# graph.connect(fir_control.get_unique_id(), 0, rx_streamer, 0)
graph.connect("0/DDC#0", 0, rx_streamer, 0)
graph.commit()

# Configure radio and ddc
radio = uhd.rfnoc.RadioControl(graph.get_block("0/Radio#0"))
ddc = uhd.rfnoc.DdcBlockControl(graph.get_block("0/DDC#0"))

radio.set_rx_frequency(1e9, 0)
radio.set_rx_gain(32, 0)
radio.set_rx_antenna("RX2", 0)
radio.set_rate(200e6)
radio.set_rx_bandwidth(0, 0)
radio.set_properties("spp:0=128")

ddc.set_output_rate(100e3, 0)
ddc.set_input_rate(200e6, 0)
ddc.set_freq(0, 0)

# Receive data
output_data = np.zeros((1, 1000), dtype=np.complex64)
rx_md = uhd.types.RXMetadata()
num_recv = rx_streamer.recv(output_data, rx_md, 10.0)
print("{}\n{}".format(num_recv, rx_md))

# Shows output data - If everything is fine this should show the impulse response which is the array of coefficients of the FIR filter
output_plot = output_data[0, 0:41]
matplotlib.pyplot.plot(output_plot.real, 'r.', output_plot.imag, 'b.')
matplotlib.pyplot.show()