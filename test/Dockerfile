FROM hashicorp/terraform as terraform

FROM python:3.8

COPY . /usr/local/src
COPY --from=terraform /bin/terraform /usr/local/bin/

WORKDIR /usr/local/src/test

RUN pip install -r requirements.txt

VOLUME /root/.aws

CMD [ "--stop", "--no-capture", "-v", "-D", "log_level=DEBUG" ]
ENTRYPOINT [ "behave" ]
