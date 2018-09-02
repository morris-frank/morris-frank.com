BASEDIR=$(CURDIR)
BUILD_DIR=$(BASEDIR)/public

help:
	@echo 'Makefile for morris.jetzt                                                 '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make public                          build all                          '
	@echo '                                                                          '

public:
	mkdir -p $(BUILD_DIR)
	sass sass/main.sass $(BUILD_DIR)/main.css

.PHONY: help public
