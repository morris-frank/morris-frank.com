help:
	@echo 'Makefile for morris.jetzt                                                 '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make public                          build all                          '
	@echo '                                                                          '

public:
	sass sass/main.sass docs/main.css

.PHONY: help public
