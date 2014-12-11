# 2012.10.31
#This makefile has been tested on Ubuntu 12.10 with gfortran 4.7.2
#It is intended to be used with
#     WT_Perf                 (v3.05.00a-adp,    Oct-2012)
#     NWTC Subroutine Library (v1.05.00,      24-Oct-2012)
#
#Older versions of the library and WT_Perf may not work with this makefile

#compiler to use
FC = gfortran
#compiler flags
FFLAGS = -O3 #-m32 -g 

#Destination for compiled pieces
DEST_DIR := WT_Perf--compiled

#Location of source files for the NWTC Library
LIB_DIR := \
	NWTC_Subroutine_Library/NWTC_Lib_v1.05.00/source

#Change SingPrec.f90 to DoubPrec.f90 for double precision
LIB_SOURCES := \
	SingPrec.f90 \
	SysGnuLinux.f90 \
	NWTC_IO.f90 \
	NWTC_Num.f90 \
	ModMesh.f90 \
	NWTC_Aero.f90 \
	NWTC_Library.f90

#Location of the source files for WT_Perf
WTP_DIR      := \
	./

WTP_SOURCES  := \
	setprog.f90 \
	WTP_Mods.f90 \
	WTP_Subs.f90

vpath %.f90 $(LIB_DIR) $(WTP_DIR)
vpath %.o $(DEST_DIR)

###########
#### You should not need to change anything beyond this point
LIB_OBJS = $(LIB_SOURCES:.f90=.o)
WTP_OBJS = $(WTP_SOURCES:.f90=.o)

#rule to do everything
all:     default
default: $(DEST_DIR) $(DEST_DIR)/WT_Perf

#general rule for making the files
%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $(DEST_DIR)/$@ -J $(DEST_DIR)


#Dependency rules
SysGnuLinux.o:  SingPrec.o
NWTC_IO.o:      SysGnuLinux.o
NWTC_Num.o:     NWTC_IO.o
NWTC_Aero.o:    NWTC_IO.o NWTC_Num.o
NWTC_Library.o: NWTC_Aero.o ModMesh.o
setprog.o:      $(LIB_OBJS)
WTP_Mods.o:     $(LIB_OBJS)
WTP_Subs.o:     $(LIB_OBJS) WTP_Mods.o


#Make sure the destination directory exists
$(DEST_DIR):
	mkdir -p $(DEST_DIR)


#For compiling WT_Perf
$(DEST_DIR)/WT_Perf: $(LIB_OBJS) $(WTP_OBJS) | $(DEST_DIR)
	$(FC) $(FLAGS) -I $(DEST_DIR) -o $(DEST_DIR)/WT_Perf \
		$(WTP_DIR)/WT_Perf.f90 \
		$(foreach src, $(LIB_OBJS), $(addprefix $(DEST_DIR)/,$(src))) \
		$(foreach src, $(WTP_OBJS), $(addprefix $(DEST_DIR)/,$(src)))

#cleanup afterwards
clean:
	rm -f $(DEST_DIR)/*.o $(DEST_DIR)/*.mod

