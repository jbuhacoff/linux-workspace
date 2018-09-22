all: clean package

clean:
	rm -rf .build .test

package:
	bash package.sh

install:
	install -d $(DESTDIR)$(prefix)/etc/profile.d
	install -m 644 src/profile.d/*.sh $(DESTDIR)$(prefix)/etc/profile.d/
	install -d $(DESTDIR)$(prefix)/bin
	install -m 755 src/script/wsync.sh $(DESTDIR)$(prefix)/bin/wsync

test:
	bash test.sh
