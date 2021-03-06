#!/opt/wapt/bin/python
# -*- coding: utf-8 -*-
# -----------------------------------------------------------------------
#    This file is part of WAPT
#    Copyright (C) 2013  Tranquil IT Systems http://www.tranquil.it
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
import os
import sys
import glob
import shutil

try:
    wapt_root_dir = os.path.abspath(os.path.dirname(os.path.realpath(__file__)))
except:
    wapt_root_dir = 'c:/tranquilit/wapt'

from waptutils import __version__

from waptutils import setloglevel,ensure_list,ensure_unicode
from waptcrypto import SSLCABundle,SSLPrivateKey,SSLCertificate
from waptpackage import PackageEntry,WaptLocalRepo

from optparse import OptionParser
import logging

logger = logging.getLogger()

__doc__ = """\
wapt-signpackages -c crtfile package1 package2

Resign a list of packages
"""

def main():
    parser=OptionParser(usage=__doc__,prog = 'wapt-signpackage')
    parser.add_option("-c","--certificate", dest="public_key", default='', help="Path to the PEM RSA certificate to embed identitiy in control. (default: %default)")
    parser.add_option("-k","--private-key", dest="private_key", default='', help="Path to the PEM RSA private key to sign packages.  (default: %default)")
    #parser.add_option("-w","--private-key-passwd", dest="private_key_passwd", default='', help="Path to the password of the private key. (default: %default)")
    parser.add_option("-l","--loglevel", dest="loglevel", default=None, type='choice',  choices=['debug','warning','info','error','critical'], metavar='LOGLEVEL',help="Loglevel (default: warning)")
    parser.add_option("-m","--message-digest", dest="md", default='sha256', help="Message digest type for signatures.  (default: %default)")
    parser.add_option("-s","--scan-packages", dest="doscan", default=False, action='store_true', help="Rescan packages and update local Packages index after signing.  (default: %default)")
    parser.add_option("-r","--remove-setup", dest="removesetup", default=False, action='store_true', help="Remove setup.py.  (default: %default)")
    parser.add_option("-i","--inc-release",    dest="increlease",    default=False, action='store_true', help="Increase release number when building package (default: %default)")
    parser.add_option("--maturity", dest="set_maturity", default=None, help="Set/change package maturity when signing package.  (default: None)")
    parser.add_option(     "--keep-signature-date", dest="keep_signature_date",default=False, action='store_true', help="Keep the current package signature date, and file changetime (default: %default)")
    parser.add_option(     "--if-needed", dest="if_needed", default=False, action='store_true',help="Re-sign package only if needed (default: warning)")
    (options,args) = parser.parse_args()

    loglevel = options.loglevel

    if len(logger.handlers) < 1:
        hdlr = logging.StreamHandler(sys.stderr)
        hdlr.setFormatter(logging.Formatter(
            u'%(asctime)s %(levelname)s %(message)s'))
        logger.addHandler(hdlr)

    if loglevel:
        setloglevel(logger,loglevel)
    else:
        setloglevel(logger,'warning')

    if len(args) < 1:
        print(parser.usage)
        sys.exit(1)

    if not options.public_key and not options.private_key:
        print('ERROR: No certificate found or specified')
        sys.exit(1)

    if options.private_key and os.path.isfile(options.private_key):
        key = SSLPrivateKey(options.private_key)
    else:
        cert = SSLCertificate(options.public_key or options.private_key)
        key = cert.matching_key_in_dirs()

    if not key:
        print('ERROR: No private key found or specified')
        sys.exit(1)

    args = ensure_list(args)

    ca_bundle = SSLCABundle()
    signers_bundle = SSLCABundle()
    signers_bundle.add_certificates_from_pem(pem_filename=options.public_key)

    waptpackages = []
    for arg in args:
        waptpackages.extend(glob.glob(arg))

    errors = []
    package_dirs = []
    for waptpackage in waptpackages:
        package_dir = os.path.abspath(os.path.dirname(waptpackage))
        if not package_dir in package_dirs:
            package_dirs.append(package_dir)

        print('Processing %s'%waptpackage)
        try:
            sign_needed=False
            pe = PackageEntry(waptfile = waptpackage)
            if options.removesetup:
                if pe.has_file('setup.py'):
                    with pe.as_zipfile(mode='a') as waptfile:
                        waptfile.remove('setup.py')
                    sign_needed=True

            if not sign_needed and options.if_needed:
                try:
                    pe.check_control_signature(trusted_bundle=signers_bundle,signers_bundle=signers_bundle)
                    for md in ensure_list(options.md):
                        if not pe.has_file(pe.get_signature_filename(md)):
                            raise Exception('Missing signature for md %s' % md)
                    logger.info('Skipping %s, already signed properly' % pe.asrequirement())
                    sign_needed = False
                except Exception as e:
                    logger.info('Sign is needed for %s because %s' % (pe.asrequirement(),e))
                    sign_needed = True

            if options.increlease:
                pe.inc_build()
                sign_needed = True

            if options.set_maturity is not None and pe.maturity != options.set_maturity:
                pe.maturity = options.set_maturity
                sign_needed = True

            if not options.if_needed or sign_needed:
                pe.sign_package(private_key=key,certificate = signers_bundle.certificates(),mds = ensure_list(options.md),keep_signature_date=options.keep_signature_date)
                newfn = pe.make_package_filename()
                if newfn != pe.filename:
                    newfn_path = os.path.join(package_dir,newfn)
                    if not os.path.isfile(newfn_path):
                        print(u"Renaming file from %s to %s to match new package's properties" % (pe.filename,newfn))
                        shutil.move(os.path.join(package_dir,pe.filename),newfn_path)
                    else:
                        print('WARNING: unable to rename file from %s to %s because target already exists' % (pe.filename,newfn))

            print('Done')
        except Exception as e:
            print(u'Error: %s'%ensure_unicode(e.message))
            errors.append([waptpackage,repr(e)])

    if options.doscan:
        for package_dir in package_dirs:
            if os.path.isfile(os.path.join(package_dir,'Packages')):
                print(u'Launching the update of Packages index in %s ...'% ensure_unicode(package_dir))
                repo = WaptLocalRepo(package_dir)
                repo.update_packages_index()
                print('Done')
    else:
        print("Don't forget to rescan your repository with wapt-scanpackages %s" % os.path.dirname(waptpackages[0]))

    if errors:
        print('Package not processed properly: ')
        for fn,error in errors:
            print(u'%s : %s' % (fn,error))

        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
