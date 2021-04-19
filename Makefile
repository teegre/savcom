PROGNAME  ?= dalias
PREFIX    ?= /usr
BINDIR    ?= $(PREFIX)/bin
SHAREDIR  ?= $(PREFIX)/share

MANPAGE    = $(PROGNAME).1

.PHONY: install
install: src/$(PROGNAME).out
	install -d  $(DESTDIR)$(BINDIR)

	install -m755  src/$(PROGNAME).out $(DESTDIR)$(BINDIR)/$(PROGNAME)
	
	install -Dm644 LICENSE    -t $(DESTDIR)$(SHAREDIR)/licenses/$(PROGNAME)

	rm src/$(PROGNAME).out

.PHONY: uninstall
uninstall:
	rm $(DESTDIR)$(BINDIR)/$(PROGNAME)
	rm $(DESTDIR)$(MANDIR)/$(MANPAGE)
	rm -rf $(DESTDIR)$(SHAREDIR)/licenses/$(PROGNAME)
