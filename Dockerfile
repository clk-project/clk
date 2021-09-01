FROM python:alpine
WORKDIR /src/
RUN apk add --update git bash
RUN python3 -m pip install pip-tools
COPY requirements.txt /src/
RUN pip-sync
RUN python3 -m pip install pytest ipdb ipython

COPY ./ /src/
RUN python3 -m pip install -e /src/

WORKDIR /
RUN clk completion show bash > ~/.bashrc
CMD bash
