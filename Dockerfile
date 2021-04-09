FROM hashicorp/terraform:0.14.10

RUN apk add make

WORKDIR /tmp
COPY . /tmp

ENTRYPOINT [ "/usr/bin/make" ]
