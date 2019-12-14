
# Reads the Networkmanager headers and spits out the enums as a series of
# python variables.

import re
import six

enum_regex = re.compile(r'typedef enum(?:\s+[a-zA-Z]+)?\s*\{(.*?)\}', re.DOTALL)
comment_regex = re.compile(r'/\*.*?\*/', re.DOTALL)
headers = [ './usr/include/libnm/nm-dbus-interface.h',
            './usr/include/libnm/nm-vpn-dbus-interface.h',
            './usr/include/libnm/nm-errors.h' ]
k_v = {}

for h in headers:
    for enum in enum_regex.findall(open(h).read()):
        enum = comment_regex.sub('', enum)
        last = -1
        for key in enum.split(','):
            if not key.strip():
                continue
            if '=' in key:
                key, val = key.split('=')
                try:
                    val = eval(val.replace('LL',''))
                except:
                    tmp = val.strip();
                    val = k_v[tmp]
            else:
                val = last + 1
            key = key.strip()
            k_v[key] = val
            print('%s = %d' % (key, val))
            last = val
