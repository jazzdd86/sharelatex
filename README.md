ShareLaTeX Docker Image
=======================

**Please read this entire file before installing ShareLaTeX via Docker. It's only
short but contains some important information.**

The recommended way to install and run ShareLaTeX Community Edition is via [Docker](https://www.docker.com/):

```
# docker run --name latex --restart=always \
    --link latex_redis:redis --link latex_mongo:mongo \
    -v /data/data-latex/texlive:/usr/local/texlive \
    -v /data/data-latex/files/:/var/lib/sharelatex \
    -e SHARELATEX_MONGO_URL=mongodb://mongo/sharelatex \
    -e SHARELATEX_REDIS_HOST=redis \
    -e VIRTUAL_HOST=latex.jotunheim.de,www.latex.jotunheim.de \
    -e SHARELATEX_SITE_URL=http://latex.jotunheim.de \
    -d jazzdd/sharelatex
```

* `--link latex_redis:redis --link latex_mongo:mongo` links the database containers directly to the sharelatex container
* `-e SHARELATEX_MONGO_URL=mongodb://mongo/sharelatex` tells sharelatex where to find the mongo db database (containers are linked therefore the url is the name given in the link option)
* `-e SHARELATEX_REDIS_HOST=redis` tells sharelatex where to find the redis database (containers are linked therefore the url is the name given in the link option)
* `-e VIRTUAL_HOST=latex.jotunheim.de,www.latex.jotunheim.de` - option for the [nginx reverse proxy](https://github.com/jwilder/nginx-proxy) - url for the virtual host redirecting to this container 
* `-e SHARELATEX_SITE_URL=http://latex.jotunheim.de` - telling sharelatex its own url (should be the same as for the VIRTUAL_HOST)

### Mongo and Redis

ShareLaTeX depends on [MongoDB](http://www.mongodb.org/) (must be 2.4 or later), and [Redis](http://redis.io/) (must be version 2.6.12 or later).


By default the ShareLaTeX Docker container looks for these running on the host
machine at port 27017 (for Mongo) and port 6379 (for Redis). These are the defaults
ports for both databases so you shouldn't need to change them.

The redis server doesn't need to be persistent, as there is no essential data written to it, it is used as caching system.

Start the redis server with following command.
```
# docker run --name latex_redis --restart=always -d redis
```

The files are stored in the mongo db.

Start the mongo server with follwing command.
```
# docker run --name latex_mongo --restart=always -v /data/data-latex/mongo/:/data/db -d mongo
```


### Storing Data

**Mongo DB**

The mongo db stores all latex project data in its database. For persistence it is mounted on the file system.
* `-v /data/data-latex/mongo/:/data/db` - the mongo db folder mounted to the host file system

**Sharelatex**
* `-v /data/data-latex/files/:/var/lib/sharelatex` stores all temporaray data such as latex output.pdf files on the host file system for backup
* `-v /data/data-latex/texlive:/usr/local/texlive` stores the texlive distribution on the host system because a texlive installation is not needed if you create a new sharelatex container after an upgrade and the container is not used to stor the texlive data


### Backups

To backup the ShareLaTeX data, you need to backup the directory you have attached
to the sharelatex and mongo db containers, as above.


### LaTeX environment
To save bandwidth, the ShareLaTeX image only comes with the installer downloaded into the image. To install it use the install-tl script.

```
docker exec -it latex /bin/bash -c "/install-tl-unx/install-tl"
```

There it can be configured what texlive installation is needed. It is recommended
to use all default values and only hit 'I' to install texlive

After installation or after recreating the sharelatex container these two commands
have to be executed. The binary files have to be linked from the texlive installation
folder to the /opt/texbin folder which is included in the PATH variable
```
# docker exec latex /bin/bash -c "chmod 777 /usr/local/texlive/2015/texmf-var -R"
# docker exec latex /bin/bash -c "ln -s /usr/local/texlive/2015/bin/* /opt/texbin"
```

### Configuration Options
* `SHARELATEX_SECURE_COOKIE`: Set this to something non-zero to use a secure cookie.
  Only use this if your ShareLaTeX instance is running behind a reverse proxy with SSL configured.


### Creating and Managing users

The following command to create your first user and make them an admin:

```
$ docker exec sharelatex /bin/bash -c "cd /var/www/sharelatex/web; grunt create-admin-user --email joe@example.com"
```
This will create a user with the given email address if they don't already exist, and make them an admin user. You will be given a URL to visit where you can set the password for this user and log in for the first time.


**Creating normal users**

Once you are logged in as an admin user, you can visit `/admin/register` on your ShareLaTeX instance and create a new users. If you have an email backend configured in your settings file, the new users will be sent an email with a URL to set their password. If not, you will have to distribute the password reset URLs manually. These are shown when you create a user.