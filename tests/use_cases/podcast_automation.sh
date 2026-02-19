#!/bin/bash -eu
# [[file:../../doc/use_cases/podcast_automation.org::run][run]]
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
      cat<<"EOEXPECTED"
Downloading 10 episodes
EOEXPECTED
}

echo 'Run tryit'

{ tryit_code || true ; } > "${TMP}/code.txt" 2>&1
tryit_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying tryit"
exit 1
}



makeitalias_code () {
      clk alias set podcast.dwim echo 'Would do something before' , podcast download --number 'noeval:tpl:{NUMBER_TO_DOWNLOAD}' , echo 'would do something after'
}

makeitalias_expected () {
      cat<<"EOEXPECTED"
New global alias for podcast.dwim: echo 'Would do something before' , podcast download --number 'tpl:{NUMBER_TO_DOWNLOAD}' , echo 'would do something after'
EOEXPECTED
}

echo 'Run makeitalias'

{ makeitalias_code || true ; } > "${TMP}/code.txt" 2>&1
makeitalias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying makeitalias"
exit 1
}



callit_code () {
      export NUMBER_TO_DOWNLOAD=100
      clk podcast dwim
}

callit_expected () {
      cat<<"EOEXPECTED"
Would do something before
Downloading 100 episodes
would do something after
EOEXPECTED
}

echo 'Run callit'

{ callit_code || true ; } > "${TMP}/code.txt" 2>&1
callit_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying callit"
exit 1
}


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
      cat<<"EOEXPECTED"
Filtering to directories: music
Downloading 10 episodes
EOEXPECTED
}

echo 'Run download_filtered'

{ download_filtered_code || true ; } > "${TMP}/code.txt" 2>&1
download_filtered_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying download_filtered"
exit 1
}



music_alias_code () {
      clk alias set podcast.music podcast --directory music download
}

music_alias_expected () {
      cat<<"EOEXPECTED"
New global alias for podcast.music: podcast --directory music download
EOEXPECTED
}

echo 'Run music_alias'

{ music_alias_code || true ; } > "${TMP}/code.txt" 2>&1
music_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying music_alias"
exit 1
}



use_music_alias_code () {
      clk podcast music
}

use_music_alias_expected () {
      cat<<"EOEXPECTED"
Filtering to directories: music
Downloading 10 episodes
EOEXPECTED
}

echo 'Run use_music_alias'

{ use_music_alias_code || true ; } > "${TMP}/code.txt" 2>&1
use_music_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_music_alias"
exit 1
}



audio_alias_code () {
      clk alias set podcast.audio podcast --directory music --directory song download
}

audio_alias_expected () {
      cat<<"EOEXPECTED"
New global alias for podcast.audio: podcast --directory music --directory song download
EOEXPECTED
}

echo 'Run audio_alias'

{ audio_alias_code || true ; } > "${TMP}/code.txt" 2>&1
audio_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying audio_alias"
exit 1
}



use_audio_alias_code () {
      clk podcast audio
}

use_audio_alias_expected () {
      cat<<"EOEXPECTED"
Filtering to directories: music, song
Downloading 10 episodes
EOEXPECTED
}

echo 'Run use_audio_alias'

{ use_audio_alias_code || true ; } > "${TMP}/code.txt" 2>&1
use_audio_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_audio_alias"
exit 1
}



group_help_with_alias_code () {
      clk podcast --help
}

group_help_with_alias_expected () {
      cat<<"EOEXPECTED"
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
}

echo 'Run group_help_with_alias'

{ group_help_with_alias_code || true ; } > "${TMP}/code.txt" 2>&1
group_help_with_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying group_help_with_alias"
exit 1
}
# run ends here
