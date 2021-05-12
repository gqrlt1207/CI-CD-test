# challenge

Overview

  The purpose of this mini-project is to create a simple hello project, and then build this project and deploy it using docker and container technology. Besides that, we also need to integrate the different parts to implement Continueous Integrationg and Continueous Deployment automatically.
  
  The design for this mini-project is as below:
  
    a. Creating a Java project and implement the simple REST API, when the app receives a request, it will response properly.
    b. Writing a bash script 'build.sh' which will use 'docker' to compile the 'hello' java project and create a final image which hosts hello app and the jre.
    c. The 'build.sh' script will perform some test to ensure the hello app works as expected.
    d. The 'build.sh' script will automatically delete the intermidate images and only keep the final image which is around 123 MB.
    e. If we pass a parameter containing 'clean'  to 'build.sh', after the test, both the helloapp container and related image will be destroyed to clean the environment.
    f. we use Jenkins pipeline to retreive the code from the GitHub and execute 'build.sh' on the related Linux server where docker is running with the version which is above 17.05.
    
 The work flow is as below:
 
 start ---> Jenkins pipeline ----->pull code from GitHub to 1 slave linux server ------> run 'build.sh' on the slave Linux server----> compiling hello project using 'maven' 
 -----> creating image which hosts the hello app ----> starting container ----> test ----> remove the intermidiate images----> end
 
 If you do not have Jenkins installed, the work flow is as below:
 
 pull code from GitHub to one linux server ------> run 'build.sh' on the Linux server----> compiling hello project using 'maven' (performed by build.sh)
 -----> creating image which hosts the hello app (performed by build.sh)----> starting container (build.sh)----> test(build.sh)----> remove the intermidiate images(build.sh)
 ----> end
    
Below is the details:


1. hello app
  
  The hello application was written in Java and spring boot framework. If you send a request like http://localhost:8081/hello with the parameter '-v' when using 'curl' command on Linux server, you will see 'HTTP/1.1 200' and get a json response as below:
  
    {"id": 1, "info": "welcome"}.
  
  It also support POST/PUT/DELETE operations. Below are some 'curl' command for your reference:
        
    curl -X POST -v http://localhost:8081/hello -H 'Content-type:application/json' -d '{"info": "this is a test."}' 
     
    curl -X PUT -v http://localhost:8081/hello/2 -H 'Content-type:application/json' -d '{"info": "update the information"}'
     
    curl -X DELETE -v http://localhost:8081/hello/2
     
     curl -X GET -v http://localhost:8081/hello/all
     
  If you want to access this API remotely, you may need to open the 8081 port in your firewall and replace the 'localhost' with the related ip address.
     
2. docker image and container

   In order to reduce the size of the final image, we use the multi-stages builds to create the related images, 2 for compiling, 2 for the hello app.
   Only the small basic jre image and the compiled jar file are included in the image,  all the middle images will be deleted automatically after the building.
   
   Because we use multi-stage builds, the required minimum Docker version is 17.05, so, please check your docker version, if it's below 17.05, you may need to upgrade your docker if you want to run the 'build.sh' script on your environment.
   
   The below is a link about upgrading the docker:
   
   https://docs.docker.com/engine/install/centos/
   
   
3. Jenkins Integration

   we can use Jenkins pipeline to execute the following 2 steps in order to make things easy:
   
          a. Fetching the code from the GitHub.
      
          b. Executing the 'build.sh' script remotely and get the test result from there.
    
    Below is the screenshot of the pipeline:
        
        Step 11/11 : ENTRYPOINT ["java", "-jar", "/hello.jar"]
        ---> Running in 47ca92e4cf8a
        Removing intermediate container 47ca92e4cf8a
        ---> 8f11d8f13833
        Successfully built 8f11d8f13833
        Successfully tagged hello:latest
        fd99a7252f2f6bebfb5deee4459edc01c5da95c098b0f4a198cb804a4f29b106
        application is not ready, wait ...
        application is not ready, wait ...
        application is not ready, wait ...
        application is not ready, wait ...
        < HTTP/1.1 200 
        Test is successful.
   
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

    For code review, we can create a 'pull request' and send to peer to review and approve.
    I created one for this practice:
    
    https://github.com/gqrlt1207/challenge/pull/1
    
    We can also use some tool to scan the code which is also helpful.

7. security review integration

    we can use some tool to scan the code to ensure there is no vulnerbility in our code, like sonar-scanner from SonarQube etc.
   
   
