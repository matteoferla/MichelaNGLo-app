#!/usr/bin/env python3
# -*- coding: utf-8 -*-
__doc__ = \
    """
    
    NB. Written for python 3, not tested under 2.
    """
__author__ = "Matteo Ferla. [Github](https://github.com/matteoferla)"
__email__ = "matteo.ferla@gmail.com"
__date__ = "${DATE}"
__license__ = "Cite me!"
__copyright__='GNU'
__version__ = "0"

import argparse, os, csv
from pprint import PrettyPrinter
pprint = PrettyPrinter().pprint

import sys
from warnings import warn
if sys.version_info[0] < 3:
    warn("Sorry man, I told you to use Python 3.")

import numpy as np
from mako.template import Template
import markdown
import string
###############################################################




class PyMolTranspiler:
    """
    The class initialises as a blank object with settings unless view and/or reps is passed.
    For views see `.convert_view(view_string)`, which processes the output of PyMOL command `set_view`
    For representation see `.convert_reps(reps_string)`, which process the output of PyMOL command `iterate 1UBQ, print resi, resn,name,ID,reps`
    """

    def __init__(self, verbose=False, validation=False,view=None, reps=None, pdb=''):
        self.verbose=verbose
        self.validation=validation
        self.pdb=pdb
        self.rotation=None
        self.modrotation=None
        self.position=None
        self.teleposition=None
        self.scale=10
        self.m4=None
        self.notes=''
        self.atoms=[]
        if view:
            self.convert_view(view)
        if reps:
            self.convert_reps(reps)


    def convert_view(self,text,output='matrix'):
        """
        Converts a Pymol `get_view` output to a NGL M4 matrix.
        If the output is set to string, the string will be a JS command that will require the object stage to exist.
        :param text:
        :param output: 'matrix' | 'string'
        :return: np 4x4 matrix or a NGL string
        """
        pymolian = np.array([float(i.replace('\\','').replace(',', '')) for i in text.split() if i.find('.') > 0])  # isnumber is for ints
        self.rotation = pymolian[0:9].reshape([3, 3])
        depth = pymolian[9:12]
        self.z = abs(depth[2])
        self.position = pymolian[12:15]
        self.teleposition = np.matmul(self.rotation, -depth) + self.position

        self.modrotation = np.multiply(self.rotation, np.array([[-1, -1, -1], [1, 1, 1], [-1, -1, -1]]).transpose())
        c = np.hstack((self.modrotation * self.z, np.zeros((3, 1))))
        m4 = np.vstack((c, np.ones((1, 4))))
        m4[3, 0:3] = -self.position
        self.m4=m4
        if self.validation == True:
            print('axes')
            print('cgo_arrow [-50,0,0], [50,0,0], gap=0,color=tv_red')
            print('cgo_arrow [0,-50,0], [0,50,0], gap=0,color=tv_green')
            print('cgo_arrow [0,0,-50], [0,0,50], gap=0,color=tv_blue')
            print('cgo_arrow {0}, {1}, gap=0'.format(self.teleposition.tolist(), self.position.tolist()))
            # So it is essential that the numbers be in f format and not e format. or it will be shifted. Likewise for the brackets.
            print('set_view (\\\n{})'.format(',\\\n'.join(['{0:f}, {1:f}, {2:f}'.format(x, y, z) for x, y, z in
                                                           zip(pymolian[:-2:3], pymolian[1:-1:3], pymolian[2::3])])))
        if output:
            return self.get_view(output)

    def get_view(self,output='matrix'):
        """
        If the output is set to string, the string will be a JS command that will require the object stage to exist.
        :param output: 'matrix' | 'string'
        :return: np 4x4 matrix or a NGL string
        """
        assert self.m4 is not None,'Cannot call get_view without having loaded the data with `convert_view(text)` or loaded a 4x4 transformation matrix (`.m4 =`)'
        if output.lower() == 'string':
            return 'var m4 = (new NGL.Matrix4).fromArray({}); stage.viewerControls.orient(m4);'.format(self.m4.reshape(16, ).tolist())
        elif output.lower() == 'matrix':
            return self.m4

    def convert_reps(self, text):
        """PyMOL>iterate 1UBQ, print resi, resn,name,ID,reps
        reps seems to be a binary number. controlling the following
        * 0th bit: sticks
        * 7th bit: line
        * 5th bit: cartoon
        * 2th bit: surface
        """
        for line in text.split('\n'):
            if not line:
                continue
            elif line.find('terate') != -1: #twice. I/i
                continue
            else:
                self.atoms.append(dict(zip(('resi', 'resn', 'name', 'ID', 'reps'),line.split())))
        return self.get_reps()

    def get_reps(self, tabbed=6): #'^'+atom['chain']
        assert self.atoms, 'Needs convert_reps first'
        T='\n'+'\t'*int(tabbed)
        sticks=[]
        lines=[]
        cartoon=[]
        for atom in self.atoms:
            reps=list(reversed("{0:0>8b}".format(int(atom['reps']))))
            # sticks
            if reps[0] == '1':
                sticks.append(atom['resi']+'.'+atom['name'])
            if reps[0] == '7':
                lines.append(atom['resi'] + '.' + atom['name'])
            if reps[5] == '1': # special case...
                cartoon.append(atom['resi'])
        cartoon=list(set(cartoon))
        code=['protein.removeAllRepresentations();']
        if lines:
            code.append('var lines = new NGL.Selection( "{0}" );'.format(' or '.join(lines)))
            code.append('protein.addRepresentation( "line", { sele: lines.string} );\n')
        if sticks:
            code.append('var sticks = new NGL.Selection( "{0}" );'.format(' or '.join(sticks)))
            code.append('protein.addRepresentation( "licorice", { sele: sticks.string} );\n')
        if cartoon:
            code.append('var cartoon = new NGL.Selection( "{0}" );'.format(' or '.join(cartoon)))
            code.append('protein.addRepresentation( "cartoon", { sele: cartoon.string} );\n')
        return T+T.join(code)

    def to_html_line(self, ngl='https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js', viewport='viewport', tabbed=6):
        """
        Returns a string to be copy-pasted into HTML code.
        :param ngl: (optional) the address to ngl.js. If unspecified it gets it from the RawGit CDN
        :param viewport: (optional) the id of the viewport div, without the hash.
        :return: a string.
        """
        return string.Template('''
        <!-- **inserted code**  -->
        <script src="$ngl" type="text/javascript"></script>
        <script type="text/javascript">
                    var stage = new NGL.Stage( "$viewport",{backgroundColor: "white"});
                    stage.loadFile( "$pdb").then(function (protein) {
                        window.protein=protein;
                        $orient
                        $reps
                        stage.viewerControls.orient(m4);
                    });
        </script>
        <!-- **end of code** -->
            ''').safe_substitute(reps=self.get_reps(tabbed=tabbed),
                                 orient=self.get_view(output='string'),
                                 pdb=('rcsb://'+self.pdb if len(self.pdb) == 4 else self.pdb),
                                 ngl=ngl,
                                 viewport=viewport)


    def write_hmtl(self, template_file='test.mako', output_file='test_generated.html', **kargs):
        if self.verbose:
            print('Making file {0} using template {1}'.format(output_file,template_file))
        template = Template(filename=template_file,format_exceptions=True)
        open(output_file, 'w', newline='\n').write(template.render_unicode(transpiler=self, **kargs))

def test():
    trans=PyMolTranspiler(verbose=True,validation=True)
    trans.pdb='1UBQ'
    view=''
    reps=''
    data=open('PyMol_output.txt').read().split('PyMOL>')
    for block in data:
        if 'get_view' in block:
            view = block
        elif 'iterate' in block: #strickly lowercase as it ends in _I_terate
            reps = block
    trans.convert_view(view)
    trans.convert_reps(reps)
    code=trans.to_html_line(ngl='ngl.js')
    trans.write_hmtl(template_file='test2.mako',output_file='test_2.html', code=code)


if __name__ == "__main__":
    ## ARGPARSER
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', action='version', version=__version__)
    parser.add_argument('--verbose', action='store_true', help='Runs giving details...')
    args = parser.parse_args()
    ## SCRIPT
    test()


    #import pymol
    #pymol.finish_launching()
    #pymol.load('test.pse')
    #pymol.cmd.get_view()
    #print('Done')
