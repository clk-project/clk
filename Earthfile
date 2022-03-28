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

side-files:
	COPY --dir .flake8 .pre-commit-config.yaml .isort.cfg .gitignore .style.yapf LICENSE pycln.toml tox.ini sonar-project.properties /src
	SAVE ARTIFACT /src /src

test-files:
	COPY --dir tests /src/
	SAVE ARTIFACT /src /src

sources:
	COPY --dir pyproject.toml MANIFEST.in setup.py fasterentrypoint.py setup.cfg versioneer.py ./clk ./.git .gitignore .gitmodules /src/
	WORKDIR /src
	SAVE ARTIFACT /src /src

INSTALL:
	COMMAND
	ARG from=build
	IF [ "${from}" == "source" ]
		DO +REQUIREMENTS
		COPY --dir +sources/src/* /src
		RUN python3 -m pip install /src
	ELSE IF [ "${from}" == "build" ]
		DO +REQUIREMENTS
		COPY +build/dist /dist
		RUN python3 -m pip install /dist/*
	ELSE IF [ "${from}" == "pypi" ]
	    RUN --no-cache python3 -m pip install clk
	END

clk:
	FROM python:alpine
 	ARG from=build
	DO +AS_USER
	DO +INSTALL --from "$from"
	RUN clk completion show bash >> ~/.bashrc
	RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
	ENTRYPOINT ["clk"]
	ARG ref=latest
	SAVE IMAGE clk:${ref}

test:
	FROM python:alpine
	DO +AS_USER
	RUN python3 -m pip install coverage pytest
 	ARG from=build
	DO +INSTALL --from "$from"
	COPY --dir +test-files/src/tests +sources/src/clk /src/
	WORKDIR /src
	ARG test_args
	IF [ "${from}" == "source" ] || [ "${from}" == "build" ]
		RUN coverage run --source /src -m pytest ${test_args}
		RUN mkdir coverage && cd coverage && coverage combine --append ../.coverage ../tests/.coverage && coverage xml
 		SAVE ARTIFACT coverage /coverage
	ELSE
		RUN pytest ${test_args}
	END

coverage:
	ARG test_args
 	ARG from=build
	FROM +test --from="$from" --test_args="$test_args"
	RUN cd /src/coverage && coverage html
	SAVE ARTIFACT /src/coverage AS LOCAL coverage

check-quality:
	FROM python:slim
	RUN apt update && apt install --yes git
	RUN python3 -m pip install pre-commit
	COPY --dir +sources/src/* +side-files/src/* +test-files/src/* /src
	RUN cd /src && pre-commit run -a

prepare-for-sonar:
	FROM alpine
	RUN apk add --update git
	COPY --dir +sources/src/clk +sources/src/.git +sources/src/.gitignore +side-files/src/sonar-project.properties /src/
	WORKDIR /src
	# asserts the repository is clean
	RUN [ "$(git status --porcelain clk | wc -l)" == "0" ]
	RUN echo sonar.projectVersion=$(git tag --sort=creatordate --merged|grep '^v'|tail -1) >> /src/sonar-project.properties
	SAVE ARTIFACT /src /src

sonar:
	FROM sonarsource/sonar-scanner-cli
	ARG from=build
	RUN [ "$from" == "build" ]
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

local-sanity-check:
	BUILD +test
	BUILD +check-quality

sanity-check:
	BUILD +local-sanity-check
	BUILD +sonar

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
