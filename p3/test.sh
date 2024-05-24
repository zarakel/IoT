echo Ouvrez un autre terminal puis rentrez cette commande :
echo curl -vk localhost:8888
echo Suite à votre test, veuillez Ctrl+C le terminal de test
sudo kubectl port-forward -n dev svc/playground 8888:8888 >/dev/null 

