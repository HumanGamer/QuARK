# QuArK  -  Quake Army Knife
#
# Copyright (C) 1996-2000 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#
#
#  This plugin adapted from mapcorridor.py, with permission
#    of CryTek Studios.
#
#$Header$


Info = {
   "plug-in":       "Extruder",
   "desc":          "Extrude 2D outlines",
   "date":          "29 Mar 2001",
   "author":        "Crytek Studios, tiglari",
   "author e-mail": "tiglari@planetquake.com",
   "quark":         "Version 6.2"
}

from quarkpy.qdictionnary import Strings
import quarkpy.qhandles
import quarkpy.mapduplicator
import quarkpy.maphandles
import quarkpy.maputils
StandardDuplicator = quarkpy.mapduplicator.StandardDuplicator
DuplicatorManager = quarkpy.mapduplicator.DuplicatorManager
RotMat = quarkpy.maputils.ArbRotationMatrix
from quarkpy.qeditor import deg2rad
from quarkpy.maphandles import MapRotateHandle
#from mapmadsel import getstashed
from quarkpy.maputils import *
from tagging import *
#from faceutils import *
from quarkpy.dlgclasses import placepersistent_dialogbox
from quarkpy.qeditor import matrix_rot_z
from quarkpy.qeditor import matrix_rot_y
from quarkpy.qhandles import aligntogrid

#
# --- wtf
#
# The ExtruderBuilder or `Flat Extruder' is an overblown
#  duplicator that stores data in a structure of group
#  inside the duplicator, accessed by instances of the
#  ExtruderDupData class.  It's got a 2d window for editing
#  the circumference points, live edit extrusion dialogs,
#  and also path control points that can be individually
#  dragged around.

#
#  Sections in this file.
#
#   --Utilities (many copies from elsewhere, needs cleanup)
#   --Duplicator texturing stuff (currently not used)
#   --ExtruderDupData class (partial OOPification of data access)
#   --Path Point stuff (dialogs, RMB menus etc, and a handle)
#   --Actual Shape Drawing (convexification etc. etc.)
#   --Testing Routines (these can probably be dumped)    
#   --Circumference Point management (menus, dialogs handles etc)
#   --The Duplicator at Last
#   --Dissociated Extruder tools (hole-punching, textureing etc)
#   --2d view stuff
#   --Extrusion Dialog stuff

#
#          ***** MAJOR SECTION *****
#
# --- Utilities:  many of these are repeats from other
#  places, and ought to be cleaned up.
#


#
# A handle for edges
#
class EdgeHandle(quarkpy.qhandles.GenericHandle):
    undomsg = "drag edge"
    hint = "tag this edge for lining up objects, etc."
    
    def __init__(self, face, vtx1, vtx2):
        pos = (vtx2+vtx1)/2
        qhandles.GenericHandle.__init__(self, pos)
        self.face = face
        self.vtx1, self.vtx2 = vtx1, vtx2
        cur = FaceHandleCursor()
        cur.pos = pos
        cur.face = face
        self.cursor = cur.getcursor
 
    def menu(self, editor, view):
        self.click(editor)
        editor.layout.clickedview = view
        return self.OriginItems(editor, view)

    def draw(self, view, cv, draghandle=None):
        p = view.proj(self.pos)
        oldcolor = cv.pencolor
        p1 = view.proj(self.vtx1)
        p2 = view.proj(self.vtx2)
        cv.pencolor = oldcolor
        if p.visible:
            cv.reset()
            cv.brushcolor = view.darkcolor
            radius = 3
            cv.ellipse(p.x-radius, p.y-radius, p.x+radius+1, p.y+radius+1)
#            cv.rectangle(p.x-3, p.y-3, p.x+4, p.y+4)

class AxisHandle(MapRotateHandle):
  "a rotating handle that controls a normalized vector spec"
  
  def __init__(self, center, dup, spec, scale1):
    axis = quarkx.vect(dup[spec])
    MapRotateHandle.__init__(self, center, axis, scale1, quarkpy.qhandles.mapicons[11])
    self.dup = dup
    self.spec = spec

  def dragop(self, flags, av):
        new = None
        if av is not None:
            new = self.dup.copy()
            new[self.spec] = av.tuple
        return [self.dup], [new], av


def CopyDefaultSpec(source, target, spec, default):
  if source[spec] is not None:
    target[spec] = source[spec]
  else:
    target[spec]=default

def AnyIsNone(src, speclist):
  for spec in speclist:
    if src[spec] is None:
      return 1
  return 0

def within(containee, container):
  test = containee
  while test is not None:
#    squawk("test: "+test.name)
    if test is container:
      return 1
    test = test.treeparent
  return 0

def find_path(source, path):
#  squawk("%s: %s"%(source.name, path))
  if len(path):
    found = source.findname(path[0])
    if found is not None:
      return find_path(found, path[1:])
    return None
  else:
    return source
 
def write3tup(vec):
  return "%.2f %.2f %.2f"%(vec[0], vec[1], vec[2])


#
# adapted from face2patch in maputils
#
def setthreepointspatch(patch, texp):
  v = getBezierControlP(patch)
  patch.vst = map(lambda v, texp=texp: quarkx.vect((v-texp[0])*texp[1], -(v-texp[0])*texp[2], 0), v)
  patch.vupdate()

#
#  should be in a utility file but isn't
#
def noneint(num):
  if num is None:
    return 0
  else:
    return int(eval(num))

#
#          ***** MAJOR SECTION *****
#
#  -- Duplicator texturing stuff, currently not used
#
class TextureDlg (placepersistent_dialogbox):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (120,60)
    dfsep = 0.05
    dlgflags = FWF_KEEPFOCUS | FWF_NOCLOSEBOX | FWF_NOESCCLOSE


    dlgdef = """
        {
        Style = "9"
        Caption = "Texturing"


        exit:py = { }
    }
    """
    def __init__(self, form, label, editor, dup):
    
        self.dup = dup
        self.editor = editor
        self.src = quarkx.newobj(":")
    
        placepersistent_dialogbox.__init__(self, form, self.src, label,
           exit = quarkpy.qtoolbar.button(
            self.commit,
            "Commit your texture changes and return to regular editing\n (you can't just bail; instead, Undo your changes then commit)\n (if, in spite of my efforts, you find some way to close this box without hitting `commit', you will have made a mess.",
            ico_editor, 0,
            "Commit Texturing"))

    def commit(self, dlg):
        self.src = None
        editor=self.editor
        dup = self.dup
        data = ExtruderDupData(dup)
        texobj = dup.findname("texobj:g")
        patches = texobj.findallsubitems("",":b3")
        dict = {}
        if patches:
          for patch in patches:
            name = patch.shortname
#            squawk(name)
            if name != "inner":
              dict[name] = patch.texturename, bezthreepoints(patch, 1)
        else:
          faces = texobj.findallsubitems("",":f")
          for face in faces:
            name = face.shortname
            if name != "inner":
              dict[name] = face.texturename, face.threepoints(4)
        keys = dict.keys()
        texinfo = quarkx.newobj("texinfo:g")
        axes = data.Axes()
        for key in keys:
          side = quarkx.newobj("%s:g"%key)
          side["tex"], threepoints = dict[key]
          p0, p1, p2 = threepoints
          side["p0"] = (data.ProjPos2Tuple(p0,axes))
          side["p1"] = (data.ProjPos2Tuple(p1,axes))
          side["p2"] = (data.ProjPos2Tuple(p2,axes))
          texinfo.appenditem(side)
        undo = quarkx.action()
        undo.exchange(texobj, texinfo)
          
        editor.ok(undo,"commit texturing")
    
        from mapmadsel import Unrestrict
        Unrestrict(editor)
        #
        # non functiona sine timer, who knows why
        #
        def restore(info):
          dup, editor = info
          editor.layout.explorer.sellist = [dup]
        quarkx.settimer(restore,(dup, editor), 20)
        qmacro.dialogbox.close(self, dlg)

def tex_pos(self):
  editor = mapeditor()
  if editor is None:
    quarkx.msgbox("Oops, no editor",MT_ERROR,MB_OK)
  dup = editor.layout.explorer.sellist[0]
  if dup is None or dup["macro"] != "dup corridor":
    quarkx.msgbox("Oops, right kind of duplicator not selected",
       MT_ERROR,MB_OK)
  data = ExtruderDupData(dup)
  #
  # make a group of patches or brushes to put the textures on.
  #
  texobj = data.TexObj(editor) 
#  parent = dup.parent
  undo=quarkx.action()
  oldtex = dup.findname("texinfo:g")
  if oldtex is None:
       undo.put(dup, texobj)
  else:
      undo.exchange(oldtex, texobj)
  editor.ok(undo,"texture setup")
  m = qmenu.item("",None)
  m.object=texobj
  from plugins.mapmadsel import RestrictByMe
  RestrictByMe(m)
  TextureDlg(quarkx.clickform, 'corr_tex', editor, dup)


quarkpy.qmacro.MACRO_tex_pos = tex_pos

#
#          ***** MAJOR SECTION *****
#
# -- ExtruderDupData class
#
# a class for defining methods to get at
#   corridor duplicator data; half-assed OOP-ification
#


class ExtruderDupData:

  def __init__(self, dup):
    self.dup = dup
    
  def Path(self):
    return self.dup.findname("spine:g")  

  def PathPoints(self):
    return self.dup.findname("spine:g").subitems
    
  def PathLen(self):
    return len(self.PathPoints())
  
  def PathPoint(self, j):
    if j==0:
      return None
    ribs = self.PathPoints()
    if j < len(ribs):
      return ribs[j]
      
  def PathLoc(self, j):
    if j==0:
      return quarkx.vect(0,0,0)
    if type(j) == type(0):
      loc = self.PathPoint(j)
    else:
      loc = j
    if loc is not None:
      loc = quarkx.vect(loc["location"]) 
    return loc

  def Org(self):
    dup = self.dup
    if dup.type==":g":
      return quarkx.vect(dup["origin"])
    else:
      return dup.origin

  def PathPos(self, j):
    pos = self.PathLoc(j)
    if pos is not None:
      pos = self.Org()+pos    
#      pos = self.dup.origin+pos
    return pos

  def Circ(self):
   return self.dup.findname("spine:g").subitems[0]
   
  def CircPoints(self):
    spine = self.dup.findname("spine:g")
    return spine.subitems[0].subitems

  #
  # get the `bounding square' of the circumference points
  #
  def CircBox(self, xtra=None):
    points = self.CircPoints()
    maxx=maxy=minx=miny=0.0
    for point in points:
      x, y = point["where"]
      if x > maxx: maxx=x
      if x < minx: minx=x
      if y > maxy: maxy=y
      if y < miny: miny=y
    result = []
    if xtra is None:
      xtra=0
    else:
      xtra,=xtra
    maxx, maxy = maxx+xtra, maxy+xtra
    minx, miny = minx-xtra, miny-xtra
    def do(x, y, result=result):
      result.append(quarkx.vect(x, y, 0))
    do(maxx, maxy)
    do(minx, maxy)
    do(minx, miny)
    do(maxx, miny)
    return result

  def CircLen(self):
    return len(self.CircPoints())

  def CircDec(self, k):
    if k==0:
      return self.CircLen()-1
    else:
      return k-1

  def CircCoords(self):
    length = len(self.CircPoints())
    result = []
    for k in range(length):
      point = self.CircPoint(k)
      x, y = point["where"]
      result.append(quarkx.vect(x, y, 0))
    return result
    
   
  def CircPoint(self, k):
    
    points = self.CircPoints()
#    squawk("%d: points %s"%(k,points))
#    squawk("%d, %d"%(k,len(points)))
#    return points [int(math.fmod(k, len(points)))]
    if k >= len(points):
      k=k-len(points)
    if k < 0:
      k=k+len(points)
    return points[k]

  def CircAttr(self, k, attr, default=None):
    val = self.CircPoint(k)[attr]
    if val is None:
      val = self.dup[attr]
    if val is None:
      val = default
    return val

  def ScaleCircPos(self, k, j=0):
      point = self.CircPoint(k)
      x, y = point["where"]
      scale = get_path_scale(self.dup, j)
      return quarkx.vect(scale*x, scale*y, 0)

  def  CircPos(self, k, j=0, planenorm=None):
    pos = self.ScaleCircPos(k, j)
    bevel = get_path_bevel(self.dup, j)
    if bevel:
      prev = self.ScaleCircPos(k-1, j)
      next = self.ScaleCircPos(k+1, j)
#      squawk("prev: %s, pos: %s, next: %s"%(prev, pos, next))
      dir = make_edge(pos-prev, next-pos)
#      squawk("k: %s, dir: %.2f %.2f %.2f"%(k,dir.x,dir.y, dir.z))
      shift = bevel*dir
      pos = pos+shift
    return self.MapCircPos(pos, j, planenorm)

  def MapCircPos(self, pos, j=0, planenorm=None):
    x, y, z = pos.tuple
    xaxis, yaxis, zaxis = self.Axes(j)
    org = self.PathPos(j)
    pos = org+x*xaxis+y*yaxis
    if 0<j and j<len(self.PathPoints()):
        if planenorm is None:
          prev_z=self.Zaxis(j-1)
          mat=matrix_rot_u2v(prev_z, (zaxis+prev_z).normalized)
          planenorm = mat*prev_z
        pos = projectpointtoplane(pos, zaxis, org, planenorm)
    return pos

  def AdjustPoints(self, points, j, names):
    newpoints = points[:]
    for i in range(len(points)):
      name=names[i]
      if name[:4]=="side":
        k = int(eval(name[5:]))
      elif name[:5]=="inner":
        k = int(eval(names[i-1][5:]))+1
      else: # eeks, it's outer, so bail
        newpoints2 = range(len(points))
        scale = get_path_scale(self.dup, j)
        for i in range(len(points)):
          point = scale*points[i]
          newpoints2[i]=self.MapCircPos(point,j)
        
        return newpoints2
        

      newpoints[i]=self.CircPos(k,j)
    return newpoints

  def Zaxis(self, j=0):
    dup = self.dup
    if j==0:
      org = self.Org()
    else:
      org = self.PathPos(j)
    diff = self.PathPos(j+1)-org
    return diff.normalized

  #
  # Note the cacheing to improve performance.  This means
  #  that if you drag a path control point, you need to
  #  start with a fresh data object.
  #
  def Axes(self, j=0):
     dup = self.dup
     try:
       start = self.cachedj
       xaxis, yaxis, zaxis = self.cachedax
     except (AttributeError):
       start = 1
       zaxis = self.Zaxis()
       side = quarkx.vect(dup["side"])
       yaxis = (side^zaxis).normalized
       xaxis = (zaxis^yaxis)
     last = len(self.PathPoints())-1

     for i in range(start,j+1):
         if i==last:
           break
         z2 = self.Zaxis(i)
         if (zaxis-z2):
           mat=matrix_rot_v2u(z2, zaxis)
           xaxis, yaxis, zaxis = mat*xaxis, mat*yaxis, z2
     self.cachedj = j
     self.cachedax = xaxis, yaxis, zaxis
     return xaxis, yaxis, zaxis

  def Transform(self, p, j):
    if j==0:
      return p
    org = self.Org()
    xaxis, yaxis, zaxis = self.Axes()
    p = p-org
    x, y, z = p*xaxis, p*yaxis, p*zaxis
    orgj = self.PathPos(j)
    xaxisj, yaxisj, zaxisj = self.Axes(j)
    return orgj+x*xaxisj+y*yaxisj+z*zaxisj
    

  def ProjPos2Tuple(self, pos, axes = None):
    if axes ==None:
      xaxis, yaxis, zaxis = self.Axes
    else:
      xaxis, yaxis, zaxis = axes
    pos2 = pos-self.dup.origin
    return pos2*xaxis, pos2*yaxis, pos2*zaxis

  def TexObj(self,editor):
    dup=self.dup
    type=dup["type"]
  
    points = self.CircCoords()
    if type == "p":
      list = make_patches(self.dup, points,2)
    if type == "b":
      cycles, names = convexify(points)
      list = make_brushes(dup, cycles, names,2)
    else:
      cycles,names = pipeify(points,self)
      list = make_brushes(dup,cycles,names,2)

    
    group = quarkx.newobj("texobj:g")
    for item in list:
      group.appenditem(item)
    return group
      
#
#  Unreconstructed non-methods
#
def get_path_scale(dup, j):
  if j==0:
    return 1.0
  data = ExtruderDupData(dup)
  scale = data.PathPoint(j)["scale"]
#  squawk("scale: %s"%scale)
  if scale is None:
    return 1.0
  else:
    return scale[0]
  
#
# ughh this needs redone right
#
def get_path_bevel(dup, j, attr="bevel"):
  if j==0:
    return 0.0
  data = ExtruderDupData(dup)
  bevel = data.PathPoint(j)[attr]
#  squawk("scale: %s"%scale)
  if bevel is None:
    return 0.0
  else:
    return bevel[0]
  

def set_circ_pos(dup, k, pos):
   data = ExtruderDupData(dup)
   if type(k)==type(0):
     point = data.CircPoint(k)
   else:
     point = k
   if point is not None:
     diff = pos-dup.origin
     xaxis, yaxis, zaxis = data.Axes()
     proj = projectpointtoplane(diff, zaxis, dup.origin, zaxis)
     point["where"] = proj*xaxis, proj*yaxis
#     point["where"] = math.atan2(x, y)/deg2rad, abs(proj)

  

def get_spine(dup):
  return dup.findname("spine:g")


def set_path_pos(dup, k, pos):
   if k==0:
     return
   if type(k)==type(0):
     spine = dup.findname("spine:g")
     ribs = spine.subitems
     if k < len(ribs):
       point=ribs[k]
     else:
       return
   else:
       point=k
   point["location"] = (pos-dup.origin).tuple


#
#  The handle
#
class ExtruderPathHandle(quarkpy.maphandles.CenterHandle):
  "A pass-through point for the path of the corridor."

  def __init__(self, dup, k):
    self.data = ExtruderDupData(dup)
    pos = self.data.PathPos(k)
    quarkpy.maphandles.CenterHandle.__init__(self, pos, dup, MapColor("Axis"))
    self.k = k


  def drag(self, v1, v2, flags, view):
        delta = v2-v1
        dup, j = self.centerof, self.k
        data = ExtruderDupData(dup)
        pos0 = data.PathPos(j)
        if flags&MB_CTRL:
            newpos = aligntogrid(pos0+delta,1)
        else:
            delta = quarkpy.qhandles.aligntogrid(delta, 1)
            newpos = pos0+delta
        if delta or (flags&MB_REDIMAGE):
            new = self.centerof.copy()
            set_path_pos(new, j, newpos)
            new = [new]
        else:
            new = None
        return [self.centerof], new

#
#          ***** MAJOR SECTION *****
#
#  -- Actual Shape Drawing

#
#  -- code for splitting a possibly concave polygon into convex ones.
#

def find_cut(input, i, prev, curr):
  found = None
  curr = curr.normalized
  for j in range(len(input)):
    if j==i or j==i+1: continue
    test = input[j]-input[i]
    if concavity(prev, test): continue
    diff = test.normalized*curr
    if found is None or found[1]<diff:
      found = (j, diff)
#  if found is None:
#    squawk("None found")
  return found[0]


from quarkpy.qeditor import matrix_rot_z
twister = matrix_rot_z(90*deg2rad)

#
# detects a concavity in a counter-clockwise traversal
#  of a polygon
#
def concavity(vec1, vec2):
  axis = twister*vec1
#  squawk("axis: %s, vec2: %s"%(axis, vec2))
  if axis*vec2 <= 0:
    return 1
  return 0


#
# Split up a possibly concave poly into convex ones
#
# The idea of this one is: cruise around the border until you
#  hit a concave angle.  If you don't you're done & return the
#  cycle.
# Otherwise check all the other vertices & find the whose angle
#  is the smallest one greater than that angle.  Split the border
#  into 2 cycles between the concavity and this new point
#  & return the union of the two cycles.
#
# Some of the code in here is for supporting currently
#  inoperative texturing mechanisms, the idea is that the
#  names argument would keep track of what sides the edges
#  come from, and so can be used to control texturing.
#  Problematic so disabled.
#

def convexify(input, names=None):
    length = len(input)
    if names==None:
        names = range(length)
        for i in names[1:]:
            names[i] = "side %d"%(i-1)
        names[0] = "side %d"%(length-1)
        return convexify(input, names)
#    squawk("convexifying %s"%input)
 
#    squawk(`names`)
    cycle = input[:]
    cycle.append(input[0])
    prev_vect = input[0]-input[length-1]

    for i in range(length-1):
#        prev_vect = cycle[i]-cycle[i-1]
        curr_vect = cycle[i+1]-cycle[i]
        if concavity(prev_vect, curr_vect):
            j = find_cut(input, i, prev_vect, curr_vect)
            pi,pj = decodeName(names[i]), decodeName(names[j])
            if i<j:
#                squawk('names: '+`names`)
                half1, names1 = convexify(cycle[i:j+1],["inner%d"%pi]+names[i+1:j+1])
                half2, names2 = convexify(input[:i+1]+input[j:],names[:i+1]+["inner%d"%pj]+names[j+1:])
#                squawk('%d<%s: %s'%(i,j,names1+names2))
                return half1+half2, names1+names2
            else:
                half1, names1 =  convexify(input[j:i+1],["inner%d"%pj]+names[j+1:i+1])
                half2, names2 =  convexify(input[i:]+input[:j+1],["inner%d"%pi]+names[i+1:]+names[:j+1])
#                squawk('else: '+`names1+names2`)
                return half1+half2, names1+names2
  
        prev_vect=curr_vect
#    squawk(`names`)
    return [input], [names]

def convexify_nums(input, nums=None):
  nums = range(len(input))
  return convexify(input, nums)
#  squawk("convexifying %s"%input)
  cycle = input[:]
  cycle.append(input[0])
  prev_vect = input[0]-input[length-1]

  for i in range(length-1):
    curr_vect = cycle[i+1]-cycle[i]
    if concavity(prev_vect, curr_vect):
      j = find_cut(input, i, prev_vect, curr_vect)
      if i<j:
        half1, nums1 = convexify(cycle[i:j+1],nums[i:j+1])
        half2, nums2 = convexify(input[:i+1]+input[j:],nums[:i+1]+nums[j:])
        return half1+half2, nums1+nums2
      else:
        half1, nums1 =  convexify(input[j:i+1],nums[j:i+1])
        half2, nums2 =  convexify(input[i:]+input[:j+1],nums[i:]+nums[:j+1])
        return half1+half2, nums1+nums2
    prev_vect=curr_vect

  return [input], [nums]


#
# This one is supposed to make an vector that sticks out from
#  the angle between to edges for making bevels etc.
#
def make_edge(v1, v2):
  n1, n2 = v1.normalized, v2.normalized
  perp = matrix_rot_z(-90*deg2rad)*n1
  if n1-n2:
    half = (-n1+n2).normalized
#    half = math.fabs(half*perp)*half
    half = half/math.fabs(half*perp)
    if concavity(n1, n2):
      return half
    return -half
  return perp

#
# Turn the innner rim of points into the outer one,for
#   punching outer holes
#
def outrim(input, data):
  length = len(input)
  cycle = input[:]
  cycle.append(input[0])
  firstedge = None
  prev_vect = input[0]-input[length-1]
  curr_vect = cycle[1]-cycle[0]
  firstedge = edge = make_edge(prev_vect,curr_vect)
#  squawk("k: 0, edge: %s"%edge)
  firstwidth, = data.CircAttr(0,"edge", (8.0,))
  width = firstwidth
  output = range(length)
  names = range(length)
  for i in range(length):
    if i < length-1:
      next_vect=cycle[i+2]-cycle[i+1]
      nextedge = make_edge(curr_vect,next_vect)      
#      squawk("k: %s, edge: %s"%(i+1,nextedge))
      nextwidth, = data.CircAttr(i+1,"edge", (8.0,))
    else:
      nextedge=firstedge
      nextwidth=firstwidth
    output[i]=cycle[i]+width*edge
 #   output[i]=[cycle[i],cycle[i+1], cycle[i+1]+nextwidth*nextedge, cycle[i]+width*edge]
    names[i] = "punch%d"%i
    prev_vect=curr_vect
    curr_vect = next_vect
    edge = nextedge
    width = nextwidth
  return output,names

#
# Autobox puts a square outer wall around a tunnel of
#  arbitrary shape.  Output wants a bit of optimization
#  (but doesn't seem too horrible to me).
#
# First we generate a long, concave outline from the circumference
#  points and their expanded bounding square.  Then this is fed
#  to convexify
#

def autobox(input, data):
  square = data.CircBox(data.dup["edge"])
  #
  # get the closed corner and circumference points.
  #
  dist, corner, circ = abs(input[0]-square[0]), 0, 0
  for i in range(len(square)):
    for j in range(len(input)):
      d2 = abs(square[i]-input[j])
      if d2<dist:
        dist, corner, circ = d2, i, j
  #
  # Now make the path, starting at inside, go out, loop around out
  # go in, loop around in.
  #
  first = input[:circ+1]
  second = input[circ:]
  first.reverse()
  second.reverse()
  path = square[:corner+1]+first+second+square[corner:]
 
  def side(i):
     return "side %d"%i
  def outer(i):
     return "outer %d"%i
     
  innernames = map(side, range(len(input)))
  outernames = map(outer, range(4))
 
  firstnames = innernames[:circ+1]
  secondnames = innernames[circ:]
  firstnames.reverse()
  secondnames.reverse()
  
  names = outernames[:corner+1]+["inner"]+firstnames[1:]+secondnames+["inner"]+outernames[corner+1:]
  names = [names[len(names)-1]]+names[:len(names)-1]
  squawk(`path`)
  squawk(`names`)
  
#  squawk("%d, %d"%(len(path),len(names)))
  return convexify(path, names)
  
#
# Makes pipes
#
# The idea of this one is: cruise around the circumference,
#  for each side generate a loop that will be turned into
#  a brush by the same code as makes brushes from the output
#  of convexify;.
#
def pipeify(input, data):


#  squawk("convexifying %s"%input)
  length = len(input)
  cycle = input[:]
  cycle.append(input[0])
  firstedge = None
  prev_vect = input[0]-input[length-1]
  curr_vect = cycle[1]-cycle[0]
  firstedge = edge = make_edge(prev_vect,curr_vect)
  firstwidth, = data.CircAttr(0,"edge", (8.0,))
  width = firstwidth
  output = range(length)
  names = range(length)
  for i in range(length):
    if i < length-1:
      next_vect=cycle[i+2]-cycle[i+1]
      nextedge = make_edge(curr_vect,next_vect)      
      nextwidth, = data.CircAttr(i+1,"edge", (8.0,))
    else:
      nextedge=firstedge
      nextwidth=firstwidth
    output[i]=[cycle[i+1], cycle[i], cycle[i]+width*edge, cycle[i+1]+nextwidth*nextedge]
 #   output[i]=[cycle[i],cycle[i+1], cycle[i+1]+nextwidth*nextedge, cycle[i]+width*edge]
    names[i] = ["side %d"%i,"inner","outer %d"%i, "inner"]
    prev_vect=curr_vect
    curr_vect = next_vect
    edge = nextedge
    width = nextwidth
  return output,names

#
# recovers circumference point indexes from connecting side names
#
def decodeName(name):
    return eval(name[5:])

#
# Adjusts circumference points for effects of scale
#   property of path points
#
# In order for it to work, the user of this routine needs
# to know that the name of an edge names its first vertex
#
def adjust_points(data, points, j, names):
  newpoints = points[:]
  for i in range(len(points)):
    name=names[i]
    if name[:4]=="side":
      k = int(eval(name[5:]))
    elif name[:5]=="inner":
      k = int(eval(names[i-1][5:]))+1
#    if name[:5]!='outer':
#       k = decodeName(name);
    else: # eeks, it's outer, so bail
      newpoints2 = range(len(points))
      scale = get_path_scale(data.dup, j)
      for i in range(len(points)):
        point = scale*points[i]
        newpoints2[i]=data.MapCircPos(point,j)
        
      return newpoints2
        

    newpoints[i]=data.CircPos(k,j)
  return newpoints

#
# Attaches the sides to the brushes
#
def attach_sides(data, j, brush, bottom, cycle, names, texpos):
#  squawk("%d, %d"%(len(cycle),len(names)))
#  squawk("j: %s"%j)
  xaxis, yaxis, zaxis = axes = data.Axes(j-1)
  frontcycle=adjust_points(data, cycle, j-1, names)
  backcycle=adjust_points(data, cycle, j, names) 
  last = frontcycle[-1]
#  squawk('cycle: '+ `cycle`)
#  squawk(`names`)
#  squawk('front: '+ `frontcycle`)
#  squawk('back: '+ `backcycle`)
#  squawk('last: %s; first: %s'%(last, frontcycle[0]))
  for i in range(len(cycle)):
      pos = frontcycle[i]
      pos2 = backcycle[i]
      new = bottom.copy()
      short = new.shortname = names[i-1]
      p0, p1, p2 = bottom.threepoints(0)
      norm = bottom.normal
#      squawk("pos: %s; last: %s"%(pos, last))
      diff = last-pos
      if not diff:
#          squawk('no diff at: '+`i`)    
#          squawk('last: '+`last`)
#          squawk('pos: '+`pos`)
          continue
#      squawk('diff: '+`diff`)
#      squawk("z: %s, d: %s"%(zaxis,diff))
      gap = pos2-pos
#      squawk(`gap^diff`)
      norm = -(gap^diff).normalized
      new.distortion(norm, pos)

      if texpos is not None:
          org = data.PathPos(j-1)
          name = "%s:g"%new.shortname
#          squawk(name)
          side = texpos.findname(name)
          if side is not None:
#              squawk('side')
              p0 = restore(side["p0"],axes,org, new)
              p1 = restore(side["p1"],axes,org, new)
              p2 = restore(side["p2"],axes,org, new)
 
              new.setthreepoints((p0, p1, p2),4)
              new["tex"] = side["tex"]
      brush.appenditem(new)
      last = pos


def make_shape(dup, init_seg, make_seg, limit=0):
    data = ExtruderDupData(dup)
    texpos = dup.findname("texinfo:g")
    if dup["elbow"]:
        global_elbow, = dup["elbow"]
    else:
        global_elbow = None
    shapes = []
    if limit:
      pathlength=limit
    else:
      pathlength = len(data.PathPoints())
    org = prev_org = data.Org()
    xaxis, yaxis, prev_z = axes = data.Axes()
    class pack:
          "a place to stick stuff"
    pack.axislist = range(pathlength)
    shapes = init_seg(data, dup, org, axes, pack)
    pack.axislist[0] = axes
    for j in range(1, pathlength):
        local_elbow = get_path_bevel(dup,j,"elbow")
        if not local_elbow:
            local_elbow = global_elbow
        if j>1:
            pack.front_elbow = prev_elbow
        if j<pathlength-1:
            pack.back_elbow = local_elbow
        prev_elbow = local_elbow
        curr_org = data.PathPos(j)
        xaxis, yaxis, zaxis = pack.axislist[j] = data.Axes(j)
        if j<pathlength-1:
            mat=matrix_rot_v2u((zaxis+prev_z).normalized, prev_z)
            norm = mat*prev_z
        else:
            zaxis = norm = prev_z
        shapes=shapes+make_seg(data, j, pathlength,prev_org, curr_org,
                          prev_z, norm, zaxis, pack)
        prev_z = zaxis
        prev_org = curr_org
    return shapes


def make_brushes(dup, cycles, names, limit=0):

    def init_seg(data, dup, org, (xaxis, yaxis, zaxis), pack):
        pack.texpos = dup.findname("texinfo:g")
        front = quarkx.newobj("front:f")
        front.setthreepoints((org, org+xaxis, org+yaxis),0)
        front["tex"] = dup["tex"]
        front.setthreepoints((org, org+128*xaxis, org+128*yaxis), 2)
        pack.front = front
        return []

    def make_seg(data, j, pathlength, prev_org, curr_org, prev_z, mid_z, zaxis, pack, cycles=cycles, names=names):
        front = pack.front
        texpos = pack.texpos
        group = quarkx.newobj("cor_seg_%d:g"%j)
        extension = abs(curr_org-prev_org)
        zdir = curr_org-prev_org
        zdirn = zdir.normalized
        back = front.copy()
        back.swapsides()
        if j>1 and pack.front_elbow:
            fchop = front.copy()
            fchop.distortion(-prev_z, prev_org)
            fchop.translate(pack.front_elbow*prev_z)
        back.translate(zdir)
        back.shortname = "back"
        p0, p1, p2 = back.threepoints(0)
        if j<pathlength-1:
            back.distortion(mid_z, p0)
            if pack.back_elbow:
                bchop = back.copy()
                bchop.distortion(zdirn,curr_org)
                bchop.translate(-pack.back_elbow*zdirn)
        else:
            back.distortion(zaxis,p0)
        for i in range(len(cycles)):
            brush = quarkx.newobj("brush:p")
            fside = front.copy()
            bside = back.copy()
            if j<pathlength-1 and pack.back_elbow:
                  bside=bchop.copy()
            if j>1 and pack.front_elbow:
                  fside=fchop.copy()
            brush.appenditem(fside), brush.appenditem(bside)
            attach_sides(data, j, brush, front, cycles[i], names[i], texpos)
            group.appenditem(brush)
            #
            # prepare the pack
            #
        front=back.copy()
        front.shortname="front"
        front.swapsides()
        pack.front = front
        return [group]

    return make_shape(dup, init_seg, make_seg, limit)    



#
# Used by make_patches below, rethink prolly called for
#
def restore(postuple, axes, org, face=None):
    x, y, z = postuple
    pos = x*axes[0]+y*axes[1]+z*axes[2]
    if face is not None:
      norm = face.normal
      return projectpointtoplane(pos+org,norm,face.dist*norm,norm)
    else:        
      return pos+org

def make_patches(dup, points, limit=0, editor=None):

    def init_seg(data, dup, org, (xaxis, yaxis, zaxis), pack, points=points):
        pack.texpos = dup.findname("texinfo:g")
        pack.texface = quarkx.newobj(":f")
        pack.inverse = dup["inverse"]
        numpoints = len(points)
        if dup["open"]:
            pack.dopoints = numpoints-1
        else:
            pack.dopoints = numpoints
        prev_pos = range(numpoints)
        for k in range(numpoints):
            prev_pos[k] = org+xaxis*points[k].x+yaxis*points[k].y
        prev_pos.append(prev_pos[0])
        pack.prev_pos = prev_pos
        pack.numpoints = numpoints
        pack.texname = dup["tex"]
        return []

    def make_seg(data, j, pathlength, prev_org, curr_org, prev_z, mid_z, zaxis, pack):
        numpoints = pack.numpoints
        dopoints = pack.dopoints
        texpos = pack.texpos
        inverse = pack.inverse
        prev_pos = pack.prev_pos
        group = quarkx.newobj("cor_seg_%d:g"%j)
        extension = abs(curr_org-prev_org)
        curr_pos = range(numpoints)
        for k in range(numpoints):
            curr_pos[k] = data.CircPos(k, j, mid_z)
  #      squawk(`numpoints`)
  #      squawk(`dopoints`)
        curr_pos.append(curr_pos[0])
        for k in range(0, dopoints):
            pos0 = prev_pos[k]
            pos1 = prev_pos[k+1]
            if j>1 and pack.front_elbow:
                def mapfront(v, org=prev_org+pack.front_elbow*prev_z, along=prev_z):
                    return projectpointtoplane(v, along, org, along)
                pos0, pos1 = map(mapfront, (pos0, pos1))        
            pos0e, pos1e = curr_pos[k], curr_pos[k+1]
            if j<pathlength-1 and pack.back_elbow:
                def mapback(v, org=curr_org-pack.back_elbow*prev_z, along=prev_z):
                    return projectpointtoplane(v, along, org, along)
                pos0e, pos1e = map(mapback, (pos0e, pos1e))
            v = range(16)
            v[0], v[3], v[12], v[15] = pos0, pos1, pos0e, pos1e
            b3 = quarkx.newobj("side %d:b3"%k)
            adjustinternals(v, 0, 1, 4)
            SetBezierPointsVec(b3, v)
            if texpos is not None:
                side = texpos.findname("side %d:g"%k)
                p0 = restore(side["p0"],prev_axes,prev_org)
                p1 = restore(side["p1"],prev_axes,prev_org)
                p2 = restore(side["p2"],prev_axes,prev_org)
                texface.setthreepoints((p0, p1, p2),1)
                texface.texturename=side["tex"]
                texface.setthreepoints((p0, p1, p2), 2)
                tex_face2patch(editor,texface,b3)
            else:
                b3["tex"] = pack.texname
            if not inverse:
                b3.swapsides()
            b3["_ptype"] = 2
            group.appenditem(b3)
        pack.prev_pos = curr_pos
        return [group]

    return make_shape(dup, init_seg, make_seg, limit)    


def make_elbows(dup, elbow, inverse, points, editor=None):

    def init_seg(data, dup, org, (xaxis, yaxis, zaxis), pack, inverse=inverse, points=points):
        pack.texpos = dup.findname("texinfo:g")
        numpoints = len(points)
        if dup["open"]:
            pack.dopoints = numpoints-1
        else:
            pack.dopoints = numpoints
        pack.numpoints = numpoints
        pack.texname = dup["tex"]
        return []

    def make_seg(data, j, pathlength, prev_org, curr_org, prev_z, mid_z, next_z, pack, elbow=elbow, inverse=inverse):
        if j==pathlength-1:
            return []
        numpoints = pack.numpoints
        dopoints = pack.dopoints
        texpos = pack.texpos
        group = quarkx.newobj("cor_seg_%d:g"%j)
        extension = abs(curr_org-prev_org)
        zdirn = (curr_org-prev_org).normalized
        def make_ring(zaxis, displacement,data=data,j=j,numpoints=numpoints):
            possies= range(numpoints)
            for k in range(numpoints):
                possies[k] = data.CircPos(k, j, zaxis)+displacement*zaxis
            possies.append(possies[0])
            return possies
        mid_pos = make_ring(mid_z, 0)
        def mapfront(v, org=curr_org-pack.back_elbow*prev_z, along=prev_z):
            return projectpointtoplane(v, along, org, along)
        start_pos=map(mapfront, mid_pos)
        def mapback(v, org=curr_org+pack.back_elbow*next_z, along=next_z):
            return projectpointtoplane(v, along, org, along)
        end_pos = map(mapback, mid_pos)
        def make_row(start, end, tex):
            def v5(v3, t2):
                return quarkx.vect(v3.tuple+t2)
            return [v5(start,(tex,0.0)),v5((start+end)/2.0,(tex,0.5)),v5(end,(tex,1.0))]
            
        for k in range(0, dopoints):
            cp = [make_row(start_pos[k], start_pos[k+1], 0.0),
                  make_row(mid_pos[k], mid_pos[k+1], 0.5),
                  make_row(end_pos[k], end_pos[k+1], 1.0)]
            b2 = quarkx.newobj("side %d:b2"%k)
            b2.cp = cp
            b2["tex"] = pack.texname
            if not inverse:
                b2.swapsides()
            group.appenditem(b2)
        return [group]

    return make_shape(dup, init_seg, make_seg, 0)    


#
#          ***** MAJOR SECTION *****
#
# -- Testing routines (prolly dumpable, Dissociate Dup
#     images seems to write errors to the console)
#

def testbrushes2(m):
  dup = m.o
  data = ExtruderDupData(dup)
  points = data.CircCoords()
#  result, names = convexify(points)
  result, names = autobox(points, data)
  prisms = make_brushes(dup, result, names)
  group = quarkx.newobj("brushes:g")
  for brush in prisms:
    group.appenditem(brush)
  undo = quarkx.action()
  undo.put(dup.parent, group, dup)
  editor=mapeditor()
  editor.ok(undo,"make brushes")


def subitemsfromlist(list,type):
  group = quarkx.newobj("group:g")
  for item in list:
    group.appenditem(item)
  return group.findallsubitems("",type)

def testbrushes(m):
  dup = m.o
  data = ExtruderDupData(dup)
  square = data.CircBox(dup["edge"])
#  squawk(`square`)
  points = data.CircCoords()
#  squawk(`points`)
  result, names = convexify(points)
  neggies = make_brushes(dup, result, names)
  box = make_brushes(dup, [square] , [["outer 0","outer 1","outer 2","outer 3"]]) 
  from mapcsg import CSGlist
  sublist = subitemsfromlist(neggies,":p")
  plist = subitemsfromlist(box,":p")
  CSGlist(plist, sublist)

  group = quarkx.newobj("group:g")
  for brush in box:
    group.appenditem(brush)
  undo = quarkx.action()
  undo.put(dup.parent, group, dup)
  editor=mapeditor()
  editor.ok(undo,"make brushes")
  
def testpatches(m):
  dup = m.o
  data = ExtruderDupData(dup)
  points = data.CircCoords()
  patches = make_patches(dup, points)
  undo = quarkx.action()
  group = quarkx.newobj("patches:g")
  for patch in patches:
    group.appenditem(patch)
  undo.put(dup.parent, group, dup)
  editor=mapeditor()
  editor.ok(undo,"make patches")

def testpipe(m):
  dup = m.o
  data = ExtruderDupData(dup)
  cycles, names = pipeify(data.CircCoords(), data)
  brushes = make_brushes(dup, cycles, names)
  undo = quarkx.action()
  group = quarkx.newobj("pipe:g")
  for brush in brushes:
    group.appenditem(brush)
  undo.put(dup.parent, group, dup)
  editor=mapeditor()
  editor.ok(undo,"make pipe")
  
#
#          ***** MAJOR SECTION *****
#
# -- Circumference Point management
#

class CoordDlg (quarkpy.dlgclasses.LiveEditDlg):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (180,145)
    dfsep = 0.35

    
    dlgdef = """
        {
        Style = "9"
        Caption = "2d Coordinate Positioning"

        sep: = {Typ="S" Txt=" "} 

        coords: = 
        {
        Txt = "Coords"
        Typ = "EQ"
        Hint = "x, y positions; map units per texture tile"
        }

      sep: = {Typ="S" Txt=" "} 

      edge: =
      {
        Txt="edge"
        Typ="EF1"
        Hint="length of patch-connecting edge in pipe mode"
      }
        sep: = {Typ="S" Txt=" "} 

 
        exit:py = { }
    }
    """


class ExtruderAnchorHandle(quarkpy.maphandles.CenterHandle):
  "A circumference point for anchoring things to"

  hint = "Tag to attaching stuff.|Doesn't drag"

  def __init__(self, dup, k, j):
#    squawk("getting pos at: %d, %d"%(k, j))
    data = ExtruderDupData(dup)
    pos = data.CircPos(k, j)
#    squawk("p: %s, %d %d"%(pos, k,j))
    quarkpy.maphandles.CenterHandle.__init__(self, pos, dup, MapColor("Duplicator"))
    self.k = k
    self.j =j
    self.data = data
    
  def drag(self, v1, v2, flags, view):
     return [self.centerof], None    

  def menu(self, editor, view):
     return self.OriginItems(editor, view)[1:]

class ExtruderCircHandle(quarkpy.maphandles.CenterHandle):
  "A pass-through point for a corridor circumference"

  def __init__(self, dup, k):
    data = ExtruderDupData(dup)
    pos = data.CircPos(k)
    quarkpy.maphandles.CenterHandle.__init__(self, pos, dup, MapColor("Duplicator"))
    self.k = k
    self.data = data

  def menu(self, editor, view):

        def backbmp1click(m, view=view, form=editor.form):
            import quarkpy.qbackbmp
            quarkpy.qbackbmp.BackBmpDlg(form, view)

        backbmp1 = qmenu.item("Background image...", backbmp1click, "choose background image")

        def ins1click(m, dup=self.centerof, k=self.k, editor=editor):
            insert_point(dup, k, editor)


        def del1click(m, dup=self.centerof, k=self.k, editor=editor):
            ptlist = ExtruderDupData(dup).CircPoints()
            if len(ptlist)<4:
              quarkx.msgbox("I'm sorry Dave, I can't let you do that",
               MT_ERROR, MB_OK)
              return
            undo = quarkx.action()
            undo.exchange(ptlist[k],None)
            undo.ok(editor.Root, "delete point")
            editor.layout.explorer.sellist = [dup]


        def coords(data=self.data, k=self.k):
          x, y = data.CircPoint(k)["where"]
          return "loc: %s, %s"%(x, y)
        
        def setcoords1click(m, dup=self.centerof, k=self.k, editor=editor):
#          quarkx.msgbox("Not yet implemented",2,4)

          class pack:
            "just a place to stick stuff"
          
          pack.dup, pack.k = dup, k
          
          def setup(self, pack=pack):
            src = self.src
            self.pack = pack
            dup, k = pack.dup, pack.k
            data = ExtruderDupData(dup)
            coords = data.CircPoint(k)["where"]
            self.src["coords"] = "%.2f %.2f"%coords
            data.edge = self.src["edge"] = data.CircAttr(k, "edge")
                        
          def action(self, pack=pack, editor=editor):
            src = self.src
            dup, k = pack.dup, pack.k
            new = dup.copy()
            newdata = ExtruderDupData(new)
#            set_circ_pos(new, k, src["coords"])
            point = newdata.CircPoint(k)
            point["where"] = read2vec(src["coords"])
            edge = src["edge"]
            if edge == new["edge"]:
              point["edge"] = None
            else:
              point["edge"] = edge
            
            undo=quarkx.action()
            undo.exchange(dup, new)
            editor.ok(undo, "set coords")
            self.pack.dup = new
            editor.layout.explorer.sellist = [new]
            
          CoordDlg(quarkx.clickform, 'coord2d', editor, setup, action)



        ins1 = quarkpy.qmenu.item("&Add a point", ins1click, "add a new control point")
        del1 = quarkpy.qmenu.item("&Delete point", del1click, "remove this control point")
        loc1 = quarkpy.qmenu.item(coords(), None, "Coords relative to object center")
        set1 = quarkpy.qmenu.item("&Coords, etc. ",setcoords1click,"|2d coords, edge thickness in pipe mode")
        return [ins1, del1, set1, backbmp1] + self.OriginItems(editor, view)

  def drag(self, v1, v2, flags, view):
        delta = v2-v1
        data = ExtruderDupData(self.centerof)
        k = self.k
        pos0 = data.CircPos(k)
        if flags&MB_CTRL:
            newpos = aligntogrid(pos0+delta,1)
        else:
            delta = quarkpy.qhandles.aligntogrid(delta, 1)
            newpos = pos0+delta
        if delta or (flags&MB_REDIMAGE):
            new = data.dup.copy()
            set_circ_pos(new, k, newpos)                    
            new = [new]
        else:
            new = None
        return [data.dup], new

def insert_point(dup, k, editor=None):
            data = ExtruderDupData(dup)
            point = data.CircPoint(k)
            ptlist = data.CircPoints()
            if k < len(ptlist)-1:
              point2 = data.CircPoint(k+1)
            else:
              point2 = data.CircPoint(0)
#            points = dup.findname("lathpts:g")
            ang, rad = point["where"]
            ang2, rad2 = point2["where"]
            newang, newrad = (ang+ang2)/2, (rad+rad2)/2
            new = point.copy()
            new["where"] = newang, newrad
            #
            # This option when we're inserting into a new thing
            #
            if editor is None:
 #             spine = dup.findname("spine:g")
 #             spine.subitems[0].insertitem(k, new)
              data.Circ().insertitem(k, new)
              return
            undo = quarkx.action()
            undo.put(data.Circ(), new, point2)
            undo.ok(editor.Root, "add a point")
            editor.layout.explorer.sellist = [dup]

class TexDlg (quarkpy.dlgclasses.LiveEditDlg):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (200,220)
    dfsep = 0.30
    dlgflags = FWF_KEEPFOCUS

    dlgdef = """
        {
        Style = "9"
        Caption = "Choose Texture for Panel"

        sep: = {Typ="S" Txt=" "} 


         texture: = 
         {
         Txt = "texture"
         Typ = "ET"
         Hint = "Name of Texture"
         GameCfg = "DD-1"
         }
          outer: = 
          {
          Txt = "outer"
          Typ = "ET"
          Hint = "Name of Texture for outer surface in pipe mode (texture used if this is empty)"
          GameCfg = "DD-1"
          }
  

         sep: = {Typ="S" Txt=" "} 

         exit:py = { }
    }
    """


class TweenHandle(EdgeHandle):
    "handle between two passthru's, for adding a new one"
    undomsg = "add point"
    hint = "drag to add point"
 
    def __init__(self, dup, k, vtx1, vtx2):
        pos = (vtx2+vtx1)/2
        quarkpy.qhandles.GenericHandle.__init__(self, pos)
        self.vtx1, self.vtx2 = vtx1, vtx2
        cur = CR_CROSSH
#        cur.pos = pos
        self.cursor = cur
        self.pos = pos
        self.dup, self.k = dup, k

    def drag(self, v1, v2, flags, view):
        delta = v2-v1
        dup = self.dup
        data = ExtruderDupData(dup)
        k = self.k
        pos0 = self.pos
        if flags&MB_CTRL:
            g1 = grid[1]
        else:
            delta = quarkpy.qhandles.aligntogrid(delta, 0)
            g1 = 0
        if delta or (flags&MB_REDIMAGE):
            new = dup.copy()
#            if k == 0:
#              k = len(data.CircPoints())-1
#              k = k-1
            insert_point(new, k)
            set_circ_pos(new, k, pos0+delta)                    
            new = [new]
        else:
            new = None
        return [dup], new



    def menu(self, editor, view):
        self.click(editor)
        editor.layout.clickedview = view

        data = ExtruderDupData(self.dup)

        def add1click(m, data=data, k=self.k, editor=editor):
          if k == 0:
            k = len(data.CircPoints())-1
          else:
            k = k-1
          insert_point(data.dup, k, editor)
        
        def length(data=data, k=self.k):
          if k == 0:
            j = len(data.PathPoints())-1
          else:
            j = k-1
          sep = data.CircPos(k)-data.CircPos(j)
          return "length: %s"%abs(sep)
        
        def tex1click(m, data=data, k=self.k, editor=editor):

          def setup(self, data=data, k=k):
            src = self.src
            dup = data.dup
            k = data.CircDec(k)
            data.tex = data.CircAttr(k, "tex")
            src["texture"] = data.tex
            data.outer = data.CircAttr(k, "outertex")
            src["outer"] = data.outer
          
          def action(self, data=data, k=k, editor=editor):
            src = self.src
            tex = src["texture"]
            outer = src["outer"]
            if tex!=data.tex or outer!=data.outer:
              k = data.CircDec(k)
              undo = quarkx.action()
              point = data.CircPoint(k)
              undo.setspec(point, "tex", tex)
              undo.setspec(point, "outertex", outer)
              editor.ok(undo,"set texture")
              data.tex = tex
              


          TexDlg(quarkx.clickform, 'corpaneltex', editor, setup, action)

          point = data.CircPoint(k)

#          texholder = point.findname("texholder:b")
#          if texholder is None:
#            undo=quarkx.action()
#            texholder.appenditem(quarkpy.mapbtns.newcube(64, data.dup["tex"]))
#            undo.put(point, texholder)
#            editor.ok(undo, "setup for texture")
#          quarkpy.mapbtns.texturebrowser()
        
        add1 = qmenu.item("&Add point", add1click, "Add a Point here")
        tex1 = qmenu.item("&Texture", tex1click, "Choose texture for this panel")
        length1 = qmenu.item(length(), None, "Length of this side")
        
        return [length1, add1] + self.OriginItems(editor, view)


#
#          ***** MAJOR SECTION *****
#
# -- The Duplicator at Last
#

def tagcordup(dup, editor):
  editor.tagging = Tagging()
  editor.tagging.taggedcor = dup
  editor.invalidateviews()
  
def gettaggedcordup(editor):
  try:
    cor = editor.tagging.taggedcor
    if checktree(editor.Root, cor):
      return cor
  except (AttributeError):
    return None
    
  
def extrudermenu(o, editor, oldmenu=quarkpy.mapentities.DuplicatorType.menu.im_func):
    "duplicator entity menu"
    menu = oldmenu(o, editor)
    if o["macro"] !="dup extruder":
        return menu
    testconc1 = qmenu.item("test brushes",testbrushes)
    testpipe1 = qmenu.item("test pipe", testpipe)
    testconc1.o = testpipe1.o = o

    n2d = qmenu.item("&2d view", editor.layout.new2dclick)

    n2d.o = o

    numen = [n2d]

    if MapOption("Developer"):
        numen = numen + [testconc1,  testpipe1]
    menu[:0] = numen + [qmenu.sep]
    return menu

quarkpy.mapentities.DuplicatorType.menu = extrudermenu

def corridorchandles(dup, editor, view):
      chandles = []
      data = ExtruderDupData(dup)
      length = len(data.CircPoints())
      p0  = data.CircPos(length-1)
      for k in range(length):
           p = data.CircPos(k)
           twh = TweenHandle(dup, k, p0, p)
           twh.hint = "len: %s|drag to add point, RMB for more"%abs(p0-p)
           chandles.append(twh)
           p0 = p
           cch = ExtruderCircHandle(dup, k)
           cch.hint = "pos %d: %s|RMB for remove point"%(k, data.CircPoint(k)["where"])
           chandles.append(cch)
      if chandles == []:
         quarkx.msgbox("Urrk, no circumference points",MT_WARNING, MB_OK)
         return
      pathlength = len(data.PathPoints())
      if view.info is not None and view.info["type"]!="2D":
        for j in range(1, pathlength):
          if data.PathPoint(j)["anchors"]:
            for k in range(length):
              chandles.append(ExtruderAnchorHandle(dup, k, j))
      return chandles


class ExtruderDuplicator(StandardDuplicator):

  def handles(self, editor, view):
    scale = view.scale()
    dup = self.dup
    data = ExtruderDupData(dup)
    org = dup.origin
    axishandles = []
    for k in range(1,len(data.PathPoints())):
      axishandles.append(ExtruderPathHandle(dup, k))
#    axishandle = ExtruderPathHandle(dup, 1)
    #
    # This `side' thing is needed to make the rotation angles
    #  define anything, maybe there will be twist factors
    #
    sidehandle = AxisHandle(org, dup, "side", scale)

    h = axishandles + [sidehandle]

    chandles = corridorchandles(dup,editor,view)

    return h + chandles + DuplicatorManager.handles(self, editor, view)

  def buildimages(self, singleimage=None):
    if singleimage is not None and singleimage>0:
      return []

    limit=0
    dup = self.dup
    data = ExtruderDupData(dup)
    aux = noneint(dup["auxiliary"])
    if aux is not None and aux & 1:
#      squawk("short")
      limit=2
    #
    # For making a brush
    #
    points = data.CircCoords()
    group = quarkx.newobj("content:g")
    group["_corridor_content"] = "1"
    if dup["elbow"] is not None:
        elbow,=dup["elbow"]
        elbow_inverse=dup["inverse"]
    else:
        elbow=0
    if dup["type"]=="b":
      cycles, nums = convexify(points)
      stuff = make_brushes(dup, cycles, nums, limit)
    elif dup["type"]=="t":
      elbow_inverse=1
      cycles, names = pipeify(points, data)
      stuff = make_brushes(dup, cycles, names, limit)
      elbow_inverse=1
    elif dup["type"]=="ab":
      elbow_inverse=1
      square = data.CircBox(dup["edge"])
      points = data.CircCoords()
      result, names = convexify(points)
      neggies = make_brushes(dup, result, names, limit)
      box = make_brushes(dup, [square] , [["outer 0","outer 1","outer 2","outer 3"]], limit) 
      from mapcsg import CSGlist
      for i in range(len(neggies)):
        sublist = neggies[i].findallsubitems("",":p")
        plist = box[i].findallsubitems("",":p")
        CSGlist(plist, sublist)
      stuff = box
    #
    # otherwise ...
    #
    else:
      stuff = make_patches(dup, points, limit)
    if elbow:
        stuff = stuff+make_elbows(dup, elbow, elbow_inverse, points)
    
    for thing in stuff:
        group.appenditem(thing)
    info = quarkx.newobj("data:g")
    info.copyalldata(dup)
    info["_corridor_data"]="1"
    return [group, info]

#
# This stuff could have been stuck into n2dfinishdrawing, but I
#  decided to keep it separate
#
def cortagfinishdrawing(editor, view, oldmore=quarkpy.qbaseeditor.BaseEditor.finishdrawing):
    oldmore(editor, view)
    dup = gettaggedcordup(editor)
    if dup is None: return
    data = ExtruderDupData(dup)
    cv = view.canvas()
    cv.pencolor = MapColor("Tag")
    cv.penstyle = PS_DOT
    prev_pos = view.proj(dup.origin)
    for j in range(1, len(data.PathPoints())):
      pos = view.proj(data.PathPos(j))
      cv.line(prev_pos, pos)
      prev_pos = pos

quarkpy.qbaseeditor.BaseEditor.finishdrawing = cortagfinishdrawing


#
#  Register the duplicator
#
quarkpy.mapduplicator.DupCodes.update({
  "dup extruder":     ExtruderDuplicator,
})

#
#          ***** MAJOR SECTION *****
#
#  --Dissociated Extruder tools
#

def gettexoption():
  opt = quarkx.setupsubset(SS_MAP, "Options")["cor_tex_lap"]
  if opt is None:
    return "track"
  else:
    return opt
    
def settexoption(opt):
  if opt == "track":
    opt = None
  quarkx.setupsubset(SS_MAP, "Options")["cor_tex_lap"] = opt
  

def corgroupmenu(o, editor, oldmenu=quarkpy.mapentities.GroupType.menu.im_func):
  menu = oldmenu(o, editor)
  info = o.findname("data:g")
  if info is not None and info["_corridor_data"]:
    from mapmadsel import getstashed
    data = ExtruderDupData(info)

    def PunchInnerClick(m,o=o,editor=editor,info=info,data=data, outer=0):
#      squawk(`data`)
      from mapcsg import CSG
      from mapmadsel import getstashed
      points = data.CircCoords()
      if outer:
        points, names = outrim(points,data)
        cycles, names = convexify(points, names)
      else:
        cycles, names = convexify(points)
      listgroup = make_brushes(info, cycles, names)
      sublist = []
      for group in listgroup:
        for item in group.findallsubitems("",":p"):
          sublist.append(item)
#      if outer:
#        cycles, names = pipeify(points,data)
#        outers = make_brushes(info,cycles,names)
#        for brush in outers[0].findallsubitems("",":p"):
#          sublist.append(brush)
      marked = getstashed(editor)
      plist = marked.findallsubitems("",":p")
      blist = marked.findallsubitems("",":b3")
      for p in sublist:
        if p in plist:
            plist.remove(p)
      if not plist and not blist:
        return
      CSG(editor, plist, sublist, "polyhedron subtraction", blist=blist)

    def PunchOuterClick(m,o=o,editor=editor,info=info,data=data,punch=PunchInnerClick):
      punch(m,o,editor,info,data,1)
      
    #
    # doesn't work, problems with position computations
    #
    def RevertClick(m,o=o,editor=editor,info=info):
      dup = quarkx.newobj("Flat Extruder:d")
      dup.copyalldata(info)
      undo=quarkx.action()
      undo.exchange(o,dup)
      editor.ok(undo,"Revert to Duplicator")
      
    def WrapClick(m,o=o,editor=editor,info=info,data=data):
      from maptagside import projecttexfrom
      sources = m.sources
      cont = find_path(o, ["content:g"])
      undo = quarkx.action()
      opt = gettexoption()
      org = data.Org()
      for j in range(2,data.PathLen()):
        for source in sources:
          name = source.name
          name, ext = string.splitfields(name,":")
          if (name[:4]=="side" or name[:5]=="outer"):
            tex = source.texturename
            type = data.dup["type"]
            if type == "p":
              face = quarkx.newobj(source.shortname+":b3")
              face["tex"] = source["tex"]
              
            else:
              texp = source.threepoints(2)
              face = source.copy()
            if opt == "track":
              def transform(p, data=data, j=j):
                return data.Transform(p,j-1)
              texp2 = map(transform, texp)
#            squawk("%s :: %s"%(texp, texp2))
              face.setthreepoints(texp2,0)
              face.setthreepoints(texp2,2)
            p0, p1, p2 = face.threepoints(1)
            seg = find_path(cont,["cor_seg_%d:g"%j])
#            squawk(seg.name)
            targets = seg.findallsubitems(name,":"+ext)
            for target in targets[:]:
              face.distortion(target.normal, p0)
 #             squawk("%s : %s"%(face.normal,target.normal))
              new = projecttexfrom(face,target)              
              undo.exchange(target, new)

      editor.ok(undo,"wrap texture")
      editor.layout.explorer.sellist = [o]
      editor.invalidateviews()      
      
    def TexOptClick(m):
      settexoption(m.opt)

    punch_inner = qmenu.item("Punch &Inner",PunchInnerClick,"|Subtract the interior of the tunnel from the marked group")
    punch_outer = qmenu.item("Punch &Outer",PunchOuterClick,"|Subtract the interior and the walls of the corrridor from the marked group.\n  Onely work works for `pipe'-type.")
    marked = getstashed(editor)
    if marked is None:
      punch_inner.state=punch_outer.state=qmenu.disabled
      punch_inner.hint=punch_inner.hint+"\n\nTo get the item enabled, mark something with RMB|Navigate Tree|<map object>|Mark."
    if info["type"]!="t":
      punch_outer_state=qmenu.disabled
    #
    # Wrapping textures from tagged faces.
    #
    seg1 = find_path(o,["content:g", "cor_seg_1:g"])
    fromtagged = qmenu.item("From &tagged",WrapClick,"|Wrap texture from first segment to others")
    type = data.dup["type"]
    if type == "p":
      import maptagzbezier
      tagged = gettaggedbzcplist(editor)
    else:
      tagged = gettaggedfaces(editor)
    if tagged is not None:
#      squawk(seg1.name)
      for face in tagged[:]:
        if not within(face, seg1):
          tagged.remove(face)
      if tagged == []:
        tagged = None
    if tagged is None:
        fromtagged.state = qmenu.disabled
        fromtagged.hint = fromtagged.hint+"\n\nFor this menu item to be enabled, you must tag some faces in the first segment of the corridor."
    else:
      fromtagged.sources = tagged
    fromfirst = qmenu.item("From &first",WrapClick,"|Wraps texture from each face of first segment.")
    if  type == "p":
      fromfirst.sources = seg1.findallsubitems("",":b3")
    else:  
      fromfirst.sources = seg1.findallsubitems("",":f")
    list = [fromtagged, fromfirst]
    curr_opt = gettexoption()
    for (label, opt, hint) in (("track", "track", "|Texture scale is shifted as is to the other segments, tracking direction changes"),
#                               ("Lapped", "lapped","|Texture is wrapped around corners to other segments"),
                               ("project", "project","|Texture is projected onto other segments.\n\n (good for some floors.)")):
      item = qmenu.item(label, TexOptClick, hint)
      item.opt = opt
      if opt == curr_opt:
        item.state = qmenu.checked
      list.append(item)

    wrap_texture = qmenu.popup("&Wrap Texture",list) 


    revert = qmenu.item("Revert",RevertClick,"|Convert corridor group back to duplicator.\n\nThe effects of retexturing, holes made etc will all be lost.")

    itemlist = [punch_inner,punch_outer, wrap_texture]
    item = qmenu.popup("Extruder Stuff",itemlist)
    menu[:0] = [item,
                qmenu.sep]
  return menu  

quarkpy.mapentities.GroupType.menu = corgroupmenu


#
#          ***** MAJOR SECTION *****
#
# --- 2d view stuff
#

def view2ddup(editor, view, dup):
    "Special code to draw only the circumference handles"

    def drawdup(view, dup=dup, editor=editor):
       gs = editor.gridstep
       view.drawgrid(quarkx.vect(gs,0,0),quarkx.vect(0,gs,0),
#         MapColor("GridLines"), DG_LINES, 0, quarkx.vect(0,0,0))
         MapColor("GridLines"))
       editor.finishdrawing(view)
        # end of drawsingleface

    data = ExtruderDupData(dup)
    origin = dup.origin
    if origin is None: return
    n = -data.Zaxis()
    if not n: return

    h = []
     # add the circ. handles
    h = corridorchandles(dup,editor,view)
    
    view.handles = quarkpy.qhandles.FilterHandles(h, SS_MAP)

    v = orthogonalvect(n, editor.layout.views[0])
    view.flags = view.flags &~ (MV_HSCROLLBAR | MV_VSCROLLBAR)
    view.viewmode = "wire"
    view.info = {"type": "2D",
                 "matrix": ~ quarkx.matrix(v, v^n, -n),
                 "bbox": quarkx.boundingboxof(map(lambda h: h.pos, view.handles)),
                 "scale": 0.01,
                 "custom": quarkpy.maphandles.singlefacezoom,
                 "origin": origin,
                 "noclick": None,
                 "mousemode": None }
    quarkpy.maphandles.singlefacezoom(view, origin)
    quarkpy.maphandles.singlefaceautozoom(view, dup)
    #
    # not sure really where to put this stuff
    #
    editor.layout.views.append(view)
#    editor.layout.oldviews = editor.layout.views
#   editor.layout.views = [view]
    editor.layout.new2dview = view  # for later removal in mapmgr
#    editor.layout.new2dobj = dup
    dup["_n2d"] = "1"
    m = qmenu.item("",None)
    m.object=dup
    from plugins.mapmadsel import RestrictByMe
    RestrictByMe(m)
    editor.setupview(view, drawdup, 0)
    return 1


def n2dfinishdrawing(editor, view, oldmore=quarkpy.qbaseeditor.BaseEditor.finishdrawing):
  "the new finishdrawning routine"
  oldmore(editor, view)
  
  try: # some awkwardness so the drawing code will chuck exceptions
    yes = 0
    if view is editor.layout.new2dview:
      yes = 1
  except: pass
  
  sel = editor.layout.explorer.sellist
  if yes: # and sel != [] and sel is list:
   if len(sel)<1: # or (sel and sel[0]["_n2d"]):
    dups = editor.Root.findallsubitems("",":d")
    for item in dups:
      if item["_n2d"]:
#        dup = item
        editor.layout.explorer.sellist = [item]
        break
    if sel:
      return
   else:

      
#    squawk(`sel`)
    dup = editor.layout.explorer.sellist[0]
    data = ExtruderDupData(dup)
    cv = view.canvas()
    cv.pencolor = MapColor("Tag")
    
    xaxis, yaxis, zaxis = data.Axes()
    points = data.CircPoints()
    p0 = prev = view.proj(data.CircPos(0))
    cv.pencolor = MapColor("Tag")
#    cv.fontname = "Small Fonts"
#    cv.fontsize = 5
#    cv.fontcolor = 0x000000
#    cv.fontname = "MS Serif"
#    cv.fontbold = 1
#    cv.textout(p0.x+5, p0.y, "(%s, %s)"%points[0]["where"])
    for point in points[1:]:
      x, y = point["where"]
      loc = dup.origin+x*xaxis+y*yaxis
      p = view.proj(loc)
      cv.line(prev, p)
      prev = p
 #     cv.textout(p.x+5, p.y, "(%s, %s)"%(x, y))
    if not dup["open"]:
      cv.line(p0, p)
      
    tagged = gettaggedcordup(editor)
    if tagged is not None:
      cv.penstyle = PS_DOT
      data = ExtruderDupData(tagged)
      points = data.CircPoints()
      p0 = prev = view.proj(data.CircPos(0))
      for point in points[1:]:
        x, y = point["where"]
        loc = dup.origin+x*xaxis+y*yaxis
        p = view.proj(loc)
        cv.line(prev, p)
        prev = p
      if not dup["open"]:
        cv.line(p0, p)
      

quarkpy.qbaseeditor.BaseEditor.finishdrawing = n2dfinishdrawing

def new2dclick(self, m):
      n2d = self.new2dwin
      if n2d is not None:
        self.new2dwin.close()
      if n2d is None:
        #
        # Set up the floating window
        #
        if mapeditor() is not self.editor: return
        n2d = quarkx.clickform.newfloating(FWF_KEEPFOCUS, "2D Extruder Window")
        x1,y1,x2,y2 = quarkx.screenrect()
        n2d.windowrect = (x2-500, y2-500, x2-20, y2-100)
        n2d.begincolor = GREEN
        n2d.endcolor = OLIVE
        n2d.onclose = self.new2dclose
        #
        #
        # ISSUE: is there a better way to pick the thing that's
        #   being edited
        #
        o = self.explorer.uniquesel
        #
        #  The 2d window itself
        #
        mv = n2d.mainpanel.newmapview()
        dup = m.o
        plugins.mapextruder.view2ddup(self.editor, mv, dup)
        self.new2dwin = n2d
      n2d.show()
 
def new2dclose(self, m):
      if self.new2dview in self.views:
        self.views.remove(self.new2dview)
      self.new2dwin = None
      del self.new2dview

      def restore(self):
        #
        # Maybe Unrestrict should be moved to a non-plugin
        #
        from plugins.mapmadsel import Unrestrict
        Unrestrict(self.editor)
        #
        # This is needed to prevent errors when editor
        #   is shut down with 2d window open1   
        #
        try:
          self.editor.invalidateviews()
        except (AttributeError):
          pass

      quarkx.settimer(restore,self,100)
      
def newclearrefs(self, oldclearrefs = quarkpy.mapmgr.MapLayout.clearrefs.im_func):
  oldclearrefs(self)
  self.new2dwin = None

quarkpy.mapmgr.MapLayout.new2dclick = new2dclick
quarkpy.mapmgr.MapLayout.new2dclose = new2dclose
quarkpy.mapmgr.MapLayout.clearrefs = newclearrefs


#
#          ***** MAJOR SECTION *****
#
#  Extrusion Dialog stuff
#

class PathExtrusionDlg(quarkpy.dlgclasses.LiveEditDlg):

    endcolor = AQUA
    size = (220,180)
    dfsep = 0.5

    dlgdef = """

      {
        Style = "9"
        Caption = "Path Extrusion Parameters"
        origin: = {Txt="&" Typ = "EF3"
                   Hint = "Location in map."}
        segments: = {Txt="&" Typ = "EF1"
                    Hint = "Number of segments"}
        seg len: = {Txt="&" Typ = "EF1"
                    Hint = "length of each segment"}
        start angle: = {Txt="&" Typ = "EF2"
                      Hint = "Starting angle; pitch, yaw relative to Eastward axis." $0D " e.g. 0 0 for due East."}

        turn angle: = {Txt="&" Typ = "EF2"
                      Hint = "Total turning angle; pitch, yaw relative to starting angle." $0D " e.g. 0 90 for a quarter-circle heading North."}

        sep: = { Typ="S" Txt = " "}

        no update: = {Txt="&" Typ = "X"
                   Hint = "If this is checked, the duplicator is not actualy updated when new data is entered (uncheck to set changes)." $0D " Useful to speed things up with big ones, or to prevent errors during revisions."}

      }"""


class RadialExtrusionDlg(quarkpy.dlgclasses.LiveEditDlg):

    endcolor = AQUA
    size = (220,200)
    dfsep = 0.5

    dlgdef = """

      {
        Style = "9"
        Caption = "Radial Extrusion Parameters"

        origin: = {Txt="&" Typ = "EF3"
                   Hint = "Location in map."}
        segments: = {Txt="&" Typ = "EF1"
                    Hint = "Number of segments"}
        center: = {Txt="&" Typ = "EF3"
                    Hint = "location of center for radial sweep." $0D " e.g. 0 -256 0 (relative to origin of duplicator by default)."}
        absolute: =  {Txt="&" Typ = "X"
                   Hint = "If checked, the center is located in absolute map coordinates" $0D " rather than relative to the origin of the duplicator."}
        normal: = {Txt="&" Typ = "EF3"
                  Hint = "Normal to the plane of the sweep."}
        sweep angle: = {Txt="&" Typ = "EF1"
                      Hint = "Degrees of arc swept out, in degrees." $0D " e.g. 360 for a full circle"}

        sep: = { Typ = "S" Txt = " "}

        no update: = {Txt="&" Typ = "X"
                   Hint = "If this is checked, the duplicator is not actualy updated when new data is entered (uncheck to set changes)." $0D " Useful to speed things up with big ones, or to prevent errors during revisions."}
      }"""

def PathExtrudeClick(btn):

    data = btn.data
    dup = data.dup
    
#    squawk(`data.PathLen()`)
    if data.PathLen()>2:
        if dup["turn angle"] is None:
           ans = quarkx.msgbox("Entering data into this dialog will overwrite previous work on this map object.  Do you wish to procede?",
                MT_WARNING, MB_YES|MB_NO)
           if ans==MR_NO:
             return
             
    def setup(self, data = data):
        src = self.src
        self.data = data
        dup = self.dup = self.data.dup
        src["origin"] = dup.origin.tuple
        src["segments"] = data.PathLen()-1,
        src["seg len"] = abs(data.PathPos(1)-data.Org()),
        CopyDefaultSpec(dup, src, "start angle", "")
        CopyDefaultSpec(dup, src, "turn angle", "")

        
    def action(self, data=data, editor=btn.editor):
        quarkx.globalaccept()
        src = self.src
        if src["no update"] or AnyIsNone(src,["start angle", "turn angle"]):
          return
          
        segs, = src["segments"]
        seglen, = src["seg len"]
        spitch, syaw = src["start angle"]
        tpitch, tyaw = src["turn angle"]
        segs = int(segs)
        spitch, syaw = spitch*deg2rad, syaw*deg2rad
        dpitch, dyaw = tpitch*deg2rad/(segs-1), tyaw*deg2rad/(segs-1)
        undo = quarkx.action()
        dup = data.dup
        locstr = write3tup(src["origin"])
        undo.setspec(dup,"origin",locstr)
        undo.setspec(dup,"start angle", (spitch, syaw))
        undo.setspec(dup,"turn angle", (tpitch, tyaw))
        oldpath = data.Path()  # this will be replaced
        newpath = quarkx.newobj("spine:g")
        newpath.appenditem(data.Circ().copy())
        dir = quarkx.vect(1, 0, 0)
        dir = matrix_rot_z(syaw)*matrix_rot_y(spitch)*dir
        twist = matrix_rot_z(dyaw)*matrix_rot_y(dpitch)
        loc = quarkx.vect(0, 0, 0)
        for i in range(segs):
            newrib = quarkx.newobj("rib:g")
            diff = seglen*dir
            loc = loc + diff
            newrib["location"] = loc.tuple
            newpath.appenditem(newrib)
            dir = twist*dir
        undo.exchange(oldpath, newpath)
        self.editor.ok(undo, "Extrude Path")
        self.editor.layout.explorer.sellist = [dup]
  
    try:
      btn.editor.layout.new2dwin.close()
    except (AttributeError):
      pass
    PathExtrusionDlg(btn.window, 'path_extrusiondlg', btn.editor, setup, action)


def RadialExtrudeClick(btn):

    data = btn.data

    dup = data.dup
    
#    squawk(`data.PathLen()`)
    if data.PathLen()>2:
        if dup["sweep angle"] is None:
           ans = quarkx.msgbox("Entering data into this dialog will overwrite previous work on this map object.  Do you wish to procede?",
                MT_WARNING, MB_YES|MB_NO)
           if ans==MR_NO:
             return


    def setup(self, data = data):
        src = self.src
        self.data = data
        dup = self.dup = self.data.dup
        src["origin"] = dup.origin.tuple
        CopyDefaultSpec(dup, src, "segments",(3,)) 
        CopyDefaultSpec(dup, src, "center", "")
        CopyDefaultSpec(dup, src, "normal", (0,0,1))
        CopyDefaultSpec(dup,src, "sweep angle", "")
        if dup["absolute"] is not None:
          src["absolute"] = "1"

    
    def action(self, data=data, editor=btn.editor):
        quarkx.globalaccept()
        src = self.src
        if src["no update"] or AnyIsNone(src, ["segments", "center", "sweep angle"]):
          return
        segs, = src["segments"]
        segs = int(segs)
        sweep, = src["sweep angle"]
        normal = quarkx.vect(src["normal"])
        turn = sweep*deg2rad/segs
        center = src["center"]
        center = quarkx.vect(center)
        rel = src["absolute"]
        if rel is None:
          rel=1
        else:
          rel=0
        rot = ArbRotationMatrix(normal, turn)
        halfrot = ArbRotationMatrix(normal, turn*0.5)
        undo=quarkx.action()
        dup = data.dup
        oldpath = data.Path()  # this will be replaced
        newpath = quarkx.newobj("spine:g")
        newpath.appenditem(data.Circ().copy())
        org = data.Org()
        if rel:
            center = org+center
        loc = org-center
        shift = center-org
        for i in range(segs):
              rimpoint = halfrot*loc
              rimnorm, locnorm = rimpoint.normalized, loc.normalized
              point = projectpointtoplane(rimpoint,rimnorm,loc,locnorm)
              newrib = quarkx.newobj("rib:g")
              newrib["location"] = (point+shift).tuple
              newpath.appenditem(newrib)
              loc = rot*loc
        newrib = quarkx.newobj("rib:g")
        newrib["location"] = (loc+shift).tuple
        newpath.appenditem(newrib)
        undo.exchange(oldpath, newpath)
        side = (center-data.Org()).normalized
        locstr = write3tup(src["origin"])
        undo.setspec(dup,"origin",locstr)
        undo.setspec(dup, "side", side.tuple)
        undo.setspec(dup,"center", src["center"])
        undo.setspec(dup,"segments", src["segments"])
        undo.setspec(dup,"normal", src["normal"])
        undo.setspec(dup,"sweep angle", src["sweep angle"])
        if rel:
           undo.setspec(dup,"absolute","")
        else:
           undo.setspec(dup,"absolute","1")
        self.editor.ok(undo, "Extrude Path")
        self.editor.layout.explorer.sellist = [dup]
          
    try:
      btn.editor.layout.new2dwin.close()
    except (AttributeError):
      pass
    RadialExtrusionDlg(btn.window, 'radial_extrusiondlg', btn.editor, setup, action)
            

#
# not used for the moment, might be resuscitated in an
#   objectification
#
def ExtrudeClick(btn):
  apply(btn.dlg, (btn.window, 'extrude', btn.editor, btn.olist))
  btn.editor.layout.new2dwin.close()

#$Log $
