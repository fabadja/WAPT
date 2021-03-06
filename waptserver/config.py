#!/usr/bin/python
# -*- coding: utf-8 -*-
# -----------------------------------------------------------------------
#    This file is part of WAPT
#    Copyright (C) 2013-2015  Tranquil IT Systems http://www.tranquil.it
#    WAPT aims to help Windows systems administrators to deploy
#    setup and update applications on users PC.
#
#    WAPT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    WAPT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with WAPT.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------
from __future__ import absolute_import
__version__ = "1.8.1"

import os
import sys

try:
    wapt_root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
except:
    wapt_root_dir = 'c:/tranquilit/wapt'

import ConfigParser
import tempfile
import platform

def type_windows():
    return platform.win32_ver()[0] != ''

def type_debian():
    return platform.dist()[0].lower() in ('debian','ubuntu','linuxmint')

def type_redhat():
    return platform.dist()[0].lower() in ('redhat','centos','fedora')

if type_debian():
    DEFAULT_WAPT_FOLDER = '/var/www/wapt'
elif type_redhat():
    DEFAULT_WAPT_FOLDER = '/var/www/html/wapt'
else:
    DEFAULT_WAPT_FOLDER = os.path.join(wapt_root_dir, 'waptserver', 'repository', 'wapt')

WAPTLOGGERS = ['waptcore','waptserver','waptserver.app','waptws','waptdb']

_defaults = {
    'client_tasks_timeout': 5,
    'clients_read_timeout': 5,
    'loglevel': 'warning',
    'secret_key': None,
    'server_uuid': None,
    'wapt_folder': DEFAULT_WAPT_FOLDER,
    'wapt_huey_db': os.path.join(tempfile.gettempdir(), 'wapthuey.db'),
    'wapt_password': None,
    'wapt_user': 'admin',
    'waptserver_port': 8080,
    'waptwua_folder': '',  # default: wapt_folder + 'wua'
    'db_name': 'wapt',
    'db_host': None,
    'db_port': 5432,
    'db_user': 'wapt',
    'db_password': None,
    'db_max_connections': 90,
    'db_stale_timeout': 300,
    'db_connect_timeout': 3,
    'use_kerberos': False,
    'max_clients': 4096,
    'encrypt_host_packages':False,
    'dc_ssl_enabled':True,
    'dc_auth_enabled':False,
    'allow_unsigned_status_data':False,
    'min_password_length':10,
    'allow_unauthenticated_registration':False,
    'allow_unauthenticated_connect':None,
    'clients_signing_key':None,
    'clients_signing_certificate':None,
    'clients_signing_crl':None,
    'clients_signing_crl_url':None,
    'clients_signing_crl_days':30,
    'client_certificate_lifetime':3650,
    'use_ssl_client_auth':False,
    'signature_clockskew':5*60,
    'token_lifetime': 12*60*60,
    'application_root':'',
    'wapt_admin_group_dn':None,
    'ldap_auth_server':None,
    'ldap_auth_base_dn':None,
    'ldap_auth_ssl_enabled':True,
    'htpasswd_path':None,
    'http_proxy':None,
    'nginx_http' : 80,
    'nginx_https': 443,
    'remote_repo_support': False,
    'diff_repo': False,
    'auto_create_ldap_users': True,
    'trusted_signers_certificates_folder':None, # path to trusted signers certificate directory
    'trusted_users_certificates_folder':None, # path to trusted users CA certificate directory
    'known_certificates_folder': os.path.join(os.path.dirname(DEFAULT_WAPT_FOLDER),'ssl'),
    'wol_port':'9'
}

for log in WAPTLOGGERS:
    _defaults['loglevel_%s' % log] = None

DEFAULT_CONFIG_FILE = os.path.join(wapt_root_dir, 'conf', 'waptserver.ini')

def load_config(cfgfile=DEFAULT_CONFIG_FILE):
    conf = _defaults.copy()

    # read configuration from waptserver.ini
    _config = ConfigParser.RawConfigParser()
    if os.path.exists(cfgfile):
        _config.read(cfgfile)
    else:
        # XXX this is a kludge
        if os.getenv('USERNAME') == 'buildbot':
            return conf

    if not _config.has_section('options'):
        _config.add_section('options')

    if _config.has_option('options', 'client_tasks_timeout'):
        conf['client_tasks_timeout'] = int(_config.get('options', 'client_tasks_timeout'))

    if _config.has_option('options', 'clients_read_timeout'):
        conf['clients_read_timeout'] = int(_config.get('options', 'clients_read_timeout'))

    if _config.has_option('options', 'loglevel'):
        conf['loglevel'] = _config.get('options', 'loglevel')

    for log in WAPTLOGGERS:
        if _config.has_option('options', 'loglevel_%s' % log):
            conf['loglevel_%s' % log] = _config.get('options', 'loglevel_%s' % log)

    if _config.has_option('options', 'secret_key'):
        secret_key = _config.get('options', 'secret_key')
        if secret_key is None or len(secret_key) < 32:
            msg = 'incorrect secret_key value %s in waptserver.ini, please run postconf.py again (missing or too short)' % secret_key
            raise Exception(msg)
        conf['secret_key'] = secret_key

    if _config.has_option('options', 'server_uuid'):
        server_uuid = _config.get('options', 'server_uuid')
        if server_uuid is None or len(server_uuid) < 10:
            msg = 'incorrect server_uuid value %s in waptserver.ini, please run postconf.py again (missing or too short)' % server_uuid
            raise Exception(msg)
        conf['server_uuid'] = server_uuid

    if _config.has_option('options', 'wapt_folder'):
        conf['wapt_folder'] = _config.get('options', 'wapt_folder').rstrip('/').rstrip('\\')

    if _config.has_option('options', 'wapt_huey_db'):
        conf['wapt_huey_db'] = _config.get('options', 'wapt_huey_db')

    if _config.has_option('options', 'wapt_password'):
        conf['wapt_password'] = _config.get('options', 'wapt_password')

    if _config.has_option('options', 'wapt_user'):
        conf['wapt_user'] = _config.get('options', 'wapt_user')

    if _config.has_option('options', 'waptserver_port'):
        conf['waptserver_port'] = _config.getint('options', 'waptserver_port')

    if _config.has_option('options', 'waptservice_port'):
        conf['waptservice_port'] = _config.getint('options', 'waptservice_port')

    # XXX must be processed after conf['wapt_folder']
    if _config.has_option('options', 'waptwua_folder'):
        conf['waptwua_folder'] = _config.get('options', 'waptwua_folder').rstrip('/').rstrip('\\')
    if not conf['waptwua_folder']:
        conf['waptwua_folder'] = conf['wapt_folder'] + 'wua'

    for param in ('db_name', 'db_host', 'db_user', 'db_password'):
        if _config.has_option('options', param):
            conf[param] = _config.get('options', param)

    for param in ('db_port', 'db_max_connections', 'db_stale_timeout', 'db_connect_timeout', 'max_clients'):
        if _config.has_option('options', param):
            conf[param] = _config.getint('options', param)

    if _config.has_option('options', 'use_ssl_client_auth'):
        conf['use_ssl_client_auth'] = _config.getboolean('options', 'use_ssl_client_auth')

    if _config.has_option('options', 'use_kerberos'):
        conf['use_kerberos'] = _config.getboolean('options', 'use_kerberos')

    if _config.has_option('options', 'dc_ssl_enabled'):
        conf['dc_ssl_enabled'] = _config.getboolean('options', 'dc_ssl_enabled')

    if _config.has_option('options', 'dc_auth_enabled'):
        conf['dc_auth_enabled'] = _config.getboolean('options', 'dc_auth_enabled')

    if _config.has_option('options', 'allow_unsigned_status_data'):
        conf['allow_unsigned_status_data'] = _config.getboolean('options', 'allow_unsigned_status_data')

    if _config.has_option('options', 'min_password_length'):
        conf['min_password_length'] = _config.getint('options', 'min_password_length')

    if _config.has_option('options', 'allow_unauthenticated_registration'):
        conf['allow_unauthenticated_registration'] = _config.getboolean('options', 'allow_unauthenticated_registration')

    if _config.has_option('options', 'allow_unauthenticated_connect'):
        conf['allow_unauthenticated_connect'] = _config.getboolean('options', 'allow_unauthenticated_connect')
    else:
        conf['allow_unauthenticated_connect'] = conf['allow_unauthenticated_registration']

    if _config.has_option('options', 'clients_signing_certificate'):
        conf['clients_signing_certificate'] = _config.get('options', 'clients_signing_certificate')

    if _config.has_option('options', 'clients_signing_key'):
        conf['clients_signing_key'] = _config.get('options', 'clients_signing_key')

    if _config.has_option('options', 'clients_signing_crl'):
        conf['clients_signing_crl'] = _config.get('options', 'clients_signing_crl')

    if _config.has_option('options', 'clients_signing_crl_days'):
        conf['clients_signing_crl_days'] = _config.getint('options', 'clients_signing_crl_days')

    if _config.has_option('options', 'clients_signing_crl_url'):
        conf['clients_signing_crl_url'] = _config.get('options', 'clients_signing_crl_url')

    if _config.has_option('options', 'client_certificate_lifetime'):
        conf['client_certificate_lifetime'] = _config.getint('options', 'client_certificate_lifetime')

    if _config.has_option('options', 'signature_clockskew'):
        conf['signature_clockskew'] = _config.getint('options', 'signature_clockskew')

    if _config.has_option('options', 'token_lifetime'):
        conf['token_lifetime'] = _config.getint('options', 'token_lifetime')

    if _config.has_option('options', 'application_root'):
        conf['application_root'] = _config.get('options', 'application_root')

    for option in ('wapt_admin_group_dn','ldap_auth_server','ldap_auth_base_dn'):
        if _config.has_option('options',option):
            conf[option] = _config.get('options', option)

    if _config.has_option('options', 'ldap_auth_ssl_enabled'):
        conf['ldap_auth_ssl_enabled'] = _config.getboolean('options', 'ldap_auth_ssl_enabled')

    if _config.has_option('options', 'auto_create_ldap_users'):
        conf['auto_create_ldap_users'] = _config.getboolean('options', 'auto_create_ldap_users')

    if _config.has_option('options', 'http_proxy'):
        conf['http_proxy'] = _config.get('options', 'http_proxy')

    # path to a htpasswd file for additional users authentication (register/unregister)
    if _config.has_option('options', 'htpasswd_path'):
        conf['htpasswd_path'] = _config.get('options', 'htpasswd_path')

    if _config.has_option('options','remote_repo_support'):
        conf['remote_repo_support'] = _config.getboolean('options','remote_repo_support')

    if _config.has_option('options','diff_repo'):
        conf['diff_repo'] = _config.getboolean('options','diff_repo')

    # path to X509 certificates file of trusted signers to restrict access to upload packages / actions proxying
    if _config.has_option('options', 'trusted_signers_certificates_folder'):
        conf['trusted_signers_certificates_folder'] = _config.get('options', 'trusted_signers_certificates_folder')

    # path to collected known certificates and associated CRL
    if _config.has_option('options', 'known_certificates_folder'):
        conf['known_certificates_folder'] = _config.get('options', 'known_certificates_folder')
    else:
        conf['known_certificates_folder'] = os.path.join(os.path.dirname(conf['wapt_folder']),'ssl')

    if _config.has_option('options', 'wol_port'):
        conf['wol_port'] = _config.get('options', 'wol_port')

    return conf

def write_config_file(cfgfile=DEFAULT_CONFIG_FILE,server_config=None,non_default_values_only=True):
    if server_config is None:
        server_config = _defaults.copy()

    # read configuration from waptserver.ini
    _config = ConfigParser.RawConfigParser()
    if os.path.isfile(cfgfile):
        _config.read(cfgfile)

    if not _config.has_section('options'):
        _config.add_section('options')

    for key in server_config:
        if not non_default_values_only or server_config[key] != _defaults.get(key):
            if server_config[key] is None:
                _config.remove_option('options',key)
            else:
                _config.set('options',key,server_config[key])

    if not os.path.isdir(os.path.dirname(cfgfile)):
        os.makedirs(os.path.dirname(cfgfile))

    with open(cfgfile,'w') as inifile:
       _config.write(inifile)

def rewrite_config_item(cfg_file=DEFAULT_CONFIG_FILE, *args):
    config = ConfigParser.RawConfigParser()
    config.read(cfg_file)
    config.set(*args)
    with open(cfg_file, 'wb') as cfg:
        config.write(cfg)

def get_http_proxies(config):
    if config.get('http_proxy') is not None:
        http_proxies = {'http':config['http_proxy'],'https':config['http_proxy']}
    else:
        http_proxies = None
    return http_proxies
