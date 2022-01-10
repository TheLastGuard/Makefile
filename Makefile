###########################################
### MACROS
###########################################

# $(1) : Compiler
# $(2) : Object file to generate
# $(3) : Source file
# $(4) : Additional dependencies
# $(5) : Compiler flags
define COMPILE
$(2) : $(3) $(4)
	$(1) -c -o $(2) $(3) $(5)

endef

# $(1) : Source file
define C2O
$(patsubst %.c,%.o,$(patsubst %.cpp,%.o,$(patsubst $(SRC)%,$(OBJ)%,$(1))))
endef

# $(1) : Source file
define C2H
$(patsubst %.c,%.h,$(patsubst %.cpp,%.hpp,$(patsubst $(SRC)%,$(INC)%,$(1))))
endef

###########################################
### CONFIG
###########################################
UNAME   := $(shell uname)
APP     := bin/game
CCFLAGS := -Wall -pedantic
CFLAGS  := $(CCFLAGS)
CC 	  := g++
C       := gcc
AR      := ar
ARFLAGS := -crs
RANLIB  := ranlib
MKDIR   := mkdir -p
SRC     := src
OBJ     := obj
INC     := include
BIN     := bin
# add another include dirs
INCDIRS := -Iinclude
# add the libraries 
# SDL2 = -lmingw32 -lSDL2main -lSDL2
LIBS    :=

ifeq ($(UNAME),Linux)
	OS := linux
else 
   OS := windows
endif

ifdef CROSSWIN
	C:=x86_64-w64-mingw32-gcc
	CC:=x86_64-w64-mingw32-g++
	AR:=x86_64-w64-mingw32-ar
	RANLIB:=x86_64-w64-mingw32-ranlib
	OS:=windows
endif

# to debug the app "make DEBUG=1"
ifdef DEBUG
   CCFLAGS += -g 
	CFLAGS  += -g
else ifdef SANITIZE
	CCFLAGS += -fsanitize=address -fno-omit-frame-pointer -O1 -g
	CFLAGS  += -fsanitize=address -fno-omit-frame-pointer -O1 -g
else 
   CCFLAGS += -O3
   CFLAGS  += -O3
endif

# find is a linux command if you are in windows you can download msys2 
# and add to the path "C:\msys64\usr\bin  (this is the defauld path)" 
# and rename the executable find.exe of msys to findg.exe to avoid problems with the Windows find command
# also rename this MACROS
ALLCPPS    := $(shell find src/ -type f  -iname *.cpp)
ALLCS      := $(shell find src/ -type f  -iname *.c)
ALLOBJ     := $(foreach F,$(ALLCPPS) $(ALLCS),$(call C2O,$(F)))
SUBDIRS    := $(shell find $(SRC) -type d)
OBJSUBDIRS := $(patsubst $(SRC)%,$(OBJ)%,$(SUBDIRS))

.PHONY: info

# Generate Executable
$(APP) : $(OBJSUBDIRS) $(ALLOBJ) $(BIN)
	$(CC) $(ALLOBJ) -o $(APP) $(CCFLAGS) $(INCDIRS) $(LIBS)

# Generate rules for all objects
$(foreach F,$(ALLCPPS),$(eval $(call COMPILE,$(CC),$(call C2O,$(F)),$(F),$(call C2H,$(F)),$(CCFLAGS) $(INCDIRS))))
$(foreach F,$(ALLCS),$(eval $(call COMPILE,$(C),$(call C2O,$(F)),$(F),$(call C2H,$(F)),$(CFLAGS) $(INCDIRS))))

info:
	$(info $(SUBDIRS))
	$(info $(OBJSUBDIRS))
	$(info $(ALLCPPS))
	$(info $(ALLCS))
	$(info $(ALLCSOBJ))

$(OBJSUBDIRS) : 
	$(MKDIR) $(OBJSUBDIRS)

$(BIN) :
	$(MKDIR) $(BIN)

## CLEAN rules
clean:
	$(RM) -r "./$(OBJ)"

cleanall: clean
	$(RM) "./$(APP)"
	$(RM) -r "./$(BIN)"

	
