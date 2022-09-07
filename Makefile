TARGET = source
DEBUG = 1
OPT = -O0
BUILD_DIR = build
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CCPP = $(PREFIX)g++
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
CPU = -mcpu=cortex-m0plus
MCU = $(CPU) -mthumb

C_DEFS =  \
-D__SAMD20E18__ \
-DDEBUG

IGNORES = 

C_SOURCES2:=$(shell find ./src ./lib -name *.c)
CPP_SOURCES2+=$(shell find ./src ./lib -name *.cpp)
C_SOURCES = $(filter-out $(IGNORES),$(C_SOURCES2) )
CPP_SOURCES = $(filter-out $(IGNORES),$(CPP_SOURCES2) )

C_INCLUDES:=$(patsubst %,-I%,$(shell find ./src ./lib -type d))

LDSCRIPT=./init/linker_script/samd20g18_flash.ld

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CPPFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -fno-rtti -fno-exceptions

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
CPPFLAGS += -g -gdwarf-2
endif

CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"
CPPFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

LIBS = -lc -lm -lnosys -lgcc -lstdc++
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -specs=nosys.specs  -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(CPP_SOURCES:.cpp=.o)))

vpath %.c $(sort $(dir $(C_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

vpath %.cpp $(sort $(dir $(CPP_SOURCES)))

$(BUILD_DIR)/%.o: %.cpp Makefile | $(BUILD_DIR) 
	$(CCPP) -c $(CPPFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.cpp=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CCPP) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/$(TARGET).elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/$(TARGET).elf | $(BUILD_DIR)
	$(BIN) $< $@	

	
$(BUILD_DIR):
	mkdir $@		

#######################################
# clean up
#######################################
clean:
	rm -fR $(BUILD_DIR)

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)