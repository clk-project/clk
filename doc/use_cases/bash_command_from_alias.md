For a more general introduction to creating bash commands, see [here](bash_command.md).

Let's imagine you want to use clk to control your musicplayer. Chances are there already exists some command line tool to do so and that you want to wrap it into clk to take advantages of aliases, parameters and flows.

On that case, you most likely will want to create a simple alias on top of exec.

For the sake of this example, let's use this fake music control program and call it 'mpc'.

```bash
echo "Running mpc with: $*"
```

Then, to use this program as a clk command, we could simply create an alias like this.

```bash
clk alias set music.play exec -- mpc play --random --use-speakers --replaygain
```

    New global alias for music.play: exec mpc play --random --use-speakers --replaygain

Then, we can simple call this command.

```bash
clk music play MyAlbum
```

    Running mpc with: play --random --use-speakers --replaygain MyAlbum

We get the benefit of parameters, flow etc.

```bash
clk music play --repeat --set-parameter global
clk music play MyAlbum
```

    New global parameters for music.play: --repeat
    Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum

Chances are that, after some time, we realize that this command should be a little more complicated than wrapping a single executable. For instance, we could want to start some music server, then play some music.

We could do this with a more complicated alias.

```bash
clk alias set music.play exec mpc start-server , exec -- mpc play --random --use-speakers --replaygain
clk music play MyAlbum
```

    Removing global alias of music.play: exec mpc play --random --use-speakers --replaygain
    New global alias for music.play: exec mpc start-server , exec mpc play --random --use-speakers --replaygain
    Running mpc with: start-server
    Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum

But in case you want more control about what you are doing, like waiting for the music server to be ready, you will have to fall back in a real command. In case you just need to bootstrap a shell command out of the alias, here is how you do this.

```bash
clk command create bash --replace-alias music.play
```

    Erasing music.play alias from global settings

This command tries hard to have the same behavior as its original alias.

```bash
clk music play MyAlbum
```

    Running mpc with: start-server
    Running mpc with: play --random --use-speakers --replaygain --repeat MyAlbum

Now, we fan change its content to do whatever we want, like waiting for the music server to be ready, trying to switch on the speakers and falling back to some other ones etc.