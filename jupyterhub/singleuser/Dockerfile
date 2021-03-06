# Link to all the dockerfiles which this image is based upon. This provides info about various packages
# already present in the image. When updating the upstream image tag, remember to update the links as well.

# Minimal: https://github.com/jupyter/docker-stacks/tree/6c85e4b43a26/minimal-notebook/Dockerfile
# Base: https://github.com/jupyter/docker-stacks/tree/6c85e4b43a26/base-notebook/Dockerfile

FROM jupyter/minimal-notebook:6c85e4b43a26

LABEL maintainer Uninett As <system@uninett.no>

# hadolint ignore=DL3002
USER root
RUN apt update && apt-get install --no-install-recommends -y \
    openssh-client=1:7.6p1-4 \
    less=487-0.1 \
    net-tools=1.60+git20161116.90da8a0-1ubuntu1 \
    man-db=2.8.3-2 \
    iputils-ping=3:20161105-1ubuntu2 \
    screen=4.6.2-1 \
    tmux=2.6-3 \
    graphviz=2.40.1-2 \
    cmake=3.10.2-1ubuntu2 \
    rsync=3.1.2-2.1ubuntu1 \
    p7zip-full=16.02+dfsg-6 \
    tzdata=2018d-1 \
    unrar=1:5.5.8-1 && \
    ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime && \
 	apt-get clean && rm -rf /var/lib/apt/lists/*


# Setup locales
ENV TZ="Europe/Oslo"

# Setup ENV for Appstore to be picked up
ENV APP_UID=999 \
	APP_GID=999 \
	PKG_JUPYTER_NOTEBOOK_VERSION=5.7.x

RUN groupadd -g "$APP_GID" notebook && \
	useradd -m -s /bin/bash -N -u "$APP_UID" -g notebook notebook && \
	chmod go+w -Rc "$CONDA_DIR" | cut -d'/' -f 5 | cut -d' ' -f 1| sed -e "s/'//g"  | uniq

ENV HOME=/home/notebook \
    XDG_CACHE_HOME=/home/notebook/.cache/
COPY start-notebook.sh /usr/local/bin/
COPY --chown=notebook:notebook .jupyter/ /opt/.jupyter/
RUN chmod go+rwx -R "$CONDA_DIR/bin" && chown notebook:notebook -R "$CONDA_DIR/bin" && \
    mkdir -p "$CONDA_DIR/.condatmp" && chmod go+rwx "$CONDA_DIR/.condatmp"

USER notebook

RUN conda update conda python && pip install -U 'pip==18.*'
RUN conda install --quiet --yes -c conda-forge \
    'jupyterhub==0.9*' \
    'jupyter_contrib_nbextensions=0.5*' \
    'tqdm=4.28*' \
    'nbdime=1.0*' \
    'nbconvert=5.4*' && \
    conda install --quiet --yes -c damianavila82 'rise=5.4.*' && \
    conda clean -tipsy && \
    git clone https://github.com/paalka/nbresuse /tmp/nbresuse && pip install /tmp/nbresuse/ && \
    jupyter serverextension enable --py nbresuse --sys-prefix && \
    jupyter nbextension install --py nbresuse --sys-prefix && \
    jupyter nbextension enable --py nbresuse --sys-prefix

# hadolint ignore=DL3002
USER root
RUN chmod go+w -R "$HOME"  && \
    chmod go+w -Rc "$CONDA_DIR" | cut -d'/' -f 5 | cut -d' ' -f 1| sed -e "s/'//g"  | uniq

USER notebook

WORKDIR $HOME
CMD ["/usr/local/bin/start-notebook.sh"]
