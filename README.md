# Simple http 'hello world' for load balancer testing
[![Docker Pulls](https://img.shields.io/docker/pulls/strm/helloworld-http.svg?style=plastic)](https://hub.docker.com/r/strm/helloworld-http/)

This image is a simple 'Hello world' in an HTTP server to be used to test load balancers. When receive an request (GET /) this image will return the current machine hostname.

It shows ```Hello from <hostname>``` for every request, making it easier to determine what host received the request.

## Running a simple test
    docker run --rm -it -p 80:80 strm/helloworld-http

Will result in a single instance running on your port 80, you can test and will get a result like it:
    
![Print](/print1.png)

## Implementing a load balancer

Now what this image is made for, test load balancers, create the following ```docker-compose.yml```

    version: '2'
    services:
        front:
            image: strm/nginx-balancer
            container_name: load-balancer
            ports:
                - "80:8080"
            environment:
                - "NODES=web1:80 web2:80"
        web1:
            image: strm/helloworld-http
        web2:
            image: strm/helloworld-http
            

To run the image use the command:

    docker-compose up

And you will see in the result that the balancer is working and balancing the request through images ```web1``` and ```web2```

