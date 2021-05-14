.PHONY: clean
all: calc

calc: calc.S
	arm-linux-gnueabi-gcc $< -o $@ -ggdb3 -static
clean:
	rm -f calc
