/**
 * Compass
 *
 * Version 0.12. Magento and Redbox use compass, but 1.0.1 breaks our
 * existing projects.
 *
 * New projects should ensure => 'latest', rather than 0.12.7.
 */

package { 'compass':
  provider => 'gem',
  ensure => '0.12.7',
}


/**
 * Vim
 *
 * It's really hard to develop without a decent editor.
 */

package { 'vim-enhanced':
  ensure => 'present',
}


/**
 * Git.
 *
 * It's necessary for pretty much everything.
 */

package { 'git':
  ensure => 'present',
}


/**
 * Unzip
 *
 * Magerun's media:dump command gives a zip archive.
 */

package { 'unzip':
  ensure => 'present',
}


/**
 * Dtach
 *
 * To start detached, long running processes. Namely, compass watch
 */

package { 'dtach':
  ensure => 'present',
}


/**
 * GCC
 *
 * Fabric needs GCC, apparently.
 */

package { 'gcc':
   ensure => 'present',
}

/**
 * Python-devel
 *
 * Fabric needs the development headers for python.
 */

package { 'python-devel':
   ensure => 'present',
   require => Package['gcc'],
}


/**
 * PIP
 *
 * We need to install pip so we can install fabric
 */

 package { 'python-pip':
   ensure => 'present',
   require => Package["python-devel"],
 }


 /**
  * Fabric
  *
  * Used for SSH tasks like pulling database from a server.
  */

package { 'fabric':
  ensure => 'present',
  require => Package["python-pip"],
  provider => 'pip',
}


/**
 * Composer
 *
 * Used to install dependencies
 */

exec { 'curl -sS https://getcomposer.org/installer | php':
  cwd => '/usr/local/bin',
  creates => '/usr/local/bin/composer.phar',
  path => '/usr/local/bin:/usr/bin',
}


/**
 * Ensure that composer is executable
 */

file { '/usr/local/bin/composer.phar':
  mode => '0755',
  require => Exec['curl -sS https://getcomposer.org/installer | php'],
}


/**
 * Magerun
 *
 * Used for everything Magento
 */

exec { 'curl -o n98-magerun.phar https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar':
  cwd => '/usr/local/bin',
  creates => '/usr/local/bin/n98-magerun.phar',
  path => '/usr/local/bin:/usr/bin',
}


/**
 * Ensure that n98-magerun is executable
 */

file { '/usr/local/bin/n98-magerun.phar':
  mode => '0755',
  require => Exec['curl -o n98-magerun.phar https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar'],
}


/**
 * Fabric tasks
 */

file { '/home/vagrant/fabfile.py':
  ensure => 'present',
  source => '/vagrant/server_config/home/vagrant/fabfile.py',
}

file { '/home/vagrant/compass_compile.sh':
  ensure => 'present',
  source => '/vagrant/server_config/home/vagrant/compass_compile.sh',
  mode => '0755',
}


/**
 * Satis repository for Composer
 *
 * Until I get given some webspace on a Redbox server...
 */

host { 'packages.local.redboxcloud.com':
  ensure => 'present',
  ip => '10.0.2.2',
}

