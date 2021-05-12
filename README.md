# challenge

Overview

  The purpose of this mini-project is to create a simple hello project, and then build this project using docker and deploy it to a container. Aside from that, we need to integrate the different parts to implement Continueous Integrationg and Continueous Deployment.
  
  The design for this mini-project is as below:
  
    a. Creating a Java project and implement the simple REST API functions, when receiving some request, response properly.
    b. Writing a bash script 'build.sh' which will uses 'docker' to compile the 'hello' java project and create a final image which contains hello app.
    c. The 'build.sh' script will perform some test to ensure the hello app is up and running. According to the test in my laptop, it ususally takes around 20 seconds for the 
        hello app to function properly. So, we put a 'for' loop to check repeadly until it get the correct outcome or time out.
    d. The 'build.sh' script will automatically delete the intermidate images and only keep the final image which is around 123 MB.
    e. If we pass a parameter containing 'clean'  to 'build.sh', after the test, both the helloapp container and related image will be destroyed to restore the environment before compiling.
    f. we use Jenkins pipeline to retreive the code from the GitHub and execute 'build.sh' on the related Linux server where docker is installed and running.
    
Below is the details:


1. hello app
  
  The hello application was written in Java and spring boot framework. If you send a request like http://localhost:8081/hello with the verbose parameter '-v' when using 'curl' command on Linux server, you will see 'HTTP/1.1 200' and get a json response as below:
  
    {"id": 1, "info": "welcome"}.
  
  It also support POST/PUT/DELETE operations. Below are some 'curl' command for your reference:
        
    curl -X POST -v http://localhost:8081/hello -H 'Content-type:application/json' -d '{"info": "this is a test."}' 
     
    curl -X PUT -v http://localhost:8081/hello/2 -H 'Content-type:application/json' -d '{"info": "update the information"}'
     
    curl -X DELETE -v http://localhost:8081/hello/2
     
     curl -X GET -v http://localhost:8081/hello/all
     
  If you want to access this API remotely, you may need to open the 8081 port in your firewall and replace the 'localhost' with the related ip address.
     
2. docker image and container

   In order to reduce the size of the final image, we use the multi-stages builds to create the related images, 2 for compiling, 2 for the hello app.
   Only the small basic jre image is included in the image,  all the middle images will be deleted automatically after the building.
   
   Because we use multi-stage builds, the minimum Docker version is 17.05, please check your docker version, if it's below 17.05, you may need to upgrade your docker.
   The below is a link about how to upgrade the docker:
   
   https://docs.docker.com/engine/install/centos/
   
   
3. Jenkins Integration

   we can use Jenkins pipeline to execute the following 2 steps in order to make things easy:
   
      a. Fetching the code from the GitHub.
      b. Executing the 'build.sh' script remotely and get the test result from there.
   
4. build.sh 

   The build.sh script will perform the following functions:
   
        a. Checking if the Docker service is running.
        b. Compiling java code using 'maven' image.
        c. Creating the final image which hosts the 'hello app'.
        d. Starting the container.
        e. Performing test which will send some request to the api address and check if it receive 'HTTP/1.1 200'.
        f. Deleting the intermidiate images.
        g. Stop & destroy the container and image if you pass a parameter containing 'clean' to the 'build.sh'.
   
   
5. How to use this repostitory:

  	    a. Clone the repository.
        b. Ensure the docker version is above 17.05 on your linux server.
        c. Run './build.sh' script.
  
  
6. code review integration

7. security review integration
   
   
