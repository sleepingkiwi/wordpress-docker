# If you need to rebuild: `docker-compose build` does the trick!
# $ docker ps <- lists all running containers so you can get name for below command
# $ docker exec -it [use-command-above]_wordpress_1 /bin/bash    <- runs bash in the named (running) container
# so you can inspect/copy files etc
FROM wordpress:latest

# allow bigger uploads
RUN touch /usr/local/etc/php/conf.d/upload-limit.ini && echo "upload_max_filesize = 32M" >> /usr/local/etc/php/conf.d/upload-limit.ini ** echo "post_max_size = 32M" >> /usr/local/etc/php/conf.d/upload-limit.ini
