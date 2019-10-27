FROM alpine:3.10.2

RUN adduser devops -D -h /home/devops

RUN apk add --no-cache curl bash git openssh-client python groff less mailcap ansible\
 && pip3 install awscli hvac openshift

ADD bump_git_version.sh make_release.sh /usr/local/bin/

RUN curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh > /tmp/install.sh \
 && chmod +x /tmp/install.sh \
 && /tmp/install.sh -i /usr/local \
 && rm -f /tmp/install.sh

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.3/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

RUN curl https://releases.hashicorp.com/vault/1.2.2/vault_1.2.2_linux_amd64.zip > /tmp/vault.zip \
 && unzip /tmp/vault.zip -d /tmp/ \
 && chmod +x /tmp/vault \
 && mv /tmp/vault /usr/local/bin/ \
 && rm -f /tmp/vault.zip

RUN curl -L https://github.com/utrace-ltd/slak-release-notifier/releases/download/RC1-0.1.0/slack-release-notifier_linux_amd64 > /usr/local/bin/slack-release-notifier \
 && chmod +x /usr/local/bin/slack-release-notifier

RUN curl -L https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 > /usr/local/bin/yq \
 && chmod +x /usr/local/bin/yq

RUN mkdir -p /home/devops/.ssh/ /home/devops/.aws/ /home/devops/.config/yandex-cloud/ /home/devops/.kube/ \
 && chmod 700 /home/devops/.ssh /home/devops/.aws/ /home/devops/.config/yandex-cloud/ /home/devops/.kube/ \
 && ssh-keyscan -t rsa git.utrace.ru >> /home/devops/.ssh/known_hosts

ADD ansible.cfg /home/devops/

RUN chown -R devops:devops /home/devops

ENV DEVOPS_PRIVATE_KEY_BASE64 ""
ENV YC_PROFILES_BASE64 ""
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
