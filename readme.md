# a basic docker-compose.yml file for my local WordPress installs

- ref: [https://docs.docker.com/compose/wordpress/](https://docs.docker.com/compose/wordpress/)
- ref: [https://dev.to/napolux/how-to-use-docker-for-easy-and-fast-wordpress-development-h62](https://dev.to/napolux/how-to-use-docker-for-easy-and-fast-wordpress-development-h62)

## what

a starting point for local WordPress installs.

used extensively on macos, untested but should(?) mostly work under linux/WSL.

runs the latest WP version by default and links `wp-content` directory to a local version - where you can add project code or create a git repo etc.

contains configuration and settings to run xdebug on the local machine.

Requires our [nginx-proxy](https://github.com/sleepingkiwi/nginx-proxy-docker) container to be running for the ssl functionality etc.

## usage

- put it in to a directory
- run `docker-compose up` to run in the terminal
- or `docker-compose up -d` to run in the background (`docker-compose stop` to stop that one)
- run `docker-compose down` to clean up everything that hasn't been saved to a volume specified in `docker-compose.yml`

See below for specifics

## Rename volumes and services

Because we run these images on a shared network we would run in to issues with the same db service being shared by multiple containers.

To resolve this we give each service it's own name keyed to the current project

Find and replace `example_site` with `your_site_name` in `docker-compose.yml`

## local domain name and ssl certs for dev

### set up a local domain for development

``` bash
# on local machine (not the Docker Image)
sudo nano /etc/hosts
# add line like:
# 127.0.0.1 example-site.local
# 127.0.0.1 db.example-site.local
```

Now you also need to add your local URL under VIRTUAL_HOST: for the WordPress and database images . Replace `example-site.local` in both places (in `docker-compose.yml`) with the name you just added to /etc/hosts

Now if you run docker-compose up (and the proxy is running) you should be able to access your image (when it's running) on `http://example-site.local` and phpmyadmin for the database at `http://db.example-site.local`

### Set up an ssl cert for that local domain

> 👋 If this is the first time setting up a cert:

#### Set up a local Cerificate Authority (CA)

_You only need to do this step once_ - if you already have one then you don't need another for each site.

- install `mkcert`
  - on macos that's `brew install mkcert` and `brew install nss`
- run `mkcert -install`

> 👋 If you already have a local CA set up:

#### Make self signed SSL certs for your local domain and give them to local proxy

These need to go into the `./certs` directory at the root of your local [nginx-proxy](https://github.com/sleepingkiwi/nginx-proxy-docker) (should be `~/dev/nginx-proxy/certs`)

``` bash
# cd into the /certs dir at the root of the nginx-proxy dir (should be ~/dev/nginx-proxy/certs)
mkcert -cert-file example-site.local.crt -key-file example-site.local.key example-site.local
mkcert -cert-file db.example-site.local.crt -key-file db.example-site.local.key db.example-site.local
```

## Using xdebug

If you have the [PHP Debug](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug) extension installed then the launch.json inside the `.vscode` dir in this repo should just work!

In vscode if you `view > run` and choose `listen for xdebug` from the dropdown in the _run and debug_ panel then vscode will automatically detect errors/breakpoints in your running code.

👋 This repo contains a `launch.json` file that works well if you have vscode open from the very root of your project (i.e. the directory containing `docker-compose.yml`).

If you just have a specific plugin/theme open in your workspace you will need to tweak the launch.json file at the root of that directory so that xdebug knows where to locate files!

## changing permissions or editing files in the running container

> If you need to find the container name use `docker ps` whilst it's running

``` bash
# whilst the container is running
docker exec -it <wordpress-container-name> bash

# changing permissions example
# you shouldn't normally have to do this!
# create missing dirs and give yourself some rights
mkdir /var/www/html/wp-content/plugins
mkdir /var/www/html/wp-content/uploads
chown -R www-data:www-data /var/www
find /var/www/ -type d -exec chmod 0755 {} \;
find /var/www/ -type f -exec chmod 644 {} \;

# make the shared dir/s editable on host system
# 🤡 pls don't deploy this - it's for local use...
find /var/www/html/wp-content/ -type d -exec chmod 0777 {} \;
find /var/www/html/wp-content/ -type f -exec chmod 666 {} \;
```
