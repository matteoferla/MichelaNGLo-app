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
__copyright__ = 'GNU'
__version__ = "0"

import argparse, os, csv
from pprint import PrettyPrinter
from collections import defaultdict
pprint = PrettyPrinter().pprint

import sys, json
from warnings import warn

if sys.version_info[0] < 3:
    warn("Sorry man, I told you to use Python 3.")

import numpy as np
from mako.template import Template
import markdown
import string


# prevent pymol from launching in normal mode.
if __name__ == '__main__':
    pymol_argv = ['pymol', '-qc']
else:
    import __main__
    __main__.pymol_argv = ['pymol', '-qc']
import pymol
pymol.finish_launching()


###############################################################

class ColorItem:
    def __init__(self, value):
        assert len(value) == 3, 'value has to be tuple outputed from Pymol by (n, i, cmd.get_color_tuple(i)) for n,i in cmd.get_color_indices()'
        # ('bismuth', 5358, (0.6196078658103943, 0.30980393290519714, 0.7098039388656616))
        self.name = value[0]
        self.index = value[1]
        self.rgb = value[2]
        self.hex = "0x{0:02x}{1:02x}{2:02x}".format(int(value[2][0]*(2**8-1)),int(value[2][1]*(2**8-1)),int(value[2][2]*(2**8-1)))

class ColorSwatch:
    def __init__(self, colors):
        self._swatch = {}
        for color in colors:
            c=ColorItem(color)
            self._swatch[c.index]=c

    def __getitem__(self, index): # a pymol color index
        if int(index) in self._swatch:
            return self._swatch[int(index)]
        else:
            return self._swatch[1] # black

class PyMolTranspiler:
    """
    The class initialises as a blank object with settings unless the `file` (filename of PSE file) or `view` and/or `reps` is passed.
    For views see `.convert_view(view_string)`, which processes the output of PyMOL command `set_view`
    For representation see `.convert_reps(reps_string)`, which process the output of PyMOL command `iterate 1UBQ, print resi, resn,name,ID,reps`
    """
    # print [(n, i, cmd.get_color_tuple(i)) for n,i in cmd.get_color_indices()]
    swatch = ColorSwatch([('white', 0, (1.0, 1.0, 1.0)), ('black', 1, (0.0, 0.0, 0.0)), ('blue', 2, (0.0, 0.0, 1.0)), ('green', 3, (0.0, 1.0, 0.0)), ('red', 4, (1.0, 0.0, 0.0)),
                     ('cyan', 5, (0.0, 1.0, 1.0)), ('yellow', 6, (1.0, 1.0, 0.0)), ('dash', 7, (1.0, 1.0, 0.0)), ('magenta', 8, (1.0, 0.0, 1.0)),
                     ('salmon', 9, (1.0, 0.6000000238418579, 0.6000000238418579)), ('lime', 10, (0.5, 1.0, 0.5)), ('slate', 11, (0.5, 0.5, 1.0)), ('hotpink', 12, (1.0, 0.0, 0.5)),
                     ('orange', 13, (1.0, 0.5, 0.0)), ('chartreuse', 14, (0.5, 1.0, 0.0)), ('limegreen', 15, (0.0, 1.0, 0.5)), ('purpleblue', 16, (0.5, 0.0, 1.0)), ('marine', 17, (0.0, 0.5, 1.0)),
                     ('olive', 18, (0.7699999809265137, 0.699999988079071, 0.0)), ('purple', 19, (0.75, 0.0, 0.75)), ('teal', 20, (0.0, 0.75, 0.75)),
                     ('ruby', 21, (0.6000000238418579, 0.20000000298023224, 0.20000000298023224)), ('forest', 22, (0.20000000298023224, 0.6000000238418579, 0.20000000298023224)),
                     ('deepblue', 23, (0.25, 0.25, 0.6499999761581421)), ('grey', 24, (0.5, 0.5, 0.5)), ('gray', 25, (0.5, 0.5, 0.5)), ('carbon', 26, (0.20000000298023224, 1.0, 0.20000000298023224)),
                     ('nitrogen', 27, (0.20000000298023224, 0.20000000298023224, 1.0)), ('oxygen', 28, (1.0, 0.30000001192092896, 0.30000001192092896)),
                     ('hydrogen', 29, (0.8999999761581421, 0.8999999761581421, 0.8999999761581421)), ('brightorange', 30, (1.0, 0.699999988079071, 0.20000000298023224)),
                     ('sulfur', 31, (0.8999999761581421, 0.7749999761581421, 0.25)), ('tv_red', 32, (1.0, 0.20000000298023224, 0.20000000298023224)),
                     ('tv_green', 33, (0.20000000298023224, 1.0, 0.20000000298023224)), ('tv_blue', 34, (0.30000001192092896, 0.30000001192092896, 1.0)),
                     ('tv_yellow', 35, (1.0, 1.0, 0.20000000298023224)), ('yelloworange', 36, (1.0, 0.8700000047683716, 0.3700000047683716)),
                     ('tv_orange', 37, (1.0, 0.550000011920929, 0.15000000596046448)), ('pink', 48, (1.0, 0.6499999761581421, 0.8500000238418579)),
                     ('firebrick', 49, (0.6980000138282776, 0.12999999523162842, 0.12999999523162842)), ('chocolate', 50, (0.5550000071525574, 0.22200000286102295, 0.11100000143051147)),
                     ('brown', 51, (0.6499999761581421, 0.3199999928474426, 0.17000000178813934)), ('wheat', 52, (0.9900000095367432, 0.8199999928474426, 0.6499999761581421)),
                     ('violet', 53, (1.0, 0.5, 1.0)), ('lightmagenta', 154, (1.0, 0.20000000298023224, 0.800000011920929)),
                     ('density', 4155, (0.10000000149011612, 0.10000000149011612, 0.6000000238418579)), ('paleyellow', 5256, (1.0, 1.0, 0.5)), ('aquamarine', 5257, (0.5, 1.0, 1.0)),
                     ('deepsalmon', 5258, (1.0, 0.5, 0.5)), ('palegreen', 5259, (0.6499999761581421, 0.8999999761581421, 0.6499999761581421)),
                     ('deepolive', 5260, (0.6000000238418579, 0.6000000238418579, 0.10000000149011612)), ('deeppurple', 5261, (0.6000000238418579, 0.10000000149011612, 0.6000000238418579)),
                     ('deepteal', 5262, (0.10000000149011612, 0.6000000238418579, 0.6000000238418579)), ('lightblue', 5263, (0.75, 0.75, 1.0)), ('lightorange', 5264, (1.0, 0.800000011920929, 0.5)),
                     ('palecyan', 5265, (0.800000011920929, 1.0, 1.0)), ('lightteal', 5266, (0.4000000059604645, 0.699999988079071, 0.699999988079071)),
                     ('splitpea', 5267, (0.5199999809265137, 0.75, 0.0)), ('raspberry', 5268, (0.699999988079071, 0.30000001192092896, 0.4000000059604645)),
                     ('sand', 5269, (0.7200000286102295, 0.550000011920929, 0.30000001192092896)), ('smudge', 5270, (0.550000011920929, 0.699999988079071, 0.4000000059604645)),
                     ('violetpurple', 5271, (0.550000011920929, 0.25, 0.6000000238418579)), ('dirtyviolet', 5272, (0.699999988079071, 0.5, 0.5)),
                     ('deepsalmon', 5273, (1.0, 0.41999998688697815, 0.41999998688697815)), ('lightpink', 5274, (1.0, 0.75, 0.8700000047683716)), ('greencyan', 5275, (0.25, 1.0, 0.75)),
                     ('limon', 5276, (0.75, 1.0, 0.25)), ('skyblue', 5277, (0.20000000298023224, 0.5, 0.800000011920929)), ('bluewhite', 5278, (0.8500000238418579, 0.8500000238418579, 1.0)),
                     ('warmpink', 5279, (0.8500000238418579, 0.20000000298023224, 0.5)), ('darksalmon', 5280, (0.7300000190734863, 0.550000011920929, 0.5199999809265137)),
                     ('helium', 5281, (0.8509804010391235, 1.0, 1.0)), ('lithium', 5282, (0.800000011920929, 0.5019607543945312, 1.0)), ('beryllium', 5283, (0.7607843279838562, 1.0, 0.0)),
                     ('boron', 5284, (1.0, 0.7098039388656616, 0.7098039388656616)), ('fluorine', 5285, (0.7019608020782471, 1.0, 1.0)),
                     ('neon', 5286, (0.7019608020782471, 0.8901960849761963, 0.9607843160629272)), ('sodium', 5287, (0.6705882549285889, 0.3607843220233917, 0.9490196108818054)),
                     ('magnesium', 5288, (0.5411764979362488, 1.0, 0.0)), ('aluminum', 5289, (0.7490196228027344, 0.6509804129600525, 0.6509804129600525)),
                     ('silicon', 5290, (0.9411764740943909, 0.7843137383460999, 0.6274510025978088)), ('phosphorus', 5291, (1.0, 0.5019607543945312, 0.0)),
                     ('chlorine', 5292, (0.12156862765550613, 0.9411764740943909, 0.12156862765550613)), ('argon', 5293, (0.5019607543945312, 0.8196078538894653, 0.8901960849761963)),
                     ('potassium', 5294, (0.5607843399047852, 0.2509803771972656, 0.8313725590705872)), ('calcium', 5295, (0.239215686917305, 1.0, 0.0)),
                     ('scandium', 5296, (0.9019607901573181, 0.9019607901573181, 0.9019607901573181)), ('titanium', 5297, (0.7490196228027344, 0.7607843279838562, 0.7803921699523926)),
                     ('vanadium', 5298, (0.6509804129600525, 0.6509804129600525, 0.6705882549285889)), ('chromium', 5299, (0.5411764979362488, 0.6000000238418579, 0.7803921699523926)),
                     ('manganese', 5300, (0.6117647290229797, 0.47843137383461, 0.7803921699523926)), ('iron', 5301, (0.8784313797950745, 0.4000000059604645, 0.20000000298023224)),
                     ('cobalt', 5302, (0.9411764740943909, 0.5647059082984924, 0.6274510025978088)), ('nickel', 5303, (0.3137255012989044, 0.8156862854957581, 0.3137255012989044)),
                     ('copper', 5304, (0.7843137383460999, 0.5019607543945312, 0.20000000298023224)), ('zinc', 5305, (0.4901960790157318, 0.5019607543945312, 0.6901960968971252)),
                     ('gallium', 5306, (0.7607843279838562, 0.5607843399047852, 0.5607843399047852)), ('germanium', 5307, (0.4000000059604645, 0.5607843399047852, 0.5607843399047852)),
                     ('arsenic', 5308, (0.7411764860153198, 0.5019607543945312, 0.8901960849761963)), ('selenium', 5309, (1.0, 0.6313725709915161, 0.0)),
                     ('bromine', 5310, (0.6509804129600525, 0.16078431904315948, 0.16078431904315948)), ('krypton', 5311, (0.3607843220233917, 0.7215686440467834, 0.8196078538894653)),
                     ('rubidium', 5312, (0.43921568989753723, 0.18039216101169586, 0.6901960968971252)), ('strontium', 5313, (0.0, 1.0, 0.0)), ('yttrium', 5314, (0.5803921818733215, 1.0, 1.0)),
                     ('zirconium', 5315, (0.5803921818733215, 0.8784313797950745, 0.8784313797950745)), ('niobium', 5316, (0.45098039507865906, 0.7607843279838562, 0.7882353067398071)),
                     ('molybdenum', 5317, (0.3294117748737335, 0.7098039388656616, 0.7098039388656616)), ('technetium', 5318, (0.23137255012989044, 0.6196078658103943, 0.6196078658103943)),
                     ('ruthenium', 5319, (0.1411764770746231, 0.5607843399047852, 0.5607843399047852)), ('rhodium', 5320, (0.03921568766236305, 0.4901960790157318, 0.5490196347236633)),
                     ('palladium', 5321, (0.0, 0.4117647111415863, 0.5215686559677124)), ('silver', 5322, (0.7529411911964417, 0.7529411911964417, 0.7529411911964417)),
                     ('cadmium', 5323, (1.0, 0.8509804010391235, 0.5607843399047852)), ('indium', 5324, (0.6509804129600525, 0.4588235318660736, 0.45098039507865906)),
                     ('tin', 5325, (0.4000000059604645, 0.5019607543945312, 0.5019607543945312)), ('antimony', 5326, (0.6196078658103943, 0.38823530077934265, 0.7098039388656616)),
                     ('tellurium', 5327, (0.8313725590705872, 0.47843137383461, 0.0)), ('iodine', 5328, (0.5803921818733215, 0.0, 0.5803921818733215)),
                     ('xenon', 5329, (0.25882354378700256, 0.6196078658103943, 0.6901960968971252)), ('cesium', 5330, (0.34117648005485535, 0.09019608050584793, 0.5607843399047852)),
                     ('barium', 5331, (0.0, 0.7882353067398071, 0.0)), ('lanthanum', 5332, (0.43921568989753723, 0.8313725590705872, 1.0)), ('cerium', 5333, (1.0, 1.0, 0.7803921699523926)),
                     ('praseodymium', 5334, (0.8509804010391235, 1.0, 0.7803921699523926)), ('neodymium', 5335, (0.7803921699523926, 1.0, 0.7803921699523926)),
                     ('promethium', 5336, (0.6392157077789307, 1.0, 0.7803921699523926)), ('samarium', 5337, (0.5607843399047852, 1.0, 0.7803921699523926)),
                     ('europium', 5338, (0.3803921639919281, 1.0, 0.7803921699523926)), ('gadolinium', 5339, (0.2705882489681244, 1.0, 0.7803921699523926)),
                     ('terbium', 5340, (0.1882352977991104, 1.0, 0.7803921699523926)), ('dysprosium', 5341, (0.12156862765550613, 1.0, 0.7803921699523926)),
                     ('holmium', 5342, (0.0, 1.0, 0.6117647290229797)), ('erbium', 5343, (0.0, 0.9019607901573181, 0.4588235318660736)),
                     ('thulium', 5344, (0.0, 0.8313725590705872, 0.32156863808631897)), ('ytterbium', 5345, (0.0, 0.7490196228027344, 0.21960784494876862)),
                     ('lutetium', 5346, (0.0, 0.6705882549285889, 0.1411764770746231)), ('hafnium', 5347, (0.3019607961177826, 0.7607843279838562, 1.0)),
                     ('tantalum', 5348, (0.3019607961177826, 0.6509804129600525, 1.0)), ('tungsten', 5349, (0.12941177189350128, 0.5803921818733215, 0.8392156958580017)),
                     ('rhenium', 5350, (0.14901961386203766, 0.4901960790157318, 0.6705882549285889)), ('osmium', 5351, (0.14901961386203766, 0.4000000059604645, 0.5882353186607361)),
                     ('iridium', 5352, (0.09019608050584793, 0.3294117748737335, 0.529411792755127)), ('platinum', 5353, (0.8156862854957581, 0.8156862854957581, 0.8784313797950745)),
                     ('gold', 5354, (1.0, 0.8196078538894653, 0.13725490868091583)), ('mercury', 5355, (0.7215686440467834, 0.7215686440467834, 0.8156862854957581)),
                     ('thallium', 5356, (0.6509804129600525, 0.3294117748737335, 0.3019607961177826)), ('lead', 5357, (0.34117648005485535, 0.3490196168422699, 0.3803921639919281)),
                     ('bismuth', 5358, (0.6196078658103943, 0.30980393290519714, 0.7098039388656616)), ('polonium', 5359, (0.6705882549285889, 0.3607843220233917, 0.0)),
                     ('astatine', 5360, (0.4588235318660736, 0.30980393290519714, 0.2705882489681244)), ('radon', 5361, (0.25882354378700256, 0.5098039507865906, 0.5882353186607361)),
                     ('francium', 5362, (0.25882354378700256, 0.0, 0.4000000059604645)), ('radium', 5363, (0.0, 0.4901960790157318, 0.0)),
                     ('actinium', 5364, (0.43921568989753723, 0.6705882549285889, 0.9803921580314636)), ('thorium', 5365, (0.0, 0.729411780834198, 1.0)),
                     ('protactinium', 5366, (0.0, 0.6313725709915161, 1.0)), ('uranium', 5367, (0.0, 0.5607843399047852, 1.0)), ('neptunium', 5368, (0.0, 0.5019607543945312, 1.0)),
                     ('plutonium', 5369, (0.0, 0.41960784792900085, 1.0)), ('americium', 5370, (0.3294117748737335, 0.3607843220233917, 0.9490196108818054)),
                     ('curium', 5371, (0.47058823704719543, 0.3607843220233917, 0.8901960849761963)), ('berkelium', 5372, (0.5411764979362488, 0.30980393290519714, 0.8901960849761963)),
                     ('californium', 5373, (0.6313725709915161, 0.21176470816135406, 0.8313725590705872)), ('einsteinium', 5374, (0.7019608020782471, 0.12156862765550613, 0.8313725590705872)),
                     ('fermium', 5375, (0.7019608020782471, 0.12156862765550613, 0.729411780834198)), ('mendelevium', 5376, (0.7019608020782471, 0.05098039284348488, 0.6509804129600525)),
                     ('nobelium', 5377, (0.7411764860153198, 0.05098039284348488, 0.529411792755127)), ('lawrencium', 5378, (0.7803921699523926, 0.0, 0.4000000059604645)),
                     ('rutherfordium', 5379, (0.800000011920929, 0.0, 0.3490196168422699)), ('dubnium', 5380, (0.8196078538894653, 0.0, 0.30980393290519714)),
                     ('seaborgium', 5381, (0.8509804010391235, 0.0, 0.2705882489681244)), ('bohri', 5382, (0.8784313797950745, 0.0, 0.21960784494876862)),
                     ('hassium', 5383, (0.9019607901573181, 0.0, 0.18039216101169586)), ('meitnerium', 5384, (0.9215686321258545, 0.0, 0.14901961386203766)),
                     ('deuterium', 5385, (0.8999999761581421, 0.8999999761581421, 0.8999999761581421)), ('lonepair', 5386, (0.5, 0.5, 0.5)),
                     ('pseudoatom', 5387, (0.8999999761581421, 0.8999999761581421, 0.8999999761581421))])

    def __init__(self, file=None, verbose=False, validation=False, view=None, representation=None, pdb='', **settings):
        """
        Converter
        :param: file: filename of PSE file.
        :param verbose: print?
        :param validation: print validation_text set for pymol?
        :param view: the text from PymOL get_view
        :param representation: the text from PyMOL iterate
        :param pdb: the PDB name or code
        """
        self.verbose = verbose
        self.validation = validation #boolean for printing.
        self.validation_text = ''
        self.pdb = pdb
        self.rotation = None
        self.modrotation = None
        self.position = None
        self.teleposition = None
        self.scale = 10
        self.m4 = None
        self.notes = ''
        self.atoms = []
        self.cartoon=[]
        self.lines=[]
        self.sticks=[]
        self.colors=[]
        self.raw_pdb=None
        if file:
            assert '.pse' in file.lower(), 'Only PSE files accepted.'
            pymol.cmd.load(file)
            v = pymol.cmd.get_view()
            keys = ('ID', 'chain', 'resi', 'resn', 'name', 'elem', 'reps', 'color')
            myspace = {'data': []} #myspace['data'] is the same as self.atoms
            pymol.cmd.iterate('(all)', "data.append({'ID': ID, 'chain': chain, 'resi': resi, 'resn': resn, 'name':name, 'elem':elem, 'reps':reps, 'color':color})", space=myspace)
            self.convert_representation(myspace['data'])
            self.convert_view(v)
            pymol.cmd.save(file.replace('.pse','')+'.pdb')
            pymol.cmd.remove('(all)')
        if view:
            self.convert_view(view)
        if representation:
            self.convert_representation(representation)

    def convert_view(self, view, **settings):
        """
        Converts a Pymol `get_view` output to a NGL M4 matrix.
        If the output is set to string, the string will be a JS command that will require the object stage to exist.
        :param view: str or tuple
        :return: np 4x4 matrix or a NGL string
        """
        if isinstance(view, str):
            pymolian = np.array([float(i.replace('\\', '').replace(',', '')) for i in view.split() if i.find('.') > 0])  # isnumber is for ints
        else:
            pymolian = np.array(view)
        self.rotation = pymolian[0:9].reshape([3, 3])
        depth = pymolian[9:12]
        self.z = abs(depth[2])*.6
        self.position = pymolian[12:15]
        self.teleposition = np.matmul(self.rotation, -depth) + self.position

        self.modrotation = np.multiply(self.rotation, np.array([[-1, -1, -1], [1, 1, 1], [-1, -1, -1]]).transpose())
        c = np.hstack((self.modrotation * self.z, np.zeros((3, 1))))
        m4 = np.vstack((c, np.ones((1, 4))))
        m4[3, 0:3] = -self.position
        self.m4 = m4
        self.validation_text = 'axes\ncgo_arrow [-50,0,0], [50,0,0], gap=0,color=tv_red\n'+\
                               'cgo_arrow [0,-50,0], [0,50,0], gap=0,color=tv_green\n'+\
                               'cgo_arrow [0,0,-50], [0,0,50], gap=0,color=tv_blue\n'+\
                               'cgo_arrow {0}, {1}, gap=0'.format(self.teleposition.tolist(), self.position.tolist())+\
                               'set_view (\\\n{})'.format(',\\\n'.join(['{0:f}, {1:f}, {2:f}'.format(x, y, z) for x, y, z in
                                                           zip(pymolian[:-2:3], pymolian[1:-1:3], pymolian[2::3])]))
            # So it is essential that the numbers be in f format and not e format. or it will be shifted. Likewise for the brackets.
        if self.validation == True:
            print(self.validation)
        return self

    def get_view(self, output='matrix', **settings):
        """
        If the output is set to string, the string will be a JS command that will require the object stage to exist.
        :param output: 'matrix' | 'string'
        :return: np 4x4 matrix or a NGL string
        """
        assert self.m4 is not None, 'Cannot call get_view without having loaded the data with `convert_view(text)` or loaded a 4x4 transformation matrix (`.m4 =`)'
        if output.lower() == 'string':
            return '//orient\nvar m4 = (new NGL.Matrix4).fromArray({});\nstage.viewerControls.orient(m4);'.format(self.m4.reshape(16, ).tolist())
        elif output.lower() == 'matrix':
            return self.m4

    def convert_representation(self, represenation, **settings):
        """iterate all, ID,chain,resi, resn,name, elem,reps, color
        reps seems to be a binary number. controlling the following
        * 0th bit: sticks
        * 7th bit: line
        * 5th bit: cartoon
        * 2th bit: surface
        """
        if isinstance(represenation,str):
            text=represenation
            headers=('ID','chain','resi', 'resn', 'name', 'elem','reps', 'color') # gets ignored if iterate> like is present
            for line in text.split('\n'):
                if not line:
                    continue
                elif line.find('terate') != -1:  # twice. I/i
                    if line.count(':'):
                        continue
                    else:
                        headers = [element.rstrip().lstrip() for element in line.split(',')][1:]
                else:
                    # pymol seems to have two alternative outputs.
                    self.atoms.append(dict(zip(headers, line.replace('(','').replace(')','').replace(',','').replace('\'','').split())))
        else:
            self.atoms=represenation
        # convert reps field
        sticks = []
        lines = []
        cartoon = []
        surface = []
        for atom in self.atoms:
            reps = list(reversed("{0:0>8b}".format(int(atom['reps']))))
            # sticks
            if reps[0] == '1':  # sticks.
                sticks.append('{resi}:{chain}.{name}'.format_map(atom))
            if reps[7] == '1':  # lines.
                lines.append('{resi}:{chain}.{name}'.format_map(atom))
            if reps[5] == '1':  # cartoon. special case...
                cartoon.append('{resi}:{chain}'.format_map(atom))
            if reps[2] == '1':
                surface.append('{resi}:{chain}'.format_map(atom))
        self.cartoon = list(set(cartoon))
        self.sticks = sticks
        self.lines = lines
        # convert color field
        colorset=defaultdict(list)
        # self.swatch[atom['color']]

        def ddictlist():  # a dict of a dict of a list. simple ae?
            return defaultdict(list)

        def tdictlist():  # a dict of a dict of a dict of a list. simple ae?
            return defaultdict(ddictlist)

        carboncolorset = defaultdict(tdictlist) # chain -> resi -> color_id -> list of atom ids
        colorset = defaultdict(ddictlist) # element -> color_id -> list of atom ids
        for atom in self.atoms:
            if atom['elem'] == 'C':
                carboncolorset[atom['chain']][atom['resi']][atom['color']].append(atom['ID'])
            else:
                colorset[atom['elem']][atom['color']].append(atom['ID'])
        self.colors = {'carbon':carboncolorset,'non-carbon': colorset}
        return self

    @staticmethod
    def collapse_list(l):
        l=sorted(l)
        for i in range(1,len(l)):
            e = l[i]
            #if l[i-1] == ....
        return ' or '.join(l)

    def get_reps(self, inner_tabbed=1, **settings):  # '^'+atom['chain']
        assert self.atoms, 'Needs convert_reps first'
        code = ['//representations','protein.removeAllRepresentations();']
        if self.colors:
            color_str='color: schemeId,'
        else:
            color_str =''
        if self.lines:
            code.append('var lines = new NGL.Selection( "{0}" );'.format(' or '.join(self.lines)))
            code.append('protein.addRepresentation( "line", {'+color_str+' sele: lines.string} );')
        if self.sticks:
            code.append('var sticks = new NGL.Selection( "{0}" );'.format(' or '.join(self.sticks)))
            code.append('protein.addRepresentation( "licorice", {'+color_str+' sele: sticks.string} );')
        if self.cartoon:
            code.append('var cartoon = new NGL.Selection( "{0}" );'.format(' or '.join(self.cartoon)))
            code.append('protein.addRepresentation( "cartoon", {'+color_str+' sele: cartoon.string, smoothSheet: true} );') # capped does not add arrow heads.
        return self.indent(code, inner_tabbed)

    def get_color(self, uniform_non_carbon=False, inner_tabbed=1, **settings):
        #determine what colors we have.
        #{'carbon':carboncolorset,'non-carbon': colorset}
        elemental_mapping = {}
        catenary_mapping = {} #pertaining to chains...
        residual_mapping = {}
        serial_mapping = {}
        #non-carbon
        for elem in self.colors['non-carbon']: # element -> color_id -> list of atom ids
            if len(self.colors['non-carbon'][elem]) == 1:
                color_id=list(self.colors['non-carbon'][elem].keys())[0]
                elemental_mapping[elem] = self.swatch[color_id].hex
            else:
                colors_by_usage=sorted(self.colors['non-carbon'][elem].keys(), key=lambda c: len(self.colors['non-carbon'][elem][c]), reverse=True)
                elemental_mapping[elem]=self.swatch[colors_by_usage[0]].hex
                if not uniform_non_carbon:
                    for color_id in colors_by_usage[1:]:
                        for serial in self.colors['non-carbon'][elem][color_id]:
                            serial_mapping[serial] = self.swatch[color_id].hex
        #carbon
        for chain in self.colors['carbon']:
            colors_by_usage = sorted(set([col for resi in self.colors['carbon'][chain] for col in self.colors['carbon'][chain][resi]]),
                                     key=lambda c: len([self.colors['carbon'][chain][resi][c] for resi in self.colors['carbon'][chain] if c in self.colors['carbon'][chain][resi]]), reverse=True)
            catenary_mapping[chain] = self.swatch[colors_by_usage[0]].hex
            for resi in self.colors['carbon'][chain]: #-> resi -> color_id -> list of atom ids
                if len(self.colors['carbon'][chain][resi]) == 1:
                    color_id = list(self.colors['carbon'][chain][resi].keys())[0]
                    if color_id != colors_by_usage[0]:
                        residual_mapping[chain+resi] = self.swatch[color_id].hex
                else:
                    print(self.colors['carbon'][chain][resi])
                    # residue with different colored carbons!
                    for color_id in self.colors['carbon'][chain][resi]:
                        for serial in self.colors['carbon'][chain][resi][color_id]:
                            serial_mapping[serial] = self.swatch[color_id].hex
        code= string.Template('''//define colors
var nonCmap = $elem;
var sermap=$ser; 
var chainmap=$chain; 
var resmap=$res;
var schemeId = NGL.ColormakerRegistry.addScheme(function (params) {
    this.atomColor = function (atom) {
        chainid=atom.chainid;
        if (! isNaN(parseFloat(chainid))) {chainid=atom.chainname} // hack for chainid/chainIndex/chainname issue if the structure is loaded from string.
        if (atom.serial in sermap)  {return +sermap[atom.serial]}
        else if (atom.element in nonCmap) {return +nonCmap[atom.element]}
        else if (chainid+atom.resno in resmap) {return +resmap[chainid+atom.resno]}
        else if (chainid in chainmap) {return +chainmap[chainid]}
        else {return 0x000000} //black as the darkest error!
    };
});''').safe_substitute(elem=json.dumps(elemental_mapping), ser=serial_mapping, chain=catenary_mapping, res=residual_mapping)
        #RE hack: curious issue that multichain protein chainid sometimes is numeric: protein.structure.eachAtom(function(atom) {console.log(atom.chainid);}); or atom.chainIndex atom.chainname
        return self.indent(code, inner_tabbed)

    def indent(self,code, tabbed=0):
        if isinstance(code, str):
            code = code.split('\n')
        return ''.join([' ' * 4 * int(tabbed) + row + '\n' for row in code])

    def get_js(self, viewport='viewport', inner_tabbed=3, uniform_non_carbon=False, image=False, **settings):
        code ='\n'
        code += 'var stage = new NGL.Stage( "{viewport}",{{backgroundColor: "white"}});\n'.format(viewport=viewport)
        if self.raw_pdb:
            code += 'var stringBlob = new Blob( [ pdbData ], { type: "text/plain"} );'
            loader=' stringBlob, { ext: "pdb" } '
        else:
            loader='"rcsb://' + (self.pdb if len(self.pdb) == 4 else self.pdb)+'"'
        code += 'stage.loadFile({loader}).then(function (protein) {{\n'.format(loader=loader)
        code += '   window.protein=protein;\n'+\
                '   {color}\n  {reps}\n   {orient}\n'.format(reps=self.get_reps(), orient=self.get_view(output='string'), color=self.get_color(uniform_non_carbon)) +\
                '});\n'
        if image:
            code = """var imagemode=true;
function activate () {
    if (imagemode) {
        var w=$('#viewport img').width();
        var h=$('#viewport img').height();
        $('#viewport img').detach();
        $('#viewport p').detach();
        $('#viewport').css('width',w).css('height',h);
        """+code+"""
        imagemode = false;
    }
}
$('#viewport img').click(activate);
""".replace('viewport',viewport)
        if self.raw_pdb:
            return 'pdbData = `{0}`;'.format(self.raw_pdb)+self.indent(code, inner_tabbed) #don't indent the raw data!
        else:
            return self.indent(code, inner_tabbed)

    def get_html(self, ngl='https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js', viewport='viewport', tabbed=0, uniform_non_carbon=False, image=False, **settings):
        """
        Returns a string to be copy-pasted into HTML code.
        :param ngl: (optional) the address to ngl.js. If unspecified it gets it from the RawGit CDN
        :param viewport: (optional) the id of the viewport div, without the hash.
        :param image: (optional) advanced mode with clickable image?
        :return: a string.
        """
        if ngl:
            ngl_string='<script src="{0}" type="text/javascript"></script>\n'.format(ngl)
        else:
            ngl_string = ''
        code=('<!-- **inserted code**  -->\n{ngl_string}<script type="text/javascript">{js}</script>\n<!-- **end of code** -->').format(
                                 ngl_string=ngl_string,
                                 js=self.get_js(viewport, inner_tabbed=tabbed + 3, uniform_non_carbon=uniform_non_carbon, image=image))
        return self.indent(code, tabbed)

    def write_hmtl(self, template_file='test.mako', output_file='test_generated.html', **kargs):
        if self.verbose:
            print('Making file {0} using template {1}'.format(output_file, template_file))
        template = Template(filename=template_file, format_exceptions=True)
        open(output_file, 'w', newline='\n').write(template.render_unicode(transpiler=self, **kargs))
        return self

def test():
    trans = PyMolTranspiler(verbose=True, validation=False)
    trans.pdb = '1UBQ'
    view = ''
    reps = ''
    data = open('PyMol_output_example.txt').read().split('PyMOL>')
    for block in data:
        if 'get_view' in block:
            view = block
        elif 'iterate' in block:  # strickly lowercase as it ends in _I_terate
            reps = block
        elif not block:
            pass #empty line.
        else:
            warn('Unknown block: '+block)
    trans.convert_view(view)
    trans.convert_representation(reps)
    code = trans.get_html(tabbed=0)  # ngl='ngl.js'
    trans.write_hmtl(template_file='test2.mako', output_file='example.html', code=code)

def file_test():
    trans = PyMolTranspiler(file='1gfl.pse')
    print(trans.get_view())
    print(trans.get_reps())


if __name__ == "__main__":
    file_test()



    exit(0)
    ## ARGPARSER
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', action='version', version=__version__)
    parser.add_argument('--verbose', action='store_true', help='Runs giving details...')
    args = parser.parse_args()
    ## SCRIPT
    test()

    # import pymol
    # pymol.finish_launching()
    # pymol.load('test.pse')
    # pymol.cmd.get_view()
    # print('Done')
