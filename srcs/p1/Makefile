all: 
	vagrant up

clean: 
	vagrant destroy jbuanS jbuanSW -f && rm -Rf .vagrant/machines/* && vagrant global-status --prune
	rm /mnt/c/token /mnt/c/k3s.yaml

re: clean all
