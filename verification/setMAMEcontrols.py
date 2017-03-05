#!/usr/bin/python2
'makes left/right override up/down, to mimic the way the real game works'
import os, re
from xml.etree import ElementTree as ET

confpath = os.environ['HOME'] + '/.mame/cfg/default.cfg'
if not os.path.exists(confpath):
    print 'no config found at', confpath
    exit(1)

xml = ET.parse(confpath)

ports = {}
for el in xml.iter('port'):
    ports[el.attrib['type']] = el

dirs = {}
for d in 'up down left right'.split():
    dirs[d] = ports['P1_JOYSTICK_' + d.upper()].find('newseq').text.split()[0]

for d, key in sorted(dirs.items()):
    print '%-5s %s' % (d, key)

for d in 'up down'.split():
    ports['P1_JOYSTICK_' + d.upper()].find('newseq').text = ' NOT '.join((dirs[d], dirs['left'], dirs['right']))
for d in 'left right'.split():
    ports['P1_JOYSTICK_' + d.upper()].find('newseq').text = dirs[d]

xml.write(confpath)
print 'config written'
