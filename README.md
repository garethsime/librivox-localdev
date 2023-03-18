# Librivox Local Dev with Docker

## Building

Make sure you've definitely cloned the librivox-ansible submodule. You'll
also need to apply the patch in `librivox-ansible.patch` to it. (Yeah, messy,
I know.)

You should be able to just run docker build now:

```bash
docker build -t librivox-local .
```

## Running

```bash
docker run --rm -it librivox-local
```

That'll drop you into a shell, which isn't strictly necessary, but is helpful
for debugging.

Or, if you need to get at the code, you can mount a volume, but I've not had
much success working this way:

```bash
docker run --rm -it -v librivox-catalog:/librivox/www/librivox.org/catalog librivox-local
```

WARNING: This makes a persistent volume. If you ever rebuild the docker images,
then you really should wipe the volume and start again since the config files
that ansible sets up may have changed.

### Hackerman - Making it actually work

The "it looks dumb, but works" way to get things going nicely is to do this:


```bash
docker run --rm -it -v "$(pwd)"/librivox-catalog:/librivox/www/librivox.org/catalog librivox-local
```

And then, _inside the container_ do:

```bash
cp -a /librivox/www/librivox.org/catalog.bak/. /librivox/www/librivox.org/catalog
```

And then, _on the host_ do:

```bash
sudo chown -R $(whoami) librivox-catalog
```

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

## Things to fix

* `$section_reader_clause` in `Librivox_search#advanced_title_search` isn't being used, so no need to
  do the query for reader IDs.
* `$section_project_ids` in `Librivox_search#advanced_title_search` isn't being used, so no need to
  do the query.
* No index on `search_table`
  ```sql
  CREATE INDEX IF NOT EXISTS search_table_source_id_idx ON search_table (source_table, source_id)
  ```
* Needs some perf testing
  ```php8
  $start = hrtime(true);
  $end = hrtime(true);
  echo "DURATION: " . ceil(($end - $start) / 1e6) . "ms\n";
  ```
