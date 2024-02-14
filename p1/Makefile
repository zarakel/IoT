all:
	vagrant up
clean:
	vagrant destroy -f jbuanS 
	vagrant destroy -f jbuanSW
	vagrant global-status --prune
	rm -Rf .vagrant/machines/*
	rm k3s.yaml token

re: clean all
