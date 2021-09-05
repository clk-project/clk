FROM python:alpine
# dependencies
RUN apk add --update git bash curl
RUN curl -sfL https://direnv.net/install.sh | bash
# setup-user
ARG uid=1000
ARG username=sam
ENV HOME=/home/$username
RUN addgroup --gid $uid --system $username \
	&& adduser --uid $uid --system $username --ingroup $username \
	&& addgroup --system $username audio \
 	&& addgroup --system $username video \
 	&& addgroup --system $username disk \
 	&& addgroup --system $username lp \
 	&& addgroup --system $username dialout \
 	&& addgroup --system $username users \
 	&& chown -R $username:$username $HOME
ENV PATH=$HOME/.local/bin:$PATH
# as-user:
ARG uid=1000
ARG username=sam
ENV HOME=/home/$username
USER $username
WORKDIR $HOME/src

RUN python3 -m pip install pip-tools
COPY requirements.txt $HOME/src/
RUN pip-sync
RUN python3 -m pip install pytest ipdb ipython

COPY ./ $HOME/src/
ARG install_args=-e
RUN python3 -m pip install $install_args $HOME/src/

WORKDIR /tmp
ENV PYTHONBREAKPOINT=ipdb.set_trace
RUN clk completion show bash >> ~/.bashrc
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
CMD bash
