.PHONY: clean
all: calc

operate.out: calc.S
	arm-linux-gnueabi-gcc $< -o $@ -ggdb3 -static -mfpu=vfp -mfloat-abi=hard -lm
clean:
	rm -f calc
