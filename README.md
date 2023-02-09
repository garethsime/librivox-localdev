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
docker run --rm -it -v librivox-www:/librivox/www/librivox.org librivox-local
```

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
