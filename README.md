# Simple http 'hello world' for load balancer testing

This image is a simple 'Hello world' in an HTTP server to be used to test load balancers. When receive an request (GET /) this image will return the current machine hostname.

## Running a simple test
    docker run --rm -it -p 80:80 strm/helloworld-http
