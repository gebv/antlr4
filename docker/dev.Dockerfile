FROM adoptopenjdk/openjdk11:alpine AS builder

WORKDIR /opt/antlr4

RUN apk add --no-cache maven git

ARG MAVEN_OPTS="-Xmx1G"

COPY . ./antlr4

RUN cd antlr4 \
    && mvn clean --projects tool --also-make \
    && mvn -DskipTests install --projects tool --also-make \
    && mv ./tool/target/antlr4-*-complete.jar antlr4-tool.jar

FROM adoptopenjdk/openjdk11:alpine-jre

ARG user=appuser
ARG group=appuser
ARG uid=1000
ARG gid=1000

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "${uid}" \
    "${user}"

COPY --from=builder /opt/antlr4/antlr4/antlr4-tool.jar /usr/local/lib/
WORKDIR /work
ENTRYPOINT ["java", "-Xmx500M", "-cp", "/usr/local/lib/antlr4-tool.jar", "org.antlr.v4.Tool"]


