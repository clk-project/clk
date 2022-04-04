FROM python:alpine

AS_USER:
	COMMAND
	RUN apk add --update bash curl
	RUN curl -sfL https://direnv.net/install.sh | bash
	ARG username=sam
	ENV HOME=/home/$username
	ARG uid=1000
	RUN addgroup --gid $uid --system $username \
		&& adduser --uid $uid --system $username --ingroup $username \
	 	&& chown -R $username:$username $HOME
	ENV PATH=$HOME/.local/bin:$PATH
	ENV HOME=/home/$username
	USER $username
	RUN echo 'source <(direnv hook bash)' >> "${HOME}/.bashrc"

REQUIREMENTS:
	COMMAND
	COPY requirements.txt /app/
	RUN python3 -m pip install -r /app/requirements.txt

side-files:
	COPY --dir .flake8 .pre-commit-config.yaml .isort.cfg .style.yapf LICENSE pycln.toml tox.ini sonar-project.properties /app
	SAVE ARTIFACT /app /app

test-files:
	COPY --dir tests /app/
	SAVE ARTIFACT /app /app

git-files:
    COPY --dir ./.git .gitignore .gitmodules /app
	SAVE ARTIFACT /app /app

sources:
	COPY --dir pyproject.toml MANIFEST.in setup.py fasterentrypoint.py setup.cfg versioneer.py ./clk /app/
	WORKDIR /app
	SAVE ARTIFACT /app /app

INSTALL:
	COMMAND
	ARG from=build
	IF [ "${from}" == "source" ]
		DO +REQUIREMENTS
		COPY --dir +sources/app/* /app
		RUN cd /app && python3 -m pip install --editable .
	ELSE IF [ "${from}" == "build" ]
		DO +REQUIREMENTS
		ARG use_git=true
		COPY (+build/dist --use_git="$use_git") /dist
		RUN python3 -m pip install /dist/*
	ELSE IF [ "${from}" == "pypi" ]
	    RUN --no-cache python3 -m pip install clk
	ELSE
		RUN echo "from=${from} must be either source, build or pypi" && exit 1
	END

VENV:
	COMMAND
	ENV VIRTUAL_ENV="${HOME}/venv"
	RUN python3 -m venv "$VIRTUAL_ENV"
	ENV PATH="$VIRTUAL_ENV/bin:$PATH"

build:
	FROM python:alpine
	COPY +sources/app /app
	ARG use_git=true
	IF [ "$use_git" == "true" ]
		RUN apk add --update git
		COPY --dir +git-files/app/* /app
	END
	WORKDIR /app
	RUN python3 setup.py bdist_wheel
	SAVE ARTIFACT dist /dist

dist:
	COPY +build/dist dist
	SAVE ARTIFACT dist /dist AS LOCAL dist

test:
	FROM python:alpine
	RUN apk add --update git
	DO +AS_USER
	DO +VENV
	RUN python3 -m pip install coverage pytest
 	ARG from=build
	ARG use_git=true
	DO +INSTALL --from "$from" --use_git="$use_git"
	COPY --dir +test-files/app/tests /app
	WORKDIR /app
	ARG test_args
 	RUN coverage run --source clk -m pytest ${test_args}
 	RUN mkdir coverage && cd coverage && coverage combine --append ../.coverage
	IF [ -e tests/.coverage ]
	   RUN cd coverage && coverage combine --append ../tests/.coverage
	END
	RUN cd coverage && coverage xml
 	RUN sed -r -i 's|filename=".+/site-packages/|filename="|g' coverage/coverage.xml
 	SAVE ARTIFACT coverage /coverage

export-coverage:
	ARG test_args
 	ARG from=source
	ARG use_git=no
	FROM +test --from="$from" --test_args="$test_args" --use_git="$use_git"
	RUN cd /app/coverage && coverage html
	SAVE ARTIFACT /app/coverage AS LOCAL coverage

clk:
	FROM python:alpine
	DO +AS_USER
	DO +VENV
 	ARG from=build
	DO +INSTALL --from "$from"
	RUN clk completion show bash >> ~/.bashrc
	RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
	ENTRYPOINT ["clk"]
	ARG ref=latest
	SAVE IMAGE clk:${ref}

check-quality:
	FROM python:slim
	RUN apt-get update && apt-get install --yes git
	RUN python3 -m pip install pre-commit
	COPY --dir +sources/app/* +side-files/app/* +test-files/app/* +git-files/app/* /app
	RUN cd /app && pre-commit run -a

sonar:
	FROM sonarsource/sonar-scanner-cli
	ARG from=build
	RUN [ "$from" == "build" ] || [ "$from" == "source" ]
	ARG use_git=true
	COPY (+test/coverage --from="$from" --use_git="$use_git") /app/coverage
	COPY --dir +sources/app/clk +git-files/app/* +side-files/app/sonar-project.properties /app/
	WORKDIR /app
	IF [ "$use_branch" == "no" ]
		# asserts the repository is clean when working in a long-liver branch
 		RUN [ "$(git status --porcelain clk | wc -l)" == "0" ]
	END
	RUN echo sonar.projectVersion=$(git tag --sort=creatordate --merged|grep '^v'|tail -1) >> /app/sonar-project.properties
	ARG use_branch=no
	IF [ "$use_branch" != "no" ]
	   RUN git checkout -B "$use_branch"
	   RUN echo sonar.branch.name="$use_branch" >> /app/sonar-project.properties
	END
	ENV SONAR_HOST_URL=https://sonarcloud.io
 	RUN --mount=type=cache,target=/opt/sonar-scanner/.sonar/cache --secret SONAR_TOKEN sonar-scanner -D sonar.python.coverage.reportPaths=/app/coverage/coverage.xml

local-sanity-check:
	ARG use_git=true
	BUILD +test --use_git="$use_git"
	BUILD +check-quality

sanity-check:
	ARG use_git=true
	BUILD +local-sanity-check --use_git="$use_git"
	ARG use_branch=no
	BUILD +sonar --use_branch="$use_branch" --use_git="$use_git"

upload:
	BUILD +sanity-check
	FROM python:alpine
	RUN apk add --update py3-twine
	COPY +build/dist /tmp/dist
	# asserts the file was generated using a tag
	RUN ls /tmp/dist/|grep -q 'clk-[0-9]\+\.[0-9]\+\.[0-9]\+'
	RUN --push --secret pypi-username --secret pypi-password twine upload --username "${pypi-username}" --password "${pypi-password}" '/tmp/dist/*'

deploy:
	BUILD +upload
