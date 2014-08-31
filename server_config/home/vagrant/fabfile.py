import hashlib
import json
import os

from xml.etree import ElementTree
from fabric.api import local, env, run, get, cd, lcd, task

project_root = '/vagrant'
magento_root = os.path.join(project_root, 'htdocs')
config = json.load(open(os.path.join(project_root, 'config.json')))

env.hosts = [config['ssh_host']]
env.port = config['ssh_port']
env.user = config['ssh_username']

# Set up SSH for password or certificate based authentication
env.password = config['ssh_password'] or None
if config['ssh_certificate']:
    env.key_filename = os.path.join('/vagrant', config['ssh_certificate'])
else:
    env.key_filename = None

def random_filename(extension):
    extension = '.' + extension if extension else ''
    return hashlib.md5(os.urandom(64)).hexdigest() + extension

@task
def clean_up():
    """Remove the project directory to get ready."""
    local('/bin/rm -rf %s' % magento_root)
    local('/bin/rm -rf %s/vendor' % project_root)

@task
def git_clone():
    """Clone a clean Magento installation into htdocs."""
    with lcd(project_root):
        local('git clone %s htdocs' %s config['magento_mirror'])
    with lcd(magento_root):
        local('git checkout "%s"' % config['magento_version'])
    local('/bin/rm -rf .git composer.json')

@task
def get_local_xml():
    local('cp /vagrant/local.xml.local /vagrant/htdocs/app/etc/local.xml')

@task
def get_media_dump():
    """SSH to remote server and get media folder.

    This uses the magical N98-Magerun, and it needs to be a fairly
    recent version, so make sure that it's installed somewhere globally
    accessible.

    In config.json, there is a field to supply the path to it, so there
    really is no excuse.

    The dump is then downloaded and unzipped into the Magento instance.
    """
    media_filename = random_filename('zip')
    media_location = os.path.join(config['tmp_dir'], media_filename)

    with cd(config['magento_root']):
        run('%s media:dump --strip %s' %
                (config['magerun'], media_location))

    get(remote_path=media_location, local_path='/tmp')

    with lcd('/tmp'):
        local('unzip %s' % media_filename)
        local('cp -r media %s' % magento_root)

@task
def create_database():
    """Create the database specified locally."""
    with lcd(magento_root):
        local('n98-magerun.phar db:create')

@task
def get_database_dump():
    """Get a database dump from the server.

    This dumps the data and imports it, assuming that the database
    has been created.
    """
    db_filename = random_filename('sql')
    db_location = os.path.join(config['tmp_dir'], db_filename)
    with cd(config['magento_root']):
        run('%s db:dump -f %s --strip="@development"' %
                (config['magerun'], db_location))

    get(remote_path=db_location, local_path='/tmp')

    with lcd(magento_root):
        local('n98-magerun.phar db:import %s' % '/tmp/' + db_filename)

@task
def install_dependencies():
    """Run composer.phar update."""
    with lcd(project_root):
        local('composer.phar update')

@task
def configure():
    """Grab bag of things that need doing.

    Note that arbitrary config settings can be added in config.json,
    under "other_config"
    """
    with lcd(magento_root):
        local('n98-magerun.phar config:set web/secure/base_url %s' %
                config['magento_base_url'])
        local('n98-magerun.phar config:set web/unsecure/base_url %s' %
                config['magento_base_url'])
        for rule in config['other_config']:
            local('n98-magerun.phar config:set %s' % rule)

@task
def compass():
    """Compile all compass projects."""
    with lcd('~'):
        local('./compass_compile.sh')

def clean_cache():
    """Flush Magento caches."""
    with lcd(magento_root):
        local('n98-magerun.phar cache:flush')

@task
def init():
    """All together now (!)"""
    clean_up()
    git_clone()
    get_local_xml()
    get_media_dump()
    create_database()
    get_database_dump()
    install_dependencies()
    configure()
    compass()
    clean_cache()

