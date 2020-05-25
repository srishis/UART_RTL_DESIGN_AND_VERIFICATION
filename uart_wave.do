onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_tb/UART_DUT/clk
add wave -noupdate /uart_tb/UART_DUT/reset
add wave -noupdate /uart_tb/UART_DUT/dvsr
add wave -noupdate /uart_tb/UART_DUT/rd_uart
add wave -noupdate /uart_tb/UART_DUT/wr_uart
add wave -noupdate /uart_tb/UART_DUT/tx_full
add wave -noupdate /uart_tb/UART_DUT/rx_empty
add wave -noupdate /uart_tb/UART_DUT/w_data
add wave -noupdate /uart_tb/UART_DUT/r_data
add wave -noupdate /uart_tb/UART_DUT/rx
add wave -noupdate /uart_tb/UART_DUT/tx
add wave -noupdate /uart_tb/UART_DUT/tick
add wave -noupdate /uart_tb/UART_DUT/rx_done_tick
add wave -noupdate /uart_tb/UART_DUT/tx_done_tick
add wave -noupdate /uart_tb/UART_DUT/tx_empty
add wave -noupdate /uart_tb/UART_DUT/tx_fifo_not_empty
add wave -noupdate /uart_tb/UART_DUT/tx_fifo_out
add wave -noupdate /uart_tb/UART_DUT/rx_data_out
add wave -noupdate -divider {RX FIFO}
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/clk
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/reset
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/rd
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/wr
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/w_data
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/empty
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/r_data
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/full
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/w_addr
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/r_addr
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/wr_en
add wave -noupdate /uart_tb/UART_DUT/fifo_rx/full_tmp
add wave -noupdate -divider RX
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/clk
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/reset
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/rx
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/s_tick
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/rx_done_tick
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/dout
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/state_reg
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/state_next
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/s_reg
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/s_next
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/n_reg
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/n_next
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/b_reg
add wave -noupdate /uart_tb/UART_DUT/uart_rx_unit/b_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {197977500 ps}
