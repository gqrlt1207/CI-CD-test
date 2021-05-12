#!/bin/bash
# version: 1.0.0

#initialize the global variables
init_variable() {
    dockerfile="$(pwd)/Dockerfile"
    baseimage="openjdk:8-jre-alpine"    
    app="helloapp"
    testlog="/tmp/test.out"
    appimage="hello:latest"
    return 0
}

#build java source code
build_app() {
    #check if the Dockerfile exists
    if [ ! -f ${dockerfile} ]; then 
        echo "${dockerfile} does not exist, abort."
	return 1
    fi

    #check if docker is running
    systemctl status docker |grep "active (running)"
    if [ $? -ne 0 ]; then
        echo "Docker is not up, please make sure docker is installed and running, abort."
        return 1
    fi
    
    docker build -t hello  .
    if [ $? -ne 0 ]; then
        echo "Failed to build hello application, abort."
        return 1
    fi

    return 0
}

#start helloapp
start_app() {
    docker run -p 8081:8081 -d --name ${app} hello
    if [ $? -ne 0 ]; then
      echo "Failed to start helloapp, exiting..."
      return 1
    fi

    return 0
}

#stop helloapp
stop_app() {
    docker stop ${app} 
    if [ $? -ne 0 ]; then
      echo "Failed to start helloapp, exiting..."
      return 1
    fi

    return 0
}


#test the hello application
test_app() {
    for((i=0;i<10;i++)); do
        curl -X GET -v http://localhost:8081/hello > ${testlog} 2>&1 
        cat ${testlog} |grep "HTTP/1.1 200"
        if [ $? -ne 0 ]; then
            echo "application is not ready, wait ..."
            sleep 6
        else
            echo "Test is successful."
            break
        fi
    done
    if [ $i -eq 10 ]; then
        echo "Test failed, abort."
        return 1
    fi

    return 0
}

#remove the intermidiate images
clean_images() {
   
    docker rmi ${baseimage} 
    for i in `docker image ls |grep -v hello |grep -v TAG |awk '{print $3}' `; do
        docker image rm $i
    done

    if [ $? -ne 0 ]; then
        echo "Faied to clean the intermidiate images."
        return 1
    fi

    return 0
}

#restore the environment
restore() {
    stop_app
    if [ $? -ne 0 ]; then
        echo "Failed to stop hello app"
        return 1
    fi
    
    docker container rm ${app}
    if [ $? -ne 0 ]; then
        echo "Failed to remove container ${app}."
        return 1
    fi

    docker rmi ${appimage} 
    if [ $? -ne 0 ]; then
       echo "Failed to remove ${appimage}."
       return 1
    fi

    return 0

}

#main code
main() {
    init_variable

    build_app
    if [ $? -ne 0 ]; then
        echo "Failed to build hello application, exiting..."
        return 1
    fi

    start_app
    if [ $? -ne 0 ]; then
        echo "Failed to start hello application, exiting..."
        return 1
    fi


    test_app
    if [ $? -ne 0 ]; then
        echo "Failed to test hello application, exiting..."
        return 1
    fi

    clean_images
    if [ $? -ne 0 ]; then
        echo "Failed to clean the intermidiate images, exiting..."
        return 1
    fi

    stop_app

    echo "Finished building and testing."

    if [[ ! -z  $1 ]] && [[ "$1" =~ "clean" ]]; then
        echo "Starting to restore the environment..."
        restore
        if [ $? -ne 0 ]; then
            echo "Failed to restore the environment."
            return 1
        fi

     fi
 
    return 0
}

#If $1 contains 'clean', the helloapp container and image will be deleted after the testing.
main $1
