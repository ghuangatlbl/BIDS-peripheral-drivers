.PHONY: all clean

UNISIM_PATH = $(XILINX)/verilog/src/unisims

ICARUS_SUFFIX=
VERILOG = iverilog$(ICARUS_SUFFIX) -Wall
VVP = vvp$(ICARUS_SUFFIX) -n
GTKWAVE = gtkwave
AWK = awk

# broken: mcp3208_wrap_tb
# put back ltc2174_tb spi_ad9268_tb spi_master_tb when they're ready
TGT = ad56x4_tb ad95xx_tb ds1822_tb mcp3208_tb sporta_tb ltc2174_tb

%_tb: %_tb.v
	$(VERILOG) -y. -o $@ $^

%_check: %_tb testcode.awk
	$(VVP) $< | $(AWK) -f $(filter %.awk, $^)

%.vcd: %_tb
	$(VVP) $< +vcd

%_view: %.vcd %.sav
	$(GTKWAVE) $^

all: $(TGT)

ltc2174_tb: ltc2174_tb.v ltc2174.v
	$(VERILOG) -y. -y$(UNISIM_PATH) -o $@ $^ $(XILINX)/verilog/src/glbl.v

# missing regression tests: ltc2174 spi_ad9268 spi_master sporta
checks: ad56x4_check ad95xx_check ds1822_check mcp3208_check

mcp3208_check: mcp3208_tb mcp3208_check.awk
	$(VVP) $< | $(AWK) -f $(filter %.awk, $^)

clean:
	rm -f $(TGT) *.vcd
