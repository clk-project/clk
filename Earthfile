FROM python:alpine

AS_USER:
	COMMAND
	RUN apk add --update git bash curl
	RUN curl -sfL https://direnv.net/install.sh | bash
	# setup-user
	ARG uid=1000
	ARG username=sam
	ENV HOME=/home/$username
	RUN addgroup --gid $uid --system $username \
		&& adduser --uid $uid --system $username --ingroup $username \
	 	&& chown -R $username:$username $HOME
	ENV PATH=$HOME/.local/bin:$PATH
	# as-user:
	ARG uid=1000
	ARG username=sam
	ENV HOME=/home/$username
	USER $username

REQUIREMENTS:
	COMMAND
	COPY requirements.txt /src/
	RUN python3 -m pip install -r /src/requirements.txt

sources:
	COPY --dir .flake8 .gitignore .gitmodules .pre-commit-config.yaml .isort.cfg .gitignore .style.yapf LICENSE pycln.toml pyproject.toml tox.ini MANIFEST.in setup.py requirements.txt sonar-project.properties fasterentrypoint.py setup.cfg versioneer.py ./tests ./clk ./.git /src/
	WORKDIR /src
	SAVE ARTIFACT /src /src

INSTALL:
	COMMAND
	ARG from=source
	IF [ "${from}" == "source" ]
		DO +REQUIREMENTS
		COPY +sources/src/ /src
		RUN python3 -m pip install /src
	ELSE IF [ "${from}" == "pypi" ]
	     RUN --no-cache python3 -m pip install clk
	END

clk:
	FROM python:alpine
 	ARG from=source
	DO +AS_USER
	DO +INSTALL --from $from
	RUN clk completion show bash >> ~/.bashrc
	RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
	ENTRYPOINT ["clk"]
	SAVE IMAGE clk

test:
	FROM python:alpine
	DO +AS_USER
	RUN python3 -m pip install coverage pytest
 	ARG from=source
	DO +INSTALL --from $from
	COPY --dir +sources/src/tests +sources/src/clk /src/
	WORKDIR /src
	IF [ "${from}" == "source" ]
		RUN coverage run --source /src -m pytest
		RUN mkdir coverage && cd coverage && coverage combine --append ../.coverage ../tests/.coverage && coverage xml
 		SAVE ARTIFACT coverage /coverage
	ELSE
		RUN pytest
	END

check-quality:
	FROM python:slim
	RUN apt update && apt install --yes git
	RUN python3 -m pip install pre-commit
	COPY +sources/src/ /src
	RUN cd /src && pre-commit run -a

prepare-for-sonar:
	FROM alpine
	RUN apk add --update git
	COPY --dir +sources/src/clk +sources/src/.git +sources/src/.gitignore +sources/src/sonar-project.properties /src/
	WORKDIR /src
	# asserts the repository is clean
	RUN [ "$(git status --porcelain clk | wc -l)" == "0" ]
	RUN echo sonar.projectVersion=$(git tag --sort=creatordate --merged|grep '^v'|tail -1) >> /src/sonar-project.properties
	SAVE ARTIFACT /src /src

sonar:
	FROM sonarsource/sonar-scanner-cli
	ARG from=source
	RUN [ "$from" == "source" ]
	COPY +prepare-for-sonar/src /src
	WORKDIR /src
	COPY (+test/coverage --from="$from") /src/coverage
	ENV SONAR_HOST_URL=https://sonarcloud.io
 	RUN --secret SONAR_TOKEN sonar-scanner -D sonar.python.coverage.reportPaths=/src/coverage/coverage.xml

build:
	FROM +sources
	RUN python3 setup.py bdist_wheel
	SAVE ARTIFACT dist /dist

dist:
	COPY +build/dist dist
	SAVE ARTIFACT dist /dist AS LOCAL dist

sanity-check:
	BUILD +test
	BUILD +sonar
	BUILD +check-quality

upload:
	BUILD +sanity-check
	FROM python:alpine
	RUN apk add --update py3-twine
	COPY +build/dist /tmp/dist
	# asserts the file was generated using a tag
	RUN ls /tmp/dist/|grep -q 'clk-[0-9]\+\.[0-9]\+\.[0-9]\+'
 	ARG PASSWORD
	RUN --push --secret pypi-username --secret pypi-password twine upload --username "${pypi-username}" --password "${pypi-password}" '/tmp/dist/*'

deploy:
	BUILD +upload
