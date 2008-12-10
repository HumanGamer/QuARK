# Two lines below to stop encoding errors in the console.
#!/usr/bin/python
# -*- coding: ascii -*-

"""   QuArK  -  Quake Army Knife

QuArK Model Editor importer for Doom3\Quake4 .md5mesh and .md5anim model files.
"""
#
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$


Info = {
   "plug-in":       "ie_md5_importer",
   "desc":          "This script imports a Doom3\Quake4 .md5mesh and .md5anim model file, textures, and animations into QuArK for editing. Original code from Blender, md5Import_0.5.py, author - Bob Holcomb.",
   "date":          "Dec 5 2008",
   "author":        "cdunde & DanielPharos",
   "author e-mail": "cdunde@sbcglobal.net",
   "quark":         "Version 6.6.0 Beta 2" }

######################################################
# Importing modules
######################################################


import sys, struct, os
from types import *
import quarkx
import quarkpy.mdleditor
import quarkpy.mdlhandles
import ie_utils
from os import path
from ie_utils import tobj
import math
from math import *
from quarkpy.qdictionnary import Strings
# HACK -- it seems that some Blender versions don't define sys.argv,
# which may crash Python if a warning occurs.
if not hasattr(sys, "argv"): sys.argv = ["???"]

# Globals for QuArK
logging = 0
importername = "ie_md5_import.py"
textlog = "md5_ie_log.txt"
editor = None
progressbar = None
scale = 1.0 # Blender uses a slide to set this scale, word search for uses.



######################################################
# Vector, Quaterion, Matrix math stuff-taken from
# Jiba's blender2cal3d script
######################################################


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

def matrix2quaternion(m):
  s = math.sqrt(abs(m[0][0] + m[1][1] + m[2][2] + m[3][3]))
  if s == 0.0:
    x = abs(m[2][1] - m[1][2])
    y = abs(m[0][2] - m[2][0])
    z = abs(m[1][0] - m[0][1])
    if   (x >= y) and (x >= z): return 1.0, 0.0, 0.0, 0.0
    elif (y >= x) and (y >= z): return 0.0, 1.0, 0.0, 0.0
    else:                       return 0.0, 0.0, 1.0, 0.0
  return quaternion_normalize([
    -(m[2][1] - m[1][2]) / (2.0 * s),
    -(m[0][2] - m[2][0]) / (2.0 * s),
    -(m[1][0] - m[0][1]) / (2.0 * s),
    0.5 * s,
    ])

def quaternion_normalize(q):
  l = math.sqrt(q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3])
  return q[0] / l, q[1] / l, q[2] / l, q[3] / l

def quaternion_multiply(q1, q2):
  r = [
    q2[3] * q1[0] + q2[0] * q1[3] + q2[1] * q1[2] - q2[2] * q1[1],
    q2[3] * q1[1] + q2[1] * q1[3] + q2[2] * q1[0] - q2[0] * q1[2],
    q2[3] * q1[2] + q2[2] * q1[3] + q2[0] * q1[1] - q2[1] * q1[0],
    q2[3] * q1[3] - q2[0] * q1[0] - q2[1] * q1[1] - q2[2] * q1[2],
    ]
  d = math.sqrt(r[0] * r[0] + r[1] * r[1] + r[2] * r[2] + r[3] * r[3])
  r[0] /= d
  r[1] /= d
  r[2] /= d
  r[3] /= d
  return r

def matrix_translate(m, v):
  m[3][0] += v[0]
  m[3][1] += v[1]
  m[3][2] += v[2]
  return m

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

def matrix_invert(m):
  det = (m[0][0] * (m[1][1] * m[2][2] - m[2][1] * m[1][2])
       - m[1][0] * (m[0][1] * m[2][2] - m[2][1] * m[0][2])
       + m[2][0] * (m[0][1] * m[1][2] - m[1][1] * m[0][2]))
  if det == 0.0: return None
  det = 1.0 / det
  r = [ [
      det * (m[1][1] * m[2][2] - m[2][1] * m[1][2]),
    - det * (m[0][1] * m[2][2] - m[2][1] * m[0][2]),
      det * (m[0][1] * m[1][2] - m[1][1] * m[0][2]),
      0.0,
    ], [
    - det * (m[1][0] * m[2][2] - m[2][0] * m[1][2]),
      det * (m[0][0] * m[2][2] - m[2][0] * m[0][2]),
    - det * (m[0][0] * m[1][2] - m[1][0] * m[0][2]),
      0.0
    ], [
      det * (m[1][0] * m[2][1] - m[2][0] * m[1][1]),
    - det * (m[0][0] * m[2][1] - m[2][0] * m[0][1]),
      det * (m[0][0] * m[1][1] - m[1][0] * m[0][1]),
      0.0,
    ] ]
  r.append([
    -(m[3][0] * r[0][0] + m[3][1] * r[1][0] + m[3][2] * r[2][0]),
    -(m[3][0] * r[0][1] + m[3][1] * r[1][1] + m[3][2] * r[2][1]),
    -(m[3][0] * r[0][2] + m[3][1] * r[1][2] + m[3][2] * r[2][2]),
    1.0,
    ])
  return r

def matrix_rotate_x(angle):
  cos = math.cos(angle)
  sin = math.sin(angle)
  return [
    [1.0,  0.0, 0.0, 0.0],
    [0.0,  cos, sin, 0.0],
    [0.0, -sin, cos, 0.0],
    [0.0,  0.0, 0.0, 1.0],
    ]

def matrix_rotate_y(angle):
  cos = math.cos(angle)
  sin = math.sin(angle)
  return [
    [cos, 0.0, -sin, 0.0],
    [0.0, 1.0,  0.0, 0.0],
    [sin, 0.0,  cos, 0.0],
    [0.0, 0.0,  0.0, 1.0],
    ]

def matrix_rotate_z(angle):
  cos = math.cos(angle)
  sin = math.sin(angle)
  return [
    [ cos, sin, 0.0, 0.0],
    [-sin, cos, 0.0, 0.0],
    [ 0.0, 0.0, 1.0, 0.0],
    [ 0.0, 0.0, 0.0, 1.0],
    ]

def matrix_rotate(axis, angle):
  vx  = axis[0]
  vy  = axis[1]
  vz  = axis[2]
  vx2 = vx * vx
  vy2 = vy * vy
  vz2 = vz * vz
  cos = math.cos(angle)
  sin = math.sin(angle)
  co1 = 1.0 - cos
  return [
    [vx2 * co1 + cos,          vx * vy * co1 + vz * sin, vz * vx * co1 - vy * sin, 0.0],
    [vx * vy * co1 - vz * sin, vy2 * co1 + cos,          vy * vz * co1 + vx * sin, 0.0],
    [vz * vx * co1 + vy * sin, vy * vz * co1 - vx * sin, vz2 * co1 + cos,          0.0],
    [0.0, 0.0, 0.0, 1.0],
    ]

def matrix_scale(fx, fy, fz):
  return [
    [ fx, 0.0, 0.0, 0.0],
    [0.0,  fy, 0.0, 0.0],
    [0.0, 0.0,  fz, 0.0],
    [0.0, 0.0, 0.0, 1.0],
    ]

def point_by_matrix(p, m):
  return [p[0] * m[0][0] + p[1] * m[1][0] + p[2] * m[2][0] + m[3][0],
          p[0] * m[0][1] + p[1] * m[1][1] + p[2] * m[2][1] + m[3][1],
          p[0] * m[0][2] + p[1] * m[1][2] + p[2] * m[2][2] + m[3][2]]

def point_distance(p1, p2):
  return math.sqrt((p2[0] - p1[0]) ** 2 + (p2[1] - p1[1]) ** 2 + (p2[2] - p1[2]) ** 2)

def vector_by_matrix(p, m):
  return [p[0] * m[0][0] + p[1] * m[1][0] + p[2] * m[2][0],
          p[0] * m[0][1] + p[1] * m[1][1] + p[2] * m[2][1],
          p[0] * m[0][2] + p[1] * m[1][2] + p[2] * m[2][2]]

def vector_length(v):
  return math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])

def vector_normalize(v):
  l = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
  try:
    return v[0] / l, v[1] / l, v[2] / l
  except:
    return 1, 0, 0

def vector_dotproduct(v1, v2):
  return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2]

def vector_crossproduct(v1, v2):
  return [
    v1[1] * v2[2] - v1[2] * v2[1],
    v1[2] * v2[0] - v1[0] * v2[2],
    v1[0] * v2[1] - v1[1] * v2[0],
    ]

def vector_angle(v1, v2):
  s = vector_length(v1) * vector_length(v2)
  f = vector_dotproduct(v1, v2) / s
  if f >=  1.0: return 0.0
  if f <= -1.0: return math.pi / 2.0
  return math.atan(-f / math.sqrt(1.0 - f * f)) + math.pi / 2.0


######################################################
# MD5 Data structures
######################################################


class md5_vert:
	vert_index=0
	co=[]
	uvco=[]
	blend_index=0
	blend_count=0

	def __init__(self):
		self.vert_index=0
		self.co=[0.0]*3
		self.uvco=[0.0]*2
		self.blend_index=0
		self.blend_count=0

	def dump(self):
		print "vert index: ", self.vert_index
		print "co: ", self.co
		print "uvco: ", self.uvco
		print "blend index: ", self.blend_index
		print "belnd count: ", self.blend_count

class md5_weight:
	weight_index=0
	bone_index=0
	bias=0.0
	weights=[]

	def __init__(self):
		self.weight_index=0
		self.bone_index=0
		self.bias=0.0
		self.weights=[0.0]*3

	def dump(self):
		print "weight index: ", self.weight_index
		print "bone index: ", self.bone_index
		print "bias: ", self.bias
		print "weighst: ", self.weights

class md5_bone:
	bone_index=0
	name=""
	bindpos=[]
	bindmat=[]
	parent=""
	parent_index=0
	blenderbone=None
	roll=0

	def __init__(self):
		self.bone_index=0
		self.name=""
		self.bindpos=[0.0]*3
		self.bindmat=[None]*3  #is this how you initilize a 2d-array
		for i in range(3): self.bindmat[i] = [0.0]*3
		self.parent=""
		self.parent_index=0
		self.blenderbone=None

	def dump(self):
		print "bone index: ", self.bone_index
		print "name: ", self.name
		print "bind position: ", self.bindpos
		print "bind translation matrix (mat): ", self.bindmat
		print "parent: ", self.parent
		print "parent index: ", self.parent_index
		print "blenderbone: ", self.blenderbone


class md5_tri:
	tri_index=0
	vert_index=[]

	def __init__(self):
		self.tri_index=0;
		self.vert_index=[0]*3

	def dump(self):
		print "tri index: ", self.tri_index
		print "vert index: ", self.vert_index

class md5_mesh:
	mesh_index=0
	verts=[]
	tris=[]
	weights=[]
	shader=""

	def __init__(self):
		self.mesh_index=0
		self.verts=[]
		self.tris=[]
		self.weights=[]
		self.shader=""

	def dump(self):
		print "mesh index: ", self.mesh_index
		print "verts: ", self.verts
		print "tris: ", self.tris
		print "weights: ", self.weights
		print "shader: ", self.shader

######################################################
# IMPORT
######################################################


def load_md5(md5_filename, basepath):
        global progressbar, tobj, logging, Strings

    ### This area is where we make the different elements of a QuArK Component, for each Component.
        # First we check for any other "Import Component"s,
        # if so we name the first component 1 more then the largest number
        # and increase each following component by 1.
        CompNbr = "None"
        comparenbr = 0
        for item in editor.Root.dictitems:
            if editor.Root.dictitems[item].shortname.startswith('Import Component'):
                getnbr = editor.Root.dictitems[item].shortname
                getnbr = getnbr.replace('Import Component', '')
                if getnbr == "":
                   nbr = 0
                else:
                    nbr = int(getnbr)
                if nbr > comparenbr:
                    comparenbr = nbr
                nbr = comparenbr + 1
                CompNbr = nbr
        if CompNbr != "None":
            pass
        else:
            CompNbr = 1

        ComponentList = []
        message = ""

        #read the file in
        file=open(md5_filename,"r")
        lines=file.readlines()
        file.close()

        md5_model=[]
        md5_bones=[]

        num_lines=len(lines)

        mesh_counter=0
        for line_counter in range(0,num_lines):
            current_line=lines[line_counter]
            words=current_line.split()

            if words and words[0]=="numJoints":
                #print "found a bunch of bones"
                num_bones=int(words[1])
                #print "num_bones: ", num_bones
            elif words and words[0]=="joints":
                for bone_counter in range(0,num_bones):
                    #make a new bone
                    md5_bones.append(md5_bone())
		    #next line
                    line_counter+=1
                    current_line=lines[line_counter]
                    words=current_line.split()
                    #skip over blank lines
                    while not words:
                        line_counter+=1
                        current_line=lines[line_counter]
                        words=current_line.split()

                    md5_bones[bone_counter].bone_index=bone_counter
                    #get rid of the quotes on either side
                    temp_name=str(words[0])
                    temp_name=temp_name[1:-1]
                    md5_bones[bone_counter].name=temp_name
         #           print "found a bone: ", md5_bones[bone_counter].name
                    md5_bones[bone_counter].parent_index = int(words[1])
         #           print "parent_index: ", md5_bones[bone_counter].parent_index
                    if md5_bones[bone_counter].parent_index>=0:
                        md5_bones[bone_counter].parent = md5_bones[md5_bones[bone_counter].parent_index].name
                    md5_bones[bone_counter].bindpos[0]=float(words[3])
                    md5_bones[bone_counter].bindpos[1]=float(words[4])
                    md5_bones[bone_counter].bindpos[2]=float(words[5])
        #            print "bindpos: ", md5_bones[bone_counter].bindpos
                    qx = float(words[8])
                    qy = float(words[9])
                    qz = float(words[10])
        #            print "qx,qy,qz: ",qx,qy,qz
                    qw = 1 - qx*qx - qy*qy - qz*qz
                    if qw<0:
                        qw=0
                    else:
                        qw = -sqrt(qw)
                    md5_bones[bone_counter].bindmat = quaternion2matrix([qx,qy,qz,qw])
       #             print "bindmat: ", md5_bones[bone_counter].bindmat
                for bone in md5_bones:
                    bone.dump()


            elif words and words[0]=="numMeshes":
                num_meshes=int(words[1])
       #         print "num_meshes: ", num_meshes
            elif words and words[0]=="mesh":
                #create a new mesh and name it
                md5_model.append(md5_mesh())
                #print "md5_mesh: ",md5_model
                md5_model[mesh_counter].mesh_index = mesh_counter
                #print "mesh_index: ",md5_model[mesh_counter].mesh_index
                while (not words or (words and words[0]!="}")):
                        line_counter+=1
                        current_line=lines[line_counter]
                        words=current_line.split()
                        if words and words[0]=="shader":
                            #print "found a shader"
                            temp_name=str(words[1])
                            temp_name=temp_name[1:-1]
                            md5_model[mesh_counter].shader=temp_name
                        if words and words[0]=="vert":
			    #print "found a vert"
                            md5_model[mesh_counter].verts.append(md5_vert())
                            vert_counter=len(md5_model[mesh_counter].verts)-1
			    #load it with the raw data
                            md5_model[mesh_counter].verts[vert_counter].vert_index=int(words[1])
                            md5_model[mesh_counter].verts[vert_counter].uvco[0]=float(words[3])
                            md5_model[mesh_counter].verts[vert_counter].uvco[1]=(1-float(words[4]))
                            md5_model[mesh_counter].verts[vert_counter].blend_index=int(words[6])
                            md5_model[mesh_counter].verts[vert_counter].blend_count=int(words[7])
                        if words and words[0]=="tri":
                            #print "found a tri"
                            md5_model[mesh_counter].tris.append(md5_tri())
                            tri_counter=len(md5_model[mesh_counter].tris)-1
                            #load it with raw data
                            md5_model[mesh_counter].tris[tri_counter].tri_index=int(words[1])
                            md5_model[mesh_counter].tris[tri_counter].vert_index[0]=int(words[2])
                            md5_model[mesh_counter].tris[tri_counter].vert_index[1]=int(words[3])
                            md5_model[mesh_counter].tris[tri_counter].vert_index[2]=int(words[4])
                        if words and words[0]=="weight":
                            #print "found a weight"
                            md5_model[mesh_counter].weights.append(md5_weight())
                            weight_counter=len(md5_model[mesh_counter].weights)-1
                            #load it with raw data
                            md5_model[mesh_counter].weights[weight_counter].weight_index=int(words[1])
                            md5_model[mesh_counter].weights[weight_counter].bone_index=int(words[2])
                            md5_model[mesh_counter].weights[weight_counter].bias=float(words[3])
                            md5_model[mesh_counter].weights[weight_counter].weights[0]=float(words[5])
                            md5_model[mesh_counter].weights[weight_counter].weights[1]=float(words[6])
                            md5_model[mesh_counter].weights[weight_counter].weights[2]=float(words[7])
                            #md5_model[mesh_counter].weights[weight_counter].dump()
                #print "end of this mesh structure"
                mesh_counter += 1


	#figure out the base pose for each vertex from the weights
        for mesh in md5_model:
                #print "updating vertex info for mesh: ", mesh.mesh_index
                mesh.dump()
                for vert_counter in range(0, len(mesh.verts)):
                        blend_index=mesh.verts[vert_counter].blend_index
                        for blend_counter in range(0, mesh.verts[vert_counter].blend_count):
                                #get the current weight info
                                w=mesh.weights[blend_index+blend_counter]
                                #print "w: "
                                #w.dump()
                                #the bone that the current weight is refering to
                                b=md5_bones[w.bone_index]
                                #print "b: "
                                #b.dump()
                                #a position is the weight position * bone transform matrix (or position)
                                pos=[0.0]*3
                                #print "pos: ", pos
                                pos= vector_by_matrix(w.weights, b.bindmat)
                                #print "pos: ", pos
                                #print "w.bias: ", w.bias
                                #print "b.bindpos: ", b.bindpos
                                pos=((pos[0]+b.bindpos[0])*w.bias, (pos[1]+b.bindpos[1])*w.bias, (pos[2]+b.bindpos[2])*w.bias)
                                #print "pos: ", pos
                                #vertex position is sum of all weight info adjusted for bias
                                mesh.verts[vert_counter].co[0]+=pos[0]
                                mesh.verts[vert_counter].co[1]+=pos[1]
                                mesh.verts[vert_counter].co[2]+=pos[2]

	#build the armature in blender
  #      print "line 515 md5_filename",md5_filename
     #   translationtable = string.maketrans("\\", "/")
     #   tempstring = string.translate(md5_filename, translationtable)
     #   lindex = string.rfind(tempstring, "/")
     #   rindex = string.rfind(tempstring, ".")
        tempstring = md5_filename.replace("\\", "/")
  #      print "line 521 tempstring",tempstring
        lindex = tempstring.rfind( "/")
        rindex = tempstring.rfind(".")
  #      print "line 524 lindex, rindex",lindex, rindex
        if lindex==-1: lindex=0
    #    tempstring = string.rstrip(tempstring, ".md5mesh")
        tempstring = tempstring.rstrip(".md5mesh")
 #       print "line 5281 tempstring",tempstring
        tempstring = tempstring[lindex+1:len(tempstring)]
 #       print "line 530 tempstring",tempstring
    #    armObj = Object.New('Armature', tempstring)
    #    armData = Blender.Armature.Armature("MD5_ARM") 
    #    armData.drawAxes = True 
    #    armObj.link(armData) 
    #    scene = Blender.Scene.getCurrent() 
    #    scene.link(armObj) 
    #    armData.makeEditable() 
        # QuArK, make bones here.
        for bone in md5_bones: 
    #        bone.blenderbone = Blender.Armature.Editbone() 
    #        headData = Blender.Mathutils.Vector(bone.bindpos[0]*scale, bone.bindpos[1]*scale, bone.bindpos[2]*scale)
            headData = quarkx.vect(bone.bindpos[0]*scale, bone.bindpos[1]*scale, bone.bindpos[2]*scale)
 #           print "line 543 bone start_point",headData
    #        bone.blenderbone.head = headData 
    #        tailData = Blender.Mathutils.Vector(bone.bindpos[0]*scale+bonesize*scale*bone.bindmat[1][0], bone.bindpos[1]*scale+bonesize*scale*bone.bindmat[1][1], bone.bindpos[2]*scale+bonesize*scale*bone.bindmat[1][2])
            tailData = quarkx.vect(bone.bindpos[0]*scale+bonesize*scale*bone.bindmat[1][0], bone.bindpos[1]*scale+bonesize*scale*bone.bindmat[1][1], bone.bindpos[2]*scale+bonesize*scale*bone.bindmat[1][2])
 #           print "line 547 bone end_point",tailData
    #        bone.blenderbone.tail = tailData 
    #        if bone.parent != "": 
    #            bone.blenderbone.parent = md5_bones[bone.parent_index].blenderbone 

            #rotate the bones correctly through this HACK (yeah it's ridiculous ;) 
            #could probably be optimized a bit... 
 #           boneisaligned=False 
 #           for i in range(0, 359): 
 #               boneisaligned=False 
 #               m = Blender.Mathutils.Matrix(bone.blenderbone.matrix) 
 #               mb = bone.bindmat 
 #               cos = vector_dotproduct(vector_normalize(m[0]), vector_normalize(mb[0])) 
 #               if cos > 0.9999: 
 #                   boneisaligned=True 
                    #print m[0], mb[0] 
 #                   break 
 #               bone.blenderbone.roll = i 
 #           if not boneisaligned: 
 #               print "Eeek!! ", bone.name, boneisaligned 
 #           armData.bones[bone.name]=bone.blenderbone 
 #       armData.update() 
 #       armObj.makeDisplayList() 
 #       scene.update(); 
 #       Blender.Window.RedrawAll()


	#dump the meshes into blender
  #      print "basepath",basepath # The full path to the game folder, ex: "C:\Program Files\Doom 3\base\"
  #      print "md5_filename",md5_filename # The full path and file name of the .md5mesh file being imported, ex.
                                          # md5_filename "C:\Program Files\Doom 3\base\models\md5\monsters\pinky\pinky.md5mesh"
        firstcomp = str(CompNbr)
        lastcomp = str(CompNbr + len(md5_model)-1)
        for mesh in md5_model: # A new QuArK component needs to be made for each mesh.
  #              print "making  Import Component ",CompNbr # The name of this component being created now, ex: "Import Component 1"
  #              print "adding mesh ", mesh.mesh_index, " to blender"
  #              print "it has ", len(mesh.verts), "verts"
                ### Creates this component's Skins:sg group.
                # Checks if the model has textures specified with it.
                skinsize = (256, 256)
                skingroup = quarkx.newobj('Skins:sg')
                skingroup['type'] = chr(2)
                if(mesh.shader!=""): # Make the QuArK Skins here
                        path = mesh.shader.split("\\")
                        path = path[len(path)-1] # This is the full shader we are looking for, ex: "models/monsters/pinky/pinky_metal"
                        shaderspath = basepath + "materials"
                        shaderfiles = os.listdir(shaderspath)
                        for shaderfile in shaderfiles:
                            noimage = ""
                            foundshader = foundtexture = foundimage = imagefile = None
                            mesh_shader = shader_file = shader_name = shader_keyword = qer_editorimage = diffusemap = map = bumpmap = addnormals = heightmap = specularmap = None
                            #read the file in
                            try: # To by pass sub-folders, should make this to check those also.
                                file=open(shaderspath+"/"+shaderfile,"r")
                            except:
                                continue
                            lines=file.readlines()
                            file.close()
                            left_cur_braket = 0
                            for line in range(len(lines)):
                                if foundshader is None and lines[line].startswith(mesh.shader+"\n"):
                                    shaderline = lines[line].replace(chr(9), "    ")
                                    shaderline = shaderline.rstrip()
                                    mesh_shader = "\r\n" + shaderline + "\r\n"
                                    shader_file = shaderspath + "/" + shaderfile
                                    shader_name = mesh.shader
                                    foundshader = mesh.shader
                                    left_cur_braket = 0
                                    continue
                                if foundshader is not None and lines[line].find("{") != -1:
                                    left_cur_braket = left_cur_braket + 1
                                if foundshader is not None and lines[line].find("}") != -1:
                                    left_cur_braket = left_cur_braket - 1
                                if foundshader is not None:
                                    if lines[line].find("qer_editorimage") != -1 or lines[line].find("diffusemap") != -1:
                                        words = lines[line].split()
                                        for word in words:
                                            if word.endswith(".tga"):
                                                foundtexture = word
                                                if lines[line].find("qer_editorimage") != -1:
                                                    shader_keyword = "qer_editorimage"
                                                else:
                                                    shader_keyword = "diffusemap"
                                                skinname = foundtexture
                                                skin = quarkx.newobj(skinname)
                                                break
                                            elif word.find("/") != -1 and (word.startswith("models") or word.startswith("textures")):
                                                foundtexture = word + ".tga"
                                                if lines[line].find("qer_editorimage") != -1:
                                                    shader_keyword = "qer_editorimage"
                                                else:
                                                    shader_keyword = "diffusemap"
                                                skinname = foundtexture
                                                skin = quarkx.newobj(skinname)
                                                break
                                        if foundtexture is not None:
                                            if os.path.isfile(basepath + foundtexture):
                                                foundimage = basepath + foundtexture
                                                image = quarkx.openfileobj(foundimage)
                                                skin['Image1'] = image.dictspec['Image1']
                                                skin['Size'] = image.dictspec['Size']
                                                skin['shader_keyword'] = shader_keyword
                                                skingroup.appenditem(skin)
                                                if skinsize == (256, 256):
                                                    skinsize = skin['Size']
                                                foundtexture = None
                                            else: # Keep looking in the shader files, the shader may be in another one.
                                                imagefile = basepath + foundtexture
                                                noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "and the 'diffusemap' image to display.\n    " + foundtexture + "\n" + "But that image file does not exist.\n"
                                    if lines[line].find("bumpmap") != -1 and (not lines[line].find("addnormals") != -1 and not lines[line].find("heightmap") != -1):
                                        words = lines[line].replace("("," ")
                                        words = words.replace(")"," ")
                                        words = words.replace(","," ")
                                        words = words.split()
                                        for word in words:
                                            if word.endswith(".tga"):
                                                bumpmap = word
                                            elif word.find("/") != -1 and (word.startswith("models") or word.startswith("textures")):
                                                bumpmap = word + ".tga"
                                    if lines[line].find("addnormals") != -1 or lines[line].find("heightmap") != -1:
                                        words = lines[line].replace("("," ")
                                        words = words.replace(")"," ")
                                        words = words.replace(","," ")
                                        words = words.split()
                                        for word in range(len(words)):
                                            if words[word].find("addnormals") != -1 and words[word+1].find("/") != -1 and (words[word+1].startswith("models") or words[word+1].startswith("textures")):
                                                addnormals = words[word+1]
                                                if not addnormals.endswith(".tga"):
                                                    addnormals = addnormals + ".tga"
                                            if words[word].find("heightmap") != -1 and words[word+1].find("/") != -1 and (words[word+1].startswith("models") or words[word+1].startswith("textures")):
                                                heightmap = words[word+1]
                                                if not heightmap.endswith(".tga"):
                                                    heightmap = heightmap + ".tga"
                                    elif lines[line].find("specularmap") != -1:
                                        words = lines[line].split()
                                        for word in words:
                                            if word.endswith(".tga"):
                                                specularmap = word
                                            elif word.find("/") != -1 and (word.startswith("models") or word.startswith("textures")):
                                                specularmap = word + ".tga"
                                    # Dec character code for space = chr(32), for tab = chr(9)
                                    elif lines[line].find(chr(32)+"map") != -1 or lines[line].find(chr(9)+"map") != -1:
                                        words = lines[line].split()
                                        for word in words:
                                            if word.endswith(".tga") and (word.startswith("models") or word.startswith("textures")) and ((not word.endswith("_dis.tga") and not word.endswith("_dis")) and (not word.endswith("dis2.tga") and not word.endswith("dis2"))):
                                                map = word
                                            elif word.find("/") != -1 and (word.startswith("models") or word.startswith("textures")) and ((not word.endswith("_dis.tga") and not word.endswith("_dis")) and (not word.endswith("dis2.tga") and not word.endswith("dis2"))):
                                                map = word + ".tga"
                                        if map is not None and not map in skingroup.dictitems.keys():
                                            imagefile = basepath + map
                                            if os.path.isfile(basepath + map):
                                                skinname = map
                                                foundimage = basepath + skinname
                                                shader_keyword = "map"
                                                # Make the skin and add it.
                                                skin = quarkx.newobj(skinname)
                                                image = quarkx.openfileobj(foundimage)
                                                skin['Image1'] = image.dictspec['Image1']
                                                skin['Size'] = image.dictspec['Size']
                                                skin['shader_keyword'] = shader_keyword
                                                skingroup.appenditem(skin)
                                                if skinsize == (256, 256):
                                                    skinsize = skin['Size']
                                            else:
                                                noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "but the texture image file it calls to display\n    " + imagefile + "\nis not there or has a different name.\nMake a copy of the file and rename it or\ncheck the shader and make a correction to add it.\n"
                                    else:
                                        if lines[line].find("/") != -1:
                                            if lines[line-1].find("qer_editorimage") != -1 or lines[line-1].find("diffusemap") != -1 or lines[line-1].find("bumpmap") != -1 or lines[line-1].find("addnormals") != -1 or lines[line-1].find("heightmap") != -1 or lines[line-1].find("specularmap") != -1 or lines[line].find(chr(32)+"map") != -1 or lines[line].find(chr(9)+"map") != -1:
                                                words = lines[line].replace("("," ")
                                                words = words.replace(")"," ")
                                                words = words.replace(","," ")
                                                words = words.split()
                                                image = None
                                                for word in words:
                                                    if word.endswith(".tga") and (word.startswith("models") or word.startswith("textures")) and ((not word.endswith("_dis.tga") and not word.endswith("_dis")) and (not word.endswith("dis2.tga") and not word.endswith("dis2"))):
                                                        image = word
                                                    elif word.find("/") != -1 and (word.startswith("models") or word.startswith("textures")) and ((not word.endswith("_dis.tga") and not word.endswith("_dis")) and (not word.endswith("dis2.tga") and not word.endswith("dis2"))):
                                                        image = word + ".tga"
                                                if (image is not None) and (not image in skingroup.dictitems.keys()):
                                                    words = lines[line-1].replace("("," ")
                                                    words = words.replace(")"," ")
                                                    words = words.replace(","," ")
                                                    words = words.split()
                                                    keys = [qer_editorimage, diffusemap, bumpmap, addnormals, heightmap, specularmap, map]
                                                    words.reverse() # Work our way backwards to get the last key name first.
                                                    for word in range(len(words)):
                                                        if words[word] in keys:
                                                            imagefile = basepath + image
                                                            if os.path.isfile(basepath + image):
                                                                skinname = image
                                                                foundimage = basepath + skinname
                                                                shader_keyword = words[word]
                                                                # Make the skin and add it.
                                                                skin = quarkx.newobj(skinname)
                                                                image = quarkx.openfileobj(foundimage)
                                                                skin['Image1'] = image.dictspec['Image1']
                                                                skin['Size'] = image.dictspec['Size']
                                                                skin['shader_keyword'] = shader_keyword
                                                                skingroup.appenditem(skin)
                                                                if skinsize == (256, 256):
                                                                    skinsize = skin['Size']
                                                            else:
                                                                noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "but the texture image file it calls to display\n    " + imagefile + "\nis not there or has a different name.\nMake a copy of the file and rename it or\ncheck the shader and make a correction to add it.\n"
                                    shaderline = lines[line].replace(chr(9), "    ")
                                    shaderline = shaderline.rstrip()
                                    if mesh_shader is not None:
                                        mesh_shader = mesh_shader + shaderline + "\r\n"
                                    if lines[line].find("}") != -1 and left_cur_braket == 0: # Done reading shader so break out of reading this file.
                                        break
                            if mesh_shader is not None:
                                if bumpmap is not None:
                                    imagefile = basepath + bumpmap
                                    if os.path.isfile(basepath + bumpmap):
                                        skinname = bumpmap
                                        foundimage = basepath + skinname
                                        shader_keyword = "bumpmap"
                                        # Make the skin and add it.
                                        skin = quarkx.newobj(skinname)
                                        image = quarkx.openfileobj(foundimage)
                                        skin['Image1'] = image.dictspec['Image1']
                                        skin['Size'] = image.dictspec['Size']
                                        skin['shader_keyword'] = shader_keyword
                                        skingroup.appenditem(skin)
                                        if skinsize == (256, 256):
                                            skinsize = skin['Size']
                                    else:
                                        noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "but the texture image file it calls to display\n    " + imagefile + "\nis not there or has a different name.\nMake a copy of the file and rename it or\ncheck the shader and make a correction to add it.\n"
                                if addnormals is not None:
                                    imagefile = basepath + addnormals
                                    if os.path.isfile(basepath + addnormals):
                                        skinname = addnormals
                                        foundimage = basepath + skinname
                                        shader_keyword = "addnormals"
                                        # Make the skin and add it.
                                        skin = quarkx.newobj(skinname)
                                        image = quarkx.openfileobj(foundimage)
                                        skin['Image1'] = image.dictspec['Image1']
                                        skin['Size'] = image.dictspec['Size']
                                        skin['shader_keyword'] = shader_keyword
                                        skingroup.appenditem(skin)
                                        if skinsize == (256, 256):
                                            skinsize = skin['Size']
                                    else:
                                        noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "but the texture image file it calls to display\n    " + imagefile + "\nis not there or has a different name.\nMake a copy of the file and rename it or\ncheck the shader and make a correction to add it.\n"
                                if heightmap is not None:
                                    imagefile = basepath + heightmap
                                    if os.path.isfile(basepath + heightmap):
                                        skinname = heightmap
                                        foundimage = basepath + skinname
                                        shader_keyword = "heightmap"
                                        # Make the skin and add it.
                                        skin = quarkx.newobj(skinname)
                                        image = quarkx.openfileobj(foundimage)
                                        skin['Image1'] = image.dictspec['Image1']
                                        skin['Size'] = image.dictspec['Size']
                                        skin['shader_keyword'] = shader_keyword
                                        skingroup.appenditem(skin)
                                        if skinsize == (256, 256):
                                            skinsize = skin['Size']
                                    else:
                                        noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "but the texture image file it calls to display\n    " + imagefile + "\nis not there or has a different name.\nMake a copy of the file and rename it or\ncheck the shader and make a correction to add it.\n"
                                if specularmap is not None:
                                    imagefile = basepath + specularmap
                                    if os.path.isfile(basepath + specularmap):
                                        skinname = specularmap
                                        foundimage = basepath + skinname
                                        shader_keyword = "specularmap"
                                        # Make the skin and add it.
                                        skin = quarkx.newobj(skinname)
                                        image = quarkx.openfileobj(foundimage)
                                        skin['Image1'] = image.dictspec['Image1']
                                        skin['Size'] = image.dictspec['Size']
                                        skin['shader_keyword'] = shader_keyword
                                        skingroup.appenditem(skin)
                                        if skinsize == (256, 256):
                                            skinsize = skin['Size']
                                    else:
                                        noimage = noimage + "\nFound needed shader for Import Component " + str(CompNbr) + ":\n    " + mesh.shader + "\n" + "in\n    " + shaderspath+"/"+shaderfile + "\n" + "but the texture image file it calls to display\n    " + imagefile + "\nis not there or has a different name.\nMake a copy of the file and rename it or\ncheck the shader and make a correction to add it.\n"
                                if imagefile is None:
                                    imagefile = "NO IMAGE FILE FOUND AT ALL, CHECK THE SHADER."
                                break
                            if foundshader is not None: # Found the shader so break out of the shader files loop.
                                break
                        if len(noimage) > 0:
                            message = message + noimage
                        if mesh.shader is not None and foundshader is None: # This component has an image but no shader was found, so...
                            texturepath = basepath + "/" + mesh.shader + ".tga"
                            if os.path.isfile(texturepath): # May not be a shader so we look for a texture with the same image name.
                                skinname = mesh.shader + ".tga"
                                skin = quarkx.newobj(skinname)
                                foundimage = basepath + skinname
                                image = quarkx.openfileobj(foundimage)
                                skin['Image1'] = image.dictspec['Image1']
                                skin['Size'] = image.dictspec['Size']
                                skingroup.appenditem(skin)
                                if skinsize == (256, 256):
                                    skinsize = skin['Size']
                            else: # If no texture is found then we are missing the shader.
                                message = message + "\nImport Component " + str(CompNbr) + " calls for the shader:\n    " + mesh.shader + "\n" + "but it could not be located in\n    " + shaderspath + "\n" + "Extract shader file to this folder\nor create a shader file if needed.\n"
             #           print "line 665 good to here",message

        #        blender_mesh=NMesh.New() # make this a QuArK component's frame verticies
                framesgroup = quarkx.newobj('Frames:fg')
                frame = quarkx.newobj('Base frame' + ':mf')
                comp_mesh = ()
                comp_verts = []
                for vert in mesh.verts:
       #                 v=NMesh.Vert(vert.co[0]*scale, vert.co[1]*scale, vert.co[2]*scale)
                        comp_mesh = comp_mesh + (vert.co[0]*scale, vert.co[1]*scale, vert.co[2]*scale)
                        #add the uv coords to the vertex
                        # As a percentage of the QuArK Skinview1.clientarea for X and Y.
        #                v.uvco[0]=vert.uvco[0]
        #                v.uvco[1]=vert.uvco[1]
                 #       print "U,V uvco values = ",vert.uvco[0], vert.uvco[1]
                        U = int(skinsize[0] * vert.uvco[0])
                        V = int(skinsize[1] * vert.uvco[1])
                        V = -V + skinsize[1]
                        v = (U, V)
                        #add the vertex to the blender mesh
            #            blender_mesh.verts.append(v)
                        comp_verts = comp_verts + [v]
         #       print "comp_mesh = ",comp_mesh
         #       print "comp_verts = ",comp_verts
                frame['Vertices'] = comp_mesh
                framesgroup.appenditem(frame)
                # Make QuArK Tris here.
                Tris = ''
                for tri in mesh.tris:
                    #    f=NMesh.Face()
                        #tell it which blender verts to use for faces
                    #    f.v.append(blender_mesh.verts[tri.vert_index[0]])
                    #    f.v.append(blender_mesh.verts[tri.vert_index[2]])
                    #    f.v.append(blender_mesh.verts[tri.vert_index[1]])
                    #    f.uv.append((blender_mesh.verts[tri.vert_index[0]].uvco[0],blender_mesh.verts[tri.vert_index[0]].uvco[1]))
                    #    f.uv.append((blender_mesh.verts[tri.vert_index[2]].uvco[0],blender_mesh.verts[tri.vert_index[2]].uvco[1]))
                    #    f.uv.append((blender_mesh.verts[tri.vert_index[1]].uvco[0],blender_mesh.verts[tri.vert_index[1]].uvco[1]))
          #              print tri.vert_index[0],comp_verts[tri.vert_index[0]][0],comp_verts[tri.vert_index[0]][1]
                        Tris = Tris + struct.pack("Hhh", tri.vert_index[0],comp_verts[tri.vert_index[0]][0],comp_verts[tri.vert_index[0]][1])
                        Tris = Tris + struct.pack("Hhh", tri.vert_index[1],comp_verts[tri.vert_index[1]][0],comp_verts[tri.vert_index[1]][1])
                        Tris = Tris + struct.pack("Hhh", tri.vert_index[2],comp_verts[tri.vert_index[2]][0],comp_verts[tri.vert_index[2]][1])
                    #    f.smooth = 1 # smooth the face, since md5 has smoothing for all faces. There's no such thing as smoothgroups in an md5.
                    #    if mesh_image!=None:
                    #            f.image=mesh_image
                        #add the face
                    #    blender_mesh.faces.append(f)
                #blender_mesh.hasVertexUV(1)


		#build the vertex groups from the bone names
		#loop through the verts and if they are influced by a bone, then they are a member of that vertex group
		#percentage by weight bias

		#put the object into blender
    #            if 0: #mesh.shader!="":  # NMesh.PutRaw() will fail if the given name is already used for another mesh...
    #                translationtable = string.maketrans("\\", "/")
    #                tempstring = string.translate(mesh.shader, translationtable)
    #                lindex = string.rfind(tempstring, "/")
    #                tempstring = string.rstrip(tempstring, ".tga")
    #                if lindex==-1: lindex=0
    #                tempstring = tempstring[lindex+1:len(tempstring)]
    #                mesh_obj=NMesh.PutRaw(blender_mesh, tempstring)
    #            else:
    #                mesh_obj=NMesh.PutRaw(blender_mesh)
		# this line would put it to the cursor location
		#cursor_pos=Blender.Window.GetCursorPos()
		#mesh_obj.setLocation(float(cursor_pos[0]),float(cursor_pos[1]),float(cursor_pos[2]))

    #            blender_mesh = mesh_obj.getData() # this seems unnecessary but the Blender documentation recommends it
    #            if mesh.shader!="":
    #                translationtable = string.maketrans("\\", "/")
    #                tempstring = string.translate(mesh.shader, translationtable)
    #                lindex = string.rfind(tempstring, "/")
    #                tempstring = string.rstrip(tempstring, ".tga")
    #                if lindex==-1: lindex=0
    #                tempstring = tempstring[lindex+1:len(tempstring)]
    #                mesh_obj.setName(tempstring)

                #vertgroup_created is an array that stores for each bone if the vertex group was already created.
                # it's used to speed up the weight creation. The alternative would have been to use NMesh.getVertGroupNames()
                ### Make the QuArK Bones here
        #        vertgroup_created=[]
        #        for b in md5_bones:
        #            vertgroup_created.append(0)

                ### Effect the QuArK Bones here also
        #        for vert in mesh.verts:
        #            weight_index=vert.blend_index
        #            for weight_counter in range(vert.blend_count):
        #                #get the current weight info
        #                w=mesh.weights[weight_index+weight_counter]
        #                #check if vertex group was already created
        #                if vertgroup_created[w.bone_index]==0:
        #                    vertgroup_created[w.bone_index]=1
        #                    blender_mesh.addVertGroup(md5_bones[w.bone_index].name)
        #                #assign the weight for this vertex
        #                blender_mesh.assignVertsToGroup(md5_bones[w.bone_index].name, [vert.vert_index], w.bias, 'replace')

        #        armObj.makeParentDeform([mesh_obj], 0, 0)

                # Now we start creating our Import Component and name it.
                Component = quarkx.newobj("Import Component " + str(CompNbr) + ':mc')
                if shader_file is not None:
                    Component['shader_file'] = shader_file
                if shader_name is not None:
                    Component['shader_name'] = shader_name
                if mesh_shader is not None:
                    Component['mesh_shader'] = mesh_shader
                Component['skinsize'] = skinsize
                Component['Tris'] = Tris
                Component['show'] = chr(1)
                sdogroup = quarkx.newobj('SDO:sdo')
                Component.appenditem(sdogroup)
                Component.appenditem(skingroup)
                Component.appenditem(framesgroup)
    #            skeletongroup = quarkx.newobj('Skeleton:bg')
    #            skeletongroup['type'] = chr(5)
    #            Component.appenditem(skeletongroup)
                ComponentList = ComponentList + [Component]
            #    progressbar.close() # un-comment this line once progress bar is set up
            #    if len(polynames) > 1:
            #        Strings[2454] = Strings[2454].replace("Processing Components " + firstcomp + " to " + lastcomp + "\n" + "Import Component " + str(CompNbr) + "\n\n", "")
            #    else:
            #        Strings[2454] = Strings[2454].replace("Import Component " + str(CompNbr) + "\n", "")
                CompNbr = CompNbr + 1

    #    return armObj
        return ComponentList, message

class md5anim_bone:
    name = ""
    parent_index = 0
    flags = 0
    frameDataIndex = 0
    bindpos = []
    bindquat = []
    #bindmat = []
    posemat = None #armature-space pose matrix, needed to import animation
    restmat = None
    invrestmat = None
    
    def __init__(self):
        name = ""
        self.bindpos=[0.0]*3
        self.bindquat=[0.0]*4
        #self.bindmat=[None]*3  #is this how you initilize a 2d-array
        #for i in range(3): self.bindmat[i] = [0.0]*3
        self.parent_index = 0
        self.flags = 0
        self.frameDataIndex = 0
        self.restmat = None
        self.invrestmat = None
        self.posemat = None

        
class md5anim:
    num_bones = 0
    md5anim_bones = []
    frameRate = 24
    numFrames = 0
    numAnimatedComponents = 0
    baseframe = []
    framedata = []

    def __init__(self):
        num_bones = 0
        md5anim_bones = []
        baseframe = []
        framedata = []
        
    def load_md5anim(self, md5_filename):
        file=open(md5_filename,"r")
        lines=file.readlines()
        file.close()

        num_lines=len(lines)

        for line_counter in range(0,num_lines):
            current_line=lines[line_counter]
            words=current_line.split()

            if words and words[0]=="numJoints":
                self.num_bones=int(words[1])
       #         print "num_bones: ", self.num_bones
                
            elif words and words[0]=="numFrames":
                self.numFrames=int(words[1])
       #         print "num_frames: ", self.numFrames
                #fill framedata array with numframes empty arrays
                self.framedata = [[]]*self.numFrames
                
            elif words and words[0]=="frameRate":
                self.frameRate=int(words[1])
       #         print "frameRate: ", self.frameRate
                
            elif words and words[0]=="numAnimatedComponents":
                self.numAnimatedComponents=int(words[1])
       #         print "numAnimatedComponents: ", self.numAnimatedComponents
                
            elif words and words[0]=="hierarchy":
                for bone_counter in range(0,self.num_bones):
                    #make a new bone
                    self.md5anim_bones.append(md5anim_bone())
		    #next line
                    line_counter+=1
                    current_line=lines[line_counter]
                    words=current_line.split()
                    #skip over blank lines
                    while not words:
                        line_counter+=1
                        current_line=lines[line_counter]
                        words=current_line.split()

                    #self.md5anim_bones[bone_counter].bone_index=bone_counter
                    #get rid of the quotes on either side
                    temp_name=str(words[0])
                    temp_name=temp_name[1:-1]
                    self.md5anim_bones[bone_counter].name=temp_name
         #           print "found bone: ", self.md5anim_bones[bone_counter].name
                    self.md5anim_bones[bone_counter].parent_index = int(words[1])
                    #if self.md5anim_bones[bone_counter].parent_index>=0:
                    #    self.md5anim_bones[bone_counter].parent = self.md5anim_bones[self.md5anim_bones[bone_counter].parent_index].name
                    self.md5anim_bones[bone_counter].flags = int(words[2])
                    self.md5anim_bones[bone_counter].frameDataIndex=int(words[3])


            elif words and words[0]=="baseframe":
                for bone_counter in range(0,self.num_bones):
                    line_counter+=1
                    current_line=lines[line_counter]
                    words=current_line.split()
                    #skip over blank lines
                    while not words:
                        line_counter+=1
                        current_line=lines[line_counter]
                        words=current_line.split()
                    self.md5anim_bones[bone_counter].bindpos[0]=float(words[1])
                    self.md5anim_bones[bone_counter].bindpos[1]=float(words[2])
                    self.md5anim_bones[bone_counter].bindpos[2]=float(words[3])
                    qx = float(words[6])
                    qy = float(words[7])
                    qz = float(words[8])
                    qw = 1 - qx*qx - qy*qy - qz*qz
                    if qw<0:
                        qw=0
                    else:
                        qw = -sqrt(qw)
                    self.md5anim_bones[bone_counter].bindquat = [qx,qy,qz,qw]

            elif words and words[0]=="frame":
                framenumber = int(words[1])
                self.framedata[framenumber]=[]
                line_counter+=1
                current_line=lines[line_counter]
                words=current_line.split()
                while words and not(words[0]=="frame" or words[0]=="}"):
                    for i in range(0, len(words)):
                        self.framedata[framenumber].append(float(words[i]))
                    line_counter+=1
                    current_line=lines[line_counter]
                    words=current_line.split()

    def apply(self, arm_obj, actionname):
      action = Blender.Armature.NLA.NewAction(actionname)
      action.setActive(arm_obj)
      thepose = arm_obj.getPose()
      for b in self.md5anim_bones:
        b.invrestmat = Blender.Mathutils.Matrix(arm_obj.getData().bones[b.name].matrix['ARMATURESPACE']).invert()
        b.restmat = Blender.Mathutils.Matrix(arm_obj.getData().bones[b.name].matrix['ARMATURESPACE'])
      for currntframe in range(1, self.numFrames+1):
   #     print "importing frame ", currntframe," of", self.numFrames
        Blender.Set("curframe", currntframe)
        for md5b in self.md5anim_bones:
          try:
            thebone = thepose.bones[md5b.name]
          except:
   #         print "could not find bone ", md5b.name, " in armature"
            continue
          (qx,qy,qz,qw) = md5b.bindquat
          lx,ly,lz = md5b.bindpos
          frameDataIndex = md5b.frameDataIndex
          if (md5b.flags & 1):
            lx = self.framedata[currntframe-1][frameDataIndex]
            frameDataIndex+=1
          if (md5b.flags & 2):
            ly = self.framedata[currntframe-1][frameDataIndex]
            frameDataIndex+=1          
          if (md5b.flags & 4):
            lz = self.framedata[currntframe-1][frameDataIndex]
            frameDataIndex+=1
          if (md5b.flags & 8):
            qx = self.framedata[currntframe-1][frameDataIndex]
            frameDataIndex+=1
          if (md5b.flags & 16):
            qy = self.framedata[currntframe-1][frameDataIndex]
            frameDataIndex+=1                     
          if (md5b.flags & 32):
            qz = self.framedata[currntframe-1][frameDataIndex]
          qw = 1 - qx*qx - qy*qy - qz*qz
          if qw<0:
            qw=0
          else:
            qw = -sqrt(qw)
          lmat = quaternion2matrix([qx,qy,qz,qw])
          lmat[3][0] = lx*scale
          lmat[3][1] = ly*scale
          lmat[3][2] = lz*scale
          lmat = Blender.Mathutils.Matrix(lmat[0], lmat[1], lmat[2], lmat[3])
          #if md5b.parent_index>=0:
          #  md5b.posemat = lmat*self.md5anim_bones[md5b.parent_index].posemat
          #else:
          #  md5b.posemat = lmat
          if md5b.parent_index>=0:
            thebone.localMatrix = Blender.Mathutils.Matrix(lmat) * (md5b.restmat * self.md5anim_bones[md5b.parent_index].invrestmat).invert()
          else:
            thebone.localMatrix = lmat * md5b.invrestmat
          thepose.update()
          thebone.insertKey(arm_obj, currntframe, [Blender.Object.Pose.ROT, Blender.Object.Pose.LOC])
          thepose.update()
      Blender.Set("curframe", 1)
      

#armobj is either an armature object or None
def load_md5anim(md5anim_filename, armobj):
  theanim = md5anim()
  theanim.load_md5anim(md5anim_filename)
  if (armobj):
    obj = armobj
  else:
    obj = None
    for armobj in Blender.Object.Get():
      data = armobj.getData()
      if type(data) is Blender.Types.ArmatureType:
        obj = armobj
        break
  if obj:
    print "applying animation to armature: ", obj.getName()
    pth, actionname = os.path.split(md5anim_filename)
    theanim.apply(obj, actionname)
    scn = Blender.Scene.GetCurrent()
    context = scn.getRenderingContext()
    context.endFrame(theanim.numFrames+1)
  else:
    print "couldn't apply animation, no armature in the scene"    
  return

######################################################
# GUI STUFF
######################################################

draw_busy_screen = 0
EVENT_NOEVENT = 1
EVENT_IMPORT = 2
EVENT_QUIT = 3
EVENT_MESHFILENAME = 4
EVENT_ANIMFILENAME = 5
EVENT_MESHFILENAME_STRINGBUTTON = 6
EVENT_ANIMFILENAME_STRINGBUTTON = 7
# md5mesh_filename = Blender.Draw.Create("")
# md5anim_filename = Blender.Draw.Create("")


# scale_slider = Blender.Draw.Create(1.0)
scale = 1.0
# bonesize_slider = Blender.Draw.Create(3.0)
bonesize = 3.0

######################################################
# Callbacks for Window functions
######################################################
def md5meshname_callback(filename):
  global md5mesh_filename
  md5mesh_filename.val=filename

def md5animname_callback(filename):
  global md5anim_filename
  md5anim_filename.val=filename
# Imports the animation file, using its file name here.
def md5camanimname_callback(filename):
  global md5camanim_filename
  md5camanim_filename.val=filename
  
######################################################
# GUI Functions
######################################################
def handle_event(evt, val):
#  if evt == Blender.Draw.ESCKEY:
#    Blender.Draw.Exit()
    return

def handle_button_event(evt):
  global EVENT_NOEVENT, EVENT_IMPORT, EVENT_QUIT, EVENT_MESHFILENAME, EVENT_ANIMFILENAME, EVENT_MESHFILENAME_STRINGBUTTON, EVENT_ANIMFILENAME_STRINGBUTTON
  global draw_busy_screen, md5mesh_filename, md5anim_filename, scale_slider, scale, bonesize_slider, bonesize
  if evt == EVENT_IMPORT:
    scale = scale_slider.val
    bonesize = bonesize_slider.val
    draw_busy_screen = 1
#     Blender.Draw.Draw()
    if len(md5mesh_filename.val)>0:
      armObj = load_md5(md5mesh_filename.val)
      if len(md5anim_filename.val)>0:
        load_md5anim(md5anim_filename.val, armObj) #load anim onto newly imported skel
    else:
      if len(md5anim_filename.val)>0:
  #      armObj = Blender.Scene.GetCurrent().getActiveObject()
        if (armObj):
          data = armObj.getData()
  #        if not (type(data) is Blender.Types.ArmatureType):
  #          armObj = None
        load_md5anim(md5anim_filename.val, armObj)
          

########################
# To run this file
########################

def import_md5_model(basepath, md5_filename):

    ComponentList, message = load_md5(md5_filename, basepath) # Loads the model.

    ### Use the 'ModelRoot' below to test opening the QuArK's Model Editor with, needs to be qualified with main menu item.
    ModelRoot = quarkx.newobj('Model:mr')
  #  ModelRoot.appenditem(Component)

    return ModelRoot, ComponentList, message


def loadmodel(root, filename, gamename, nomessage=0):
    "Loads the model file: root is the actual file,"
    "filename is the full path and name of the .md5mesh file selected."
    "gamename is None."
    "For example:  C:\Program Files\Doom 3\base\models\md5\monsters\pinky\pinky.md5mesh"

    global editor, progressbar, tobj, logging, importername, textlog, Strings
    editor = quarkpy.mdleditor.mdleditor

    ### First we test for a valid (proper) model path.
    basepath = ie_utils.validpath(filename)
    basepath = basepath.replace("\\", "/")
    if basepath is None:
        return

    logging, tobj, starttime = ie_utils.default_start_logging(importername, textlog, filename, "IM") ### Use "EX" for exporter text, "IM" for importer text.

    ### Lines below here loads the model into the opened editor's current model.
    ModelRoot, ComponentList, message = import_md5_model(basepath, filename)

    if ModelRoot is None or ComponentList is None or ComponentList == []:
        quarkx.beep() # Makes the computer "Beep" once if a file is not valid. Add more info to message.
        quarkx.msgbox("Invalid .md5 model.\nEditor can not import it.", quarkpy.qutils.MT_ERROR, quarkpy.qutils.MB_OK)
        progressbar.close()
        return

    undo = quarkx.action()
    for Component in ComponentList:
        undo.put(editor.Root, Component)
        editor.Root.currentcomponent = Component
        compframes = editor.Root.currentcomponent.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            compframe.compparent = editor.Root.currentcomponent # To allow frame relocation after editing.
         #   progressbar.progress() # un-comment this line once progress bar is set up

    editor.Root.currentcomponent = ComponentList[0]  # Sets the current component.
  #  progressbar.close() # un-comment this line once progress bar is set up
    Strings[2454] = Strings[2454].replace(Component.shortname + "\n", "")
    ie_utils.default_end_logging(filename, "IM", starttime) ### Use "EX" for exporter text, "IM" for importer text.

    editor.ok(undo, str(len(ComponentList)) + " .md5 Components imported") # Let the ok finish the new components before going on.

    comp = editor.Root.currentcomponent
    skins = comp.findallsubitems("", ':sg')      # Gets the skin group.
    if len(skins[0].subitems) != 0:
        comp.currentskin = skins[0].subitems[0]      # To try and set to the correct skin.
        quarkpy.mdlutils.Update_Skin_View(editor, 2) # Sends the Skin-view for updating and center the texture in the view.
    else:
        comp.currentskin = None

    editor = None   #Reset the global again
    if message != "":
        message = message + "================================\n\n"
        message = message + "You need to find and supply the proper texture(s) and folder(s) above.\n"
        message = message + "Extract the required folder(s) and file(s) to the 'game' folder.\n\n"
        message = message + "If a texture does not exist it may be a .dds or some other type of image file.\n"
        message = message + "If so then you need to make a .tga file copy of that texture, perhaps in PaintShop Pro.\n\n"
        message = message + "You may also need to rename it to match the exact name above.\n"
        message = message + "Either case, it would be for editing purposes only and should be placed in the proper folder.\n\n"
        message = message + "Once this is done, then delete the imported components and re-import the model."
        quarkx.msgbox("Missing Skin Textures:\n\n================================\n" + message, quarkpy.qutils.MT_INFORMATION, quarkpy.qutils.MB_OK)

### To register this Python plugin and put it on the importers menu.
import quarkpy.qmdlbase
import ie_md5_import # This imports itself to be passed along so it can be used in mdlmgr.py later.
quarkpy.qmdlbase.RegisterMdlImporter(".md5 Doom3\Quake4 Importer", ".md5mesh file", "*.md5mesh", loadmodel, ie_md5_import)


def dataformname(o):
    "Returns the data form for this type of object 'o' (a model component) to use for the Specific/Args page."

    NbrOfLines = "10"

    skin_dlgdef = """
    {
      Help = "These are the Specific settings for Doom3\Quake4 (.md5mesh) model types."$0D
             "md5 models use 'meshes' the same way that QuArK uses 'components'."$0D
             "Each can have its own special Surface or skin texture settings."$0D
             "These textures may or may not have 'shaders' that they use for special effects."$0D0D22
             "shader file"$22" - Gives the full path and name of the .mtr material"$0D
             "           shader file that the selected skin texture uses, if any."$0D22
             "shader name"$22" - Gives the name of the shader located in the above file"$0D
             "           that the selected skin texture uses, if any."$0D22
             "skin name"$22" - The currently selected skin texture name."$0D22
             "shader keyword"$22" - Gives the above shader 'keyword' that is used to identify"$0D
             "          the currently selected skin texture used in the shader, if any."$0D22
             "edit shader"$22" - Opens shader below in a text editor."$0D22
             "mesh shader"$22" - Contains the full text of this skin texture's shader, if any."$0D
             "          This can be copied to a text file, changed and saved."
      shader_file:    = {Typ="E"   Txt="shader file"  Hint="Gives the full path and name of the .mtr material"$0D"shader file that the selected skin texture uses, if any."}
      shader_name:    = {Typ="E"   Txt="shader name"  Hint="Gives the name of the shader located in the above file"$0D"that the selected skin texture uses, if any."}
      skin_name:      = {t_ModelEditor_texturebrowser = ! Txt="skin name"    Hint="The currently selected skin texture name."}
      shader_keyword: = {Typ="E"   Txt="shader keyword"  Hint="Gives the above shader 'keyword' that is used to identify"$0D"the currently selected skin texture used in the shader, if any."}
      extedit:tbbtn   = {
                         Typ = "M"
                         Txt = "edit shader ---->"
                         Hint = "Opens shader below"$0D"in a text editor."
                         Msg = "EXTE"
                         Cap = "edit shader"
                         Icon = $6677777777777776600000000000007660FFFFFFFFFFF07660FFFFFFFFFFF07660F7
                                $F33FFFFFF07660FFF3333FF7F07660F7F333118FF07660FFFF331118807660FFFF91
                                $1111807760FF7FF91111107760FFFFFF9111117660FF877FF911111660FFFFFFFF91
                                $111160F777787F79111660FFFFFFFF7F911660FFFFFFFF7069666000000000066666
                        }
      mesh_shader:    = {Typ="M"  Rows = """ + chr(34) + NbrOfLines + chr(34) + """ Scrollbars="1" Txt = "mesh shader"  Hint="Contains the full text of this skin texture's shader, if any."$0D"This can be copied to a text file, changed and saved."}
    }
    """

    from quarkpy.qeditor import ico_dict # Get the dictionary list of all icon image files available.
    import quarkpy.qtoolbar              # Get the toolbar functions to make the button with.
    editor = quarkpy.mdleditor.mdleditor # Get the editor.
    ico_maped = ico_dict['ico_maped']    # Just to shorten our call later.
    icon_btns = {}                       # Setup our button list, as a dictionary list, to return at the end.
    vtxcolorbtn = quarkpy.qtoolbar.button(editor.layout.colorclick, "Color UV Vertex mode||When active, puts the editor vertex selection into this mode and uses the 'COLR' specific setting as the color to designate these types of vertexes.\n\nIt also places the editor into Vertex Selection mode if not there already and clears any selected vertexes to protect from including unwanted ones by mistake.\n\nAny vertexes selected in this mode will become Color UV Vertexes and added to the component as such. Click the InfoBase button or press F1 again for more detail.|intro.modeleditor.dataforms.html", ico_maped, 10)
    icon_btns['color'] = vtxcolorbtn     # Put our button in the above list to return.

    if o.name == editor.Root.currentcomponent.currentskin.name: # If this is not done it will cause looping through multiple times.
        if o.parent.parent.dictspec.has_key("shader_keyword") and o.dictspec.has_key("shader_keyword"):
            if o.parent.parent.dictspec['shader_keyword'] != o.dictspec['shader_keyword']:
                o['shader_keyword'] = o.parent.parent.dictspec['shader_keyword']
        if o.parent.parent.dictspec.has_key("skin_name") and o.parent.parent.dictspec['skin_name'] != o.name:
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
            quarkpy.mdlutils.Update_Skin_View(editor)

    DummyItem = o
    while (DummyItem.type != ":mc"): # Gets the object's model component.
        DummyItem = DummyItem.parent
    if DummyItem.type == ":mc":
        comp = DummyItem
        # This sections handles the data for this model type skin page form.
        # This makes sure what is selected is a model skin, if so it returns the Skin page data to make the form with.
        if len(comp.dictitems['Skins:sg'].subitems) == 0 or o in comp.dictitems['Skins:sg'].subitems:
            formobj = quarkx.newobj("md5_mc:form")
            formobj.loadtext(skin_dlgdef)
            return formobj, icon_btns
    else:
        return None, None


def dataforminput(o):
    "Returns the default settings or input data for this type of object 'o' (a model component) to use for the Specific/Args page."

    DummyItem = o
    while (DummyItem.type != ":mc"): # Gets the object's model component.
        DummyItem = DummyItem.parent
    if DummyItem.type == ":mc":
        comp = DummyItem
        # This sections handles the data for this model type skin page form.
        # This makes sure what is selected is a model skin, if so it fills the Skin page data and adds the items to the component.
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
            if not comp.dictspec.has_key('mesh_shader'):
                comp['mesh_shader'] = "None"


# ----------- REVISION HISTORY ------------
#
# $Log$
# Revision 1.2  2008/12/06 19:25:58  cdunde
# Development update.
#
# Revision 1.1  2008/12/05 09:30:14  cdunde
# Added setup file for Doom3 Quake4 .md5mesh and .md5anim model importing.
#
#

