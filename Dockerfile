FROM python:alpine
WORKDIR /src/
RUN apk add --update git
RUN python3 -m pip install pip-tools
COPY requirements.txt /src/
RUN pip-sync
RUN python3 -m pip install pytest

COPY ./ /src/
RUN python3 -m pip install /src/

WORKDIR /
