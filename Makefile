# path to STM32F103 standard peripheral library
STD_PERIPH_LIBS ?= ./STM32F4xx_DSP_StdPeriph_Lib_V1.9.0/

# list of source files
SOURCES  = main.c led.c
SOURCES += stm32f4xx_it.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_rcc.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c
ASM_SOURCES = $(STD_PERIPH_LIBS)/Libraries/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc_ride7/startup_stm32f40_41xxx.s
LDSCRIPT = STM32F407ZETx_FLASH.ld
# name for output binary files
PROJECT ?= led
OUTPUT = ./build
# compiler, objcopy (should be in PATH)
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

# path to st-flash (or should be specified in PATH)
ST_FLASH ?= st-flash

# specify compiler flags
CFLAGS  = -g -O2 -Wall
# CFLAGS += -TSTM32F417IG_FLASH.ld
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 # -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -DSTM32F40_41xxx -DUSE_STDPERIPH_DRIVER
CFLAGS += -Wl,--gc-sections
CFLAGS += -I.
CFLAGS += -I$(STD_PERIPH_LIBS)/Libraries/CMSIS/Include/core_m4/
CFLAGS += -I$(STD_PERIPH_LIBS)/Libraries/STM32F4xx_StdPeriph_Driver/inc/
CFLAGS += -I${STD_PERIPH_LIBS}/Libraries/CMSIS/Device/ST/STM32F4xx/Include/
CFLAGS += -T$(LDSCRIPT)
OBJS = $(SOURCES:.c=.o)

all: $(PROJECT).elf
	mv $(PROJECT).elf $(PROJECT).hex $(PROJECT).bin $(OUTPUT)/.
# compile
$(PROJECT).elf: $(SOURCES)
	mkdir build
	$(CC) $(CFLAGS) $(ASM_SOURCES) $^ -o $@ -lm
	$(OBJCOPY) -O ihex $(PROJECT).elf $(PROJECT).hex
	$(OBJCOPY) -O binary $(PROJECT).elf $(PROJECT).bin

# remove binary files
clean:
	rm -f *.o *.elf *.hex *.bin
	rm -rf build

# flash
flash:
	sudo $(ST_FLASH) write $(OUTPUT)/$(PROJECT).bin 0x8000000