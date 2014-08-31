# Magento and Vagrant

This project is the base Vagrant configuration we use for Magento
projects. It contains a Vagrantfile, Puppet manifests, server config
files, and fabric tasks.


## Quick start

You will need:

+ `composer.json`;
+ SSH details to a server with a canonical database and media folder
+ `local.xml`
+ Vagrant

If you have all of those things, then:

1. Set values in `config.json`
2. `vagrant up`
3. `./manage.sh init`
4. Set a host pointing to the IP address set in `Vagrantfile`
5. Profit.


## Structure

The webserver is configured to look at `/vagrant/htdocs` and serve up
PHP files (5.3). There is a Percona 5.5 database installation, with a
passwordless root user. Composer and N98-Magerun come preinstalled.

To set up a project, you can clone your Magento repository into
`htdocs/`, and run `composer.phar install`. Then you'll need to install
the database and you should be good to go.

There are several Fabric tasks to help you with this, and they are
described at the end.


## Vagrantfile

This project is based on CentOS 6.5, and the Puppet manifests assume
that. Feel free to change the Operating System, but you'll have to
change a lot of things. Notably, the package for PHP on Debian is
called `php5`, rather than `php`. There's a lot of little stuff like
that.

If you run multiple projects, you will want to change the assigned IP
address so that they do not collide. I opted for a private IP address
rather than port forwarding, because it makes urls nicer and makes
debugging friendlier.


## Puppet Manifests

The base manifest installs everything needed on any server, including
a production server. In the future, we are looking to use this system
as a deployment vector, so we've kept concerns separated early.

The redbox manifest installs everything needed on a development server.
This includes compass, fabric, git, vim, and other dev-land software.


## Server Config

These have not yet been separated into development and production
environments, but it is a configuration that works.


## Fabric tasks

There are several Fabric tasks defined to help maintain projects that
are build a certain way. We build our projects by importing a fresh
installation of Magento, and installing our dependencies on top of it
as Composer packages. This prevents has several benefits:

+ No tampering of core files.
+ Much easier upgrade path.
+ More easily reproducible environment.

If your Magento builds look like this as well, then you're in luck.

These are tasks that run on the guest machine. They can be accessed
by running `./manage.sh {{command}}` on the host machine.

There is a `config.json` file in the root of the project that allows
for several customisations. At the very least, you will want to set SSH
details for pulling the media folder and a database dump.

If you are installing Enterprise projects, you will want to point the
`magento_mirror` at a repository for EE.

If configuration needs to be done after installation, the array
`other_config` contains a list of calls made to `n98-magerun config:set`.

+ `clean_up`

  Destroy the `htdocs/` and `vendor/` directories.

+ `git_clone`

  Clone a base copy of Magento into the `htdocs/`. The repository to
  use can be configured in `config.json`

+ `get_local_xml`

  Copy a local.xml from the base repository into the correct location
  for Magento. This config file should exist before the project is
  installed.

  We don't generate this from scratch because sometimes other server
  specific configuration is put into `local.xml`.

+ `get_media_dump`

  Download the media folder from the configured remote server and
  extract it into `htdocs/media`.

+ `create_database`

  Create the database configured in local.xml.

+ `get_database_dump`

  Take a development dump of the database on the configured remote
  server and import it.

+ `install_dependencies`

  Run `composer.phar update`

+ `compass`

  Compile all compass projects, except those in the `rwd` package.

+ `clean_cache`

  Flush all Magento caches.

+ `init`

  All of the above, in order.

## To Do

+ Debian Support
+ Start a detached process for compiling compass
+ Support other project structures
+ Create separate deployment classes (dev, prod)
+ Separate server configuration
