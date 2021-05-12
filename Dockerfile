FROM maven:latest AS builder
ENV APP_HOME=/app/
COPY pom.xml $APP_HOME
COPY src $APP_HOME/src/
WORKDIR $APP_HOME
RUN mvn clean package -DskipTests

FROM openjdk:8-jre-alpine
COPY --from=builder /app/target/hello-0.0.1.jar /hello.jar
RUN ls -lrt /hello.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "/hello.jar"]
