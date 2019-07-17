#!/usr/bin/env python3
# -*- coding: utf-8 -*-
__doc__ = \
    """
    NB. Written for python 3, not tested under 2. See readme.md
    """
__author__ = "Matteo Ferla. [Github](https://github.com/matteoferla)"
__email__ = "matteo.ferla@gmail.com"
__date__ = "${DATE}"
__license__ = "Cite me!"
__copyright__ = 'GNU'
__version__ = "0"

import argparse, os, re, threading
from copy import deepcopy
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

from Bio.Data.IUPACData import protein_letters_1to3 as p1to3


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
        """
        ColorSwatch()._swatch is a dictionary with indicing being the pymol color number. The values are ColorItem instances.
        Preloading the colors is faster than querying pymol.
        `print [(n, i, cmd.get_color_tuple(i)) for n,i in cmd.get_color_indices()]` in Pymol generates a good amount, but it is not the full amount.
        :param colors: a list like [('white', 0, (1.0, 1.0, 1.0))]
        """
        self._swatch = {}
        for color in colors:
            c=ColorItem(color)
            self._swatch[c.index]=c

    def __getitem__(self, index): # a pymol color index
        if int(index) in self._swatch:
            return self._swatch[int(index)]
        else:
            return ColorItem(['', index, pymol.cmd.get_color_tuple(int(index))])


class PyMolTranspilerDeco:
    """
    Decorator for the bound methods of PyMolTranspiler that use Pymol.
    The session is shared... so only one thread at the time.
    """
    lock = threading.Lock()

    def __init__(self, fun):
        self.fun = fun


    def __get__(self, obj, type=None):
        return self.__class__(self.fun.__get__(obj, type))

    def __call__(self, *args, **kwargs):
        try:
            return self.fun(*args, **kwargs)
        except Exception as err:
            if self.lock.locked(): #the code errored before the lock could be released.
                self.close_up()
            raise err

    def clean_up(self):
        pymol.cmd.remove('(all)')
        pymol.cmd.delete('(all)')

    def close_up(self):
        self.clean_up()
        if self.lock.locked():
            self.lock.release()
        else:
            warn('The lock was off already...')

    def start_up(self):
        if not self.lock.acquire(timeout=60): #one minute wait.
            self.clean_up() #something failed very very ungracefully.
            self.lock.acquire()
            warn('The thread waited for over a minite!')
        self.clean_up()


class PyMolTranspiler:
    """
    The class initialises as a blank object with settings unless the `file` (filename of PSE file) or `view` and/or `reps` is passed.
    For views see `.convert_view(view_string)`, which processes the output of PyMOL command `set_view`
    For representation see `.convert_reps(reps_string)`, which process the output of PyMOL command `iterate 1UBQ, print resi, resn,name,ID,reps`
    """
    tmp = os.getcwd() #temp folder.
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
    _iterate_cmd = "data.append({'ID': ID,  'segi': segi, 'chain': chain, 'resi': resi, 'resn': resn, 'name':name, 'elem':elem, 'reps':reps, 'color':color, 'ss': ss, 'cartoon': cartoon, 'label': label})"

    @PyMolTranspilerDeco
    def __init__(self, file=None, verbose=False, validation=False, view=None, representation=None, pdb='', skip_disabled=True, **settings):
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
        self.slab_far = 1
        self.slab_near = 1
        self.fov = 40
        self.m4 = None
        self.m4_alt = None
        self.notes = ''
        self.atoms = []
        self.sticks = []  # 0 licorice
        self.stick_transparency = 0
        self.spheres = []  # 1 spacefill
        self.sphere_transparency = 0
        self.surface = []  # 2 surface
        self.surface_transparency = 0
        self.label = {} #sele : text
        self.cartoon = []  # 5 cartoon
        self.cartoon_transparency = 0
        self.ribbon = []  # 6 backbone
        self.ribbon_transparency = 0
        self.lines = []  # 7 line
        self.mesh = []  # 8 surface {contour: true}
        self.dots = []  # 9 point
        self.cell = []  # 11 cell
        self.putty = []  # NA.
        self.colors=[]
        self.distances=[] #and h-bonds...
        self.ss=[]
        self.code=''
        self.raw_pdb=None  #this is set from the instance `prot.raw_pdb = open(file).read()`
        self.custom_mesh = []
        if file:
            #print(file)
            assert '.pse' in file.lower(), 'Only PSE files accepted.'
            ##orient
            pymol.cmd.load(file)
            v = pymol.cmd.get_view()
            self.convert_view(v)
            self.fix_structure()
            names_for_mesh_route = [] #this is for a last ditch attempt.
            names_not_mesh = []
            ### sort the pymol objetcs into relevant methods
            for obj_name in pymol.cmd.get_names():
                obj = pymol.cmd.get_session(obj_name)['names'][0]
                """
                https://pymolwiki.org/index.php/Get_session
                0 => name
                1 => obj or sele?
                2 => enabled?
                3 => reps
                4 => obj_type
                5 => obj_data... complicated.
                6 => group_name
                """
                #pymol.cmd.get_type(obj_name) equivalents in comments
                if obj[4] == 1: #object:molecule
                    if obj[1]:
                        continue #PyMOL selection has no value.
                    if obj[2] == 0: # PyMOL disabled
                        if skip_disabled:
                            names_not_mesh.append(obj_name)
                        else:
                            raise NotImplementedError()
                    else:#enabled
                        """ the attr names in get_model differ slightly from the ones iterate gives.
                         as raw pymol output needs to  be an option and
                         the reps variable differs from flags (not even sure they are the same)
                         the get_model way has been depracated, even though iterate seems more barbarous.
                         here is the old code:
                        data = [{'ID': atom.id,
                                 'chain': atom.chain,
                                 'resi': atom.resi, #resi_number is int, but has offset issues?
                                 'resn': atom.resn, #3letter
                                 'name': atom.name,
                                 'elem': atom.symbol,
                                 'reps': atom.flags,
                                 'color': atom.color_code,
                                 'segi': atom.segi}
                                for atom in pymol.cmd.get_model(obj_name)]
                        """
                        myspace = {'data': []}  # myspace['data'] is the same as self.atoms
                        pymol.cmd.iterate(obj_name, self._iterate_cmd, space=myspace)
                        self.convert_representation(myspace['data'], **settings)
                        self.stick_transparency = float(pymol.cmd.get('stick_transparency'))
                        self.surface_transparency = float(pymol.cmd.get('transparency'))
                        self.cartoon_transparency = float(pymol.cmd.get('cartoon_transparency'))
                        self.sphere_transparency = float(pymol.cmd.get('sphere_transparency'))
                        self.ribbon_transparency = float(pymol.cmd.get('ribbon_transparency'))
                        self.fov = float(pymol.cmd.get("field_of_view"))
                        self.fog = float(pymol.cmd.get("fog_start"))*100
                        self.parse_ss(myspace['data'])
                        names_not_mesh.append(obj_name)
                elif obj[4] == 2: #object:map
                    names_for_mesh_route.append(obj_name)
                elif obj[4] == 3: #object:mesh
                    names_for_mesh_route.append(obj_name)
                elif obj[4] == 4: #'object:measurement'
                    if obj[2] == 0: # PyMOL disabled
                        if skip_disabled:
                            names_not_mesh.append(obj_name)
                        else:
                            raise NotImplementedError()
                    else:
                        list_of_coordinates = obj[5][2][0][1]
                        current_distances = []
                        for pi in range(0, len(list_of_coordinates), 6):
                            coord_A = list_of_coordinates[pi:pi + 3]
                            coord_B = list_of_coordinates[pi + 3:pi + 6]
                            current_distances.append({'atom_A': self.get_atom_id_of_coords(coord_A),
                                                      'atom_B': self.get_atom_id_of_coords(coord_B)})
                        self.distances.append({'pairs': current_distances, 'color': obj[5][0][2]})
                elif obj[4] == 5: # no idea
                    continue
                elif obj[4] == 6: #object:cgo
                    names_for_mesh_route.append(obj_name)
                elif obj[4] == 7: #object:surface
                    names_for_mesh_route.append(obj_name)
                elif obj[4] == 12: # object:group
                    continue
            pdbfile = os.path.join(self.tmp, os.path.split(file)[1].replace('.pse','.pdb'))
            pymol.cmd.save(pdbfile)
            pymol.cmd.delete('all')
            if names_for_mesh_route and 1==0: ##TODO reimplement
                """
                This secion has an issue with the alibi transformation.
                The coordinate vectors need to be moved by the camera movement probably.
                """
                objfile = os.path.join(self.tmp, os.path.split(file)[1].replace('.pse','.obj'))
                pymol.cmd.save(objfile)
                self.custom_mesh = PyMolTranspiler.convert_mesh(open(objfile,'r'))
                os.remove(objfile)
        if view:
            self.convert_view(view)
        if representation:
            self.convert_representation(representation, **settings)

    @classmethod
    def get_atom_id_of_coords(cls, coord):
        """
        Returns the pymol atom object correspondng to coord. "Needed" for distance.
        :param coord: [x, y, z] vector
        :return: atom
        """
        for on in pymol.cmd.get_names(enabled_only=1): #pymol.cmd.get_names_of_type('object:molecule') does not handle enabled.
            if pymol.cmd.get_type(on) == 'object:molecule':
                o = pymol.cmd.get_model(on)
                if o:
                    for atom in o.atom:
                        if all([atom.coord[i] == c for i,c in enumerate(coord)]):
                            return atom
        else:
            return None

    @classmethod
    @PyMolTranspilerDeco
    def load_pdb(cls, file):
        """
        Loads a pdb into a transpiler obj
        :param file: str file name
        :return: self
        """
        self = cls()
        with open(file) as w:
            self.raw_pdb = w.read()
        pymol.cmd.load(file)
        self.fix_structure()
        myspace = {'data': []}
        # myspace['data'] is the same as self.atoms, which is "kind of the same" as pymol.cmd.get_model('..').atoms
        pymol.cmd.iterate('(all)', self._iterate_cmd, space=myspace)
        self.parse_ss(myspace['data'])
        return self


    @staticmethod
    def _mutagen(outfile, mutations, chain):
        """
        Create a mutant protein based on a list of mutations on the already loaded protein.
        :param outfile: str the file to save the mod as.
        :param mutations: list of string in the single letter format (A234P) without "p.".
        :param chain: str chain id in the pdb loaded.
        :return: None
        """
        pymol.cmd.wizard("mutagenesis")
        pymol.cmd.do("refresh_wizard")
        for mutant in mutations:
            n = re.search("(\d+)", mutant).group(1)
            if re.match("\w{3}d+\w{3}", mutant):  # 3 letter Arg
                f = re.match("\w{3}d+(\w{3})", mutant).group(1).upper()
            else:  # 1 letter R
                f = p1to3[mutant[-1]].upper()
            pymol.cmd.get_wizard().set_mode(f)
            #print('*'*10,f"{chain}/{n}/")
            pymol.cmd.get_wizard().do_select(f"{chain}/{n}/")
            pymol.cmd.get_wizard().apply()
            #m = pymol.cmd.get_model(f"resi {n} and name CA").atom
            #if m:
            #    pass
            #    # assert f == m[0].resn, f'Something is not right {r} has a {m[0].atom}'
        pymol.cmd.save(outfile)
        pymol.cmd.delete('(all)')

    @classmethod
    @PyMolTranspilerDeco
    def mutate_code(cls, code, outfile, mutations, chain):
        """
        Create a mutant protein based on a list of mutations on a PDB code.
        :param code: str pdb code.
        :param outfile: str the file to save the mod as.
        :param mutations: list of string in the single letter format (A234P) without "p.".
        :param chain: str chain id in the pdb loaded.
        :return:
        """
        pymol.cmd.fetch(code)
        cls._mutagen(outfile, mutations, chain)
        return 1

    @classmethod
    @PyMolTranspilerDeco
    def mutate_file(cls, infile, outfile, mutations, chain):
        """
        Create a mutant protein based on a list of mutations on a PDB file path.
        :param infile: str
        :param outfile: str the file to save the mod as.
        :param mutations: list of string in the single letter format (A234P) without "p.".
        :param chain: str chain id in the pdb loaded.
        :return:
        """
        pymol.cmd.load(infile)
        cls._mutagen(outfile, mutations, chain)
        return 1

    def fix_structure(self):
        """
        Fix any issues with structure. see pymol_model_chain_segi.md for more.
        empty chain issue.
        :return:
        """
        # This really ought to a class and this half-breed. But get new letter returns a letter not in old_chains
        old_chains = list()

        def get_new_letter():
            possible = iter('ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                            'abcdefghijklmnopqrstuvwxyz')
                           # 'ßÞÐÅÆØ' + 'ÀÁÂÃÄÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝ' +
                           # 'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ')
            new = next(possible)
            while new in old_chains:
                new = next(possible)
            old_chains.append(new)
            return new
        # whereas a chain can be called ?, it causes problems. So these are strictly JS \w characters.
        # Only latin-1 is okay in NGL. Any character above U+00FF will be rendered as the last two bytes. (U+01FF will be U+00FF say)
        #non-ascii are not okay in PyMol
        for on in pymol.cmd.get_names(enabled_only=1):
            # pymol.cmd.get_names_of_type('object:molecule') does not handle enabled.
            if pymol.cmd.get_type(on) == 'object:molecule':
                o = pymol.cmd.get_model(on)
                if o:
                    chains = set([atom.chain for atom in o.atom])
                    for c in chains:
                        if not c: # missing chain ID is still causing issues.
                            new_chain = get_new_letter()
                            pymol.cmd.alter(f"{on} and chain ''", f'chain="{new_chain}"')
                        elif c in old_chains:
                            new_chain = get_new_letter()
                            pymol.cmd.alter(f"{on} and chain {c}", f'chain="{new_chain}"')
                        else:
                            old_chains.append(c)
        pymol.cmd.alter("all", "segi=''") # not needed. NGL does not recognise segi. Currently writtten to ignore it.
        pymol.cmd.sort('all')
        pymol.cmd.create('mike_combined','enabled',1) #the 1 means that only the first "state" = model is used.
        for on in pymol.cmd.get_names_of_type('object:molecule'):
            if on != 'mike_combined':
                pymol.cmd.delete(on)

    def convert_view(self, view, **settings):
        """
        Converts a Pymol `get_view` output to a NGL M4 matrix.
        If the output is set to string, the string will be a JS command that will require the object stage to exist.

        fog and alpha not implemented.
        pymol.cmd.get("field_of_view"))
        pymol.cmd.get("fog_start")

        :param view: str or tuple
        :return: np 4x4 matrix or a NGL string
        """
        if isinstance(view, str):
            pymolian = np.array([float(i.replace('\\', '').replace(',', '')) for i in view.split() if i.find('.') > 0])  # isnumber is for ints
        else:
            pymolian = np.array(view)
        self.rotation = pymolian[0:9].reshape([3, 3])
        depth = pymolian[9:12]
        self.z = abs(depth[2])*1 #arbitrary... correction. fov should be the same.
        self.position = pymolian[12:15]
        self.teleposition = np.matmul(self.rotation, -depth) + self.position
        self.slab_near = pymolian[11] + pymolian[15]
        self.slab_far = pymolian[11] + pymolian[16]
        # slabs are not clipping...
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
        return self

    def get_view(self, output='matrix', **settings):
        """
        If the output is set to string, the string will be a JS command that will require the object stage to exist.
        :param output: 'matrix' | 'string'
        :return: np 4x4 matrix or a NGL string
        """
        warn('This method will be removed soon.',DeprecationWarning)
        assert self.m4 is not None, 'Cannot call get_view without having loaded the data with `convert_view(text)` or loaded a 4x4 transformation matrix (`.m4 =`)'
        if output.lower() == 'string':
            return '//orient\nvar m4 = (new NGL.Matrix4).fromArray({});\nstage.viewerControls.orient(m4);'.format(self.m4.reshape(16, ).tolist())
        elif output.lower() == 'matrix':
            return self.m4

    def convert_representation(self, represenation, **settings):
        """iterate all, ID, segi, chain,resi, resn,name, elem,reps, color, ss
        reps seems to be a binary number. controlling the following
        * 0th bit: sticks
        * 7th bit: line
        * 5th bit: cartoon
        * 2th bit: surface
        """
        if isinstance(represenation,str):
            text=represenation
            headers=('ID','segi','chain','resi', 'resn', 'name', 'elem','reps', 'color', 'cartoon', 'label') # gets ignored if iterate> like is present
            for line in text.split('\n'):
                if not line:
                    continue
                elif line.find('terate') != -1:  # twice. [Ii]terate
                    if line.count(':'):
                        continue
                    else:
                        headers = [element.rstrip().lstrip() for element in line.split(',')][1:]
                else:
                    # pymol seems to have two alternative outputs.
                    self.atoms.append(dict(zip(headers, line.replace('(','').replace(')','').replace(',','').replace('\'','').split())))
        else:
            self.atoms=represenation
        # convert reps field. See https://github.com/matteoferla/MichelaNGLo#primitive-equivalence-table for table.
        rep2name = ['sticks', 'spheres', 'surface', 'label', 'non-bounded spheres', 'cartoon', 'ribbon', 'lines', 'mesh','dots','non-bounded', 'cell', 'putty']
        ## determine shape of protein data
        structure = {}
        for atom in self.atoms:
            if atom['chain'] not in structure:
                structure[ atom['chain'] ] = {}
            if atom['resi'] not in structure[ atom['chain'] ]:
                structure[ atom['chain'] ][ atom['resi'] ] = {}
            structure[ atom['chain'] ][ atom['resi'] ][ atom['name'] ] = False
        ## deetermine values for protein
        repdata = {rep2name[i]: deepcopy(structure) for i in (0, 1, 2, 5, 6, 7, 8, 9, 11, 12)}
        for atom in self.atoms:
            reps = [r == '1' for r in reversed("{0:0>12b}".format(int(atom['reps'])))]
            reps[1] = reps[1] or reps[4]  # hetero spheres fix
            reps[7] = reps[7] or reps[10]  # hetero line fix
            assert atom['chain'], 'The atom has no chain. This ought to be fixed upstream!'
            for i in (0, 1, 2, 5, 6, 7, 8, 9, 11):
                repdata[ rep2name[i] ][ atom['chain'] ][ atom['resi'] ][ atom['name'] ] = reps[i]
            #label
            if reps[3]:
                self.label['{resi}:{chain}.{name}'.format(**atom)] = atom['label']
        ## deal with putty.
        for atom in self.atoms:
            if atom['name'] == 'CA' and atom['cartoon'] == 7:  # putty override.
                repdata['putty'][ atom['chain'] ][ atom['resi'] ] = {name: True for name in structure[ atom['chain'] ][ atom['resi'] ]}
                # cartoon off!
                repdata['cartoon'][atom['chain']][atom['resi']] = {name: False for name in structure[ atom['chain'] ][ atom['resi'] ]}
        ##convert
        for i in (0, 1, 2, 5, 6, 7, 8, 9, 11, 12):
            transdata = []
            rep_name = rep2name[i]
            chain_homo_state = True  # are the chains homogeneously represented as rep_name?
            chain_list = []  # a list in case the chains differ
            for chain in repdata[rep_name]:
                resi_homo_state = True  # are the residues homogeneously represented as rep_name?
                resi_list = [] # a list in case the chain is not homogeneous.
                for resi in repdata[rep_name][chain]:
                    if all(repdata[rep_name][chain][resi].values()):
                        resi_list.append(resi)
                    elif any(repdata[rep_name][chain][resi].values()): # some/all are present
                        if not all(repdata[rep_name][chain][resi].values()):   # some are present
                            transdata.extend([f'{resi}:{chain}.{name}' for name in repdata[rep_name][chain][resi] if repdata[rep_name][chain][resi]])
                            resi_homo_state = False
                    else: # none are.
                        resi_homo_state = False
                if resi_homo_state: # no residues differ
                    chain_list.append(':{chain}')
                else:
                    transdata.extend([f'{resi}:{chain}' for resi in resi_list]) # todo... add selection reduction
                    chain_homo_state = False
            if chain_homo_state:
                transdata.append('*')
            elif len(chain_list):
                transdata.extend(chain_list)
            else:
                pass
            setattr(self, rep_name, transdata)

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
        self.convert_color(**settings)
        return self

    @staticmethod
    def collapse_list(l):
        ## not implemented
        l=sorted(l)
        for i in range(1,len(l)):
            e = l[i]
            #if l[i-1] == ....
        return ' or '.join(l)


    def get_reps(self, inner_tabbed=1, stick='sym_licorice', **settings):  # '^'+atom['chain']
        warn('This method will be removed soon.', DeprecationWarning)
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
            if stick == 'sym_licorice':
                code.append('protein.addRepresentation( "licorice", {'+color_str+' sele: sticks.string, multipleBond: "symmetric"} );')
            elif stick == 'licorice':
                code.append('protein.addRepresentation( "licorice", {' + color_str + ' sele: sticks.string} );')
            elif stick == 'hyperball':
                code.append('protein.addRepresentation( "hyperball", {' + color_str + ' sele: sticks.string} );')
            elif stick == 'ball':
                code.append('protein.addRepresentation( "ball+stick", {' + color_str + ' sele: sticks.string, multipleBond: "symmetric"} );')
        if self.cartoon:
            code.append('var cartoon = new NGL.Selection( "{0}" );'.format(' or '.join(self.cartoon)))
            code.append('protein.addRepresentation( "cartoon", {'+color_str+' sele: cartoon.string, smoothSheet: true} );') # capped does not add arrow heads.
        if self.surface:
            code.append('var surf = new NGL.Selection( "{0}" );'.format(' or '.join(self.surface)))
            code.append('protein.addRepresentation( "surface", {' + color_str + ' sele: surf.string} );')
        return self.indent(code, inner_tabbed)

    def convert_color(self, uniform_non_carbon=False, inner_tabbed=1, **settings):
        #determine what colors we have.
        #{'carbon':carboncolorset,'non-carbon': colorset}
        self.elemental_mapping = {}
        self.catenary_mapping = {} #pertaining to chains...
        self.residual_mapping = {}
        self.serial_mapping = {}
        #non-carbon
        for elem in self.colors['non-carbon']: # element -> color_id -> list of atom ids
            if len(self.colors['non-carbon'][elem]) == 1:
                color_id=list(self.colors['non-carbon'][elem].keys())[0]
                self.elemental_mapping[elem] = self.swatch[color_id].hex
            else:
                colors_by_usage=sorted(self.colors['non-carbon'][elem].keys(), key=lambda c: len(self.colors['non-carbon'][elem][c]), reverse=True)
                self.elemental_mapping[elem]=self.swatch[colors_by_usage[0]].hex
                if not uniform_non_carbon:
                    for color_id in colors_by_usage[1:]:
                        for serial in self.colors['non-carbon'][elem][color_id]:
                            self.serial_mapping[serial] = self.swatch[color_id].hex
        #carbon
        for chain in self.colors['carbon']:
            colors_by_usage = sorted(set([col for resi in self.colors['carbon'][chain] for col in self.colors['carbon'][chain][resi]]),
                                     key=lambda c: len([self.colors['carbon'][chain][resi][c] for resi in self.colors['carbon'][chain] if c in self.colors['carbon'][chain][resi]]), reverse=True)
            self.catenary_mapping[chain] = self.swatch[colors_by_usage[0]].hex
            for resi in self.colors['carbon'][chain]: #-> resi -> color_id -> list of atom ids
                if len(self.colors['carbon'][chain][resi]) == 1:
                    color_id = list(self.colors['carbon'][chain][resi].keys())[0]
                    if color_id != colors_by_usage[0]:
                        self.residual_mapping[chain+resi] = self.swatch[color_id].hex
                else:
                    # residue with different colored carbons!
                    for color_id in self.colors['carbon'][chain][resi]:
                        for serial in self.colors['carbon'][chain][resi][color_id]:
                            self.serial_mapping[serial] = self.swatch[color_id].hex
        return self

    def parse_ss(self, data, **settings):
        def _deal_with():
            if ss_last == 'H':  # previous was the other type
                self.ss.append('{typos}    {ss_count: >3}HA {resn_start} {chain}  {resi_start: >3}  {resn_end} {chain}  {resi_end: >3} {h_class: >2}                                  {length: >2}'.format(
                    typos='HELIX',
                    ss_count=ss_count[ss_last],
                    resn_start=resn_start,
                    resi_start=resi_start,
                    resn_end=resn_last,
                    resi_end=resi_last,
                    chain=chain,
                    h_class=1,
                    length=int(resi_last) - int(resi_start)
                ))
                ss_count[ss_last] += 1
            elif ss_last == 'S':  # previous was the other type
                self.ss.append('{typos}  {ss_count: >3} {ss_count: >2}S 1 {resn_start} {chain} {resi_start: >3}  {resn_end} {chain} {resi_end: >3}  0'.format(
                    typos='SHEET',
                    ss_count=ss_count[ss_last],
                    resn_start=resn_start,
                    resi_start=resi_start,
                    resn_end=resn_last,
                    resi_end=resi_last,
                    chain=chain,
                    h_class=0,
                    length=int(resi_last) - int(resi_start)
                ))
                ss_count[ss_last] += 1

        ss_last = 'L'
        resi_start = '0'
        resn_start = 'XXX'
        resi_last = '0'
        resn_last = 'XXX'
        ss_count = {'H': 1, 'S': 1, 'L': 0}
        chain = 'X'
        for line in data:  # ss_list:
            if line['name'] == 'CA':
                (resi_this, ss_this, resn_this, chain) = (line['resi'], line['ss'], line['resn'], line['chain'])
                if ss_last != ss_this:
                    # deal with previous first
                    _deal_with()
                    # deal with current
                    if ss_this in ('S', 'H'):  # start of a new
                        resi_start = resi_this
                        resn_start = resn_this
                        ss_last = ss_this
                # move on
                resi_last = resi_this
                resn_last = resn_this
                ss_last = ss_this
        _deal_with()
        return self

    def get_html(self, ngl='https://cdn.rawgit.com/arose/ngl/v0.10.4-1/dist/ngl.js', **settings):
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
        if not self.code:
            self.get_js(**settings)
        return '<!-- **inserted code**  -->\n{ngl_string}<script type="text/javascript">{js}</script>\n<!-- **end of code** -->'.format(
                                 ngl_string=ngl_string,
                                 js=self.code)

    def write_hmtl(self, template_file='test.mako', output_file='test_generated.html', **kargs):
        if self.verbose:
            print('Making file {0} using template {1}'.format(output_file, template_file))
        template = Template(filename=template_file, format_exceptions=True)
        open(output_file, 'w', newline='\n').write(
            template.render_unicode(transpiler=self, **kargs))
        return self

    def get_js(self, **settings):
        code=Template(filename=os.path.join('michelanglo_app','transpiler_templates', 'output.js.mako'))\
            .render_unicode(structure=self, **settings)
        self.code=code
        return code

    def get_loadfun_js(self, **settings):
        code = Template(filename=os.path.join('michelanglo_app','transpiler_templates',  'loadfun.js.mako')) \
            .render_unicode(structure=self, **settings)
        self.code = code
        return code

    @classmethod
    def convert_mesh(cls,fh, scale=0, centroid_mode='unaltered', origin=None):
        """
        Given a fh or iterable of strings, return a mesh, with optional transformations.
        Note color will be lost.
        Only accepts trianglular meshes!
        :param fh: file handle
        :param scale: 0 do nothing. else Angstrom size
        :param centroid_mode: unaltered | origin | center
        :param origin: if centroid_mode is origin get given a 3d vector.
        :return: {'o_name': object_name, 'triangles': mesh triangles}
        """
        mesh = []
        o_name = ''
        scale_factor = 0
        vertices = []
        trilist = []
        sum_centroid = [0, 0, 0]
        min_size = [0, 0, 0]
        max_size = [0, 0, 0]
        centroid = [0, 0, 0]
        for row in fh:
            if row[0] == 'o':
                if o_name:
                    mesh.append({'o_name': o_name, 'triangles': trilist})
                    vertices = []
                    trilist = []
                    scale_factor = 0
                    sum_centroid = [0, 0, 0]
                    min_size = [0, 0, 0]
                    max_size = [0, 0, 0]
                o_name = row.rstrip().replace('o ', '')
            elif row[0] == 'v':
                vertex = [float(e) for e in row.split()[1:]]
                vertices.append(vertex)
                for ax in range(3):
                    sum_centroid[ax] += vertex[ax]
                    min_size[ax] = min(min_size[ax], vertex[ax])
                    max_size[ax] = max(max_size[ax], vertex[ax])
            elif row[0] == 'f':
                if not scale:
                    scale_factor = 1
                elif scale_factor == 0:  # first face.27.7  24.5
                    # euclid = sum([(max_size[ax]-min_size[ax])**2 for ax in range(3)])**0.5
                    scale_factor = scale / max(
                        [abs(max_size[ax] - min_size[ax]) for ax in range(3)])
                    if centroid_mode == 'origin':
                        centroid = [sum_centroid[ax] / len(vertices) for ax in range(3)]
                    elif centroid_mode == 'unaltered':
                        centroid = [0, 0, 0]
                    elif centroid_mode == 'custom':
                        #origin = request.POST['origin'].split(',')
                        centroid = [sum_centroid[ax] / len(vertices) - float(origin[ax]) / scale_factor for ax in
                                    range(3)]  # the user gives scaled origin!
                    else:
                        raise ValueError('Invalid request')
                new_face = [e.split('/')[0] for e in row.split()[1:]]
                if (len(new_face) != 3):
                    pass
                trilist.extend(
                    [int((vertices[int(i) - 1][ax] - centroid[ax]) * scale_factor * 100) / 100 for i in new_face[0:3]
                     for ax in range(3)])
        mesh.append({'o_name': o_name, 'triangles': trilist})
        print(mesh)
        return mesh

def test():
    transpiler = PyMolTranspiler(verbose=True, validation=False)
    transpiler.pdb = '1UBQ'
    view = ''
    reps = ''
    data = open(os.path.join('michelanglo_app','static','pymol_demo.txt')).read().split('PyMOL>')
    for block in data:
        if 'get_view' in block:
            view = block
        elif 'iterate' in block:  # strickly lowercase as it ends in *I*terate
            reps = block
        elif not block:
            pass #empty line.
        else:
            warn('Unknown block: '+block)
    transpiler.convert_view(view)
    transpiler.convert_representation(reps)
    code = transpiler.get_html(tabbed=0)  # ngl='ngl.js'
    return transpiler

def file_test():
    transpiler = PyMolTranspiler(file='1gfl.pse')
    print(transpiler.get_view())
    print(transpiler.get_reps())
    return transpiler

def new_template_testing():
    #transpiler = PyMolTranspiler(file='images/1ubq.pse')
    transpiler = test()
    transpiler.pdb = '1UBQ'
    transpiler.m4_alt = None
    code=transpiler.get_js(toggle_fx=True, viewport='viewport', variants=[], save_button='save_button', backgroundColor='white',tag_wrapped=True)
    transpiler.write_hmtl(template_file='test2.mako', output_file='example.html', code=code)

if __name__ == "__main__":
    ## ARGPARSER
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--version', action='version', version=__version__)
    parser.add_argument('--verbose', action='store_true', help='Runs giving details...')
    args = parser.parse_args()
    exit(0)

    ## Tests
    test()
    file_test()
    new_template_testing()
