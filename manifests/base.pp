

/**
 * First, Percona
 *
 * Version 5.5
 */

package { 'Percona-Server-server-55':
  ensure => latest,
  notify => Service['mysql'],
}

service { 'mysql':
  ensure => 'running',
}


/**
 * PHP
 *
 * Version 5.3
 */

package { 'php':
  ensure => 'installed',
  notify => [Service['httpd'], File['/etc/php.ini']],
}


/**
 * PHP installs Apache2, which we are not using.
 *
 * If PHP is installed before Nginx, we must stop httpd, otherwise
 * Nginx will not be able to start.
 */

service { 'httpd':
  ensure => 'stopped',
}


/**
 * Base PHP configuration.
 *
 * Among other things, sets a timezone.
 */

file { '/etc/php.ini':
  source => '/vagrant/server_config/etc/php.ini',
  ensure => 'present',
}


/**
 * A few extensions required by Magento.
 */

package { 'php-mcrypt':
  ensure => 'installed',
  notify => Service['php-fpm'],
}

package { 'php-gd':
  ensure => 'installed',
  notify => Service['php-fpm'],
}

package { 'php-pdo':
  ensure => 'installed',
  notify => Service['php-fpm'],
}

package { 'php-mysql':
  ensure => 'installed',
  notify => Service['php-fpm'],
}


/**
 * For running PHP on Nginx
 */

package { 'php-fpm':
  ensure => 'installed',
  notify => [File['/etc/php-fpm.conf'], File['/etc/php-fpm.d/www.conf']],
}


/**
 * Configuration for PHP-FPM
 *
 * Sets the process manager to listen on port 9001. (we are using port
 * 9000 for Xdebug.)
 */

file { '/etc/php-fpm.conf':
  source => '/vagrant/server_config/etc/php-fpm.conf',
  ensure => 'present',
  notify => Service['php-fpm'],
}

file { '/etc/php-fpm.d/www.conf':
  source => '/vagrant/server_config/etc/php-fpm.d/www.conf',
  ensure => 'present',
  notify => Service['php-fpm'],
}


/**
 * We need PHP-FPM to be running.
 */

service { 'php-fpm':
  ensure => 'running',
}


/**
 * Nginx
 * Version 1.4.4
 */

package { 'nginx':
  ensure => '1.4.4-1.el6.ngx',
  notify => File['/etc/nginx/nginx.conf'],
}


/**
 * Nginx configuration, optimised for Magento.
 */

file { '/etc/nginx/nginx.conf':
  ensure => 'present',
  source => '/vagrant/server_config/etc/nginx/nginx.conf',
  notify => File['/etc/nginx/conf'],
}


/**
 * Magento specific configuration (rewrites, fcgi, security).
 */

file { '/etc/nginx/conf':
  ensure => 'directory',
  source => '/vagrant/server_config/etc/nginx/conf',
  recurse => 'true',
  notify => File['/etc/nginx/conf.d'],
}


/**
 * By default, nginx includes anything in conf.d/
 */

file { '/etc/nginx/conf.d':
  ensure => 'directory',
  source => '/vagrant/server_config/etc/nginx/conf.d',
  recurse => 'true',
  notify => Service['nginx'],
  purge => 'true',
}


/**
 * We need our webserver to be running.
 */

service { 'nginx':
  ensure => 'running',
}


/**
 * A basic phpinfo page to show that things are working
 */

file { '/var/www':
  ensure => 'present',
  source => '/vagrant/server_config/var/www',
  recurse => 'true',
  require => Package['nginx'],
}

