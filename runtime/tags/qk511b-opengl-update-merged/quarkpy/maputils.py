"""   QuArK  -  Quake Army Knife

Various Map editor utilities.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#


import quarkx
from qeditor import *
from qdictionnary import Strings



#
# Function below removed. Use "view.scale()" instead.
#

#def scaleofview(view):
#    "The scale of the given view, or 1.0 for 3D views."
#    if view.info["type"]!="3D":
#        try:
#            return view.info["scale"]
#        except KeyError:
#            pass
#    return 1.0



#
# Is a given object still in the tree view, or was it removed ?
#
def checktree(root, obj):
    while obj is not root:
        t = obj.parent
        if t is None or not (obj in t.subitems):
            return 0
        obj = t
    return 1     


#
# The UserDataPanel class, overridden to be map-specific.
#

def chooselocaltexture(item):
    editor = mapeditor()
    if editor is None: return
    import mapbtns
    mapbtns.applytexture(editor, item.text)

def loadlocaltextures(item):
    editor = mapeditor()
    if editor is None: return
    items = []
    for tex in quarkx.texturesof([editor.Root]):
        m = qmenu.item(tex, chooselocaltexture)
        m.menuicon = ico_objects[1][iiTexture]
        items.append(m)
    return items


class MapUserDataPanel(UserDataPanel):

    def btnclick(self, btn):
        #
        # Send the click message to the module mapbtns.
        #
        import mapbtns
        mapbtns.mapbuttonclick(btn)

    def buildbuttons(self, btnpanel):
        Btns = []
        for tb, icon in (("New map items...", 25), ("Texture Browser...", 26)):
            icons =  (ico_maped[0][icon], ico_maped[1][icon])
            toolboxes = quarkx.findtoolboxes(tb)
            for toolbox, root in toolboxes:
                new = quarkx.newobj(root.shortname + '.qtxfolder')
                new.appenditem(root.copy())
                btn = self.newbutton(new, btnpanel, icons)
                btn.toolbox = toolbox
                del btn.ondrop
                Btns.append(btn)
            Btns.append(qtoolbar.smallgap)
        new = quarkx.newobj(Strings[185]+".qtxfolder")
        new.appenditem(quarkx.newobj("local:"))
        btn = self.newbutton(new, btnpanel, icons)
        btn.toolbox = Strings[185]
        del btn.ondrop
        del btn.onclick
        btn.menu = loadlocaltextures
        Btns.append(btn)
        Btns.append(qtoolbar.newline)
        return Btns + UserDataPanel.buildbuttons(self, btnpanel)

    def deletebutton(self, btn):
        if hasattr(btn, "toolbox"):
            quarkx.msgbox(Strings[5670] % btn.toolbox, MT_ERROR, MB_OK)
        else:
            UserDataPanel.deletebutton(self, btn)

    def drop(self, btnpanel, list, i, source):
        if len(list)==1 and list[0].type == ':g':
            quarkx.clickform = btnpanel.owner
            editor = mapeditor()
            if editor is not None and source is editor.layout.explorer:
                choice = quarkx.msgbox("You are about to create a new button from this group. Do you want the button to display a menu with the items in this group ?\n\nYES: you can pick up individual items when you click on this button.\nNO: you can insert the whole group in your map by clicking on this button.",
                  MT_CONFIRMATION, MB_YES_NO_CANCEL)
                if choice == MR_CANCEL:
                    return
                if choice == MR_YES:
                    list = [group2folder(list[0])]
        UserDataPanel.drop(self, btnpanel, list, i, source)


def group2folder(group):
    new = quarkx.newobj(group.shortname + '.qtxfolder')
    for obj in group.subitems:
        if obj.type == ':g':
            obj = group2folder(obj)
        else:
            obj = obj.copy()
        new.appenditem(obj)
    return new

def degcycle(shear):
    if shear > 180:
      shear = shear-360
    if shear < -180:
      shear = shear+360
    return shear

def undo_exchange(editor, old, new, msg):
  undo = quarkx.action()
  undo.exchange(old, new)
  editor.ok(undo, msg)

def perptonormthru(source, dest, normthru):
  "the line from source to dest that is perpendicular to (normalized) normthru"
  diff = source-dest
  dot = diff*normthru
  return diff - dot*normthru
  
#
# Sets sign of vector so that its dot product is
#  positive w.r.t. the axis it's most closely
#  colinear with
#
def set_sign(vec):
  gap = ind = 0
  tuple = vec.tuple
  for i in range(3):
    if tuple[i]>gap:
      gap = tuple[i]
      ind = i
    if gap < 0:
      return -vec
    else:
      return vec
def ArbRotationMatrix(normal, angle):
     # qhandles.UserRotationMatrix with an angle added
     # normal: normal vector for the view plane
     # texpdest: new position of the reference vector texp4
     # texp4: reference vector (handle position minus rotation center)
     # g1: if True, snap angle to grid
    SNAP = 0.998
    cosangle = math.cos(angle)
    sinangle = math.sin(angle)
#    oldcos = cosangle
#    cosangle = cosangle*cosa-sinangle*sina
#    sinangle = sinangle*cosa+sina*oldcos
 
    m = quarkx.matrix((cosangle,  sinangle, 0),
                      (-sinangle, cosangle, 0),
                      (    0,        0,     1))
    v = orthogonalvect(normal, None)
    base = quarkx.matrix(v, v^normal, -normal)
    return base * m * (~base)

def squawk(text):
  if quarkx.setupsubset(SS_MAP, "Options")["Developer"]:
    quarkx.msgbox(text, MT_INFORMATION, MB_OK)


