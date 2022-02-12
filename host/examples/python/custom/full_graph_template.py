import uhd
import numpy as np
from time import sleep

# Create graph
graph = uhd.rfnoc.RfnocGraph("addr=10.10.23.2")


# Connect blocks
graph.connect("0/Radio#0", 0, "0/DDC#0", 0, False)
# graph.connect("0/DDC#0", 0, "0/DUC#1", 0, False)
graph.connect("0/DDC#0", 0, "0/FIR#0", 0, False)
graph.connect("0/FIR#0", 0, "0/DUC#1", 0, False)
graph.connect("0/DUC#1", 0, "0/Radio#1", 0, False)

graph.connect("0/Radio#1", 0, "0/DDC#1", 0, False)
# graph.connect("0/DDC#1", 0, "0/DUC#0", 0, True)
graph.connect("0/DDC#1", 0, "0/FIR#1", 0, False)
graph.connect("0/FIR#1", 0, "0/DUC#0", 0, True)
graph.connect("0/DUC#0", 0, "0/Radio#0", 0, False)


# Get Block controllers
radio0 = uhd.rfnoc.RadioControl(graph.get_block("0/Radio#0"))
radio1 = uhd.rfnoc.RadioControl(graph.get_block("0/Radio#1"))
ddc0 = uhd.rfnoc.DdcBlockControl(graph.get_block("0/DDC#0"))
ddc1 = uhd.rfnoc.DdcBlockControl(graph.get_block("0/DDC#1"))
duc0 = uhd.rfnoc.DucBlockControl(graph.get_block("0/DUC#0"))
duc1 = uhd.rfnoc.DucBlockControl(graph.get_block("0/DUC#1"))
fir0 = uhd.rfnoc.FirFilterBlockControl(graph.get_block("0/FIR#0"))
fir1 = uhd.rfnoc.FirFilterBlockControl(graph.get_block("0/FIR#1"))


# Set block properties
# Radio0
radio0.set_rx_frequency(1e9, 0)
radio0.set_rx_gain(32, 0)
radio0.set_rx_antenna("RX2", 0)
radio0.set_rate(200e6)
radio0.set_rx_bandwidth(200e6, 0)
radio0.set_properties("spp:0=128")
radio0.enable_rx_timestamps(False, 0)
radio0.set_tx_frequency(1e9, 0)
radio0.set_tx_gain(32, 0)
radio0.set_tx_antenna("TX/RX", 0)
# radio1.set_rate(200e6)
radio0.set_tx_bandwidth(200e6, 0)
# radio1.set_properties("spp:0=128")

# Radio1
radio1.set_rx_frequency(1e9, 0)
radio1.set_rx_gain(32, 0)
radio1.set_rx_antenna("RX2", 0)
radio1.set_rate(200e6)
radio1.set_rx_bandwidth(200e6, 0)
radio1.set_properties("spp:0=128")
radio1.enable_rx_timestamps(False, 0)
radio1.set_tx_frequency(1e9, 0)
radio1.set_tx_gain(32, 0)
radio1.set_tx_antenna("TX/RX", 0)
# radio1.set_rate(200e6)
radio1.set_tx_bandwidth(200e6, 0)
# radio1.set_properties("spp:0=128")

# DDC0
# ddc0.set_input_rate(200e6, 0)
# ddc0.set_output_rate(100e3, 0)
# ddc0.set_freq(0, 0)

# DDC1
# ddc1.set_input_rate(200e6, 0)
# ddc1.set_output_rate(100e3, 0)
# ddc1.set_freq(0, 0)
# ddc1.set_output_properties("scaling=1.0", 0)

# DUC0
# duc0.set_input_rate(100e3, 0)
# duc0.set_output_rate(200e6, 0)
# duc0.set_freq(0, 0)
# duc0.set_input_properties("scaling=1.0", 0)

# DUC1
# duc1.set_input_rate(100e3, 0)
# duc1.set_output_rate(200e6, 0)
# duc1.set_freq(0, 0)

# FIR0
fir0.set_coefficients([32767, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

# FIR1
fir1.set_coefficients([32767, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
# fir1.set_input_properties("scaling=1.0", 0)


# Commit blocks
for edge in graph.enumerate_active_connections():
    print(edge.to_string())

graph.commit()

sleep(1)

streamcmd = uhd.rfnoc.lib.types.stream_cmd(uhd.rfnoc.lib.types.stream_mode.start_cont)
streamcmd.stream_now = True
radio0.issue_stream_cmd(streamcmd, 0)
radio1.issue_stream_cmd(streamcmd, 0)

print("Press Enter to exit the script")
input()

radio0.issue_stream_cmd(uhd.rfnoc.lib.types.stream_cmd(uhd.rfnoc.lib.types.stream_mode.stop_cont), 0)
radio1.issue_stream_cmd(uhd.rfnoc.lib.types.stream_cmd(uhd.rfnoc.lib.types.stream_mode.stop_cont), 0)