# image for java 21 mvn Stage 1
FROM maven:3.9-eclipse-temurin-21-jammy AS build

WORKDIR /app

COPY . .

# giving executable permission to the file && instaling package
RUN chmod +x mvnw && ./mvnw clean package -DskipTests


# Stage 2
FROM eclipse-temurin:21-jre-alpine AS runner

WORKDIR /app

# Updating packages 
RUN apk update && apk upgrade --no-cache

#Adding group && adding user to that group
RUN addgroup -S devops && adduser -S -G devops devops

# Running as that user
USER devops

#Copying only build pack
COPY --from=build /app/target/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
