IMAGE_NAME="davidmcdonald93/reverse_docking:latest"
sudo docker build -t ${IMAGE_NAME} .
sudo docker push ${IMAGE_NAME}
sudo docker rm $(sudo docker ps --filter=status=exited --filter=status=created -q)
sudo docker rmi $(sudo docker images -a --filter=dangling=true -q)