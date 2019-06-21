FROM alpine:3.7
RUN apk add --no-cache curl bash git openssh-client python py-pip groff less mailcap \
 && pip install awscli \
 && apk --purge del py-pip

ADD bump_git_version.sh /usr/local/bin/

RUN curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh > /tmp/install.sh \
 && chmod +x /tmp/install.sh \
 && /tmp/install.sh -i /usr/local \
 && rm -f /tmp/install.sh

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.3/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

RUN mkdir -p /root/.ssh/ /root/.aws/ /root/.config/yandex-cloud/ /root/.kube/ \
 && chmod 700 /root/.ssh /root/.aws/ /root/.config/yandex-cloud/ /root/.kube/ \
 && ssh-keyscan -t rsa git.utrace.ru >> ~/.ssh/known_hosts

ENV DEVOPS_PRIVATE_KEY_BASE64 ""
ENV YC_PROFILES_BASE64 ""
ENV KUBECTL_CONFIG_BASE64 ""

ENV GIT_AUTHOR_NAME "devops@utrace.ru"
ENV GIT_AUTHOR_EMAIL "devops@utrace.ru"

ENV AWS_ACCESS_KEY_ID "id"
ENV AWS_SECRET_ACCESS_KEY "secret"
ENV AWS_REGION "us-east-1"

ADD container-entrypoint.sh /usr/sbin/

WORKDIR "/root"

ENTRYPOINT ["/usr/sbin/container-entrypoint.sh"]
