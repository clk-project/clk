#!/bin/bash -eu
# [[id:e6078fc8-4b12-44ad-b008-20f0b7311069::+BEGIN_SRC bash :exports none :tangle ../../tests/use_cases/bash_command_from_alias.sh :noweb yes :shebang "#!/bin/bash -eu"][No heading:13]]
. ./sandboxing.sh
cat <<"EOF" > "${TMP}/bin/mpc"
#!/bin/bash
echo "Running mpc with: $*"
EOF
chmod +x "${TMP}/bin/mpc"

create_code () {
      clk alias set music.play exec -- mpc play --random --use-speakers --replaygain
}

create_expected () {
      cat<<"EOEXPECTED"
New global alias for music.play: exec mpc play --random --use-speakers --replaygain
EOEXPECTED
}

echo 'Run create'

{ create_code || true ; } > "${TMP}/code.txt" 2>&1
create_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying create"
exit 1
}


use_play_code () {
      clk music play MyAlbum
}

use_play_expected () {
      cat<<"EOEXPECTED"
Running mpc with: play --random --use-speakers --replaygain MyAlbum
EOEXPECTED
}

echo 'Run use_play'

{ use_play_code || true ; } > "${TMP}/code.txt" 2>&1
use_play_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_play"
exit 1
}


use_parameters_code () {
      clk music play --repeat --set-parameter global
      clk music play MyAlbum
}

use_parameters_expected () {
      cat<<"EOEXPECTED"
New global parameters for music.play: --repeat
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
}

echo 'Run use_parameters'

{ use_parameters_code || true ; } > "${TMP}/code.txt" 2>&1
use_parameters_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying use_parameters"
exit 1
}


more_complicated_alias_code () {
      clk alias set music.play exec mpc start-server , exec -- mpc play --random --use-speakers --replaygain
      clk music play MyAlbum
}

more_complicated_alias_expected () {
      cat<<"EOEXPECTED"
Removing global alias of music.play: exec mpc play --random --use-speakers --replaygain
New global alias for music.play: exec mpc start-server , exec mpc play --random --use-speakers --replaygain
Running mpc with: start-server
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
}

echo 'Run more_complicated_alias'

{ more_complicated_alias_code || true ; } > "${TMP}/code.txt" 2>&1
more_complicated_alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying more_complicated_alias"
exit 1
}


show-alias_code () {
      clk alias show music.play
}

show-alias_expected () {
      cat<<"EOEXPECTED"
music.play exec mpc start-server, exec mpc play --random --use-speakers --replaygain
EOEXPECTED
}

echo 'Run show-alias'

{ show-alias_code || true ; } > "${TMP}/code.txt" 2>&1
show-alias_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying show-alias"
exit 1
}


bootstrap_code () {
      clk command create bash --replace-alias music.play
}

bootstrap_expected () {
      cat<<"EOEXPECTED"
Erasing music.play alias from global settings
EOEXPECTED
}

echo 'Run bootstrap'

{ bootstrap_code || true ; } > "${TMP}/code.txt" 2>&1
bootstrap_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying bootstrap"
exit 1
}


try_command_code () {
      clk music play MyAlbum
}

try_command_expected () {
      cat<<"EOEXPECTED"
Running mpc with: start-server
Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum
EOEXPECTED
}

echo 'Run try_command'

{ try_command_code || true ; } > "${TMP}/code.txt" 2>&1
try_command_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying try_command"
exit 1
}


which_code () {
      clk command which music.play|sed "s|$(pwd)|.|"
}

which_expected () {
      cat<<"EOEXPECTED"
./clk-root/bin/music.play
EOEXPECTED
}

echo 'Run which'

{ which_code || true ; } > "${TMP}/code.txt" 2>&1
which_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying which"
exit 1
}


help_code () {
      clk music play --help|sed "s|$(pwd)|.|"|head -10
}

help_expected () {
      cat<<"EOEXPECTED"
Usage: clk music play [OPTIONS] [ARGS]...

  Description Converted from the alias music.play

  The current parameters set for this command are: --repeat

  Edit this command by running `clk command edit music.play`
  Or edit ./clk-root/bin/music.play directly.

Arguments:

EOEXPECTED
}

echo 'Run help'

{ help_code || true ; } > "${TMP}/code.txt" 2>&1
help_expected > "${TMP}/expected.txt" 2>&1
diff -uBw "${TMP}/code.txt" "${TMP}/expected.txt" || {
echo "Something went wrong when trying help"
exit 1
}
# No heading:13 ends here
