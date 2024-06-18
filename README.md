# Librivox Local Dev with Docker

## Building

First, make sure you've cloned the librivox-ansible submodule:


```bash
cd librivox-ansible
git submodule init
git submodule update
cd ..
```

Now, back in the parent directory, you should be able to build the docker image:

```bash
docker build -t librivox-local .
```

(This step will take a while depending on your network speed and the speed of
your local mirrors, but you only have to do it when there are breaking changes,
which seems to be very infrequent.)

## Running

There's some first-time setup that's required to get the librivox-catalog code
out of the docker image and somewhere accessible:

```bash
./first-time-setup.sh
```

You should now have a `./librivox-catalog` directory that has all of the
librivox-catalog code in it, including the git repo, and this is where you
should point your IDE. From now on, you can start the server up any time like
this:

```bash
docker run --rm -it -v "$(pwd)"/librivox-catalog:/librivox/www/librivox.org/catalog librivox-local
```

That will drop you into a bash shell _inside_ the container, which is mostly
useful for debugging.

NOTE: This will give you a new container every time with a fresh copy of the
database. If you're precious about any custom data or config you've set up, then
remove the `--rm` flag and `docker start`/`docker stop` the container as usual.

## Accessing the Site

Make sure your `/etc/hosts` file contains the following:

```
172.17.0.2        librivox.org
172.17.0.2    dev.librivox.org
172.17.0.2  forum.librivox.org
172.17.0.2   wiki.librivox.org
172.17.0.2    www.librivox.org
```

Then, you can open up the site here: https://librivox.org/search

When we build the image, we make a new HTTPS certificate to use, so your browser
should show you a big warning that the site isn't safe. You can just accept the
risk and continue.

## Caveats

The site is running inside the container, so you don't actually have PHP or the
database or anything set up on your main OS. This means that there are some
operations that are best performed from inside the container:

 - Running the tests
 - Connecting to the database

## Appendix: What's with the freaky first-time setup?

The Ansible playbooks provision everything into this directory:
`/librivox/www/librivox.org/catalog`, including some additional config files
that are not checked into the `librivox-catalog` repository. Without those
config files, nothing will run.

To work around this, what we do is:

1. Back up the catalog files to `/librivox/www/librivox.org/catalog.bak`.
2. Start the container with `./librivox-catalog` mounted over the top of
   `/librivox/www/librivox.org/catalog`. At this point, that directory will be
   empty.
3. Inside the container, we copy everything from `catalog.bak` to `catalog`,
   which brings the whole git repo and all of the config files we need. At this
   point, you'll have a heap of stuff in `./librivox-catalog` on the host, but
   since the files were created by the container, it'll all belong to the root
   user.
4. On the host, we change the ownership of the directory to be the current user
   instead of root, which is generally what you want.
