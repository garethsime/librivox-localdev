# Building

```
docker build -t librivox-local .
```

I also changed some files in librivox-ansible. You can apply `librivox-ansible.patch`.

```
docker run --rm -it librivox-local
```

And you'll want to load the catalog db as per README and then go to:
https://librivox.org/search (once you've configured your own `/etc/hosts`
file, that is)
