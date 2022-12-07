# a basic docker-compose.yml file for my local WordPress installs

- ref: [https://docs.docker.com/compose/wordpress/](https://docs.docker.com/compose/wordpress/)
- ref: [https://dev.to/napolux/how-to-use-docker-for-easy-and-fast-wordpress-development-h62](https://dev.to/napolux/how-to-use-docker-for-easy-and-fast-wordpress-development-h62)

## what

a starting point for local WordPress installs.

runs the latest WP version by default and links wp-content directory to a local version - in there is where you can add project code or create a git repo etc.

## usage

- put it in to a directory
- run `docker-compose up` or `docker-compose up -d` (`docker-compose stop` to stop that one)
- run `docker-compose down` to clean up everything that hasn't been saved to a volume specified in `docker-compose.yml`

See below for specifics

## Set unique ports

If you are running lots of these images then the ports on localhost will conflict so it makes sense to keep them separate. You can update `docker-compose.yml`, specifically the `ports:` sections to ensure there are no conflicts!

## local domain name and ssl certs for dev

### set up a local domain for development

``` bash
# on local machine (not the Docker Image)
sudo nano /etc/hosts
# add line like:
# 127.0.0.1 example-site.local
```

Now you should be able to access your image (when it's running) on `http://example-site.local:PORT`

### Set up an ssl cert for that local domain

> If this is the first time setting up a cert:

#### Set up a local Cerificate Authority (CA)

_You only need to do this step once_ - if you already have one then you don't need another for each site.

- install `mkcert`
  - on macos that's `brew install mkcert` and `brew install nss`
- run `mkcert -install`

> If yoy already have a local CA set up:

#### Make self signed SSL certs for your local domain

``` bash
# cd into the proxy/certs dir at the root of this repo
mkcert -cert-file example-site.local.crt -key-file example-site.local.key example-site.local
```

#### change the proxy file to point to your new domain

just replace all instances of _example-site.local_ in `proxy/conf/default-ssl.conf` with the local domain for your site.

#### enable ssl on apache for every run

> This is a horrible way to do this really - is there a better (less manual) way?

We need to copy the images `docker-entrypoint.sh` file and add a few lines to the end...

``` bash
# from the root project directory
# get [IMAGENAME] from `docker ps`
docker cp [IMAGENAME]_wordpress_1:/usr/local/bin/docker-entrypoint.sh .
```

replace the last line of the `docker-entrypoint.sh` file with

``` sh
a2enmod ssl
a2ensite default-ssl
service apache2 restart
service apache2 stop
exec "$@"
```

## permissions

on first run you might get errors trying to install new plugins etc.

if you do you can run the following commands.

> If you need to find the container name use `docker ps` whilst it's running

``` bash
# whilst the container is running
docker exec -it <wordpress-container-name> bash

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
