CC = clang++
LD = clang++
CPPFLAGS = -std=c++17  -I/opt/iot/include -D__DEBUG__=1

LDFLAGS = -L/opt/iot/lib -liot -lpthread

ROOTDIR = ./

CP = cp
ECHO = echo

BUILD_DIR = build

# SIMPLETEST_OBJECT = $(BUILD_DIR)/simpletest.o
LOG_OBJECT = $(BUILD_DIR)/log.o

#I'm assuming we wouldn't need this anymore?
CPP_SOURCES = 
CPP_HEADERS = 
C_SOURCES = 

RECEIVER = receiver

APP = Socket


OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(CPP_SOURCES:.cpp=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.cpp=.o)))

vpath %.cpp $(sort $(dir $(CPP_SOURCES)))
vpath %.cpp src


$(BUILD_DIR)/%.o: %.cpp $(CPP_HEADERS) Makefile | $(BUILD_DIR)
	$(ECHO) compiling $<
	$(CC) -c $(CPPFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(ECHO) compiling $<
	clang -c $(CFLAGS) $< -o $@

all: $(BUILD_DIR) $(BUILD_DIR)/$(APP) $(BUILD_DIR)/$(TEST_APP)

run: $(BUILD_DIR)/$(APP)
	$(BUILD_DIR)/$(APP)

$(BUILD_DIR)/$(APP): client_send.cpp $(OBJECTS) Makefile
	$(ECHO) linking $<
	$(CC) $(CPPFLAGS) -o $@ ./client_send.cpp $(LDFLAGS) $(OBJECTS)
	$(ECHO) successs

$(BUILD_DIR)/$(RECEIVER): client_receiver.cpp $(OBJECTS) Makefile
	$(ECHO) linking $<
	$(CC) $(CPPFLAGS) $(LDFLAGS) -o $@ ./client_receiver.cpp $(OBJECTS)
	$(ECHO) successs

.PHONY: all test clean


$(BUILD_DIR):
	mkdir $@

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)/$(APP) $(BUILD_DIR)/*.o

#######################################
# dependencies
#######################################
-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)


