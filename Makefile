install: token_mgmt.8.gz
	echo install -D -m 0755 sbin/token_mgmt ${PREFIX}/sbin
	if [ -d "${PREFIX}/share" ]; then \
	  echo install -D -m 0644 token_mgmt.8.gz ${PREFIX}/share/man/man8 ; \
	else \
	  echo install -D -m 0644 token_mgmt.8.gz ${PREFIX}/usr/share/man/man8 ; \
	fi
# todo finish

token_mgmt.8.gz: token_mgmt.8
	gzip --keep $<

clean:
	rm -f *.gz \
	rm -f etc/token_mgmt/overlays/*.tar \
	rm -f etc/token_mgmt/profiles/*.tar
