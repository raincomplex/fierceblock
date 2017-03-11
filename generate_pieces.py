#!/usr/bin/python2
import sys, pygame, math

confpath = sys.argv[1]

def parsevalue(s):
    s = s.strip()
    if ',' in s:
        return map(parsevalue, s.split(','))
    if s.isdigit():
        return int(s)
    return s

conf = {}
for line in open(confpath, 'r'):
    if '=' not in line:
        continue
    key, value = line.split('=', 1)
    key = key.strip()
    value = parsevalue(value)
    conf[key] = value

image = pygame.image.load(conf['image'])

w, h = image.get_size()
sw = w / (1 + (conf['size'][0] + 1)*4)
sh = h / (1 + (conf['size'][1] + 1)*len(conf['names']))

def getsquare(x, y):
    color = image.get_at((int((x+.5)*sw), int((y+.5)*sh)))
    for i in range(3):
        if color[i] != conf['piececolor'][i]:
            return False
    return True

print
print 'local P = {}'
print

y = 0
for name in conf['names']:
    print '-- piece ' + name
    blocks = []
    for x in range(4):
        s = ''
        lst = []
        for by in range(conf['size'][1]):
            by2 = by + 1 + y*(1+conf['size'][1])
            for bx in range(conf['size'][0]):
                bx2 = bx + 1 + x*(1+conf['size'][0])
                sq = getsquare(bx2, by2)
                if sq:
                    lst.append((bx - conf['center'][0], -(by - conf['center'][1])))
                if sq:
                    s += '#'
                else:
                    s += '.'
            s += '\n'
        print '-- ' + s.rstrip().replace('\n', '\n-- ')
        print
        blocks.append(lst)
        
    print "P['%s'] = {" % name
    print "   name = '%s'," % name
    print '   spawn = {x=%d, y=%d},' % (conf['spawn'][0], conf['spawn'][1])
    print '   rotation = {'
    for lst in blocks:
        lst = ['{x=%d, y=%d}' % (a, b) for a, b in lst]
        print '      {%s},' % ', '.join(lst)
    print '   },'
    print '}'
    print
    
    y += 1

print 'return P'
