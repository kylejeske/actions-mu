FROM python:3-stretch AS base
RUN apt-get -y update \
        && apt-get -y --no-install-recommends install \
            apt-utils \
        && apt-get -y --no-install-recommends install \
            curl \
            groff \
            jq
RUN pip install --upgrade pip \
        && pip install setuptools awscli
ENTRYPOINT [ "/bin/sh", "-c" ]

FROM scratch AS utility-runner
LABEL name="mu"
LABEL version="0.1.0"
LABEL repository="http://github.com/kylejeske/actions/mu"
LABEL homepage="http://github.com/kylejeske/actions"
LABEL com.github.actions.name="GitHub Action for MU"
LABEL com.github.actions.description="Wraps the stelligent CLI to enable common MU commands."
LABEL com.github.actions.icon="box"
LABEL com.github.actions.color="yellow"
ENV FILE="mu"
ENV LATEST-MU="1.5.10"
COPY --from=0 / /
VOLUME [ "/local" ]
WORKDIR /local
RUN curl -sLk --url https://github.com/stelligent/mu/releases/download/v1.5.10/mu-linux-amd64 -o dockerbuild.file.mu \
        && mv dockerbuild.file.mu /usr/sbin/mu \
        && chmod +x /usr/sbin/mu 
ENTRYPOINT [ "/bin/sh", "-c" ]
CMD [ "/usr/sbin/mu" ]