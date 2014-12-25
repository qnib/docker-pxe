#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""Generate netlist

Usage:
  create_j2.py [options] <template> <dest_file>

Options:
  -h --help             Show this screen.
  --version             Show version.
"""

# load librarys
import sys
from docopt import docopt
import jinja2
import os

def main():
    """ main function """
    options = docopt(__doc__,  version='0.1')
    templateLoader = jinja2.FileSystemLoader( searchpath="/" )
    templateEnv = jinja2.Environment( loader=templateLoader )
    TEMPLATE_FILE = options.get("<template>")
    template = templateEnv.get_template( TEMPLATE_FILE )

    outputText = template.render( os.environ )
    with open(options.get("<dest_file>"), "w") as fd:
        fd.write(outputText)

if __name__ == "__main__":
    main()
