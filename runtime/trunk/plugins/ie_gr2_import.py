# Two lines below to stop encoding errors in the console.
#!/usr/bin/python
# -*- coding: ascii -*-

"""   QuArK  -  Quake Army Knife

QuArK Model Editor importer for .gr2 model files.
"""
#
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$


Info = {
   "plug-in":       "ie_gr2_importer",
   "desc":          "This script imports a .gr2 model file, using the QuArK grnreader.exe converter.",
   "date":          "Dec 19 2009",
   "author":        "cdunde & DanielPharos",
   "author e-mail": "cdunde@sbcglobal.net",
   "quark":         "Version 6.6.0 Beta 4" }


# Python specific modules import.
import quarkx
import sys, struct, os, math, Lib, Lib.base64
from quarkpy.qutils import *
from quarkpy.qeditor import MapColor # Strictly needed for QuArK bones MapColor call.from types import *
import quarkpy.qhandles
import quarkpy.mdleditor
import quarkpy.mdlhandles
import quarkpy.mdlutils
import ie_utils
from os import path
from ie_utils import tobj
import math
from math import *
from quarkpy.qdictionnary import Strings

# Globals
SS_MODEL = 3
logging = 0
importername = "ie_gr2_import.py"
textlog = "gr2_ie_log.txt"
editor = None
progressbar = None

global line_counter
global lines
line_counter = 0
lines = None

######################################################
# Vector, Quaterion, Matrix math stuff-taken from
# Jiba's blender2cal3d script
######################################################

def quaternion_normalize(q):
    m = math.sqrt(q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3])
    return [q[0]/m, q[1]/m, q[2]/m, q[3]/m]

def quaternion2matrix(q):
    xx = q[0] * q[0]
    yy = q[1] * q[1]
    zz = q[2] * q[2]
    xy = q[0] * q[1]
    xz = q[0] * q[2]
    yz = q[1] * q[2]
    wx = q[3] * q[0]
    wy = q[3] * q[1]
    wz = q[3] * q[2]
    return [[1.0 - 2.0 * (yy + zz),       2.0 * (xy + wz),       2.0 * (xz - wy), 0.0],
            [      2.0 * (xy - wz), 1.0 - 2.0 * (xx + zz),       2.0 * (yz + wx), 0.0],
            [      2.0 * (xz + wy),       2.0 * (yz - wx), 1.0 - 2.0 * (xx + yy), 0.0],
            [0.0                  , 0.0                  , 0.0                  , 1.0]]

def matrix_determinant(m):
    a = m[0][0]
    b = m[0][1]
    c = m[0][2]
    d = m[1][0]
    e = m[1][1]
    f = m[1][2]
    g = m[2][0]
    h = m[2][1]
    i = m[2][2]
    return a*e*i - a*f*h + b*f*g - b*d*i + c*d*h - c*e*g

def matrix_multiply(b, a):
    return [ [
        a[0][0] * b[0][0] + a[0][1] * b[1][0] + a[0][2] * b[2][0],
        a[0][0] * b[0][1] + a[0][1] * b[1][1] + a[0][2] * b[2][1],
        a[0][0] * b[0][2] + a[0][1] * b[1][2] + a[0][2] * b[2][2],
        0.0,
        ], [
        a[1][0] * b[0][0] + a[1][1] * b[1][0] + a[1][2] * b[2][0],
        a[1][0] * b[0][1] + a[1][1] * b[1][1] + a[1][2] * b[2][1],
        a[1][0] * b[0][2] + a[1][1] * b[1][2] + a[1][2] * b[2][2],
        0.0,
        ], [
        a[2][0] * b[0][0] + a[2][1] * b[1][0] + a[2][2] * b[2][0],
        a[2][0] * b[0][1] + a[2][1] * b[1][1] + a[2][2] * b[2][1],
        a[2][0] * b[0][2] + a[2][1] * b[1][2] + a[2][2] * b[2][2],
         0.0,
        ], [
        a[3][0] * b[0][0] + a[3][1] * b[1][0] + a[3][2] * b[2][0] + b[3][0],
        a[3][0] * b[0][1] + a[3][1] * b[1][1] + a[3][2] * b[2][1] + b[3][1],
        a[3][0] * b[0][2] + a[3][1] * b[1][2] + a[3][2] * b[2][2] + b[3][2],
        1.0,
        ] ]

def point_by_matrix(p, m):
  return [
        p[0] * m[0][0] + p[1] * m[1][0] + p[2] * m[2][0] + m[3][0],
        p[0] * m[0][1] + p[1] * m[1][1] + p[2] * m[2][1] + m[3][1],
        p[0] * m[0][2] + p[1] * m[1][2] + p[2] * m[2][2] + m[3][2]
    ]

def CleanupName(name):
    BetterName = name.replace("/", "\\")
    BetterName = BetterName.split("\\")
    if len(BetterName) > 1:
        BetterName = BetterName[-2] + "\\" + BetterName[-1]
    else:
        BetterName = BetterName[0]
    i = BetterName.rfind(".")
    if i <> -1:
        BetterName = BetterName[:i]
    return BetterName


def InterpretIntTuple(text):
    text = text.strip()
    text = text.replace("[", "")
    text = text.replace("]", "")
    text = text.split(",")
    tuple = []
    for item in text:
        tuple += [int(item)]
    return tuple

def InterpretFloatTuple(text):
    text = text.strip()
    text = text.replace("[", "")
    text = text.replace("]", "")
    text = text.split(",")
    tuple = []
    for item in text:
        tuple += [float(item)]
    return tuple

class gr2_coords:
    flags = 0
    origin = [0., 0., 0.]
    rotation = [0., 0., 0., 1.]
    scale = [1., 0., 0., 0., 1., 0., 0., 0., 1.]

    def __init__(self):
        self.flags = 0
        self.origin = [0., 0., 0.]
        self.rotation = [0., 0., 0., 1.]
        self.scale = [1., 0., 0., 0., 1., 0., 0., 0., 1.]

class gr2_art_tool(dict):
    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Art tool section doesn't have deeper levels.
                raise "Error: Corrupt art tool section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of art tool section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt art tool section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt art tool section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                self[current_line[0]] = current_line[1]
        return

class gr2_exporter_tool(dict):
    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Exporter tool section doesn't have deeper levels.
                raise "Error: Corrupt exporter tool section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of exporter tool section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt exporter tool section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt exporter tool section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                self[current_line[0]] = current_line[1]
        return

class gr2_bone:
    name = ""
    parentindex = -1
    transform = gr2_coords()
    InverseWorldTransform = None
    LODError = 0.

    def __init__(self):
        self.name = ""
        self.parentindex = -1
        self.transform = gr2_coords()
        self.InverseWorldTransform = None
        self.LODError = 0.

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Bone section doesn't have deeper levels.
                raise "Error: Corrupt bone section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of bone section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt bone section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt bone section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "bone name":
                    self.name = current_line[1]
                elif current_line[0] == "bone parentindex":
                    self.parentindex = int(current_line[1])
                elif current_line[0] == "bone transform dimensions":
                    self.transform.flags = int(current_line[1])
                elif current_line[0] == "bone transform origin":
                    self.transform.origin = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "bone transform rotation":
                    self.transform.rotation = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "bone transform scale":
                    self.transform.scale = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "bone InverseWorldTransform":
                    self.InverseWorldTransform = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "bone LODError":
                    self.LODError = float(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt bone section! Don't know what to do with: ", current_line
        return

class gr2_skeleton:
    name = ""
    LOD_type = 0
    bones = []

    def __init__(self):
        self.name = ""
        self.LOD_type = 0
        self.bones = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Deeper level.
                current_line = current_line[:-2]
                if current_line == "bone":
                    # This is a bone section.
                    bone = gr2_bone()
                    self.bones += [bone]
                    bone.ReadData()
                else:
                    raise "Error: Corrupt skeleton section! Unknown section name: ", current_line
            elif current_line == ")":
                # End of skeleton section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt skeleton section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt skeleton section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "skeleton name":
                    self.name = current_line[1]
                elif current_line[0] == "skeleton LOD type":
                    self.LOD_type = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt skeleton section! Don't know what to do with: ", current_line
        return

class gr2_model:
    name = ""
    initial_placement = gr2_coords()
    meshbindings = []
    skeletonbinding = -1

    def __init__(self):
        self.name = ""
        self.initial_placement = gr2_coords()
        self.meshbindings = []
        self.skeletonbinding = -1

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Model section doesn't have deeper levels.
                raise "Error: Corrupt model section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of model section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt model section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt model section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "model name":
                    self.name = current_line[1]
                elif current_line[0] == "model initial placement dimensions":
                    self.initial_placement.flags = int(current_line[1])
                elif current_line[0] == "model initial placement origin":
                    self.initial_placement.origin = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "model initial placement rotation":
                    self.initial_placement.rotation = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "model initial placement scale":
                    self.initial_placement.scale = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "meshbinding":
                    self.meshbindings += [int(current_line[1])]
                elif current_line[0] == "skeletonbinding":
                    self.skeletonbinding = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt model section! Don't know what to do with: ", current_line
        return

class gr2_animation:
    name = ""
    duration = 0.
    timestep = 0.
    oversampling = 0.
    trackgroups = []

    def __init__(self):
        self.name = ""
        self.duration = 0.
        self.timestep = 0.
        self.oversampling = 0.
        self.trackgroups = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Animation section doesn't have deeper levels.
                raise "Error: Corrupt animation section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of animation section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt animation section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt animation section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "animation name":
                    self.name = current_line[1]
                elif current_line[0] == "animation duration":
                    self.duration = float(current_line[1])
                elif current_line[0] == "animation timestep":
                    self.timestep = float(current_line[1])
                elif current_line[0] == "animation oversampling":
                    self.oversampling = float(current_line[1])
                elif current_line[0] == "trackgroup":
                    self.trackgroups += [int(current_line[1])]
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt animation section! Don't know what to do with: ", current_line
        return

class gr2_texture:
    fromfilename = ""
    texturetype = 0
    width = 0
    height = 0
    encoding = 0
    subformat = 0
    BytesPerPixel = 0
    ShiftForComponent = [0, 0, 0, 0]
    BitsForComponent = [0, 0, 0, 0]
    imagedata = ""

    def __init__(self):
        self.fromfilename = ""
        self.texturetype = 0
        self.width = 0
        self.height = 0
        self.encoding = 0
        self.subformat = 0
        self.BytesPerPixel = 0
        self.ShiftForComponent = [0, 0, 0, 0]
        self.BitsForComponent = [0, 0, 0, 0]
        self.imagedata = ""

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Texture section doesn't have deeper levels.
                raise "Error: Corrupt texture section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of texture section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt texture section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt texture section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "fromfilename":
                    self.fromfilename = current_line[1]
                elif current_line[0] == "texturetype":
                    self.texturetype = int(current_line[1])
                elif current_line[0] == "width":
                    self.width = int(current_line[1])
                elif current_line[0] == "height":
                    self.height = int(current_line[1])
                elif current_line[0] == "encoding":
                    self.encoding = int(current_line[1])
                elif current_line[0] == "subformat":
                    self.subformat = int(current_line[1])
                elif current_line[0] == "BytesPerPixel":
                    self.BytesPerPixel = int(current_line[1])
                elif current_line[0] == "ShiftForComponent":
                    self.ShiftForComponent = InterpretIntTuple(current_line[1])
                elif current_line[0] == "BitsForComponent":
                    self.BitsForComponent = InterpretIntTuple(current_line[1])
                elif current_line[0] == "imagedata":
                    self.imagedata = Lib.base64.b64decode(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt texture section! Don't know what to do with: ", current_line
        return

class gr2_map:
    usage = ""
    material = -1

    def __init__(self):
        self.usage = ""
        self.material = -1

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Map section doesn't have deeper levels.
                raise "Error: Corrupt map section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of map section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt map section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt map section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "map usage":
                    self.usage = current_line[1]
                elif current_line[0] == "map material":
                    self.material = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt map section! Don't know what to do with: ", current_line
        return

class gr2_material:
    name = ""
    maps = []
    texture = None

    def __init__(self):
        self.name = ""
        self.maps = []
        self.texture = None

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Deeper level.
                current_line = current_line[:-2]
                if current_line == "map":
                    # This is a map section.
                    map = gr2_map()
                    self.maps += [map]
                    map.ReadData()
                elif current_line == "texture":
                    # This is a texture section.
                    texture = gr2_texture()
                    self.texture = texture
                    texture.ReadData()
                else:
                    raise "Error: Corrupt material section! Unknown section name: ", current_line
            elif current_line == ")":
                # End of material section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt material section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt material section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "material name":
                    self.name = current_line[1]
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt material section! Don't know what to do with: ", current_line
        return

class gr2_vertexdata:
    name = ""

    def __init__(self):
        self.name = ""

    def ReadData(self):
        global lines
        global line_counter
        #@
        return

class gr2_tritopology_group:
    materialindex = 0
    trifirst = 0
    tricount = 0

    def __init__(self):
        self.materialindex = 0
        self.trifirst = 0
        self.tricount = 0

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Tritopology group section doesn't have deeper levels.
                raise "Error: Corrupt tritopology group section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of tritopology group section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt tritopology group section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt tritopology group section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "group materialindex":
                    self.materialindex = int(current_line[1])
                elif current_line[0] == "group trifirst":
                    self.trifirst = int(current_line[1])
                elif current_line[0] == "group tricount":
                    self.tricount = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt tritopology group section! Don't know what to do with: ", current_line
        return

class gr2_tritopology:
    groups = []
    faces = []

    def __init__(self):
        self.groups = []
        self.faces = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Deeper level.
                current_line = current_line[:-2]
                if current_line == "group":
                    # This is a group section.
                    group = gr2_tritopology_group()
                    self.groups += [group]
                    group.ReadData()
                elif current_line == "face":
                    # This is a face section.
                    face = gr2_face()
                    self.faces += [face]
                    face.ReadData()
                else:
                    raise "Error: Corrupt tritopology section! Unknown section name: ", current_line
            elif current_line == ")":
                # End of tritopology section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt tritopology section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt tritopology section! Bad line!"
                #current_line[0] = current_line[0].strip()
                #current_line[1] = current_line[1].strip()
                # Don't know what to do with this...
                raise "Error: Corrupt tritopology section! Don't know what to do with: ", current_line
        return

class gr2_vert:
    number = 0
    position = []
    texturecoords = []
    normal = []
    boneindices = []
    boneweights = []

    def __init__(self):
        self.number = 0
        self.position = []
        self.texturecoords = []
        self.normal = []
        self.boneindices = []
        self.boneweights = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Vert section doesn't have deeper levels.
                raise "Error: Corrupt vert section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of vert section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt vert section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt vert section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "vert number":
                    self.number = int(current_line[1])
                elif current_line[0] == "vert position":
                    self.position = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "vert texture coords":
                    self.texturecoords = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "vert normal":
                    self.normal = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "vert bone indices":
                    self.boneindices = InterpretIntTuple(current_line[1])
                elif current_line[0] == "vert bone weights":
                    self.boneweights = InterpretIntTuple(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt vert section! Don't know what to do with: ", current_line
        return

class gr2_face:
    indices = []

    def __init__(self):
        self.indices = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Face section doesn't have deeper levels.
                raise "Error: Corrupt face section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of face section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt face section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt face section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "face indices":
                    self.indices = InterpretIntTuple(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt face section! Don't know what to do with: ", current_line
        return

class gr2_materialbinding:
    material = -1

    def __init__(self):
        self.material = -1

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Materialbinding section doesn't have deeper levels.
                raise "Error: Corrupt materialbinding section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of materialbinding section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt materialbinding section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt materialbinding section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "materialbinding material":
                    self.material = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt materialbinding section! Don't know what to do with: ", current_line
        return

class gr2_bonebinding:
    bonename = ""
    OBBMin = []
    OBBMax = []

    def __init__(self):
        self.bonename = ""
        self.OBBMin = []
        self.OBBMax = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Bonebinding section doesn't have deeper levels.
                raise "Error: Corrupt bonebinding section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of bonebinding section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt bonebinding section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt bonebinding section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "bonebinding bonename":
                    self.bonename = current_line[1]
                elif current_line[0] == "bonebinding OBBMin":
                    self.OBBMin = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "bonebinding OBBMax":
                    self.OBBMax = InterpretFloatTuple(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt bonebinding section! Don't know what to do with: ", current_line
        return

class gr2_mesh:
    name = ""
    verts = []
    primarytopologybinding = -1
    materialbindings = []
    bonebindings = []

    def __init__(self):
        self.name = ""
        self.verts = []
        self.primarytopologybinding = -1
        self.materialbindings = []
        self.bonebindings = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Deeper level.
                current_line = current_line[:-2]
                if current_line == "vert":
                    # This is a vert section.
                    vert = gr2_vert()
                    self.verts += [vert]
                    vert.ReadData()
                elif current_line == "materialbinding":
                    # This is a materialbinding section.
                    materialbinding = gr2_materialbinding()
                    self.materialbindings += [materialbinding]
                    materialbinding.ReadData()
                elif current_line == "bonebinding":
                    # This is a bonebinding section.
                    bonebinding = gr2_bonebinding()
                    self.bonebindings += [bonebinding]
                    bonebinding.ReadData()
                else:
                    raise "Error: Corrupt mesh section! Unknown section name: ", current_line
            elif current_line == ")":
                # End of mesh section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt mesh section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt mesh section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "mesh name":
                    self.name = current_line[1]
                elif current_line[0] == "mesh primarytopologybinding":
                    self.primarytopologybinding = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt mesh section! Don't know what to do with: ", current_line
        return

class gr2_curve:
    format = 0
    degree = 0
    dimension = 0
    knots = []
    controls = []

    def __init__(self):
        self.format = 0
        self.degree = 0
        self.dimension = 0
        self.knots = []
        self.controls = []

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Curve section doesn't have deeper levels.
                raise "Error: Corrupt curve section! Found deeper level where none was expected!"
            elif current_line == ")":
                # End of curve section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt curve section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt curve section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "curve format":
                    self.format = int(current_line[1])
                elif current_line[0] == "curve degree":
                    self.degree = int(current_line[1])
                elif current_line[0] == "curve dimension":
                    self.dimension = int(current_line[1])
                elif current_line[0] == "curve knot":
                    self.knots += [float(current_line[1])]
                elif current_line[0] == "curve control":
                    self.controls += [InterpretFloatTuple(current_line[1])]
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt curve section! Don't know what to do with: ", current_line
        return

class gr2_transformtrack:
    name = ""
    flags = 0
    orientationcurve = None
    positioncurve = None
    scaleshearcurve = None

    def __init__(self):
        self.name = ""
        self.flags = 0
        self.orientationcurve = None
        self.positioncurve = None
        self.scaleshearcurve = None

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Deeper level.
                current_line = current_line[:-2]
                if current_line == "orientationcurve":
                    # This is an orientationcurve section.
                    curve = gr2_curve()
                    self.orientationcurve = curve
                    curve.ReadData()
                elif current_line == "positioncurve":
                    # This is a positioncurve section.
                    curve = gr2_curve()
                    self.positioncurve = curve
                    curve.ReadData()
                elif current_line == "scaleshearcurve":
                    # This is a scaleshearcurve section.
                    curve = gr2_curve()
                    self.scaleshearcurve = curve
                    curve.ReadData()
                else:
                    raise "Error: Corrupt transformtrack section! Unknown section name: ", current_line
            elif current_line == ")":
                # End of transformtrack section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt transformtrack section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt transformtrack section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "transformtrack name":
                    self.name = current_line[1]
                elif current_line[0] == "transformtrack flags":
                    self.flags = int(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt transformtrack section! Don't know what to do with: ", current_line
        return

class gr2_trackgroup:
    name = ""
    transformtracks = []
    initial_placement = gr2_coords()

    def __init__(self):
        self.name = ""
        self.transformtracks = []
        self.initial_placement = gr2_coords()

    def ReadData(self):
        global lines
        global line_counter
        while 1:
            current_line = lines[line_counter].strip()
            line_counter+=1   # Increase line_counter here, so we don't forget it.
            if current_line[-2:] == " (":
                # Deeper level.
                current_line = current_line[:-2]
                if current_line == "transformtrack":
                    # This is a transformtrack section.
                    transformtrack = gr2_transformtrack()
                    self.transformtracks += [transformtrack]
                    transformtrack.ReadData()
                else:
                    raise "Error: Corrupt trackgroup section! Unknown section name: ", current_line
            elif current_line == ")":
                # End of trackgroup section.
                break
            else:
                current_line = current_line.split(":", 1)
                if current_line is None:
                    raise "Error: Corrupt trackgroup section! Empty line!"
                if len(current_line) != 2:
                    raise "Error: Corrupt trackgroup section! Bad line!"
                current_line[0] = current_line[0].strip()
                current_line[1] = current_line[1].strip()
                if current_line[0] == "trackgroup name":
                    self.name = current_line[1]
                elif current_line[0] == "trackgroup initial placement dimensions":
                    self.initial_placement.flags = int(current_line[1])
                elif current_line[0] == "trackgroup initial placement origin":
                    self.initial_placement.origin = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "trackgroup initial placement rotation":
                    self.initial_placement.rotation = InterpretFloatTuple(current_line[1])
                elif current_line[0] == "trackgroup initial placement scale":
                    self.initial_placement.scale = InterpretFloatTuple(current_line[1])
                else:
                    # Don't know what to do with this...
                    raise "Error: Corrupt trackgroup section! Don't know what to do with: ", current_line
        return

def LoadGR2MSFile(MSfilename):
    global lines
    global line_counter

    art_tool = None
    exporter_tool = None
    models = []
    animations = []
    textures = []
    materials = []
    skeletons = []
    vertexdatas = []
    tritopologies = []
    meshes = []
    trackgroups = []

    file = open(MSfilename,"r")
    lines = file.readlines()
    file.close()
    try:
        line_counter = 0
        try:
            while line_counter < len(lines):
                current_line = lines[line_counter]
                line_counter+=1 # Skip the section name.
                if current_line is None or current_line == "":
                    # Empty line; skip it.
                    continue
                words = current_line.split()
                if len(words) == 0:
                    # Empty line; skip it.
                    continue
                SectionName = words[0:-1]
                if SectionName is None or len(SectionName) == 0:
                    # Not a valid section name!
                    raise "Error: Corrupt gr2 .ms file! Don't know what to do with: ", current_line
                SectionName = " ".join(SectionName)
                if SectionName == "art tool":
                    # This is an art tool section.
                    if art_tool is not None:
                        raise "Error: Corrupt gr2 .ms file: Multiple art tool sections!"
                    art_tool = gr2_art_tool()
                    art_tool.ReadData()
                elif SectionName == "exporter tool":
                    # This is an exporter tool section.
                    if exporter_tool is not None:
                        raise "Error: Corrupt gr2 .ms file: Multiple exporter tool sections!"
                    exporter_tool = gr2_exporter_tool()
                    exporter_tool.ReadData()
                elif SectionName == "model":
                    # This is a model section.
                    model = gr2_model()
                    models += [model]
                    model.ReadData()
                elif SectionName == "animation":
                    # This is an animation section.
                    animation = gr2_animation()
                    animations += [animation]
                    animation.ReadData()
                elif SectionName == "texture":
                    # This is a texture section
                    texture = gr2_texture()
                    textures += [texture]
                    texture.ReadData()
                elif SectionName == "material":
                    # This is a material section.
                    material = gr2_material()
                    materials += [material]
                    material.ReadData()
                elif SectionName == "skeleton":
                    # This is a skeleton section.
                    skeleton = gr2_skeleton()
                    skeletons += [skeleton]
                    skeleton.ReadData()
                elif SectionName == "vertexdata":
                    # This is a vertexdata section.
                    vertexdata = gr2_vertexdata()
                    vertexdatas += [vertexdata]
                    vertexdata.ReadData()
                elif SectionName == "tritopology":
                    # This is a tritopology section.
                    tritopology = gr2_tritopology()
                    tritopologies += [tritopology]
                    tritopology.ReadData()
                elif SectionName == "mesh":
                    # This is a mesh section.
                    mesh = gr2_mesh()
                    meshes += [mesh]
                    mesh.ReadData()
                elif SectionName == "trackgroup":
                    # This is a trackgroup section.
                    trackgroup = gr2_trackgroup()
                    trackgroups += [trackgroup]
                    trackgroup.ReadData()
                else:
                    # Don't know what this; skip it.
                    raise "Error: Corrupt gr2 .ms file! Don't know what to do with section: ", SectionName
        except:
            print "Error in gr2 .ms file line: ", line_counter
            print "Error follows..."
            raise
    finally:
        line_counter = 0
        lines = None

    return [art_tool, exporter_tool, models, animations, textures, materials, skeletons, vertexdatas, tritopologies, meshes, trackgroups]

def loadmodel(root, filename, gamename, nomessage=0):
    global editor
    editor = quarkpy.mdleditor.mdleditor

    bone_group_names = []
    if filename.find("\\attachments\\") != -1:
        gr2_mesh_path = filename.split("\\attachments\\")[0]
    elif filename.find("\\animations\\") != -1:
        gr2_mesh_path = filename.split("\\animations\\")[0]
    else:
        gr2_mesh_path = filename.rsplit('\\', 1)[0]

    bone_group_name = gr2_mesh_path.rsplit('\\', 1)[1]
    bone_group_names = bone_group_names + [bone_group_name]
    found_group_name = 0
    for item in editor.layout.explorer.sellist: # Allows selected components to be animated with other models.
        if item.type == ":mc" and not item.name.startswith(bone_group_name):
            tempname = checkname = item.shortname.split(" ")[0]
            for bone in editor.Root.dictitems['Skeleton:bg'].subitems:
                while 1:
                    if bone.shortname.find(tempname) != -1:
                        tempname = tempname.rsplit("_", 1)[0]
                        if not tempname in bone_group_names:
                            bone_group_names = bone_group_names + [tempname]
                        found_group_name = 1
                        break
                    else:
                        if not tempname.find("_") != -1:
                            break
                        tempname = tempname.rsplit("_", 1)[0]
                if found_group_name != 0:
                    break
                tempname = checkname
        if found_group_name != 0:
            break

    pth, animframename = os.path.split(filename)
    animframename = animframename.split(".")[0]

    # Convert the GR2 file into a GR2MS file.
    cmdline = 'grnreader ' + '\"' + filename + '\"'
    fromdir = quarkx.exepath + "dlls"
    process = quarkx.runprogram(cmdline, fromdir)
    MSfilename = quarkx.exepath + "dlls/output.ms"
    goahead = 0
    while not goahead:
        try:
            file = open(MSfilename,"rw")
        except:
            quarkx.wait(100)
        else:
            file.close()
            goahead = 1
    try:
        art_tool, exporter_tool, models, animations, textures, materials, skeletons, vertexdatas, tritopologies, meshes, trackgroups = LoadGR2MSFile(MSfilename)
    finally:
        os.remove(MSfilename)

    # Do whatever user-filtering is needed here.
    """if nomessage == 0:
        if len(models) != 0:
            choice = quarkx.msgbox("There are "+str(len(models))+" model(s) in this file. Do you want to load them into QuArK?", MT_CONFIRMATION, MB_YES_NO_CANCEL)
            if choice == MR_CANCEL:
                return None
            if choice == MR_NO:
                models = []
        if len(animations) != 0:
            choice = quarkx.msgbox("There are "+str(len(animations))+" animation(s) in this file. Do you want to load them into QuArK?", MT_CONFIRMATION, MB_YES_NO_CANCEL)
            if choice == MR_CANCEL:
                return None
            if choice == MR_NO:
                animations = []"""

    # Process art tool settings.
    if art_tool is not None and art_tool.has_key("art tool units per meter"):
        art_tool_units = float(art_tool["art tool units per meter"])
        if art_tool_units <= 0:
            art_tool_units = 1.0
        art_tool_units = abs(1.0 - (32.0 * (1.0 / art_tool_units)))
    else:
        art_tool_units = -32.0
    if art_tool is not None and art_tool.has_key("art tool origin"):
        art_tool_origin = InterpretFloatTuple(art_tool["art tool origin"])
    else:
        art_tool_origin = [0.000000,0.000000,0.000000]
    if art_tool is not None and art_tool.has_key("art tool right vector"):
        art_tool_right_vector = InterpretFloatTuple(art_tool["art tool right vector"])
    else:
        art_tool_right_vector = [1.000000,0.000000,0.000000]
    if art_tool is not None and art_tool.has_key("art tool up vector"):
        art_tool_up_vector = InterpretFloatTuple(art_tool["art tool up vector"])
    else:
        art_tool_up_vector = [0.000000,1.000000,0.000000]
    if art_tool is not None and art_tool.has_key("art tool back vector"):
        art_tool_back_vector = InterpretFloatTuple(art_tool["art tool back vector"])
    else:
        art_tool_back_vector = [0.000000,0.000000,1.000000]

    # Construct this here, so it doesn't have to be rebuild every time ArtTool(De)Transform is called.
    arttool_origin = quarkx.vect(art_tool_origin[0], art_tool_origin[1], art_tool_origin[2])
    arttool_rotmatrix = quarkx.matrix((art_tool_right_vector[0], art_tool_back_vector[0], art_tool_up_vector[0]) #FIXME: Right way around???
                                     ,(-art_tool_right_vector[1], -art_tool_back_vector[1], -art_tool_up_vector[1])
                                     ,(art_tool_right_vector[2], art_tool_back_vector[2], art_tool_up_vector[2]))

    def ArtToolTransform(old_pos):
        pos = quarkx.vect(old_pos[0], old_pos[1], old_pos[2])
        return ArtToolTransformVect(pos).tuple

    def ArtToolDetransform(old_pos):
        pos = quarkx.vect(old_pos[0], old_pos[1], old_pos[2])
        return ArtToolDetransformVect(pos).tuple

    def ArtToolTransformVect(old_pos):
        pos = arttool_rotmatrix * old_pos
        pos = pos - arttool_origin
        pos = pos * art_tool_units
        return pos

    def ArtToolDetransformVect(old_pos):
        pos = old_pos / art_tool_units
        pos = pos + arttool_origin
        pos = (~arttool_rotmatrix) * pos
        return pos

    def ArtToolTransformMatrix(old_rot):
        rot = arttool_rotmatrix * old_rot
        return rot

    undo = quarkx.action()

    progressbar = quarkx.progressbar(2454, len(models)) #FIXME: Text message!!!

    # Workaround; models with no meshes shouldn't be loaded.
    TMPmodels = []
    for current_model in models:
        if len(current_model.meshbindings) != 0:
            TMPmodels += [current_model]
    models = TMPmodels

    #
    # Process what we loaded.
    #

    #First, convert the materials to QuArK skins
    QuArK_skins = []
    def DoMaterial(current_material):
        result = []
        current_texture = current_material.texture
        if current_texture is not None and len(current_texture.imagedata) != 0:
            texturename = current_texture.fromfilename
            if texturename.find("\\") != -1:
                texturename = texturename.rsplit("\\", 1)[1]
            if texturename.find("/") != -1:
                texturename = texturename.rsplit("/", 1)[1]
            skin = quarkx.newobj(texturename)
            ImgData = ''
            BytesPerPixel = len(current_texture.imagedata) / (current_texture.width * current_texture.height)
            Padding=(int(((current_texture.width * 8) + 31) / 32) * 4) - (current_texture.width * 1)
            for y in range(current_texture.height):
                PixelIndex = current_texture.width * (current_texture.height - y - 1)
                for x in range(current_texture.width):
                    PixelData = current_texture.imagedata[PixelIndex * BytesPerPixel:PixelIndex * BytesPerPixel+3]
                    red, green, blue = struct.unpack("<3B", PixelData)
                    ImgData += struct.pack("BBB", blue, green, red)
                    PixelIndex += 1
                ImgData += "\0" * Padding
            skin['Image1'] = ImgData
            skin['Size'] = (float(current_texture.width), float(current_texture.height))
            result += [skin]
        for current_map in current_material.maps:
            current_material_index = current_map.material
            if current_material_index != -1:
                result += DoMaterial(materials[current_material_index])
        return result
    for current_material in materials:
        QuArK_skins += [DoMaterial(current_material)]

    Full_ComponentList = []
    Full_QuArK_bones = []
    bonelist = editor.ModelComponentList['bonelist']
    for current_model in models:
        ComponentList = []
        QuArK_bones = []
        if current_model.skeletonbinding != -1:
            current_skeleton = skeletons[current_model.skeletonbinding]
            QuArK_bone_pos = [[]] * len(current_skeleton.bones)
            QuArK_bone_rotmatrix = [[]] * len(current_skeleton.bones)
            QuArK_bone_scale = [[]] * len(current_skeleton.bones)
            QuArK_bone_pos_raw = [[]] * len(current_skeleton.bones)
            QuArK_bone_rotmatrix_raw = [[]] * len(current_skeleton.bones)
            QuArK_bone_scale_raw = [[]] * len(current_skeleton.bones)
            for bone_index in range(len(current_skeleton.bones)):
                current_bone = current_skeleton.bones[bone_index]
                # Add bone_group_name to all bones of this group to make compatible with other importers
                # and allow proper exporting of bones whether structured or not.
                new_bone = quarkx.newobj(bone_group_name + "_" + current_bone.name + ":bone")
                new_bone['flags'] = (0,0,0,0,0,0)
                new_bone['show'] = (1.0,)
                new_bone['parent_index'] = str(current_bone.parentindex)
                if current_bone.parentindex == -1:
                    # Update the bone name.
                    # Handle initial placement.
                    if current_model.initial_placement.flags & 1:
                        parent_pos = (current_model.initial_placement.origin[0], current_model.initial_placement.origin[1], current_model.initial_placement.origin[2])
                    else:
                        parent_pos = (0.0, 0.0, 0.0)
                    if current_model.initial_placement.flags & 2:
                        parent_rot = quaternion2matrix(current_model.initial_placement.rotation)
                    else:
                        parent_rot = [[1.0, 0.0, 0.0, 0.0],
                                      [0.0, 1.0, 0.0, 0.0],
                                      [0.0, 0.0, 1.0, 0.0],
                                      [0.0, 0.0, 0.0, 1.0]]
                    if current_model.initial_placement.flags & 4:
                        parent_scale = [[current_model.initial_placement.scale[0], current_model.initial_placement.scale[1], current_model.initial_placement.scale[2], 0.0],
                                        [current_model.initial_placement.scale[3], current_model.initial_placement.scale[4], current_model.initial_placement.scale[5], 0.0],
                                        [current_model.initial_placement.scale[6], current_model.initial_placement.scale[7], current_model.initial_placement.scale[8], 0.0]]
                    else:
                        parent_scale = [[1.0, 0.0, 0.0, 0.0],
                                        [0.0, 1.0, 0.0, 0.0],
                                        [0.0, 0.0, 1.0, 0.0],
                                        [0.0, 0.0, 0.0, 1.0]]
                else:
                    parent_pos = QuArK_bone_pos[current_bone.parentindex]
                    parent_rot = QuArK_bone_rotmatrix[current_bone.parentindex]
                    parent_scale = QuArK_bone_scale[current_bone.parentindex]
                QuArK_bone_pos_raw[bone_index] = (current_bone.transform.origin[0], current_bone.transform.origin[1], current_bone.transform.origin[2])
                QuArK_bone_rotmatrix_raw[bone_index] = quaternion2matrix(current_bone.transform.rotation)
                QuArK_bone_scale_raw[bone_index] = [[current_bone.transform.scale[0], current_bone.transform.scale[1], current_bone.transform.scale[2], 0.0],
                                                    [current_bone.transform.scale[3], current_bone.transform.scale[4], current_bone.transform.scale[5], 0.0],
                                                    [current_bone.transform.scale[6], current_bone.transform.scale[7], current_bone.transform.scale[8], 0.0],
                                                    [0.0                            , 0.0                            , 0.0                            , 1.0]]
                if current_bone.transform.flags & 4:
                    # Apply scale.
                    bone_scale = [[current_bone.transform.scale[0], current_bone.transform.scale[1], current_bone.transform.scale[2], 0.0],
                                  [current_bone.transform.scale[3], current_bone.transform.scale[4], current_bone.transform.scale[5], 0.0],
                                  [current_bone.transform.scale[6], current_bone.transform.scale[7], current_bone.transform.scale[8], 0.0],
                                  [0.0                            , 0.0                            , 0.0                            , 1.0]]
                    bone_scale = matrix_multiply(bone_scale, parent_scale)
                else:
                    bone_scale = parent_scale
                if current_bone.transform.flags & 1:
                    # Apply origin.
                    bone_pos = point_by_matrix(current_bone.transform.origin, parent_rot)
                    bone_pos = point_by_matrix(bone_pos, parent_scale)
                    bone_pos = (parent_pos[0] + bone_pos[0], parent_pos[1] + bone_pos[1], parent_pos[2] + bone_pos[2])
                else:
                    bone_pos = parent_pos
                if current_bone.transform.flags & 2:
                    # Apply rotation.
                    bone_rot = quaternion2matrix(current_bone.transform.rotation)
                    bone_rot = matrix_multiply(parent_rot, bone_rot)
                else:
                    bone_rot = parent_rot
                QuArK_bone_pos[bone_index] = bone_pos
                QuArK_bone_rotmatrix[bone_index] = bone_rot
                QuArK_bone_scale[bone_index] = bone_scale
                new_bone['position'] = ArtToolTransform(bone_pos)
                new_bone.position = quarkx.vect(new_bone.dictspec['position'])
                if new_bone['parent_index'] == str(-1):
                    new_bone['parent_name'] = "None"
                    new_bone['bone_length'] = (0.0, 0.0, 0.0)
                else:
                    new_bone['parent_name'] = QuArK_bones[int(new_bone.dictspec['parent_index'])].name
                    new_bone['bone_length'] = (-quarkx.vect(QuArK_bones[int(new_bone.dictspec['parent_index'])].dictspec['position']) + quarkx.vect(new_bone.dictspec['position'])).tuple
                new_bone['rotmatrix'] = "None"
                new_bone['scale'] = (1.0,)
                new_bone['component'] = "None" # None for now and get the component name later.
                new_bone['draw_offset'] = (0.0, 0.0, 0.0)
                new_bone['_color'] = MapColor("BoneHandles", 3)
                new_bone['draw_offset'] = (0.0, 0.0, 0.0)
                new_bone.rotmatrix = quarkx.matrix((1, 0, 0), (0, 1, 0), (0, 0, 1))
                new_bone.vtxlist = {}
                new_bone.vtx_pos = {}
                QuArK_bones += [new_bone]


                if not editor.ModelComponentList.has_key('gr2_data'):
                    editor.ModelComponentList['gr2_data'] = {}
                bone_rot = ((bone_rot[0][0], bone_rot[1][0], bone_rot[2][0]),
                            (bone_rot[0][1], bone_rot[1][1], bone_rot[2][1]),
                            (bone_rot[0][2], bone_rot[1][2], bone_rot[2][2]))
                bonelist[new_bone.name] = {'frames': {'meshframe:mf': {'position': new_bone.position.tuple, 'rotmatrix': bone_rot}}}
                bonelist[new_bone.name]['type'] = 'gr2'
                editor.ModelComponentList['gr2_data'][new_bone.name] = {}
                editor.ModelComponentList['gr2_data'][new_bone.name]['bone_pos'] = QuArK_bone_pos[bone_index]
                editor.ModelComponentList['gr2_data'][new_bone.name]['bone_rotmatrix'] = QuArK_bone_rotmatrix[bone_index]
                editor.ModelComponentList['gr2_data'][new_bone.name]['bone_scale'] = QuArK_bone_scale[bone_index]
                editor.ModelComponentList['gr2_data'][new_bone.name]['bone_pos_raw'] = QuArK_bone_pos_raw[bone_index]
                editor.ModelComponentList['gr2_data'][new_bone.name]['bone_rotmatrix_raw'] = QuArK_bone_rotmatrix_raw[bone_index]
                editor.ModelComponentList['gr2_data'][new_bone.name]['bone_scale_raw'] = QuArK_bone_scale_raw[bone_index]
        full_bone_vtx_list = {} # { bone_index : { component_full_name : [ vtx, vtx, vtx ...] } }
        for bone_index in range(len(QuArK_bones)):
            full_bone_vtx_list[bone_index] = {}
        for current_mesh_nr in current_model.meshbindings:
            current_mesh = meshes[current_mesh_nr]
            bone_index_conv_list = []
            if current_model.skeletonbinding != -1:
                for current_bonebinding in current_mesh.bonebindings:
                    found_bone = None
                    bone_index = 0
                    for bone_obj in QuArK_bones:
                        tempname = bone_obj.name
                        for bone_group_name in bone_group_names:
                            if bone_obj.name.startswith(bone_group_name + "_"):
                                tempname = bone_obj.name.replace(bone_group_name + "_", "")
                                break
                        if tempname == current_bonebinding.bonename + ':bone':
                            found_bone = bone_obj
                            break
                        bone_index += 1
                    if found_bone is None:
                        raise "Error: Corrupt gr2 .ms file! Can't match up mesh bonebindings!"
                    bone_index_conv_list += [bone_index]
            vert_index = 0
            frame_vertices = ()
            new_modelcomponentlist = {'bonevtxlist': {}, 'colorvtxlist': {}, 'weightvtxlist': {}}
            if current_model.skeletonbinding != -1:
                bone_vtx_list = {} # { bone_index : { component_full_name : [ vtx, vtx, vtx ...] } }
                for bone_index in range(len(QuArK_bones)):
                    bone_vtx_list[bone_index] = []
            for current_vert in current_mesh.verts:
                current_pos = ArtToolTransform(current_vert.position)
                frame_vertices = frame_vertices + (current_pos[0], current_pos[1], current_pos[2])

                # Bone bindings.
                if current_model.skeletonbinding != -1:
                    for i in range(0, 4):
                        if current_vert.boneweights[i] == 0:
                            # This index is not bound.
                            if (i == 0) and (len(QuArK_bones) != 0):
                                # There are bones; assign this bone to the origin bone (0).
                                current_vert.boneindices[i] = 0
                                current_vert.boneweights[i] = 255
                            else:
                                # Skip it.
                                continue
                        fixed_index = bone_index_conv_list[current_vert.boneindices[i]]
                        bone_vtx_list[fixed_index] = bone_vtx_list[fixed_index] + [vert_index]
                        if not new_modelcomponentlist['bonevtxlist'].has_key(QuArK_bones[fixed_index].name):
                            new_modelcomponentlist['bonevtxlist'][QuArK_bones[fixed_index].name] = {}
                        if not new_modelcomponentlist['bonevtxlist'][QuArK_bones[fixed_index].name].has_key(vert_index):
                            new_modelcomponentlist['bonevtxlist'][QuArK_bones[fixed_index].name][vert_index] = {}
                            new_modelcomponentlist['bonevtxlist'][QuArK_bones[fixed_index].name][vert_index]['color'] = QuArK_bones[fixed_index]['_color']
                        if not new_modelcomponentlist['weightvtxlist'].has_key(vert_index):
                            new_modelcomponentlist['weightvtxlist'][vert_index] = {}
                        if not new_modelcomponentlist['weightvtxlist'][vert_index].has_key(QuArK_bones[fixed_index].name):
                            new_modelcomponentlist['weightvtxlist'][vert_index][QuArK_bones[fixed_index].name] = {}
                        weight_value = float(current_vert.boneweights[i])/255.0
                        color = quarkpy.mdlutils.weights_color(editor, weight_value)
                        new_modelcomponentlist['weightvtxlist'][vert_index][QuArK_bones[fixed_index].name]['weight_value'] = weight_value
                        new_modelcomponentlist['weightvtxlist'][vert_index][QuArK_bones[fixed_index].name]['color'] = color
                vert_index += 1

            if current_mesh.primarytopologybinding != -1:
                current_tritopology = tritopologies[current_mesh.primarytopologybinding]
                for current_face_group_nr in range(len(current_tritopology.groups)):
                    current_face_group = current_tritopology.groups[current_face_group_nr]
                    if len(current_tritopology.groups) <> 1:
                        Component = quarkx.newobj(bone_group_name + "_" + current_mesh.name + " group " + str(current_face_group_nr+1) + ":mc")
                    else:
                        Component = quarkx.newobj(bone_group_name + "_" + current_mesh.name + ":mc")
                    ComponentList += [Component]
            
                    #Now do the skins
                    skins = []
                    skinsize = None
                    current_materialindex = current_face_group.materialindex
                    current_materialbinding = current_mesh.materialbindings[current_materialindex]
                    if current_materialbinding.material != -1:
                        for skin in QuArK_skins[current_materialbinding.material]:
                            if skinsize is None:
                                skinsize = skin['Size']
                            skins += [skin]
                    if skinsize is None:
                        skinsize = (256, 256)
                    Component['skinsize'] = skinsize
                    if len(new_modelcomponentlist) <> 0:
                        editor.ModelComponentList[Component.name] = new_modelcomponentlist
            
                    Tris = ''
                    trifirst = current_face_group.trifirst
                    tricount = current_face_group.tricount
                    for current_face_nr in range(trifirst, trifirst+tricount):
                        current_face = current_tritopology.faces[current_face_nr]
                        vert_index = [[]] * 3
                        texcoordX = [[]] * 3
                        texcoordY = [[]] * 3
                        for i in range(0, 3):
                            vert_index[i] = current_face.indices[i]
                            texcoordX[i] = current_mesh.verts[vert_index[i]].texturecoords[0]
                            if (texcoordX[i] < -20) or (texcoordX[i] > 20):
                                texcoordX[i] = texcoordX[i] - float(int(texcoordX[i] / 20) * 20)
                            texcoordY[i] = current_mesh.verts[vert_index[i]].texturecoords[1]
                            if (texcoordY[i] < -20) or (texcoordY[i] > 20):
                                texcoordY[i] = texcoordY[i] - float(int(texcoordY[i] / 20) * 20)
                        Tris = Tris + struct.pack("Hhh", vert_index[2], texcoordX[2]*skinsize[0], texcoordY[2]*skinsize[1])
                        Tris = Tris + struct.pack("Hhh", vert_index[1], texcoordX[1]*skinsize[0], texcoordY[1]*skinsize[1])
                        Tris = Tris + struct.pack("Hhh", vert_index[0], texcoordX[0]*skinsize[0], texcoordY[0]*skinsize[1])
                    Component['Tris'] = Tris
                    Component['show'] = chr(1)
                    framesgroup = quarkx.newobj('Frames:fg')
                    skingroup = quarkx.newobj('Skins:sg')
                    skingroup['type'] = chr(2)
                    for skin in skins:
                        skingroup.appenditem(skin.copy()) #Put a COPY in the skingroup
                    sdogroup = quarkx.newobj('SDO:sdo')
                    Component.appenditem(sdogroup)
                    Component.appenditem(skingroup)
                    Component.appenditem(framesgroup)
                    frame = quarkx.newobj('meshframe:mf')
                    frame['Vertices'] = frame_vertices
                    framesgroup.appenditem(frame)
                    undo.put(editor.Root, Component)
            
                    if current_model.skeletonbinding != -1:
                        for bone_index in range(len(QuArK_bones)):
                            full_bone_vtx_list[bone_index][Component.name] = bone_vtx_list[bone_index]

        for bone_index in range(len(QuArK_bones)):
            QuArK_bones[bone_index].vtxlist = full_bone_vtx_list[bone_index]
            vtxcount = 0
            usekey = None
            for key in QuArK_bones[bone_index].vtxlist.keys():
                if len(QuArK_bones[bone_index].vtxlist[key]) > vtxcount:
                    usekey = key
                    vtxcount = len(QuArK_bones[bone_index].vtxlist[key])
            if usekey is not None:
                temp = {}
                temp[usekey] = QuArK_bones[bone_index].vtxlist[usekey]
                QuArK_bones[bone_index].vtx_pos = temp
                comp = None
                for item in ComponentList:
                    if item.name == usekey:
                        comp = item
                        break
                vtxpos = quarkx.vect(0, 0, 0)
                frame_vertices = comp.dictitems['Frames:fg'].subitems[0].vertices
                for vtx in range(len(QuArK_bones[bone_index].vtx_pos[usekey])):
                    vtxpos = vtxpos + frame_vertices[QuArK_bones[bone_index].vtx_pos[usekey][vtx]]
                vtxpos = vtxpos/float(len(QuArK_bones[bone_index].vtx_pos[usekey]))
                QuArK_bones[bone_index]['draw_offset'] = (QuArK_bones[bone_index].position - vtxpos).tuple
                QuArK_bones[bone_index]['component'] = usekey
            else:
                QuArK_bones[bone_index]['component'] = ComponentList[-1].name
        for Component in ComponentList:
            # This needs to be done for each component or bones will not work if used in the editor.
            quarkpy.mdlutils.make_tristodraw_dict(editor, Component)
        Full_ComponentList += ComponentList

        bones_in_editor = {}
        for group in editor.Root.dictitems['Skeleton:bg'].subitems:
            for bone_group_name in bone_group_names:
                if group.name.startswith(bone_group_name):
                    group_bones = group.findallsubitems("", ':bone')
                    for bone in group_bones:
                        bones_in_editor[bone.name] = bone
        editor_bone_names = bones_in_editor.keys()
   #     exchange_bones = []
        editor_bone_group = editor.Root.dictitems['Skeleton:bg']
        for new_bone in QuArK_bones:
            if new_bone.name in editor_bone_names:
                continue
            else:
                if new_bone.dictspec['parent_name'] == "None":
                    undo.put(editor_bone_group, new_bone)
                else:
                    undo.put(QuArK_bones[int(new_bone.dictspec['parent_index'])], new_bone)
        for new_bone in QuArK_bones:
            if new_bone.name in editor_bone_names:
                editor_bone = bones_in_editor[new_bone.name] #.copy()
                vtxlist = editor_bone.vtxlist
                for comp_name in new_bone.vtxlist.keys():
                    vtxlist[comp_name] = new_bone.vtxlist[comp_name]
                editor_bone.vtxlist = vtxlist
   #             exchange_bones = exchange_bones + [editor_bone]
   #     print "line 1428 exchange_bones", len(exchange_bones)
   #     for editor_bone in exchange_bones:
   #         undo.exchange(bones_in_editor[editor_bone.name], editor_bone)
            
        Full_QuArK_bones += QuArK_bones
        progressbar.progress()
    progressbar.close()

    # ANIMATION STARTS HERE.
    TMP_ComponentList = []
    for item in editor.Root.subitems:
        for bone_group_name in bone_group_names:
            if item.type == ":mc" and item.name.startswith(bone_group_name + "_"):
                TMP_ComponentList = TMP_ComponentList + [item]
    if len(TMP_ComponentList) != 0:
        Full_ComponentList += TMP_ComponentList
        
    # Only get the model's bone groups needed.
    allbones = editor.Root.dictitems['Skeleton:bg'].findallsubitems("", ':bone')
    TMP_QuArK_bones = []
    for bone_group_name in bone_group_names:
        for bone in allbones:
            if bone.name.startswith(bone_group_name + "_"):
                TMP_QuArK_bones = TMP_QuArK_bones + [bone]
    if len(TMP_QuArK_bones) != 0:
        Full_QuArK_bones += TMP_QuArK_bones

    NumberOfBones = len(Full_QuArK_bones)

    # Store bone-data for easy access.
    QuArK_bone_pos = [[]] * NumberOfBones
    QuArK_bone_rotmatrix = [[]] * NumberOfBones
    QuArK_bone_scale = [[]] * NumberOfBones
    QuArK_bone_pos_raw = [[]] * NumberOfBones
    QuArK_bone_rotmatrix_raw = [[]] * NumberOfBones
    QuArK_bone_scale_raw = [[]] * NumberOfBones
    for bone_counter in range(len(Full_QuArK_bones)):
        found_bone = 0
        bone_obj = Full_QuArK_bones[bone_counter]
        if editor.ModelComponentList.has_key('gr2_data'):
            if editor.ModelComponentList['gr2_data'].has_key(bone_obj.name):
                found_bone = 1
                QuArK_bone_pos[bone_counter] = editor.ModelComponentList['gr2_data'][bone_obj.name]['bone_pos']
                QuArK_bone_rotmatrix[bone_counter] = editor.ModelComponentList['gr2_data'][bone_obj.name]['bone_rotmatrix']
                QuArK_bone_scale[bone_counter] = editor.ModelComponentList['gr2_data'][bone_obj.name]['bone_scale']
                QuArK_bone_pos_raw[bone_counter] = editor.ModelComponentList['gr2_data'][bone_obj.name]['bone_pos_raw']
                QuArK_bone_rotmatrix_raw[bone_counter] = editor.ModelComponentList['gr2_data'][bone_obj.name]['bone_rotmatrix_raw']
                QuArK_bone_scale_raw[bone_counter] = editor.ModelComponentList['gr2_data'][bone_obj.name]['bone_scale_raw']
        if found_bone == 0:
            QuArK_bone_pos[bone_counter] = ArtToolDetransformVect(bone_obj.position).tuple
            # These cannot be recovered.
            QuArK_bone_rotmatrix[bone_counter] = [[1.0, 0.0, 0.0, 0.0],
                                                  [0.0, 1.0, 0.0, 0.0],
                                                  [0.0, 0.0, 1.0, 0.0],
                                                  [0.0, 0.0, 0.0, 1.0]]
            QuArK_bone_scale[bone_counter] = [[1.0, 0.0, 0.0, 0.0],
                                              [0.0, 1.0, 0.0, 0.0],
                                              [0.0, 0.0, 1.0, 0.0],
                                              [0.0, 0.0, 0.0, 1.0]]
            QuArK_bone_pos_raw[bone_counter] = ArtToolDetransformVect(bone_obj.position).tuple
            # These cannot be recovered.
            QuArK_bone_rotmatrix_raw[bone_counter] = [[1.0, 0.0, 0.0, 0.0],
                                                      [0.0, 1.0, 0.0, 0.0],
                                                      [0.0, 0.0, 1.0, 0.0],
                                                      [0.0, 0.0, 0.0, 1.0]]
            QuArK_bone_scale_raw[bone_counter] = [[1.0, 0.0, 0.0, 0.0],
                                                  [0.0, 1.0, 0.0, 0.0],
                                                  [0.0, 0.0, 1.0, 0.0],
                                                  [0.0, 0.0, 0.0, 1.0]]

    progressbar = quarkx.progressbar(2454, len(animations)) #FIXME: Text message!!!

    for current_animation in animations:
        NumberOfFrames = 20 # QuArK: Overwriting the timestep to reduce the number of frames.
        FileNumberOfFrames = int(round(current_animation.duration / current_animation.timestep))
        for item in editor.Root.subitems:
            if item.type == ":mc":
                if item.dictspec.has_key('gr_max_frames'):
                    NumberOfFrames = int(item.dictspec['gr_max_frames'])
                break
        if NumberOfFrames > 20 and NumberOfFrames > FileNumberOfFrames:
            NumberOfFrames = FileNumberOfFrames

        BoneNameToBoneIndex = {}
        for bone_index in range(len(Full_QuArK_bones)):
            BoneNameToBoneIndex[Full_QuArK_bones[bone_index].name] = bone_index

        # Prepare arrays to store the bone-animation-data.
        QuArK_frame_position_raw = [[]] * NumberOfFrames
        QuArK_frame_matrix_raw = [[]] * NumberOfFrames
        QuArK_frame_scale_raw = [[]] * NumberOfFrames
        for frame_counter in range(0,NumberOfFrames):
            QuArK_frame_position_raw[frame_counter] = [[]] * NumberOfBones
            QuArK_frame_matrix_raw[frame_counter] = [[]] * NumberOfBones
            QuArK_frame_scale_raw[frame_counter] = [[]] * NumberOfBones
            for bone_counter in range(0,NumberOfBones):
                # Set default values.
                QuArK_frame_position_raw[frame_counter][bone_counter] = QuArK_bone_pos_raw[bone_counter]
                QuArK_frame_matrix_raw[frame_counter][bone_counter] = QuArK_bone_rotmatrix_raw[bone_counter]
                QuArK_frame_scale_raw[frame_counter][bone_counter] = QuArK_bone_scale_raw[bone_counter]
                #FIXME:SHOULD BE ABLE TO DELETE _RAW's LATER?!?

        # Create the new frames.
        new_frames = {}
        for Component in Full_ComponentList:
            base_frame = Component.dictitems['Frames:fg'].subitems[0]
            frame_bunch = []
            for current_frame_index in range(0, NumberOfFrames):
                new_frame = base_frame.copy()
                new_frame.shortname = CleanupName(animframename) + " frame " + str(current_frame_index + 1)
                frame_bunch += [new_frame]
                undo.put(base_frame.parent, new_frame)
            new_frames[Component.name] = frame_bunch

        BoneToTrackGroup = {}
        for current_trackgroup_index in current_animation.trackgroups:
            current_trackgroup = trackgroups[current_trackgroup_index]
            for current_transformtrack in current_trackgroup.transformtracks:
                found_bone = None
                bone_index = 0
                for bone_obj in Full_QuArK_bones:
                    tempname = bone_obj.name
                    for bone_group_name in bone_group_names:
                        if bone_obj.name.startswith(bone_group_name + "_"):
                            tempname = bone_obj.name.replace(bone_group_name + "_", "")
                            break
                    if tempname == current_transformtrack.name + ':bone':
                        found_bone = bone_obj
                        break
                    bone_index += 1
                if found_bone is None:
                    continue
                    #raise "Error: Corrupt gr2 .ms file! Can't match up transformtracks!"
                BoneToTrackGroup[bone_index] = current_trackgroup
                for frame_index in range(NumberOfFrames):
                    frametime = float(frame_index) / float(NumberOfFrames) * current_animation.duration
                    current_curve_pos = current_transformtrack.positioncurve
                    current_curve_rot = current_transformtrack.orientationcurve
                    current_curve_scale = current_transformtrack.scaleshearcurve

                    # Do position curve.
                    if current_curve_pos.dimension == 3:
                        use_knot = -1
                        for current_knot_index in range(len(current_curve_pos.knots)):
                            if current_curve_pos.knots[current_knot_index] >= frametime:
                                use_knot = current_knot_index
                                break
                        if use_knot == -1:
                            # No "suitable" knot found; use last knot.
                            use_knot = len(current_curve_pos.knots) - 1
                        x = current_curve_pos.controls[use_knot][0]
                        y = current_curve_pos.controls[use_knot][1]
                        z = current_curve_pos.controls[use_knot][2]
                        QuArK_frame_position_raw[frame_index][bone_index] = (x, y, z)
                    elif current_curve_pos.dimension == 0:
                        QuArK_frame_position_raw[frame_index][bone_index] = (0.0, 0.0, 0.0)
                    else:
                        raise "Error: Corrupt gr2 .ms file! Bad number of dimensions for position curve!"

                    # Do orientation curve.
                    if current_curve_rot.dimension == 4:
                        use_knot = -1
                        for current_knot_index in range(len(current_curve_rot.knots)):
                            if current_curve_rot.knots[current_knot_index] >= frametime:
                                use_knot = current_knot_index
                                break
                        if use_knot == -1:
                            # No "suitable" knot found; use last knot.
                            use_knot = len(current_curve_rot.knots) - 1
                        qx = current_curve_rot.controls[use_knot][0]
                        qy = current_curve_rot.controls[use_knot][1]
                        qz = current_curve_rot.controls[use_knot][2]
                        qw = current_curve_rot.controls[use_knot][3]
                        qx, qy, qz, qw = quaternion_normalize([qx, qy, qz, qw])
                        QuArK_frame_matrix_raw[frame_index][bone_index] = quaternion2matrix([qx, qy, qz, qw])
                    elif current_curve_rot.dimension == 0:
                        QuArK_frame_matrix_raw[frame_index][bone_index] = [[1.0, 0.0, 0.0, 0.0],
                                                                           [0.0, 1.0, 0.0, 0.0],
                                                                           [0.0, 0.0, 1.0, 0.0],
                                                                           [0.0, 0.0, 0.0, 1.0]]
                    else:
                        raise "Error: Corrupt gr2 .ms file! Bad number of dimensions for orientation curve!"

                    # Do scaleshear curve.
                    if current_curve_scale.dimension == 9:
                        use_knot = -1
                        for current_knot_index in range(len(current_curve_scale.knots)):
                            if current_curve_scale.knots[current_knot_index] >= frametime:
                                use_knot = current_knot_index
                                break
                        if use_knot == -1:
                            # No "suitable" knot found; use last knot.
                            use_knot = len(current_curve_scale.knots) - 1
                        sxx = current_curve_scale.controls[use_knot][0]
                        sxy = current_curve_scale.controls[use_knot][1]
                        sxz = current_curve_scale.controls[use_knot][2]
                        syx = current_curve_scale.controls[use_knot][3]
                        syy = current_curve_scale.controls[use_knot][4]
                        syz = current_curve_scale.controls[use_knot][5]
                        szx = current_curve_scale.controls[use_knot][6]
                        szy = current_curve_scale.controls[use_knot][7]
                        szz = current_curve_scale.controls[use_knot][8]
                        QuArK_frame_scale_raw[frame_index][bone_index] = [[sxx, sxy, sxz, 0.0],
                                                                          [syx, syy, syz, 0.0],
                                                                          [szx, szy, szz, 0.0],
                                                                          [0.0, 0.0, 0.0, 1.0]]
                    elif current_curve_scale.dimension == 0:
                        QuArK_frame_scale_raw[frame_index][bone_index] = [[1.0, 0.0, 0.0, 0.0],
                                                                          [0.0, 1.0, 0.0, 0.0],
                                                                          [0.0, 0.0, 1.0, 0.0],
                                                                          [0.0, 0.0, 0.0, 1.0]]
                    else:
                        raise "Error: Corrupt gr2 .ms file! Bad number of dimensions for scale curve!"

        # Process animation frame data.
        QuArK_frame_position = [[]] * NumberOfFrames
        QuArK_frame_matrix = [[]] * NumberOfFrames
        QuArK_frame_scale = [[]] * NumberOfFrames
        for frame_counter in range(0,NumberOfFrames):
            QuArK_frame_position[frame_counter] = [[]] * NumberOfBones
            QuArK_frame_matrix[frame_counter] = [[]] * NumberOfBones
            QuArK_frame_scale[frame_counter] = [[]] * NumberOfBones
            BonesToDo = range(0,NumberOfBones)
            BoneDone = []
            for bone_counter in range(0,NumberOfBones):
                BoneDone += [0]
            while len(BonesToDo) != 0:
              DelayBones = []
              for bone_counter in BonesToDo:
                current_bone = Full_QuArK_bones[bone_counter]
                current_bone_parentname = current_bone.dictspec['parent_name']
                if current_bone_parentname == "None":
                    # Handle initial placement.
                    if BoneToTrackGroup.has_key(bone_counter):
                        current_trackgroup = BoneToTrackGroup[bone_counter]
                        if current_trackgroup.initial_placement.flags & 1:
                            parent_pos = (current_trackgroup.initial_placement.origin[0], current_trackgroup.initial_placement.origin[1], current_trackgroup.initial_placement.origin[2])
                        else:
                            parent_pos = (0.0, 0.0, 0.0)
                        if current_trackgroup.initial_placement.flags & 2:
                            parent_rot = quaternion2matrix(current_trackgroup.initial_placement.rotation)
                        else:
                            parent_rot = [[1.0, 0.0, 0.0, 0.0],
                                          [0.0, 1.0, 0.0, 0.0],
                                          [0.0, 0.0, 1.0, 0.0],
                                          [0.0, 0.0, 0.0, 1.0]]
                        if current_trackgroup.initial_placement.flags & 4:
                            parent_scale = [[current_trackgroup.initial_placement.scale[0], current_trackgroup.initial_placement.scale[1], current_trackgroup.initial_placement.scale[2], 0.0],
                                            [current_trackgroup.initial_placement.scale[3], current_trackgroup.initial_placement.scale[4], current_trackgroup.initial_placement.scale[5], 0.0],
                                            [current_trackgroup.initial_placement.scale[6], current_trackgroup.initial_placement.scale[7], current_trackgroup.initial_placement.scale[8], 0.0],
                                            [0.0                                          , 0.0                                          , 0.0                                          , 1.0]]
                        else:
                            parent_scale = [[1.0, 0.0, 0.0, 0.0],
                                            [0.0, 1.0, 0.0, 0.0],
                                            [0.0, 0.0, 1.0, 0.0],
                                            [0.0, 0.0, 0.0, 1.0]]
                    else:
                        # These can't be recovered.
                        parent_pos = (0.0, 0.0, 0.0)
                        parent_rot = [[1.0, 0.0, 0.0, 0.0],
                                      [0.0, 1.0, 0.0, 0.0],
                                      [0.0, 0.0, 1.0, 0.0],
                                      [0.0, 0.0, 0.0, 1.0]]
                        parent_scale = [[1.0, 0.0, 0.0, 0.0],
                                        [0.0, 1.0, 0.0, 0.0],
                                        [0.0, 0.0, 1.0, 0.0],
                                        [0.0, 0.0, 0.0, 1.0]]
                else:
                    if not BoneNameToBoneIndex.has_key(current_bone_parentname):
                        raise "Error: Corrupt gr2 .ms file! Can't find parent bone!"
                    parentbone_index = BoneNameToBoneIndex[current_bone_parentname]
                    if BoneDone[parentbone_index] == 0:
                        # This bone is being processed before its parent! This is BAD!
                        DelayBones += [bone_counter]
                        continue
                    parent_pos = QuArK_frame_position[frame_counter][parentbone_index]
                    parent_rot = QuArK_frame_matrix[frame_counter][parentbone_index]
                    parent_scale = QuArK_frame_scale[frame_counter][parentbone_index]

                raw_position = QuArK_frame_position_raw[frame_counter][bone_counter]
                raw_matrix = QuArK_frame_matrix_raw[frame_counter][bone_counter]
                raw_scale = QuArK_frame_scale_raw[frame_counter][bone_counter]

                # Apply origin.
                bone_pos = point_by_matrix(raw_position, parent_rot)
                bone_pos = point_by_matrix(bone_pos, parent_scale)
                bone_pos = (parent_pos[0] + bone_pos[0], parent_pos[1] + bone_pos[1], parent_pos[2] + bone_pos[2])

                # Apply rotation
                bone_rot = matrix_multiply(parent_rot, raw_matrix)

                # Apply scale.
                bone_scale = matrix_multiply(raw_scale, parent_scale)

                QuArK_frame_position[frame_counter][bone_counter] = bone_pos
                QuArK_frame_matrix[frame_counter][bone_counter] = bone_rot
                QuArK_frame_scale[frame_counter][bone_counter] = bone_scale

                frame = {}
                frame['position'] = ArtToolTransform(bone_pos)
                frame['rotmatrix'] = ArtToolTransformMatrix(quarkx.matrix((bone_rot[0][0], bone_rot[1][0], bone_rot[2][0]),
                                                                          (bone_rot[0][1], bone_rot[1][1], bone_rot[2][1]),
                                                                          (bone_rot[0][2], bone_rot[1][2], bone_rot[2][2]))).tuple
                comp = Full_ComponentList[0]
                current_frame = new_frames[comp.name][frame_counter]
                bonelist[current_bone.name]['frames'][current_frame.name] = frame
                if frame_counter == 0 and len(models) != 0 and len(animations) != 0: # File has both the model & animation.
                    #Copy this for the meshframe
                    bonelist[current_bone.name]['frames']['meshframe:mf'] = frame

                BoneDone[bone_counter] = 1
              BonesToDo = DelayBones

        #FIXME: have to update "draw_offset"!

        # Apply animation data.
        for frame_counter in range(0,NumberOfFrames):
            for mesh_counter in range(len(Full_ComponentList)):
                comp = Full_ComponentList[mesh_counter]
                current_frame = new_frames[comp.name][frame_counter]
                oldverts = newverts = current_frame.vertices
                vert_newpos = []
                vert_weight_values = []
                for vert_counter in range(len(oldverts)):
                    vert_newpos += [quarkx.vect(0.0, 0.0, 0.0)]
                    vert_weight_values += [0.0]
                for bone_counter in range(0,NumberOfBones):
                    current_bone = Full_QuArK_bones[bone_counter]
                    if current_bone.vtxlist.has_key(comp.name):
                        vtxlist = current_bone.vtxlist[comp.name]
                        if len(models) != 0 and len(animations) != 0: # File has both the model & animation.
                            frame = bonelist[current_bone.name]['frames'][new_frames[comp.name][0].name] #@
                            old_bone_pos = quarkx.vect(frame['position'])
                            old_bone_rot = quarkx.matrix(frame['rotmatrix'])
                        else:
                            old_bone_pos = current_bone.position
                            old_bone_rot = quarkx.matrix(bonelist[current_bone.name]['frames']['meshframe:mf']['rotmatrix'])
                        frame = bonelist[current_bone.name]['frames'][current_frame.name]
                        new_bone_pos = quarkx.vect(frame['position'])
                        new_bone_rot = quarkx.matrix(frame['rotmatrix'])
                        # new_bone_scale?
                        for vert_index in vtxlist:
                            weight_value = 1.0
                            if editor.ModelComponentList[comp.name]['weightvtxlist'].has_key(vert_index) and editor.ModelComponentList[comp.name]['weightvtxlist'][vert_index].has_key(current_bone.name):
                                weight_value = editor.ModelComponentList[comp.name]['weightvtxlist'][vert_index][current_bone.name]['weight_value']
                            vert_weight_values[vert_index] += weight_value

                            newpos = oldverts[vert_index] - old_bone_pos
                            newpos = new_bone_rot * (~old_bone_rot) * newpos
                            newpos = (newpos + new_bone_pos) * weight_value
                            vert_newpos[vert_index] += newpos
                            
                for vert_counter in range(len(oldverts)):
                    # Use this to fake a (weight_value = 1.0)
                    #vert_newpos[vert_counter] += oldverts[vert_counter] * (1.0 - vert_weight_values[vert_counter])
                    newverts[vert_counter] = vert_newpos[vert_counter]
                current_frame.vertices = newverts
        progressbar.progress()

    progressbar.close()

    #Strings[2454] = Strings[2454].replace(Component.shortname + "\n", "")
    #ie_utils.default_end_logging(filename, "IM", starttime) ### Use "EX" for exporter text, "IM" for importer text.

    try:
        editor.Root.currentcomponent = Full_ComponentList[0]  # Sets the current component.
    except:
        quarkx.beep() # Makes the computer "Beep" once if a file is not valid.
        quarkx.msgbox("Invalid Action !\n\nYou are trying to load an animation file only    \n" + filename + "\n\nBut there is no model mesh in the editor.\nImport the model first then try again.", quarkpy.qutils.MT_ERROR, quarkpy.qutils.MB_OK)
        return

    undomessage = CleanupName(filename)
    undomessage = undomessage.split("\\")
    undomessage = undomessage[-1]
    if (len(meshes) <> 0) and (len(animations) == 0):
        undomessage = "MESH " + undomessage
    elif (len(meshes) == 0) and (len(animations) <> 0):
        undomessage = "ANIM " + undomessage
    else:
        undomessage = "MIXD " + undomessage
    editor.ok(undo, undomessage + " loaded")

    comp = editor.Root.currentcomponent
    skins = comp.findallsubitems("", ':sg')      # Gets the skin group.
    if len(skins[0].subitems) != 0:
        comp.currentskin = skins[0].subitems[0]      # To try and set to the correct skin.
        quarkpy.mdlutils.Update_Skin_View(editor, 2) # Sends the Skin-view for updating and center the texture in the view.
    else:
        comp.currentskin = None
    return

### To register this Python plugin and put it on the importers menu.
import quarkpy.qmdlbase
import ie_gr2_import # This imports itself to be passed along so it can be used in mdlmgr.py later for the Specifics page.
quarkpy.qmdlbase.RegisterMdlImporter(".gr2 Importer", ".gr2 mesh or anim file", "*.gr2", loadmodel, ie_gr2_import)


def vtxcolorclick(btn):
    global editor
    if editor is None:
        editor = quarkpy.mdleditor.mdleditor # Get the editor.
    if quarkx.setupsubset(SS_MODEL, "Options")["LinearBox"] == "1":
        editor.ModelVertexSelList = []
        editor.linearbox = "True"
        editor.linear1click(btn)
    else:
        if editor.ModelVertexSelList != []:
            editor.ModelVertexSelList = []
            quarkpy.mdlutils.Update_Editor_Views(editor)


def colorclick(btn):
    global editor
    import quarkpy.qtoolbar # Get the toolbar functions to make the button with.
    if editor is None:
        editor = quarkpy.mdleditor.mdleditor # Get the editor.
    if not quarkx.setupsubset(SS_MODEL, "Options")['VertexUVColor'] or quarkx.setupsubset(SS_MODEL, "Options")['VertexUVColor'] == "0":
        quarkx.setupsubset(SS_MODEL, "Options")['VertexUVColor'] = "1"
        quarkpy.qtoolbar.toggle(btn)
        btn.state = quarkpy.qtoolbar.selected
        quarkx.update(editor.form)
        vtxcolorclick(btn)
    else:
        quarkx.setupsubset(SS_MODEL, "Options")['VertexUVColor'] = "0"
        quarkpy.qtoolbar.toggle(btn)
        btn.state = quarkpy.qtoolbar.normal
        quarkx.update(editor.form)

def dataformname(o):
    "Returns the data form for this type of object 'o' (a model's skin texture) to use for the Specific/Args page."
    global editor
    import quarkpy.mdlentities # Used further down in a couple of places.

    # Next line calls for the Shader Module in mdlentities.py to be used.
    external_skin_editor_dialog_plugin = quarkpy.mdlentities.UseExternalSkinEditor()

    # Next line calls for the Vertex U,V Color Module in mdlentities.py to be used.
    vtx_UVcolor_dialog_plugin = quarkpy.mdlentities.UseVertexUVColors()

    # Next line calls for the Vertex Weights Specifics Module in mdlentities.py to be used.
    vertex_weights_specifics_plugin = quarkpy.mdlentities.UseVertexWeightsSpecifics()

    # Next line calls for the Shader Module in mdlentities.py to be used.
    Shader_dialog_plugin = quarkpy.mdlentities.UseShaders()

    dlgdef = """
    {
      Help = "These are the Specific settings for Granny (.gr2) model types."$0D
             "gr2 models use 'meshes' the same way that QuArK uses 'components'."$0D
             "Each can have its own special Surface or skin texture settings."$0D
             "These textures may or may not have 'shaders' that they use for special effects."$0D0D22
             "skin name"$22" - The currently selected skin texture name."$0D22
             "edit skin"$22" - Opens this skin texture in an external editor."$0D22
             "nbr of frames"$22" - Sets the number of animation key frames to be imported, default = 20."$0D
             "            The grater number of frames to be imported can take much longer."$0D
             "            If the file has fewer frames then this setting that is what will load."$0D22
             "Vertex Color"$22" - Color to use for this component's u,v vertex color mapping."$0D
             "            Click the color display button to select a color."$0D22
             "show weight colors"$22" - When checked, if component has vertex weight coloring they will show."$0D
             "          If NOT checked and it has bones with vetexes, those will show."$0D
             "shader file"$22" - Gives the full path and name of the .mtr material"$0D
             "           shader file that the selected skin texture uses, if any."$0D22
             "shader name"$22" - Gives the name of the shader located in the above file"$0D
             "           that the selected skin texture uses, if any."$0D22
             "shader keyword"$22" - Gives the above shader 'keyword' that is used to identify"$0D
             "          the currently selected skin texture used in the shader, if any."$0D22
             "shader lines"$22" - Number of lines to display in window below, max. = 35."$0D22
             "edit shader"$22" - Opens shader below in a text editor."$0D22
             "mesh shader"$22" - Contains the full text of this skin texture's shader, if any."$0D22
             "          This can be copied to a text file, changed and saved."
      skin_name:      = {t_ModelEditor_texturebrowser = ! Txt="skin name"    Hint="The currently selected skin texture name."}
      """ + external_skin_editor_dialog_plugin + """
      Sep: = {Typ = "S"   Txt = ""}
      gr_max_frames: = {
                     Typ = "EU"
                     Txt = "nbr of frames"
                     Hint = "Sets the number of animation key frames to be imported, default = 20."$0D
                            "The grater number of frames to be imported can take much longer."$0D
                            "If the file has fewer frames then this setting that is what will load."
                    }
      """ + vtx_UVcolor_dialog_plugin + """
      """ + vertex_weights_specifics_plugin + """
      """ + Shader_dialog_plugin + """
    }
    """

    from quarkpy.qeditor import ico_dict # Get the dictionary list of all icon image files available.
    import quarkpy.qtoolbar              # Get the toolbar functions to make the button with.
    editor = quarkpy.mdleditor.mdleditor # Get the editor.
    ico_mdlskv = ico_dict['ico_mdlskv']  # Just to shorten our call later.
    icon_btns = {}                       # Setup our button list, as a dictionary list, to return at the end.
    vtxcolorbtn = quarkpy.qtoolbar.button(colorclick, "Color mode||When active, puts the editor vertex selection into this mode and uses the 'COLR' specific setting as the color to designate these types of vertexes.\n\nIt also places the editor into Vertex Selection mode if not there already and clears any selected vertexes to protect from including unwanted ones by mistake.\n\nAny vertexes selected in this mode will become Color UV Vertexes and added to the component as such. Click the InfoBase button or press F1 again for more detail.|intro.modeleditor.dataforms.html#specsargsview", ico_mdlskv, 5)
    # Sets the button to its current status, that might be effected by another importer file, either on or off.
    if quarkx.setupsubset(SS_MODEL, "Options")['VertexUVColor'] == "1":
        vtxcolorbtn.state = quarkpy.qtoolbar.selected
    else:
        vtxcolorbtn.state = quarkpy.qtoolbar.normal
    vtxcolorbtn.caption = "" # Texts shows next to button and keeps the width of this button so it doesn't change.
    icon_btns['color'] = vtxcolorbtn # Put our button in the above list to return.
    # Next line calls for the Vertex Weights system in mdlentities.py to be used.
    vtxweightsbtn = quarkpy.qtoolbar.button(quarkpy.mdlentities.UseVertexWeights, "Open or Update\nVertex Weights Dialog||When clicked, this button opens the dialog to allow the 'weight' movement setting of single vertexes that have been assigned to more then one bone handle.\n\nClick the InfoBase button or press F1 again for more detail.|intro.modeleditor.dataforms.html#specsargsview", ico_mdlskv, 5)
    vtxweightsbtn.state = quarkpy.qtoolbar.normal
    vtxweightsbtn.caption = "" # Texts shows next to button and keeps the width of this button so it doesn't change.
    icon_btns['vtxweights'] = vtxweightsbtn # Put our button in the above list to return.

    if (editor.Root.currentcomponent.currentskin is not None) and (o.name == editor.Root.currentcomponent.currentskin.name): # If this is not done it will cause looping through multiple times.
        if o.parent.parent.dictspec.has_key("shader_keyword") and o.dictspec.has_key("shader_keyword"):
            if o.parent.parent.dictspec['shader_keyword'] != o.dictspec['shader_keyword']:
                o['shader_keyword'] = o.parent.parent.dictspec['shader_keyword']
        if (o.parent.parent.dictspec.has_key("skin_name")) and (o.parent.parent.dictspec['skin_name'] != o.name) and (not o.parent.parent.dictspec['skin_name'] in o.parent.parent.dictitems['Skins:sg'].dictitems.keys()):
            # Gives the newly selected skin texture's game folders path and file name, for example:
            #     models/monsters/cacodemon/cacoeye.tga
            skinname = o.parent.parent.dictspec['skin_name']
            skin = quarkx.newobj(skinname)
            # Gives the full current work directory (cwd) path up to the file name, need to add "\\" + filename, for example:
            #     E:\Program Files\Doom 3\base\models\monsters\cacodemon
            cur_folder = os.getcwd()
            # Gives just the actual file name, for example: cacoeye.tga
            tex_file = skinname.split("/")[-1]
            # Puts the full path and file name together to get the file, for example:
            # E:\Program Files\Doom 3\base\models\monsters\cacodemon\cacoeye.tga
            file = cur_folder + "\\" + tex_file
            image = quarkx.openfileobj(file)
            skin['Image1'] = image.dictspec['Image1']
            skin['Size'] = image.dictspec['Size']
            skin['shader_keyword'] = o.parent.parent.dictspec['shader_keyword']
            skingroup = o.parent.parent.dictitems['Skins:sg']
            undo = quarkx.action()
            undo.put(skingroup, skin)
            editor.ok(undo, o.parent.parent.shortname + " - " + "new skin added")
            editor.Root.currentcomponent.currentskin = skin
            editor.layout.explorer.sellist = [editor.Root.currentcomponent.currentskin]
            quarkpy.mdlutils.Update_Skin_View(editor, 2)

    DummyItem = o
    while (DummyItem.type != ":mc"): # Gets the object's model component.
        DummyItem = DummyItem.parent
    comp = DummyItem

    if comp.type == ":mc": # Just makes sure what we have is a model component.
        if not comp.dictspec.has_key('gr_max_frames'):
            comp['gr_max_frames'] = "20"
        elif int(comp.dictspec['gr_max_frames']) < 2:
            comp['gr_max_frames'] = "2"

        formobj = quarkx.newobj("gr2_mc:form")
        formobj.loadtext(dlgdef)
        return formobj, icon_btns
    else:
        return None, None

def dataforminput(o):
    "Returns the default settings or input data for this type of object 'o' (a model's skin texture) to use for the Specific/Args page."

    DummyItem = o
    while (DummyItem.type != ":mc"): # Gets the object's model component.
        DummyItem = DummyItem.parent
    if DummyItem.type == ":mc":
        comp = DummyItem

        if not comp.dictspec.has_key('vtx_color'):
            comp['vtx_color'] = "0.75 0.75 0.75"
        # This sections handles the data for this model type skin page form.
        # This makes sure what is selected is a model skin, if so it fills the Skin page data and adds the items to the component.
        # It also handles the shader file which its name is the full path and name of the skin texture.
        if len(comp.dictitems['Skins:sg'].subitems) == 0 or o in comp.dictitems['Skins:sg'].subitems:
            if not comp.dictspec.has_key('shader_file'):
                comp['shader_file'] = "None"
            if not comp.dictspec.has_key('shader_name'):
                comp['shader_name'] = "None"
            if not comp.dictspec.has_key('skin_name'):
                if len(comp.dictitems['Skins:sg'].subitems) != 0:
                   comp['skin_name'] = o.name
                else:
                   comp['skin_name'] = "no skins exist"
            else:
                if len(comp.dictitems['Skins:sg'].subitems) != 0:
                   comp['skin_name'] = o.name
                else:
                   comp['skin_name'] = "no skins exist"
            if not comp.dictspec.has_key('shader_keyword'):
                if o.dictspec.has_key("shader_keyword"):
                    comp['shader_keyword'] = o.dictspec['shader_keyword']
                else:
                    comp['shader_keyword'] = o['shader_keyword'] = "None"
            else:
                if o.dictspec.has_key("shader_keyword"):
                    comp['shader_keyword'] = o.dictspec['shader_keyword']
                else:
                    comp['shader_keyword'] = o['shader_keyword'] = "None"
            if not comp.dictspec.has_key('shader_lines'):
                if quarkx.setupsubset(SS_MODEL, "Options")["NbrOfShaderLines"] is not None:
                    comp['shader_lines'] = quarkx.setupsubset(SS_MODEL, "Options")["NbrOfShaderLines"]
                else:
                    comp['shader_lines'] = "8"
                    quarkx.setupsubset(SS_MODEL, "Options")["NbrOfShaderLines"] = comp.dictspec['shader_lines']
            else:
                quarkx.setupsubset(SS_MODEL, "Options")["NbrOfShaderLines"] = comp.dictspec['shader_lines']
            if not comp.dictspec.has_key('mesh_shader'):
                comp['mesh_shader'] = "None"

# ----------- REVISION HISTORY ------------
#
# $Log$
# Revision 1.26  2010/05/15 17:38:13  cdunde
# To avoid loading error and give the user a message.
#
# Revision 1.25  2010/05/15 03:29:50  cdunde
# Small change to handle models without imbedded textures.
#
# Revision 1.24  2010/05/14 20:18:57  danielpharos
# Added skin importing for .gr2 models.
#
# Revision 1.23  2010/05/10 19:47:31  cdunde
# Texture UV fix by DanielPharos.
#
# Revision 1.22  2010/05/10 18:41:49  danielpharos
# Also output actual error.
#
# Revision 1.21  2010/05/07 19:11:12  cdunde
# To allow model attachments to animate with model,
# selected components to animate with other components
# and some file cleanup.
#
# Revision 1.20  2010/05/07 06:22:34  cdunde
# Changed mesh variable name reused in animation section to avoid confusion.
#
# Revision 1.19  2010/05/06 22:26:24  cdunde
# Great animation improvement fixes by DanielPharos.
#
# Revision 1.18  2010/05/04 19:39:03  cdunde
# Update to work much better with models that do and do not include animation in the same file.
#
# Revision 1.17  2010/05/03 21:59:22  cdunde
# File update fixes by DanielPharos. Still a work in progress.
#
# Revision 1.16  2010/05/01 07:16:40  cdunde
# Update by DanielPharos to allow removal of weight_index storage in the ModelComponentList related files.
#
# Revision 1.15  2010/05/01 04:25:37  cdunde
# Updated files to help increase editor speed by including necessary ModelComponentList items
# and removing redundant checks and calls to the list.
#
