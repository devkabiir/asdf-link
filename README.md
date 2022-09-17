# asdf-link
Generic plugin for versioning system tools with [asdf](https://github.com/asdf-vm/asdf).

## About

This is a plugin for tools that have *No* ASDF installer (maybe because the package
is hosted at a private location, or perhaps things that you already installed with
a vendor package manager, eg `brew` on OSX which supports many installed versions).

Or maybe things that can only be installed with some GUI interaction and for which 
creating an asdf installer would be a bit complicated, eg Android tools, AWS or Google Cloud tools.

For example, many systems already come with `perl` installed (two versions on my system).
Or on OSX where you can install the java tools via many methods, like the official package 
from [java.com](http://java.com), or by using other methods like `brew`, `macports`,
or sdk managers like [sdkman](http://sdkman.io/usage.html) or [jabba](https://github.com/shyiko/jabba),
there are lots of ways to get things installed on your system, and ASDF wont ever replace
them all.

In these cases you might still want to use the convenient ASDF `.tool-versions` file to
enable the right tool per project or system wide, so that you just cd into the
working directory of your like and let asdf select the right executable for you.

## Installation
```shell
asdf plugin add link https://github.com/devkabiir/asdf-link
```

## Usage
The usage is quite simple, you have to run:
```shell
asdf link <tool-name> <version-name> <...shim-paths>
```
where
- `tool-name` is the name you want to use in asdf, it shall be unique and not
  conflicting with other asdf plugins.
- `version-name` the first version you want to be made available in asdf.
  Defaults to `latest`
- `shim-paths` space separated directory paths where binaries can be found for
  the tool, asdf will create shims for such binaries.
  Defaults to `$PWD`

You can run the same command multiple times as well, as it's idempotent in
nature. The result will be as expected.  
This is particularly handy when building/developing a tool locally and you want
to link it with asdf.

## Example
Suppose you want to build and install [zls](https://github.com/zigtools/zls) for
your M1 Mac and the binaries are not available.
```shell
# Clone
git clone https://github.com/zigtools/zls
cd zls

# We need master version of zig to build zls
asdf local zig master
# Build
zig build -Drelease-safe

# The output binary will be ./zig-out/bin/zls
# We only need to provide the parent directory.
asdf link zls master ./zig-out/bin
```

That's it! you now have a local master build of zls installed in asdf.  
Using your new tool is the same as any other asdf plugin.
```shell
# For global installs
asdf global zls master

# For local installs
asdf local zls master

# Check version
zls --version # 0.10.0-dev.238+0428b97
```

When you want to update `zls`, build it again and if the binaries dont have
different paths or names you dont have to do anything. If the binary names/paths
change you can run the command to link again 
```shell
asdf link zls master ./zig-out/bin ./other-path/bin
```

## Custom Install

The first thing you have to do is to think of a good name. That is the name of the
tool you will be selecting versions for. Say `jdk`, `perl`, `android`, etc.

```shell
## READ above before copy-paste this line
# You can execute this as many times as you want with different names
$ asdf plugin-add NAME https://github.com/devkabiir/asdf-link
```

This can be anything, from now on, these examples will be for `jdk`.

```shell
$ asdf plugin-add jdk https://github.com/devkabiir/asdf-link
```

Now if you execute `asdf list-all jdk` you will notice it will only say `link`.
That is because we cannot possibly know which versions are available. And actually,
this plugin will *let you install ANY version* you give to it. So it's up to you
to use a meaningful version. 

In my case, I have the following jdks `1.8` which I downloaded from the java
website and `1.9` which was installed with `brew install Caskroom/versions/java9-beta`

```shell
$ ls /Library/Java/JavaVirtualMachines/
jdk1.8.0_111.jdk jdk-9.jdk
```

To use them, lets tell ASDF about their existance with:

```shell
$ asdf install jdk 1.9
Link your system binaries to /Users/devkabiir/.asdf/installs/jdk/1.9/bin
```

As previously mentioned, this plugin lets you install *any* version,
actually it just creates a `bin/` directory for you. The idea is that
we link (hence the plugin name) our versioned binaries into that `bin/` directory directory.

```shell
# linking all the java tools into the 1.9 versioned bin/
$ ln -vs /Library/Java/JavaVirtualMachines/jdk-9.jdk/Contents/Home/bin/* /Users/devkabiir/.asdf/installs/jdk/1.9/bin/

# after this, just reshim
$ asdf reshim jdk
```

And we are done, you can create a `.tool-versions` in the current directory
by using `asdf local jdk 1.9`. See the [asdf](https://github.com/asdf-vm/asdf)
documentaion for more on managing versions.


The advantage of using this plugin is that even if you have *lots* of binaries on `/usr/local/bin`,
by hand-picking and linking them inside the plugin's `bin/` directory, you get shims for free. The
following is the [travis test](https://github.com/devkabiir/asdf-link/blob/master/.travis.yml) we use, linking perl.

```shell
# perla is spanish for perl
$ asdf plugin-add perla https://github.com/devkabiir/asdf-link
$ asdf install perla 5.18
$ ln -s /usr/bin/perl5.18 ~/.asdf/installs/perla/5.18/bin/perla
$ asdf reshim
$ asdf local perla 5.18
$ perla -v
```
