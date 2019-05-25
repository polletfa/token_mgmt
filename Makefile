install: token_mgmt.8.gz
	install -D -m 0755 -t "${PREFIX}"/sbin sbin/token_mgmt
	if [ -d "${PREFIX}/share" ]; then \
	  install -D -m 0644 -t "${PREFIX}"/share/man/man8 token_mgmt.8.gz ; \
	else \
	  install -D -m 0644 -t "${PREFIX}"/usr/share/man/man8 token_mgmt.8.gz ; \
	fi
	install -D -d -m 0700 "${PREFIX}"/etc/token_mgmt "${PREFIX}"/etc/token_mgmt/overlays "${PREFIX}"/etc/token_mgmt/profiles
	install -D -m 0644 -t "${PREFIX}"/etc/token_mgmt/overlays/guest-autologin/ etc/token_mgmt/overlays/guest-autologin/override.conf
	install -D -m 0755 -t "${PREFIX}"/etc/token_mgmt/profiles/guest/ etc/token_mgmt/profiles/guest/post-load.sh
	install -D -d -m 0755 "${PREFIX}"/etc/token_mgmt/profiles/guest/overlays/lib/systemd/system
	rm -f "${PREFIX}"/etc/token_mgmt/profiles/guest/overlays/lib/systemd/system/getty@tty1.service.d.tar
	ln -s "${PREFIX}"/etc/token_mgmt/overlays/guest-autologin.tar "${PREFIX}"/etc/token_mgmt/profiles/guest/overlays/lib/systemd/system/getty@tty1.service.d.tar
	install -D -C -b --suffix .previous -m 0600 -t "${PREFIX}/etc/token_mgmt" etc/token_mgmt/picture etc/token_mgmt/config
	install -D -C -b --suffix .previous -m 0644 -t /lib/systemd/system/ token_mgmt.service
	systemctl enable token_mgmt

token_mgmt.8.gz: token_mgmt.8
	gzip --keep $<

clean:
	rm -f *.gz \
	rm -f etc/token_mgmt/overlays/*.tar \
	rm -f etc/token_mgmt/profiles/*.tar
