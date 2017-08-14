CXX := c++

# Find all the names of CPP files in the src directory.
CPP_FILES := $(wildcard src/*.cpp)
H_FILES := $(wildcard src/*.h)

TEST_FILES := $(shell find ./tests/ -name "*.cpp")
TEST_EXECUTABLES := $(TEST_FILES:.cpp=.out)

ifdef TESTCASE
TEST_SINGLE_FILE := $(addprefix tests/, $(addsuffix .cpp, $(TESTCASE)))
TEST_SINGLE_EXECUTABLE := $(addprefix tests/, $(addsuffix .out, $(TESTCASE)))
else
TESTCASE := $(shell echo $$TESTCASE)
TEST_SINGLE_FILE := $(addprefix tests/, $(addsuffix .cpp, $(TESTCASE)))
TEST_SINGLE_EXECUTABLE := $(addprefix tests/, $(addsuffix .out, $(TESTCASE)))
endif

# Get the corresponding obj/FILE.o paths for the CPP files.
OBJ_FILES := $(addprefix obj/, $(notdir $(CPP_FILES:.cpp=.o)))

# The directories to search for includes from.
### Sometimes, header files are in other directories.
### This is where one might place those directory paths.
TESTINCLUDEDIR = 
INCLUDEDIR = -Isrc/shaka/ -Isrc/

# These are for including the libraries you want to use.
### Ignore these for now; we have not covered libraries yet.
LIBSDIR = 
LIBS = 
TESTLIBSDIR = 
TESTLIBS = -lgtest -lpthread

# Flags for the linker step.
LD_FLAGS  := $(INCLUDEDIR) $(LIBSDIR) $(LIBS)

# Flags for the C++ compilation step.
CXX_FLAGS := -Wall -Wextra -pedantic --std=c++11 -g \
			 $(INCLUDEDIR) $(LIBSDIR) $(LIBS) 

TEST_FLAGS := -Wall -Wextra -pedantic --std=c++11 -g \
			  $(INCLUDEDIR) $(TESTINCLUDEDIR) \
			  $(LIBSDIR) $(TESTLIBSDIR) \
			  $(LIBS) $(TESTLIBS)

.PHONY: clean clean-all clean-docs clean-tests-docs clean-tests \
	    run clean-test run-test docs test-edit

# The default rule to be build when just `make` is run.
all: bin/repl

# Build the main executable and place inside the (bin)ary directory..
bin/repl: ./src/repl/main.cpp
	$(CXX) -o $@ $^ $(CXX_FLAGS)

# A rule to build all the object files from the source files.
obj/%.o: src/%.cpp
	$(CXX) $(CXX_FLAGS) -c -o $@ $<

# A POSIX-compliant clean command
clean: 
	rm bin/repl

clean-all: clean clean-tests clean-docs clean-tests-docs

clean-docs:
	rm -rf docs/*

clean-tests-docs:
	rm -rf tests-docs/*

clean-tests:
	rm -rf tests/**/*.out

run:
	cd bin; ./repl; cd ../

docs: $(CPP_FILES)
	cd docs; doxygen ../doxygen_config_file; cd ../

test-edit: 
	vim ./tests/$(TESTCASE).cpp

tests: $(TEST_EXECUTABLES)

test: $(TEST_SINGLE_EXECUTABLE)
	@echo "Test case: " $(value TESTCASE)

clean-test:
	@echo "Test case:" $(value TESTCASE)
	rm ./tests/$(TESTCASE).out

run-test: $(TEST_SINGLE_EXECUTABLE)
	@echo "Test case: " $(value TESTCASE)
	$(TEST_SINGLE_EXECUTABLE)

$(TEST_SINGLE_EXECUTABLE): $(TEST_SINGLE_FILE)
	$(CXX) -o $@ $^ $(TEST_FLAGS)

tests/%.out: tests/%.cpp
	$(CXX) -o $@ $^ $(TEST_FLAGS)
