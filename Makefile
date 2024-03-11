CC = clang++
LD = clang++
CPPFLAGS = -std=c++17  -I/opt/iot/include -D__DEBUG__=1

LDFLAGS = -lpthread -L/opt/iot/lib -liot -lpthread


ROOTDIR = ./

CP = cp
ECHO = echo

BUILD_DIR = build

# SIMPLETEST_OBJECT = $(BUILD_DIR)/simpletest.o
LOG_OBJECT = $(BUILD_DIR)/log.o

CPP_SOURCES = ./log.cpp
CPP_HEADERS = ./log.hpp
C_SOURCES = ./simpletest/simpletest.cpp

TEST_SOURCE = test_log.cpp log.cpp simpletest/simpletest.cpp
# TEST_OBJECT = $(patsubst %.cpp, $(BUILD_DIR)/%.o, $(notdir $(TEST_SOURCE)))

APP = APP2
TEST_APP = test_log

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(CPP_SOURCES:.cpp=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.cpp=.o)))

vpath %.cpp $(sort $(dir $(CPP_SOURCES)))
vpath %.cpp src

# OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
# vpath %.c $(sort $(dir $(C_SOURCES)))

$(BUILD_DIR)/%.o: %.cpp $(CPP_HEADERS) Makefile | $(BUILD_DIR)
	$(ECHO) compiling $<
	$(CC) -c $(CPPFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(ECHO) compiling $<
	clang -c $(CFLAGS) $< -o $@

all: $(BUILD_DIR) $(BUILD_DIR)/$(APP) $(BUILD_DIR)/$(TEST_APP)

run: $(BUILD_DIR)/$(APP)
	$(BUILD_DIR)/$(APP)

$(BUILD_DIR)/$(APP): main_part2.cpp $(OBJECTS) Makefile
	$(ECHO) linking $<
	$(CC) $(CPPFLAGS) $(LDFLAGS) -o $@ ./main_part2.cpp $(OBJECTS)
	$(ECHO) successs

.PHONY: all test clean

# Compile simpletest.cpp and log.cpp separately
$(SIMPLETEST_OBJECT): ./simpletest/simpletest.cpp $(CPP_HEADERS) Makefile | $(BUILD_DIR)
	$(ECHO) compiling $<
	$(CC) -c $(CPPFLAGS) $< -o $@

$(LOG_OBJECT): log.cpp $(CPP_HEADERS) Makefile | $(BUILD_DIR)
	$(ECHO) compiling $<
	$(CC) -c $(CPPFLAGS) $< -o $@

# Link test executable with separate object files
test: $(BUILD_DIR)/$(TEST_APP)
	$(BUILD_DIR)/$(TEST_APP)

$(BUILD_DIR)/$(TEST_APP): $(OBJECTS) $(SIMPLETEST_OBJECT)  ./test_log.o $(TEST_OBJECT) Makefile
	$(ECHO) linking $<
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(SIMPLETEST_OBJECT)  ./test_log.o $(TEST_OBJECT)
	$(ECHO) successs



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


