.PHONY += clean fclean mclean

clean: FORCE
ifneq ($(VERBOSE), )
	$(RM) -rf $(OBJ_DIR)
	$(RM) -f test.bin
else
	@$(ECHO) $(SNAME): Removing $(OBJ_DIR) and test.bin
	@$(RM) -rf $(OBJ_DIR) test.bin
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j clean;)
else
	@$(ECHO) $(SNAME): Recursive clean on $(CLIB)
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j clean;)
endif
endif
endif

fclean: FORCE
ifneq ($(VERBOSE), )
	$(RM) -rf $(OBJ_DIR) $(SNAME) $(BUILD_NAME) test.bin
else
	@$(ECHO) $(SNAME): Removing $(SNAME), $(BUILD_NAME), $(OBJ_DIR) and test.bin
	@$(RM) -rf $(OBJ_DIR) $(SNAME) $(BUILD_NAME) test.bin
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j fclean;)
else
	@$(ECHO) $(SNAME): Recursive fclean on $(CLIB)
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j fclean;)
endif
endif
endif

mclean: FORCE
ifneq ($(VERBOSE), )
	$(RM) -rf $(BUILD_ROOT) CMakeLists.txt cmake-build-debug CMakeFiles
else
	@$(ECHO) $(SNAME): Removing $(BUILD_ROOT), CMakeLists.txt cmake-build-debug and CMakeFiles
	@$(RM) -rf $(BUILD_ROOT) CMakeLists.txt cmake-build-debug CMakeFiles
endif
ifneq ($(RECURSIVE), )
ifneq ($(CLIB), )
ifneq ($(VERBOSE), )
	$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j mclean;)
else
	@$(ECHO) $(SNAME): Recursive mclean on $(CLIB)
	@$(foreach V, $(dir $(CLIB)), $(MAKE) $(FORWARD) -C $(V) --no-print-directory -j mclean;)
endif
endif
endif
