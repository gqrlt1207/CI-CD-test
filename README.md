# challenge

Overview

  The purpose of this mini-project is to create a simple hello project, build this project and deploy it to container. Besides that, we also need to streamline those separated steps to implement CI/CD. With more and more business moving to internet, Security review integration becomes more important, so it's also one of the goals of this project.
  
  The design for this mini-project is as below:
  
    a. Creating a Java project to implement the simple REST API to enable CRUD operations.
    b. Writing a bash script 'build.sh' which will use 'docker' to compile the 'hello' java project, perform security scan using SonarQube tool, create a final image which hosts hello app and the jre environment.
    c. The 'build.sh' script will perform some test to ensure the hello app works as expected.
    d. The 'build.sh' script will automatically delete the intermediate images and only keep the final image which is around 123 MB.
    e. If we pass a parameter containing 'clean'  to 'build.sh', after the test, both the helloapp container and related image will be destroyed to clean the environment.
    f. we use Jenkins pipeline to retreive the code from the GitHub and execute 'build.sh' on the related Linux server where docker is running with the version which is above 17.05.
    
 The work flow is as below:
 
 start ---> Jenkins pipeline ----->pull code from GitHub to 1 slave linux server ------> run 'build.sh' on the slave Linux server----> compiling hello project using 'maven' 
 ----->scan the code using SonarQube tool---> creating image which hosts the hello app ----> starting container ----> test ----> remove the intermediate images----> end
 
 If you do not have Jenkins installed, the work flow is as below:
 
 pull code from GitHub to one linux server ------> run 'build.sh' on the Linux server----> compiling hello project using 'maven'
 ----->scan the code using SonarQube tool----> creating image which hosts the hello app----> starting container----> test----> remove the intermediate images
 ----> end
 
 Most of the tasks are executed by 'build.sh' script which is the main part of this project.
    
Below is the details:


1. hello app
  
  The hello application was developed using Java and spring boot framework. If you use 'curl' command to send a request to http://localhost:8081/hello with the parameter '-v' on Linux server, you will get 'HTTP/1.1 200' and a json response similar to the following json string:
  
    {"id": 1, "info": "welcome"}.
  
  It also support POST/PUT/DELETE operations. Below are some 'curl' command for your reference:
        
    curl -X POST -v http://localhost:8081/hello -H 'Content-type:application/json' -d '{"info": "this is a test."}' 
     
    curl -X PUT -v http://localhost:8081/hello/2 -H 'Content-type:application/json' -d '{"info": "update the information"}'
     
    curl -X DELETE -v http://localhost:8081/hello/2
     
     curl -X GET -v http://localhost:8081/hello/all
     
  If you want to access this API remotely, you may need to open the 8081 port in your firewall and replace the 'localhost' with the related ip address.
     
2. docker image and container (Dockerfile & Dockerfile2)

   In order to reduce the size of the final image, we use the multi-stages builds to create the related images, 2 for compiling, 2 for the hello app etc.
   Only the small basic jre image and the compiled jar file are included in the final image,  all the middle images will be deleted automatically after the building.
   
   Because we use multi-stage builds, the required minimum Docker version is 17.05, so, please check your docker version, if it's below 17.05, you may need to upgrade your docker if you want to run the 'build.sh' script on your environment.
   
   The below is the link to how to upgrade the docker:
   
   https://docs.docker.com/engine/install/centos/
   
   
3. Jenkins Integration (jenkins_pipeline.txt file)

   we can use Jenkins pipeline to execute only the following 2 steps to complete our task which makes life easier:
   
          a. Fetching the code from the GitHub.
      
          b. Executing the 'build.sh' script remotely and get the test result from there.
    
    Below is executing result extracted from the Jenkins pipeline:
        
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
   
   In order to run the Jenkins pipeline, we need to install 'git' and clone the repository to make it work smoothly.
   
4. build.sh 

   The build.sh script will perform the following functions:
   
        a. Checking if the Docker service is running.
        b. Compiling java code using 'maven' image and perform security scan using SonarQube tool.
        c. Creating the final image which hosts the 'hello app'.
        d. Starting the container.
        e. Performing test which will send some request to the api address and check if it receive 'HTTP/1.1 200'.
        f. Deleting the intermediate images.
        g. Stop & destroy the container and image if you pass a parameter containing 'clean' to the 'build.sh'.
   
   when your run 'build.sh' on linux server, please make sure it has 'execution' permission. If not, run command 'chmod 755 build.sh' please.
   
5. How to use this repostitory:

  	    a. Clone the repository.
        b. Ensure the docker version is above 17.05 on your linux server.
        c. Run './build.sh' script.
  
  
6. code review integration

    For code review, we can create a 'pull request' and send to peers to review and approve before we merge our code to the main branch to reduce the human error.
    However, the syntax error is easy to be detected, the logical error is a little bit hard to be found.
    
    I created one pull request for this practice:
    
    https://github.com/gqrlt1207/challenge/pull/1
    
    We can also use some tool to scan the code which is also helpful.

7. security review integration

    I use SonarQube to perform security scan when I compile the code using the docker, below is the snippet from the Dockerfile2:
    
          RUN mvn sonar:sonar \
          -Dsonar.projectKey=hello \
          -Dsonar.host.url=http://${ip-address}:9000 \
          -Dsonar.login=${token}
      
   In order to run the above command, we need to get the value of the following 2 parameters: 
   
        a: ${ip-address} which is used to communicate among the dockers
    
        b: ${token} which is used to access the sonar server
    
   We can use the following command to get the internal ip address of SonarQube server:
   
          docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube
   
   To generate the 'token', we can use the default username/password  : admin/admin to send a api request to create it as below:
    
          curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "name=${user_tokenName}" -u admin:admin localhost:9000/api/user_tokens/generate
      
   If the Sonar server was installed before, the default credential will not work, so there is no way to get the token, in this scenario, 'build.sh' will skip security scan.
   
   
   
      
  
   
   
