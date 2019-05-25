install: token_mgmt.8.gz
	install -D -m 0755 -t "${PREFIX}"/sbin sbin/token_mgmt
	if [ -d "${PREFIX}/share" ]; then \
	  install -D -m 0644 -t "${PREFIX}"/share/man/man8 token_mgmt.8.gz ; \
	else \
	  install -D -m 0644 -t "${PREFIX}"/usr/share/man/man8 token_mgmt.8.gz ; \
	fi
	install -D -d -m 0700 "${PREFIX}"/etc/token_mgmt "${PREFIX}"/etc/token_mgmt/overlays "${PREFIX}"/etc/token_mgmt/profiles
	for d in overlays profiles; do \
	  for i in etc/token_mgmt/"$$d"/*; do if [ -d "$$i" ]; then \
	    install -D -d -m 0700 "${PREFIX}/$$i" ; \
	    cp -a "$$i/"* "${PREFIX}/$$i" ; \
	  fi; done ; \
	done
	install -D -C -b --suffix .previous -m 0600 -t "${PREFIX}/etc/token_mgmt" etc/token_mgmt/picture etc/token_mgmt/config

token_mgmt.8.gz: token_mgmt.8
	gzip --keep $<

clean:
	rm -f *.gz \
	rm -f etc/token_mgmt/overlays/*.tar \
	rm -f etc/token_mgmt/profiles/*.tar
