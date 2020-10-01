#build
docker build . -t hello-service-node:1
#run
docker run -d -it --name hello-service-container -p 8888:8888 --env JAEGER_HOST=localhost hello-service-node:1