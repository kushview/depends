#!/usr/bin/python3

import glob, os, shutil
from subprocess import call

HOST_X64='x86_64-apple-darwin'
HOST_ARM='arm-apple-darwin'
HOST_UNIVERSAL='universal-apple-darwin'

def main():
    if os.path.isdir (HOST_UNIVERSAL):
        shutil.rmtree (HOST_UNIVERSAL)
    
    libs = glob.glob ("./%s/**/*.a" % (HOST_X64), recursive=True)
    libs += glob.glob ("./%s/**/*.dylib" % (HOST_X64), recursive=True)
    for f1 in libs:
        if (os.path.islink (f1)): continue
        
        f2 = f1.replace ('%s' % (HOST_X64), '%s' % (HOST_ARM))
        f2 = f2.replace ('-mt-x64', '-mt-a64')
        f3 = f1.replace ('%s' % (HOST_X64), '%s' %(HOST_UNIVERSAL))
        f3 = f3.replace ('-mt-x64', '-mt')

        if os.path.exists (f1) and os.path.exists (f2):
            libdir = os.path.dirname (f3)
            if not os.path.isdir (libdir):
                os.makedirs (libdir)
            call (['lipo', '-create', f1, f2, '-output', f3])

    for f1 in glob.glob ("./%s/**/*.pc" % (HOST_X64), recursive=True):
        f2 = f1.replace (HOST_X64, HOST_UNIVERSAL)
        
        pcdir = os.path.dirname (f2)
        if not os.path.isdir (pcdir):
            os.makedirs (pcdir)
        
        f = open (f1, 'r')
        txt = f.read()
        f.close()
        
        f = open (f2, 'w')
        f.write (txt.replace (HOST_X64, HOST_UNIVERSAL))
        f.close()

    for subdir in 'native include etc share'.split():
        shutil.copytree (os.path.join (HOST_X64, subdir),
                         os.path.join (HOST_UNIVERSAL, subdir))

if __name__ == '__main__':
    main()
