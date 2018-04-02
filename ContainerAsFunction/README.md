# Creating a Function from a Docker Image

There are various unix utilities that can be "packaged" as Functions. 
Similar to the concept of Web enabled, Webservice enabled, this example demonstrates
exposing unix utilities as *REST* enabled. This example walks through a simple example 
of using "tr" utility to transform input payload to upper case (aka TOUPPER service).
This example also demonstrates a "no code" approach to leverage many such utilities using Docker file.

As you make your way through this tutorial, look out for this icon.
![](images/userinput.png) Whenever you see it, it's time for you to
perform an action. 

## Prequisites

This tutorial requires you to have both Docker and Fn installed. If you need
help with Fn installation you can find instructions in the
[Introduction to Fn](../Introduction/README.md) tutorial.

# Getting Started

Before we can get starting there are a couple of configuration steps to take
care of.

## Start Fn Server

Next, if it isn't already running, you'll need to start the Fn server.  We'll
run it in the foreground to let us see the server log messages so let's open a
new terminal for this.

   Start the Fn server using the `fn` cli:

   ![](images/userinput.png)
   >`fn start`

## A Custom Function Container Image

This example has only one artifact - a Dockerfile that converts input to uppercase using *tr*.

`echo "hello" | tr [:lower:] [:upper:]`

### Dockerfile

The `Dockerfile` for our function is also very simple.  It starts with
a light alpine base image, and sets the entrypoint so that when the container is started the
`tr` is run with CMD set to convert to upper case.

![](images/userinput.png) Create the following into a file named `Dockerfile`:

```dockerfile
FROM alpine

ENTRYPOINT ["tr"]

CMD ["[:lower:]", "[:upper:]"]
```

### Building the Function Image

In your working directory, build and run the image as you would any Docker image:

1. Build your function container image with `docker build`:

   ![](images/userinput.png)
   >`docker build . -t <yourdockerid>/tr-hello:0.0.1`

2. Test the image by running it with a name parameter:

   ![](images/userinput.png)
   >`echo -n "hello" | docker run -i --rm <yourdockerid>/node-hello:0.0.1`

   The output should be the same as be except "Jane" in place of "World":

   ```
   HELLO
   ```

Great!  We have a working Docker image.  Now let's deploy it as a function.

## Publishing the Function Image

When developing locally you don't need to deploy to Docker Hub--the
local Fn server can find your function image on the local machine. But
eventually you are going to want to run your function on a remote
Fn server which requires you to publish your function image in
a repository like Docker Hub.  You can do this with a standard `docker push` 
but again this step is optional when we're working locally.

![](images/userinput.png)
>`docker push <yourdockerid>/tr-hello:0.0.1`

## Creating the Fn App and Defining the Route

Once we have a function container image we can associate that image with a
['route'](https://github.com/fnproject/fn/blob/master/docs/developers/model.md#routes).  

1. First we need an 
['application'](https://github.com/fnproject/fn/blob/master/docs/developers/model.md#applications)
to contain our functions.  Applications define a namespace to organize functions
and can contain configuration values that are shared across all functions in
that application:

   ![](images/userinput.png)
   >`fn apps create demoapp`

   ```
   Successfully created app:  demoapp
   ```

2. We then create a route that uses our manually built container image:

   ![](images/userinput.png)
   >`fn routes create demoapp /toupper -i <yourdockerid>/tr-hello:0.0.1`

   ```xml
   /toupper created with <yourdockerid>/tr-hello:0.0.1
   ```

3. We can confirm the route is correctly defined by getting a list of the routes
defined for an application:

   ![](images/userinput.png)
   >`fn routes list demoapp`

   You should see something like:

   ```xml
   path    image                            endpoint
   /toupper  <yourdockerid>/tr-hello:0.0.1  localhost:8080/r/demoapp/toupper
   ```

At this point all the Fn server has is configuration metadata.
It has the name of an application and a function route that is part
of that application that points to a named and tagged Docker image.  It's
not until that route is invoked that this metadata is used.

## Calling the Function

Calling a function that was created through a manually defined route is no
different from calling a function defined using `fn deploy`--which is exactly
as intended!

1. Call the function using `fn call`:

   ![](images/userinput.png)
   >`echo -n "hello" | fn call demoapp /toupper

   This will produce the expected output:

   ```sh
   HELLO
   ```

2. Call the function with curl using it's http endpoint.  You can find out the
endpoints for each of your routes using the `fn routes list` command we used
above.

   ![](images/userinput.png)
   >`curl -d "hello" http://localhost:8080/r/demoapp/toupper`

   This will produce exactly the same output as when using `fn call`, as 
   expected.

   ```sh
   HELLO
   ```
When the function is invoked, regardless of the mechanism, the Fn server 
looks up the function image name and tag associated with the route and 
has Docker run a container. If the required image is not already available
locally then Docker will attempt to pull the image from the Docker registry.

In our local development scenario, the image is already on the local machine
so you won't see a 'pull' message in the Fn server log.

# Conclusion

Having completed this tutorial you've successfully built a Docker image,
defined a function as implemented by that image, and invoked the function
resulting in the creation of a container using that image.  Congratulations!

**Go:** [Back to Contents](../README.md)
