#!/bin/bash
# version: 1.0.0

#initialize the global variables
init_variable() {
    dockerfile="$(pwd)/Dockerfile"
    baseimage="openjdk:8-jre-alpine"    
    app="helloapp"
    testlog="/tmp/test.out"
    appimage="hello:latest"
    sonarqube_installed=false
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
   
    if ! sonarqube_installed; then  
    	docker build -t hello  -f- ./ < Dockerfile
    else
	docker build -t hello -f- ./ < Dockerfiletmp
    fi

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

#check if sonarqube is installed.
#if it's true, do nothing because we do not know the credential
#if it's false, install sonarqube and generate new Dockerfile
#to scan code
sonarqube_integration() {
	rm -f Dockerfiletmp
        cp -p Dockerfile2 Dockerfiletmp

	docker ps |grep -i sonarqube
	if [ $? -eq 0 ]; then
		echo "sonarqube is running."
		sonarqube_installed=true
		return 1
	fi

	docker pull sonarqube
	docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube

	sonarqube_ip=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonarqube`
	echo ${sonarqube_ip}
	sleep 90
	curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "name=hello" -u admin:admin http://localhost:9000/api/user_tokens/generate > /tmp/test.out

	grep -Po '"token":.*?[^\\]",' /tmp/test.out > token_info

	token=`cat ./token_info |cut -d ":" -f 2 |sed 's/,//g' |sed 's/"//g'`
	echo "The token is ${token}."
	sed -i "s/localhost/${sonarqube_ip}/g" Dockerfiletmp
	sed  -i "s/-Dsonar.login=.*/-Dsonar.login=${token}/g" Dockerfiletmp
	rm -r -f ./token_info
	
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
    for i in `docker image ls |grep -v hello|grep -v sonarqube |grep -v TAG |awk '{print $3}' `; do
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


    if ! sonarqube_installed; then
	docker stop sonarqube
	docker rm sonarqube
	docker rmi sonarqube:latest
    fi

    return 0

}

#main code
main() {
    init_variable

    sonarqube_integration

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

    #stop_app

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
