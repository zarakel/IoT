all:
	vagrant up
clean:
	vagrant destroy -f jbuanS 
	vagrant global-status --prune
	if test -f ./.vagrant/machines/jbuanS; then \
		rm -Rf .vagrant/machines/*; \
	fi

re: clean all
