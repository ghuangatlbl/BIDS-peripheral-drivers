# LBL peripheral_drivers library

This directory hold drivers for chips that get directly attached to FPGAs.
Many of them are SPI or I2C attached chips.  These modules will typically
get instantiated by a board-support module.

Drivers for the following peripheral chips:

* AD5644R (ad56x4\_driver4.v) SPI, DAC
* AD9512 (ad95xx\_driver.v) SPI, clock divider
* DS1822 (ds1822\_driver.v) 1-Wire, serial number and thermometer
* MCP3208 (mcp3208\_rcvr.v) SPI, 8-channel ADC

All of the above are used on LLRF4 and LLRF4.6 boards.
All come with behavioral models and test benches, including simple regression tests.

* AD5644R (ad56x4\_driver3.v), SPI, DAC
* AD9258 (ad9258.v) SPI, high-speed ADC
* AD9xxx (ad9xxx\_driver.v) SPI, clock divider
* MAX1820 (max1820.v) sync pin, switching regulator
* MCP3208 (mcp3208\_wrap.v) SPI, 8-channel ADC, more features than above
* AD7794, TLC3548 (sporta.v) SPI, ADCs shared with a CPLD

The modules above are less well tested or documented than the previous ones.
  
## File Index:
* `ad56x4_driver3.v`
* `ad56x4_driver4.v`
* `ad95xx_driver.v`
* `bias_ctl.v`
* `ds1822_driver.v`
* `ds1822_state.v`
* `ds1822.v`
* `FDCP.v`
* `max1820.v`
* `mcp3208_behav.v`
* `mcp3208_rcvr.v`
* `sideboard.v`
* `sporta_demux.v`
* `sporta.v`
