#!/usr/bin/env bash
# [[file:../../doc/use_cases/tests/use_cases/bash_command_from_alias.sh :noweb yes :shebang "#!/usr/bin/env bash"][No heading:27]]
set -eu
. ./sandboxing.sh
mkdir -p "${TMP}/bin"
export PATH="${TMP}/bin:${PATH}"
cat <<"EOF" > "${TMP}/bin/mpc"
#!/usr/bin/env bash
echo "Running mpc with: $*"
EOF
chmod +x "${TMP}/bin/mpc"

create_code () {
      clk alias set music.play exec -- mpc play --random --use-speakers --replaygain
}

create_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for music.play: exec mpc play --random --use-speakers --replaygain
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run create'

{ create_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/create"
else
    create_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying create"
        exit 1
    }
fi


use_play_code () {
      clk music play MyAlbum
}

use_play_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running mpc with: play --random --use-speakers --replaygain MyAlbum
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run use_play'

{ use_play_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/use_play"
else
    use_play_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying use_play"
        exit 1
    }
fi


use_parameters_code () {
      clk music play --repeat --set-parameter global
      clk music play MyAlbum
}

use_parameters_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global parameters for music.play: --repeat
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run use_parameters'

{ use_parameters_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/use_parameters"
else
    use_parameters_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying use_parameters"
        exit 1
    }
fi


try-completion_code () {
      clk completion try --last -- music play --set-parameter g
}

try-completion_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
global
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try-completion'

{ try-completion_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try-completion"
else
    try-completion_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try-completion"
        exit 1
    }
fi


more_complicated_alias_code () {
      clk alias set music.play exec mpc start-server , exec -- mpc play --random --use-speakers --replaygain
      clk music play MyAlbum
}

more_complicated_alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Removing global alias of music.play: exec mpc play --random --use-speakers --replaygain
New global alias for music.play: exec mpc start-server , exec mpc play --random --use-speakers --replaygain
Running mpc with: start-server
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run more_complicated_alias'

{ more_complicated_alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/more_complicated_alias"
else
    more_complicated_alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying more_complicated_alias"
        exit 1
    }
fi


show-alias_code () {
      clk alias show music.play
}

show-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
music.play exec mpc start-server, exec mpc play --random --use-speakers --replaygain
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run show-alias'

{ show-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/show-alias"
else
    show-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying show-alias"
        exit 1
    }
fi


help-alias_code () {
      clk music play --help|head -10
}

help-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk music play [OPTIONS] [COMMAND]...

  Alias for: exec mpc start-server , exec mpc play --random --use-speakers --replaygain

  The current parameters set for this command are: --repeat

  Edit this alias by running `clk alias edit music.play`
  Or adjust this command `clk alias set music.play exec mpc start-server , exec mpc play --random --use-speakers
  --replaygain`
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run help-alias'

{ help-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/help-alias"
else
    help-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying help-alias"
        exit 1
    }
fi


editor_writes <<'EOF'
exec mpc start-server
exec mpc wait-for-server
exec mpc play --random --use-speakers --replaygain
EOF

clk alias edit music.play


run-edited-alias_code () {
      clk music play MyAlbum
}

run-edited-alias_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running mpc with: start-server
Running mpc with: wait-for-server
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run run-edited-alias'

{ run-edited-alias_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/run-edited-alias"
else
    run-edited-alias_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying run-edited-alias"
        exit 1
    }
fi


bootstrap_code () {
      clk command create bash --replace-alias music.play
}

bootstrap_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing music.play alias from global settings
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run bootstrap'

{ bootstrap_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/bootstrap"
else
    bootstrap_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying bootstrap"
        exit 1
    }
fi


try_command_code () {
      clk music play MyAlbum
}

try_command_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running mpc with: start-server
Running mpc with: wait-for-server
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run try_command'

{ try_command_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/try_command"
else
    try_command_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying try_command"
        exit 1
    }
fi


which_code () {
      clk command which music.play
}

which_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
./clk-root/bin/music.play
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run which'

{ which_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/which"
else
    which_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying which"
        exit 1
    }
fi


help_code () {
      clk music play --help|head -10
}

help_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Usage: clk music play [OPTIONS] [ARGS]...

  Description Converted from the alias music.play

  The current parameters set for this command are: --repeat

  Edit this external command by running `clk command edit music.play`
  Or edit ./clk-root/bin/music.play directly.

Positional arguments:

EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/help"
else
    help_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying help"
        exit 1
    }
fi


cat<<"EOH" > "$(clk command which music.play)"
#!/usr/bin/env bash
  set -eu

source "_clk.sh"

clk_usage () {
    cat<<EOF
$0

Play an album
--
A:album:str:The album to play
F:--repeat:Keep playing it
EOF
}

clk_help_handler "$@"

args=()
if clk_true repeat
then
    args+=(--repeat)
fi
clk exec mpc start-server
clk exec mpc wait-for-server
clk exec mpc play --random --use-speakers --replaygain "${args[@]}" "$(clk_value album)"

EOH


play-an-album_code () {
      clk music play Kind-of-Blue
}

play-an-album_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Running mpc with: start-server
Running mpc with: wait-for-server
Running mpc with: play --random --use-speakers --replaygain --repeat Kind-of-Blue
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run play-an-album'

{ play-an-album_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/play-an-album"
else
    play-an-album_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying play-an-album"
        exit 1
    }
fi



music-loud_code () {
      clk alias set music.loud exec mpc volume 100 , music play
      clk music loud Kind-of-Blue
}

music-loud_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
New global alias for music.loud: exec mpc volume 100 , music play
Running mpc with: volume 100
Running mpc with: start-server
Running mpc with: wait-for-server
Running mpc with: play --random --use-speakers --replaygain --repeat Kind-of-Blue
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run music-loud'

{ music-loud_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/music-loud"
else
    music-loud_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying music-loud"
        exit 1
    }
fi



convert-music-loud_code () {
      clk command create bash --replace-alias music.loud
      clk music loud Bitches-Brew
}

convert-music-loud_expected () {
      local expected
      expected="$(cat<<"EOEXPECTED"
Erasing music.loud alias from global settings
Running mpc with: volume 100
Running mpc with: start-server
Running mpc with: wait-for-server
Running mpc with: play --random --use-speakers --replaygain --repeat Bitches-Brew
EOEXPECTED
)"
      # org says nil where the block said nothing
      test "${expected}" = nil || echo "${expected}"
}

echo 'Run convert-music-loud'

{ convert-music-loud_code || true ; } > "${TMP}/code.txt" 2>&1
if [ -n "${CLK_RECORD_RESULTS-}" ]
then
    cp "${TMP}/code.txt" "${CLK_RECORD_RESULTS}/convert-music-loud"
else
    convert-music-loud_expected > "${TMP}/expected.txt" 2>&1
    diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
        echo "Something went wrong when trying convert-music-loud"
        exit 1
    }
fi
# No heading:27 ends here
