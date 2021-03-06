# Creating a Function from a built-in Unix utility

This sample demonstrates how to package common unix utilies and cli as Function. You are probably familiar with terms such as -
Web enabled, Webservice enabled etc. Think of this technique as *API* enable command line utilities. This implementation is very basic and uses string/text payload instead of JSON payload to illustrate an idea.
Have you used or heard ot "tr"? Well, [tr](http://linuxcommand.org/lc3_man_pages/tr1.html) is a very useful utility that is available in most linux distributions. This example shows how to build a function to return input transformed to uppercase. 

This example also demonstrates a "no code" approach to leverage many such utilities using busybox with resulting docker image around 1.5Mb.

As you make your way through this tutorial, look out for this icon.
![](images/userinput.png) Whenever you see it, it's time for you to
perform an action. 

## Test tr execution

Try the following command on a unix shell.
![](images/userinput.png)
>```sh
>echo "hello" | tr [:lower:] [:upper:]
>```

```txt
HELLO
```


## Before you begin

This tutorial requires you to have both Docker and Fn installed. If you need
help with Fn installation you can find instructions in the
[Install and Start FN tutorial](https://github.com/fnproject/tutorials/blob/master/install/README.md).


## Start Fn Server

If it isn't already running, you'll need to start the Fn server.  We'll
run it in the foreground to let us see the server log messages so let's open a
new terminal for this.

   Start the Fn server using the `fn` cli:

   ![](images/userinput.png)
   >```sh
   >fn start
   >```

### Create the function

Let us start by creating a directory in a new terminal.
![](images/userinput.png)
   >```sh
   >mkdir trapp
   >cd trapp
   >```

![](images/userinput.png) 
Copy the following into a file named `Dockerfile`

```dockerfile
FROM busybox
WORKDIR /app
ADD run-tr.sh /app
ENTRYPOINT ["/app/run-tr.sh"]
```

In the terminal type the following:

![](images/userinput.png) 
>```sh
> fn init --runtime docker --trigger http 
>```

The output will be 
```txt
Dockerfile found. Using runtime 'docker'.
func.yaml created.
```

![](images/userinput.png) 
Copy the following into a file named `run-tr.sh`
```txt
#env
if [ "$FN_PATH" = "/upper" ]; then
   tr [:lower:] [:upper:]
fi
if [ "$FN_PATH" = "/lower" ]; then
   tr  [:upper:] [:lower:]
fi
```

This is a unix shell script defined as ENTRYPOINT for the docker container.


### Edit the func.yaml to match the run-tr.sh
Take a look at the generated func.yaml

```txt
name: trapp
version: 0.0.1
triggers:
- name: trapp-trigger
  type: http
  source: /trapp-trigger
```
The name corresponds to directory name - trapp. 

![](images/userinput.png)
Edit the **triggers** section to match the following:
```txt
triggers:
- name: tr-upper
  type: http
  source: /upper
- name: tr-lower
  type: http
  source: /lower   
```
![](images/userinput.png)
List the files in the current directory
>```sh
>ls
>```

The output should include the following files:
```txt
Dockerfile func.yaml  run-tr.sh
```

The contents of func.yaml
```txt
schema_version: 20180708
name: trapp
version: 0.0.1
triggers:
- name: tr-upper
  type: http
  source: /upper
- name: tr-lower
  type: http
  source: /lower
```

### Deploy your function

You now have all the files to build and deploy the function.

![](images/userinput.png)
>```sh
>fn deploy --app trapp --local
>```
You should see output similar to:
   ```txt
   Deploying trapp to app: trapp
   Bumped to version 0.0.2
   Building image trapp:0.0.2
   Updating function trapp using image trapp:0.0.2...
   Successfully created app:  trapp
   Successfully created function: trapp with trapp:0.0.2
   Successfully created trigger: tr-upper
   Successfully created trigger: tr-lower
   ```
   
FN server exposes the function as an HTTP endpoint.
![](images/userinput.png)
List the http endpoints for the function:
>```sh
>fn list triggers trapp
>```

You should see output as following:
```txt
FUNCTION        NAME            TYPE    SOURCE  ENDPOINT
trapp           tr-lower        http    /lower  http://localhost:8080/t/trapp/lower
trapp           tr-upper        http    /upper  http://localhost:8080/t/trapp/upper
```

## Test your function
Call the function with curl using it's http endpoint.   
![](images/userinput.png)
>```sh
>curl -d "Hello World" http://localhost:8080/t/trapp/lower
>```

```txt
hello world
```
>```sh
>curl -d "Hello World" http://localhost:8080/t/trapp/upper
>```

```txt
HELLO WORLD
```

# Conclusion

Having completed this tutorial you've successfully defined a function for built-in unix utilities 
and invoked as REST endpoint or in other words created an API. Congratulations!
Check out [tr examples](https://shapeshed.com/unix-tr) for tr usage to build useful functions.


