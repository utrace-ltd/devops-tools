FROM alpine:3.13

RUN adduser devops -D -h /home/devops

RUN apk add --no-cache curl bash git openssh-client openssl ca-certificates python3 py3-pip groff less mailcap sshpass \
 && apk --no-cache add --virtual build-dependencies python3-dev libffi-dev musl-dev gcc cargo openssl-dev libressl-dev build-base && \
    pip3 install --upgrade pip wheel && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install ansible-core==2.11.6 ansible && \
    pip3 install mitogen ansible-lint jmespath && \
    pip3 install --upgrade pywinrm && \
    pip3 install --upgrade kubernetes hvac openshift awscli && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo
 
ADD bump_git_version.sh make_release.sh /usr/local/bin/

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

RUN curl https://releases.hashicorp.com/vault/1.9.1/vault_1.9.1_linux_amd64.zip > /tmp/vault.zip \
 && unzip /tmp/vault.zip -d /tmp/ \
 && chmod +x /tmp/vault \
 && mv /tmp/vault /usr/local/bin/ \
 && rm -f /tmp/vault.zip

RUN curl https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_linux_amd64.zip > /tmp/terraform.zip \
 && unzip /tmp/terraform.zip -d /tmp/ \
 && chmod +x /tmp/terraform \
 && mv /tmp/terraform /usr/local/bin/ \
 && rm -f /tmp/terraform.zip

RUN curl https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz > /tmp/helm.tar.gz \
 && tar -zxvf /tmp/helm.tar.gz \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && rm -fR /tmp/helm.tar.gz linux-amd64/

RUN curl -L https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 > /usr/local/bin/yq \
 && chmod +x /usr/local/bin/yq

RUN mkdir -p /home/devops/.ssh/ /home/devops/.aws/ /home/devops/.config/yandex-cloud/ /home/devops/.kube/ \
 && chmod 700 /home/devops/.ssh /home/devops/.aws/ /home/devops/.config/yandex-cloud/ /home/devops/.kube/ \
 && ssh-keyscan -t rsa git.utrace.ru >> /home/devops/.ssh/known_hosts

ADD ansible.cfg /home/devops/

RUN chown -R devops:devops /home/devops

ENV DEVOPS_PRIVATE_KEY_BASE64 ""
ENV KUBECTL_CONFIG_BASE64 ""

ENV GIT_AUTHOR_NAME "devops@example.com"
ENV GIT_AUTHOR_EMAIL "devops@example.com"

ENV AWS_ACCESS_KEY_ID "id"
ENV AWS_SECRET_ACCESS_KEY "secret"
ENV AWS_REGION "us-east-1"

ENV VAULT_ADDR=http://vault.example.com
ENV VAULT_TOKEN=""

ADD container-entrypoint.sh /usr/sbin/

USER devops
WORKDIR "/home/devops"

ENTRYPOINT ["/usr/sbin/container-entrypoint.sh"]
