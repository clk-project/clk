#!/bin/bash -eu
# [[file:bash_command_from_alias.org::+BEGIN_SRC bash :exports none :tangle bash_command_from_alias.sh :noweb yes :shebang "#!/bin/bash -eu"][No heading:10]]
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

diff -uBw <(create_code 2>&1) <(create_expected) || {
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

diff -uBw <(use_play_code 2>&1) <(use_play_expected) || {
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

diff -uBw <(use_parameters_code 2>&1) <(use_parameters_expected) || {
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

diff -uBw <(more_complicated_alias_code 2>&1) <(more_complicated_alias_expected) || {
echo "Something went wrong when trying more_complicated_alias"
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

diff -uBw <(bootstrap_code 2>&1) <(bootstrap_expected) || {
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

diff -uBw <(try_command_code 2>&1) <(try_command_expected) || {
echo "Something went wrong when trying try_command"
exit 1
}
# No heading:10 ends here
