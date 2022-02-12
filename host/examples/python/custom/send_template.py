import uhd
import numpy as np

# Create graph
graph = uhd.rfnoc.RfnocGraph("addr=10.10.23.3")

# Create tx streamer
sa = uhd.usrp.StreamArgs('fc32', 'sc16')
sa.args = "spp=128"
tx_streamer = graph.create_tx_streamer(1, sa)

# Connect graph
graph.connect(tx_streamer, 0, "0/DUC#0", 0)
graph.connect("0/DUC#0", 0, "0/Radio#0", 0, False)
graph.commit()

# Configure radio and duc
radio = uhd.rfnoc.RadioControl(graph.get_block("0/Radio#0"))
duc = uhd.rfnoc.DucBlockControl(graph.get_block("0/DUC#0"))

radio.set_tx_frequency(1e9, 0)
radio.set_tx_gain(32, 0)
radio.set_tx_antenna("TX/RX", 0)
radio.set_rate(200e6)
radio.set_tx_bandwidth(200e6, 0)
radio.set_properties("spp:0=128")

duc.set_output_rate(200e6, 0)
duc.set_input_rate(100e3, 0)
duc.set_freq(0, 0)

# Create input
input_data = np.ones((1, 1000), dtype=np.complex64)
input_data[0, 0] = (1.0)

# matplotlib.pyplot.plot(input_data[0].real, 'r', input_data[0].imag, 'b')
# matplotlib.pyplot.show()

# Send data
while True:
    tx_md = uhd.types.TXMetadata()
    tx_md.start_of_burst = True
    tx_md.end_of_burst = True
    num_sent = tx_streamer.send(input_data, tx_md)
    print("{}\n".format(num_sent))