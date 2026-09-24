#!/usr/bin/env bash
# [[file:../../doc/use_cases/podcast_automation.org::run][run]]
set -eu
. ./sandboxing.sh

clk command create python podcast --group --force --description "Dealing with podcasts" --body "
@podcast.command()
@option('--number', type=int, default=10, help='How many episodes to download at once')
def download(number):
    'Downloading podcasts'
    print(f'Downloading {number} episodes')
"


tryit_code () {
      clk podcast download
}

tryit_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Downloading 10 episodes
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run tryit'

{ tryit_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/tryit"
else
    tryit_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying tryit"
        exit 1
    }
fi



makeitalias_code () {
      clk alias set podcast.dwim echo 'Would do something before' , podcast download --number 'noeval:tpl:{NUMBER_TO_DOWNLOAD}' , echo 'would do something after'
}

makeitalias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for podcast.dwim: echo 'Would do something before' , podcast download --number 'tpl:{NUMBER_TO_DOWNLOAD}' , echo 'would do something after'
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run makeitalias'

{ makeitalias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/makeitalias"
else
    makeitalias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying makeitalias"
        exit 1
    }
fi



callit_code () {
      export NUMBER_TO_DOWNLOAD=100
      clk podcast dwim
}

callit_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Would do something before
Downloading 100 episodes
would do something after
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run callit'

{ callit_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/callit"
else
    callit_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying callit"
        exit 1
    }
fi


clk command create python podcast --group --force --description "Dealing with podcasts" --body "
@podcast.command()
@option('--number', type=int, default=10, help='How many episodes to download at once')
def download(number):
    'Downloading podcasts'
    print(f'Downloading {number} episodes')

from pathlib import Path

from clk.lib import createfile, makedirs, move, tempdir


@podcast.command()
@argument('episode', help='The episode to download')
def get(episode):
    'Download an episode'
    collection = Path('music')
    with tempdir() as workspace:
        downloading = Path(workspace) / episode
        createfile(downloading, 'some audio\n')
        makedirs(collection)
        move(downloading, collection / episode)
    createfile(collection / 'fetched.txt', f'{episode}\n', append=True)
"


get_episodes_code () {
      clk podcast get episode-1.mp3
      clk podcast get episode-2.mp3
      ls music
      cat music/fetched.txt
}

get_episodes_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
episode-1.mp3
episode-2.mp3
fetched.txt
episode-1.mp3
episode-2.mp3
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run get_episodes'

{ get_episodes_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/get_episodes"
else
    get_episodes_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying get_episodes"
        exit 1
    }
fi


clk command create python podcast --group --force --description "Dealing with podcasts" --body "
@group()
@option('--directory', '-d', multiple=True, help='Only work with these directories')
def podcast(directory):
    'Dealing with podcasts'
    if directory:
        print(f'Filtering to directories: {', '.join(directory)}')

@podcast.command()
@option('--number', type=int, default=10, help='How many episodes to download at once')
def download(number):
    'Downloading podcasts'
    print(f'Downloading {number} episodes')
"


download_filtered_code () {
      clk podcast --directory music download
}

download_filtered_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Filtering to directories: music
Downloading 10 episodes
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run download_filtered'

{ download_filtered_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/download_filtered"
else
    download_filtered_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying download_filtered"
        exit 1
    }
fi



music_alias_code () {
      clk alias set podcast.music podcast --directory music download
}

music_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for podcast.music: podcast --directory music download
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run music_alias'

{ music_alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/music_alias"
else
    music_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying music_alias"
        exit 1
    }
fi



use_music_alias_code () {
      clk podcast music
}

use_music_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Filtering to directories: music
Downloading 10 episodes
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run use_music_alias'

{ use_music_alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/use_music_alias"
else
    use_music_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying use_music_alias"
        exit 1
    }
fi



audio_alias_code () {
      clk alias set podcast.audio podcast --directory music --directory song download
}

audio_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for podcast.audio: podcast --directory music --directory song download
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run audio_alias'

{ audio_alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/audio_alias"
else
    audio_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying audio_alias"
        exit 1
    }
fi



use_audio_alias_code () {
      clk podcast audio
}

use_audio_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Filtering to directories: music, song
Downloading 10 episodes
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run use_audio_alias'

{ use_audio_alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/use_audio_alias"
else
    use_audio_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying use_audio_alias"
        exit 1
    }
fi



group_help_with_alias_code () {
      clk podcast --help
}

group_help_with_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk podcast [OPTIONS] COMMAND [ARGS]...

  Dealing with podcasts

  Edit this custom command by running `clk command edit podcast`
  Or edit ./clk-root/python/podcast.py directly.

Options:
  -d, --directory TEXT  Only work with these directories
  --help-all            Show the full help message, automatic options included.
  --help                Show this message and exit.

Commands:
  audio     Alias for: podcast --directory music --directory son...
  download  Downloading podcasts
  dwim      Alias for: echo 'Would do something before' , podcas...
  music     Alias for: podcast --directory music download

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run group_help_with_alias'

{ group_help_with_alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/group_help_with_alias"
else
    group_help_with_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying group_help_with_alias"
        exit 1
    }
fi


mkdir -p lib
cat<<'EOF' > lib/podcastlib.py
from clk.types import Suggestion

STATES = ["todo", "to-process", "next", "ready", "done"]

stateType = Suggestion(STATES)
EOF
export PYTHONPATH="$(pwd)/lib"

clk command create bash podcast.extract-audio
cat <<"EOH" > "$(clk command which podcast.extract-audio)"
#!/usr/bin/env bash
set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Extract the audio of the episodes in that state
--
O:--state:podcastlib.stateType:The state of the episodes to extract the audio of:{"default": "to-process"}
EOF
}

clk_help_handler "$@"

echo "extracting the audio of the episodes in state $(clk_value state)"
EOH


run_extract_audio_code () {
      clk podcast extract-audio
}

run_extract_audio_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
extracting the audio of the episodes in state to-process
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run_extract_audio'

{ run_extract_audio_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run_extract_audio"
else
    run_extract_audio_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run_extract_audio"
        exit 1
    }
fi



state_completion_code () {
      clk completion try --remove-bash-formatting --last podcast extract-audio --state ""
}

state_completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
todo
to-process
next
ready
done
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run state_completion'

{ state_completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/state_completion"
else
    state_completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying state_completion"
        exit 1
    }
fi


sed -i 's/"done"]/"done", "to-digest"]/' lib/podcastlib.py


state_completion_after_code () {
      clk completion try --remove-bash-formatting --last podcast extract-audio --state ""
}

state_completion_after_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
todo
to-process
next
ready
done
to-digest
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run state_completion_after'

{ state_completion_after_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/state_completion_after"
else
    state_completion_after_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying state_completion_after"
        exit 1
    }
fi
# run ends here
