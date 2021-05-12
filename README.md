# challenge
1. hello app
  The hello application was written in Java and spring boot framework. If you send a request like http://localhost:8081/hello with the verbose outcome, you will see 'HTTP /1.1 200' and get a json response like {"id": 1, "info": "welcome"}.
  It also support POST/PUT/DELETE operations. Below are some 'curl' command for your reference:
     curl -X POST -v localhost:8081/hello -H 'Content-type:application/json' -d '{"info": "this is a test."}'   
     curl -X PUT -v localhost:8081/hello/2 -H 'Content-type:application/json' -d '{"info": "update the information"}'
     curl -X DELETE -v localhost:8081/hello/2
     curl -X GET -v localhost:8081/hello/all
     
