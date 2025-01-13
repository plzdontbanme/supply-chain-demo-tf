FROM alpine:latest

ARG FIRST_VERSION=1.10.3
ARG SECOND_VERSION=1.10.4

RUN apk update && \
    apk add --no-cache curl wget unzip git nano aws-cli

RUN wget https://releases.hashicorp.com/terraform/${FIRST_VERSION}/terraform_${FIRST_VERSION}_linux_amd64.zip && \
    unzip terraform_${FIRST_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    wget https://releases.hashicorp.com/terraform/${SECOND_VERSION}/terraform_${SECOND_VERSION}_linux_amd64.zip && \
    mkdir -p /root/.aws/ && \
    echo "unzip terraform_${SECOND_VERSION}_linux_amd64.zip -d /usr/local/bin/" > /update.sh && \
    chmod +x /update.sh

COPY config /root/.aws/config

# TODO: delete this after it's all working
RUN git clone https://github.com/plzdontbanme/supply-chain-demo-tf.git

CMD ["/bin/sh"]