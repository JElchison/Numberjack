
SRC = ./src
SOL = ./solvers

SOLVERS = $(wildcard $(SOL)/*)
TARGETS = $(patsubst $(SOL)/%, %, $(SOLVERS))
TARGET_LIB = $(TARGETS:=_lib)
TARGET_INSTALL = $(TARGETS:=_install)
TARGET_LOCAL = $(TARGETS:=_local)
TARGET_CLEAN = $(TARGETS:=_clean)
TARGET_CLEAN_SWIG = $(TARGETS:=_clean_swig)



all: $(TARGET_LIB)

%_lib: $(SOL)/%
	cd $(SOL)/$(@:_lib=); make 

install: $(TARGET_INSTALL)
	cd $(SRC); python setup.py install

%_install: $(SOL)/%
	cd $(SOL)/$(@:_install=); make install_python

local_install: $(TARGET_LIB) $(TARGET_LOCAL)
	cp src/*.py ./local_lib/
	chmod +x ./local_lib/*.py*
	chmod +x ./local_lib/*.so 
	tools/help.sh


%_local: $(SOL)/%
	cp $(SOL)/$(@:_local=)/python/*.py* ./local_lib/
	cp $(SOL)/$(@:_local=)/python/_*.so* ./local_lib/


uninstall:
	python tools/uninstall.py 

clean: $(TARGET_CLEAN)
	rm -rf local_lib/*

%_clean: $(SOL)/%
	@echo $(SOL)/$(@:_clean=)
	cd $(SOL)/$(@:_clean=); make clean

clean_swig: $(TARGET_CLEAN_SWIG)

%_clean_swig: $(SOL)/%
	@echo $(SOL)/$(@:_clean_swig=)
	cd $(SOL)/$(@:_clean_swig=); make clean_swig

DATE := $(shell date '+%y-%m-%d')
ACCOUNT := $(shell users)

cluster: release
	scp Numberjack.0.1.$(DATE).bz2 4c131:/home/$(ACCOUNT)/

release: Numberjack.0.1.$(DATE).bz2

Numberjack.0.1.$(DATE).bz2: Numberjack.0.1.$(DATE)/src
	@echo Build archive
	rm -rf Numberjack.0.1.$(DATE)/solvers/scip
	tar -cjf Numberjack.0.1.$(DATE).bz2 Numberjack.0.1.$(DATE)
	rm -rf Numberjack.0.1.$(DATE)

Numberjack.0.1.$(DATE)/src: $(SOLVERS) src/Numberjack.py 
	@echo Export Numberjack version 0.1.$(DATE)
	mkdir Numberjack.0.1.$(DATE)
	git archive master --format=tar | tar -x -C ./Numberjack.0.1.$(DATE)