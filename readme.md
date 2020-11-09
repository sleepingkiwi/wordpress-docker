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
