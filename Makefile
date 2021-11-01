PROGNAME  ?= dalias
PREFIX    ?= /usr
BINDIR    ?= $(PREFIX)/bin
SHAREDIR  ?= $(PREFIX)/share
MANDIR    ?= $(SHAREDIR)/man/man1

MANPAGE    = $(PROGNAME).1

.PHONY: install
install: src/$(PROGNAME).sh
	install -d  $(BINDIR)
	install -m755  src/$(PROGNAME).sh $(BINDIR)/$(PROGNAME)
	install -Dm644 $(MANPAGE) -t $(MANDIR)
	install -Dm644 LICENSE    -t $(SHAREDIR)/licenses/$(PROGNAME)

.PHONY: uninstall
uninstall:
	rm $(BINDIR)/$(PROGNAME)
	rm $(MANDIR)/$(MANPAGE)
	rm -rf $(SHAREDIR)/licenses/$(PROGNAME)
