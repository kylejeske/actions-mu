#FROM python:3-stretch
FROM debian:stable-slim AS utility-base

LABEL name="mu"
LABEL version="1.0.0"
LABEL repository="http://github.com/kylejeske/actions/mu"
LABEL homepage="http://github.com/kylejeske/actions"

LABEL com.github.actions.name="GitHub Action for MU"
LABEL com.github.actions.description="Wraps the stelligent CLI to enable common MU commands."
LABEL com.github.actions.icon="box"
LABEL com.github.actions.color="yellow"

ENV FILE="mu"
ENV LATEST-MU="1.5.10"
#COPY   /usr/local/bin/mu
#RUN true \
#        && apt-get update \
#        && apt-get install -y --no-install-recommends curl groff jq \
#        #&& apt-get -y clean autoclean autoremove \
#        && true

RUN true \
        && apt-get -y update \
        && apt-get -y install curl \
        && curl -sL https://github.com/stelligent/mu/releases/download/v1.5.10/mu-linux-amd64 -o .dockerbuild.file.mu \
        && mv .dockerbuild.file.mu /usr/local/bin/mu \
        && chmod +x /usr/local/bin/mu \
        && true

#RUN true \
#        && rm -rf /var/lib/apt/lists/* \
#        && pip install --upgrade pip \
#        && pip install setuptools awscli \
#        true

COPY "entrypoint.sh" "/entrypoint.sh"
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mu"]