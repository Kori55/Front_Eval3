# Etapa 1: Compilar la aplicación Java y generar archivos estáticos
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN apk add --no-cache maven && \
    mvn clean compile -DskipTests

# Ejecutar el generador para crear los archivos estáticos
RUN mvn exec:java@default

# Etapa 2: Servir con nginx
FROM nginx:alpine

# Copiar los archivos generados desde la etapa anterior
COPY --from=builder /app/output /usr/share/nginx/html

# Copiar configuración de nginx (opcional, para mejor control)
RUN echo 'server { \
    listen 8080; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]