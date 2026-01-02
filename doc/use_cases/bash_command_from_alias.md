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

As aliases grow, you may need to take a look at what it does to avoid getting lost.

You can call the alias command to do so.

```bash
clk alias show music.play
```

    music.play exec mpc start-server, exec mpc play --random --use-speakers --replaygain

Note that showing the help of the command also gives that information.

```bash
clk music play --help|head -10
```

```
Usage: clk music play [OPTIONS] [COMMAND]...

  Alias for: exec mpc start-server , exec mpc play --random --use-speakers --replaygain

  The current parameters set for this command are: --repeat

  Edit this alias by running `clk alias edit music.play`

Arguments:
  COMMAND  The command to execute
```

Even doing so, you may at some point want more control about what you are doing, like waiting for the music server to be ready, you will have to fall back in a real command. Replacing this alias with a shell command is straightforward:

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

Now, we can change its content to do whatever complicated flow we like.

You can simply run `clk command edit music.play` and it will be open in the editor mentioned in the `EDITOR` environment variable.

If instead, you want to get the path of the command to open it yourself, you can simply ask for it.

```bash
clk command which music.play
```

    ./clk-root/bin/music.play

Note that it is also shown in the help of the command.

```bash
clk music play --help|head -10
```

```
Usage: clk music play [OPTIONS] [ARGS]...

  Description Converted from the alias music.play

  The current parameters set for this command are: --repeat

  Edit this external command by running `clk command edit music.play`
  Or edit ./clk-root/bin/music.play directly.

Arguments:
```
