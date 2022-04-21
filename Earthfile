IMPORT github.com/Konubinix/Earthfile AS e

AS_USER:
    COMMAND
    RUN apk add --update bash curl
    RUN curl -sfL https://direnv.net/install.sh | bash
    DO e+USE_USER
    RUN echo 'source <(direnv hook bash)' >> "${HOME}/.bashrc"

requirements:
    FROM python:3.8-alpine
    RUN python3 -m pip install pip-tools
    DO e+USE_USER
    COPY --dir fasterentrypoint.py versioneer.py setup.cfg setup.py /app
    WORKDIR /app
    RUN --no-cache pip-compile
    SAVE ARTIFACT requirements.txt AS LOCAL requirements.txt

DEPENDENCIES:
    COMMAND
    # whether we use the requirements from the source code
    ARG build_requirements=no
    IF [ "${build_requirements}" == "no" ]
        COPY requirements.txt /app/
    ELSE
        # get a newly generated requirements
        COPY +requirements/requirements.txt /app/requirements.txt
    END
    RUN python3 -m pip install -r /app/requirements.txt

side-files:
    FROM scratch
    COPY --dir .flake8 .pre-commit-config.yaml .isort.cfg .style.yapf LICENSE pycln.toml tox.ini sonar-project.properties /app
    SAVE ARTIFACT /app /app

test-files:
    FROM scratch
    COPY --dir tests /app/
    SAVE ARTIFACT /app /app

git-files:
    FROM scratch
    COPY --dir ./.git .gitignore .gitmodules /app
    SAVE ARTIFACT /app /app

sources:
    FROM scratch
    COPY --dir pyproject.toml MANIFEST.in setup.py fasterentrypoint.py setup.cfg versioneer.py ./clk /app/
    SAVE ARTIFACT /app /app

INSTALL:
    COMMAND
    ARG from=build
    ARG build_requirements=no
    IF [ "${from}" == "source" ]
        DO +DEPENDENCIES --build_requirements="${build_requirements}"
        COPY --dir +sources/app/* /app
        RUN cd /app && python3 -m pip install --editable .
    ELSE IF [ "${from}" == "build" ]
        DO +DEPENDENCIES --build_requirements="${build_requirements}"
        ARG use_git=true
        COPY (+build/dist --use_git="$use_git") /dist
        RUN python3 -m pip install /dist/*
    ELSE IF [ "${from}" == "pypi" ]
         RUN --no-cache python3 -m pip install clk
    ELSE
        # assume it is the url to install from
        RUN python3 -m pip install "${from}"
    END
    RUN clk completion --case-insensitive install bash && echo 'source "${HOME}/.bash_completion"' >> "${HOME}/.bashrc"

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
    FROM scratch
    COPY +build/dist dist
    SAVE ARTIFACT dist /dist AS LOCAL dist

test:
    FROM python:alpine
    RUN apk add --update git
    DO +AS_USER
    DO +VENV
    RUN python3 -m pip install coverage pytest
    ARG from=source
    ARG use_git=no
    ARG build_requirements=no
    DO +INSTALL --from "$from" --use_git="$use_git" --build_requirements="${build_requirements}"
    COPY --dir +test-files/app/tests /app
    WORKDIR /app
    ARG test_args
    ENV CLK_ALLOW_INTRUSIVE_TEST=True
    RUN coverage run --source clk -m pytest ${test_args}
    RUN mkdir coverage && cd coverage && coverage combine --append ../.coverage
    IF [ -e tests/.coverage ]
        RUN cd coverage && coverage combine --append ../tests/.coverage
    END
    RUN cd coverage && coverage xml
        RUN sed -r -i 's|filename=".+/site-packages/|filename="|g' coverage/coverage.xml
    RUN mkdir output && mv coverage output
    IF [ "${from}" == "build" ]
        RUN mkdir output/dist && mv /dist/* output/dist/
    END
        SAVE ARTIFACT output /output

export-coverage:
    FROM scratch
    ARG test_args
    ARG from=source
    ARG use_git=no
    FROM +test --from="$from" --test_args="$test_args" --use_git="$use_git"
    RUN cd /app/output/coverage && coverage html
    SAVE ARTIFACT /app/output/coverage AS LOCAL coverage

docker:
    FROM python:alpine
    RUN apk add --update git
    DO +AS_USER
    DO +VENV
    ARG from=build
    DO +INSTALL --from "$from"
    RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
    ENTRYPOINT ["bash"]
    ARG ref=latest
    SAVE IMAGE clk:${ref}

pre-commit-base:
    FROM python:slim
    RUN apt-get update && apt-get install --yes git
    DO e+USE_USER
    RUN python3 -m pip install pre-commit
    WORKDIR /app

export-pre-commit-update:
    FROM +pre-commit-base
    RUN git init
    COPY --dir .pre-commit-config.yaml .
    RUN --no-cache pre-commit autoupdate
    SAVE ARTIFACT .pre-commit-config.yaml AS LOCAL .pre-commit-config.yaml

pre-commit-cache:
    FROM +pre-commit-base
    RUN git init
    COPY --dir .pre-commit-config.yaml .
    RUN pre-commit run -a
    SAVE ARTIFACT ${HOME}/.cache/pre-commit cache

check-quality:
    FROM +pre-commit-base
    COPY --dir .pre-commit-config.yaml .
    COPY +pre-commit-cache/cache $HOME/.cache/pre-commit
    COPY --dir +git-files/app/* +sources/app/* +side-files/app/* +test-files/app/* .
    RUN pre-commit run -a

sonar:
    FROM sonarsource/sonar-scanner-cli
    ARG from=build
    RUN [ "$from" == "build" ] || [ "$from" == "source" ]
    ARG use_git=true
    ARG build_requirements=no
    COPY (+test/output --from="$from" --use_git="$use_git" --build_requirements="${build_requirements}") /app/output
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
    RUN --mount=type=cache,target=/opt/sonar-scanner/.sonar/cache --secret SONAR_TOKEN sonar-scanner -D sonar.python.coverage.reportPaths=/app/output/coverage/coverage.xml
    SAVE ARTIFACT output

local-sanity-check:
    FROM scratch
    BUILD +check-quality
    ARG use_git=no
    ARG from=source
    ARG build_requirements=no
    COPY (+test/output --use_git="$use_git" --from="$from" --build_requirements="${build_requirements}") output
    SAVE ARTIFACT output

sanity-check:
    FROM scratch
    BUILD +check-quality
    ARG use_git=true
    ARG use_branch=no
    ARG build_requirements=no
    COPY (+sonar/output --use_branch="${use_branch}" --use_git="${use_git}" --build_requirements="${build_requirements}") output
    SAVE ARTIFACT output

upload:
    COPY +sanity-check/output output
    FROM python:alpine
    RUN apk add --update py3-twine
    # asserts the file was generated using a tag
    RUN ls output/dist/|grep -q 'clk-[0-9]\+\.[0-9]\+\.[0-9]\+'
    RUN --push --secret pypi-username --secret pypi-password twine upload --username "${pypi-username}" --password "${pypi-password}" 'output/dist/*'

deploy:
    FROM scratch
    BUILD +upload
