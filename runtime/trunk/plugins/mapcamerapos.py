# QuArK  -  Quake Army Knife
#
# Copyright (C) 2001 The Quark Community
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "Camera Position Duplicator",
   "desc":          "storeable camera positions",
   "date":          "13 June 2001",
   "author":        "tiglari",
   "author e-mail": "tiglari@planetquake.com",
   "quark":         "Quark 6.3" }

#
#  Lots of design suggestions by quantum_red.
#

import quarkx
import quarkpy.mapeditor
import quarkpy.mapentities
import quarkpy.mapduplicator
import quarkpy.qhandles
from quarkpy import qutils
import quarkpy.mapsearch
from quarkpy import dlgclasses
import quarkpy.qmacro
import quarkpy.mapselection
import quarkpy.mapmenus
import quarkpy.qmenu

import mapmadsel

#
# because of this, things from maphandles can be used
#  w/o qualification
#
from quarkpy.maphandles import *


#
# Tries to find the last 3D view clicked on
#
def get3DView(editor,makeone=0):
    #
    # A bit of showoff coding, see the online Python tutorial,
    #   functional programming techniques
    #
    views = filter(lambda v:v.info["type"]=="3D",editor.layout.views)
    if len(views)==0:
        if makeone:
            editor.layout.new3Dwindow(None)
            views = filter(lambda v:v.info["type"]=="3D",editor.layout.views)
            return views[0]
        else:
            quarkx.msgbox("Open a 3D view", qutils.MT_INFORMATION, qutils.MB_OK)
            return
    elif len(views)==1:
        return views[0]
    for view in views:
        #
        # put it in an exception-catching block for in case
        #   editor doesn't have a last3DView
        #
        try:
            if view is editor.last3DView:
                return view
        except (AttributeError):
            pass
    #
    # If intelligent selection fails, take the first.
    #
    return views[0]

#
# We're going to trigger these actions both by menu
#  items and buttons in a dialog, so we define them
#  independently of the UI elements that call them.
#
def setView(o,editor):
    view = get3DView(editor,makeone=1)
    if view is None:
        return
    view.cameraposition = o.origin, o["yaw"][0], o["pitch"][0]
    editor.invalidateviews()
    editor.currentcampos=o

def storeView(o,editor):
    view = get3DView(editor)
    if view is None:
        return
    pos, yaw, pitch = view.cameraposition
    undo = quarkx.action()
    undo.setspec(o,"origin",str(pos))
    #
    # note setting values as 1-element tuples (Python docco)
    #
    undo.setspec(o,"yaw",(yaw,))
    undo.setspec(o,"pitch",(pitch,))
    editor.ok(undo,"store camera position")
    editor.currentcampos=o

#
# We have to clear our editor.currentcampos to prevent it from leaking
#

def newcloseroot(self, oldcloseroot = quarkpy.mapeditor.MapEditor.CloseRoot.im_func):
  oldcloseroot(self)
  self.currentcampos = None

quarkpy.mapeditor.MapEditor.CloseRoot = newcloseroot

#
# The menu redefinition trick, as discussed in the plugin tutorial
#  in the infobase.  'o' is the duplicator object
#
def camposmenu(o, editor, oldmenu=quarkpy.mapentities.DuplicatorType.menu.im_func):
    "camera position entity menu"

    menu = oldmenu(o, editor)
    if o["macro"] !="cameraposition":
        return menu

    def setViewClick(m,o=o,editor=editor):
        setView(o,editor)

    def storeViewClick(m,o=o,editor=editor):
        storeView(o,editor)

    storeitem=quarkpy.qmenu.item("Store View",storeViewClick,"|Store 3D view position in this position item.")
    getitem=quarkpy.qmenu.item("Set View", setViewClick,"|Set 3D view position from this position item.\n\nThen use PgUp/Down with 'C' depressed to cycle prev/next camera positions in the same group as this one.\n\nThis won't work until a view has been set or stored in the group with the menu item")
    return [getitem, storeitem]

quarkpy.mapentities.DuplicatorType.menu = camposmenu

#
# Icons in the treeview represent map objects directly,
#   while icons in the map views represent their handles.
#   the code here uses the object's menu as the handle's.
#
class CamPosHandle(quarkpy.qhandles.IconHandle):

    def __init__(self, origin, centerof):
        quarkpy.qhandles.IconHandle.__init__(self, origin, centerof)

    def menu(self, editor, view):
        return camposmenu(self.centerof, editor)

#
# The creation of an extremely simple duplicator ...
# Define a class and register it by updating the DupCodes.
#
class CamPosDuplicator(quarkpy.mapduplicator.StandardDuplicator):

    def handles(self, editor, view):
        org = self.dup.origin
        if org is None:
            org = quarkx.vect(self.dup["origin"])
        hndl = CamPosHandle(org, self.dup)
        return [hndl]

quarkpy.mapduplicator.DupCodes.update({
  "cameraposition":  CamPosDuplicator,
})

#
# See the dialog box section in the advanced customization
#  section of the infobase.  SimpleCancelDlgBox is
#  defined in quarkpy.qeditor.
#
class NameDialog(SimpleCancelDlgBox):
    "A simple dialog box to enter a name."

    endcolor = AQUA
    size = (330,140)
    dfsep = 0.45
    dlgdef = """
      {
        Style = "9"
        Caption = "Enter name"
        sep: = {Typ="S" Txt=" "}    // some space
        name: = {
          Txt=" Enter the name :"
          Typ="E"
        }
        local: = {Typ="X" Hint="Put camera in currently selected group, if possible" $0D " (sister to selected non-group)"}
        sep: = {Typ="S" Txt=" "}    // some space
        sep: = {Typ="S" Txt=""}    // a separator line
        cancel:py = {Txt="" }
      }
    """

    def __init__(self, form, action, initialvalue=None):
        src = quarkx.newobj(":")
        if initialvalue is not None:
           src["name"]=initialvalue
        self.initialvalue=initialvalue
        self.action=action
        SimpleCancelDlgBox.__init__(self, form, src)

    #
    # This is executed when the data changes, close when a new
    #   name is provided
    #
    def datachange(self, df):
        if self.src["name"]!=self.initialvalue:
            self.close()

    #
    # This is executed when the OK button is pressed
    #   FIXME: 'local' code doesn't work right, dialog
    #   would need some redesign
    #
    def ok(self):
        name = self.src["name"]
        if name is None:
            name="Camera Position"
        self.name=name
        self.local = self.src["local"]
        self.action(self)

#
# This is called by two interface items, so pulled
#  out of both of them
#
def addPosition(view3D, editor):
        #
        # Dialogs run 'asynchronously', which means
        #  that the after the creation of the dialog just
        #  runs without waiting for a value to be entered
        #  into the dialog.  So if you don't want something
        #  to happen until then, you need to code it in a
        #  function that gets passed to the dialog as
        #  a parameter, which is what this is.
        #
        def action(self, view3D=view3D,editor=editor):
            #
            # NB: elsewhere in the code, 'yaw' tends to
            # be misnamed as 'roll'
            #
            #  pitch = up/down angle (relative to x axis)
            #  yaw = left/right angle (relative to x axis)
            #  roll = turn around long axis (relative to y)
            #
            pos, yaw, pitch = view3D.cameraposition
            camdup = quarkx.newobj(self.name+":d")
            camdup["macro"] = "cameraposition"
            pozzies=None
            if self.src["local"]:
                sel = editor.layout.explorer.uniquesel
                if sel is not None:
                    if sel.type==":g":
                        pozzies = sel
                    else:
                       pozzies=sel.treeparent # returns None if parent outside of tree
            if pozzies is None:
                pozzies = editor.Root.findname("Camera Positions:g")
            undo=quarkx.action()
            if pozzies is None:
                pozzies = quarkx.newobj("Camera Positions:g")
                undo.put(editor.Root,pozzies)
            undo.put(pozzies, camdup)
            undo.setspec(camdup,"origin",str(pos))
            undo.setspec(camdup,"yaw",(yaw,))
            undo.setspec(camdup,"pitch",(pitch,))
            editor.ok(undo,'add camera position')
        #
        # Now execute the dialog
        #
        NameDialog(quarkx.clickform,action,"Camera Position")



#
# And more menu redefinition, this time for the
#  EyePositionMap handle defined in maphandles.py.
#
def newEyePosMenu(self, editor, view):

    def addClick(m,self=self,editor=editor):
        addPosition(self.view3D,editor)

    item = quarkpy.qmenu.item('Add position',addClick)
    return [item]

EyePositionMap.menu = newEyePosMenu

def backmenu(editor, view=None, origin=None, oldbackmenu = quarkpy.mapmenus.BackgroundMenu):
  menu = oldbackmenu(editor, view, origin)

  def addClick(m,view=view,editor=editor):
      addPosition(view,editor)

  if view is not None and view.info["type"]=="3D":
      menu.append(quarkpy.qmenu.item("Add Camera Position",addClick, "|Add Camera Position:\n\nWhen selected, this function is used to set and store 3D camera views. This feature will only work for the Editor's 3D view and not the 3D view window.\n\nPress F1 again or click the 'InfoBase' for more detailed information on its use.|intro.mapeditor.floating3dview.html#camera"))
  return menu

quarkpy.mapmenus.BackgroundMenu = backmenu



#
# A Live Edit dialog.  Closely modelled on the Microbrush
#  H/K dialog, so look at that for enlightenment
#
class FindCameraPosDlg(dlgclasses.LiveEditDlg):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (220,160)
    dfsep = 0.35
    dlgflags = qutils.FWF_KEEPFOCUS

    dlgdef = """
        {
        Style = "9"
        Caption = "Camera position finder"

        cameras: = {
          Typ = "C"
          Txt = "Positions:"
          Items = "%s"
          Values = "%s"
          Hint = "These are the camera positions.  Pick one," $0D " then push buttons on row below for action."
        }

        sep: = { Typ="S" Txt=""}

        buttons: = {
        Typ = "PM"
        Num = "3"
        Macro = "camerapos"
        Caps = "TVS"
        Txt = "Actions:"
        Hint1 = "Select the chosen one in the treeview"
        Hint2 = "Set the view to the chosen one"
        Hint3 = "Store the view in the chosen one"
        }

        num: = {
          Typ = "EF1"
          Txt = "# found"
        }

        sep: = { Typ="S" Txt=""}

        exit:py = {Txt="" }
    }
    """

    def select(self):
        index = int(self.chosen)
        #
        # FIXME: dumb hack, revise mapmadsel
        #
        m = quarkpy.qmenu.item("",None)
        m.object=self.pack.cameras[index]
        mapmadsel.SelectMe(m)

    def setview(self):
        index = int(self.chosen)
        editor=mapeditor()
        if editor is None:
            return
        setView(self.pack.cameras[index],editor)

    def storeview(self):
        index = int(self.chosen)
        editor=mapeditor()
        if editor is None:
            return
        storeView(self.pack.cameras[index],editor)


#
# Define the zapview macro here, put the definition into
#  quarkpy.qmacro, which is where macros called from Delphi
#  live.
#
def macro_camerapos(self, index=0):
    editor = mapeditor()
    if editor is None: return
    if index==1:
        editor.cameraposdlg.select()
    elif index==2:
        editor.cameraposdlg.setview()
    elif index==3:
        editor.cameraposdlg.storeview()

quarkpy.qmacro.MACRO_camerapos = macro_camerapos

def findClick(m):
    editor=mapeditor()

    class pack:
        "stick stuff in this"

    def setup(self, pack=pack, editor=editor):
        editor.cameraposdlg=self
        self.pack=pack
        cameras = filter(lambda d:d["macro"]=="cameraposition",editor.Root.findallsubitems("",":d"))
        pack.cameras = cameras
        pack.slist = map(lambda obj:obj.shortname, cameras)
        pack.klist = map(lambda d:`d`, range(len(cameras)))
        #
        #  wtf doesn't this work, item loads but function is trashed
        #
#        self.src["cameras"] = pack.klist[0]
        self.src["cameras$Items"] = "\015".join(pack.slist)
        self.src["cameras$Values"] = "\015".join(pack.klist)
        self.src["num"]=len(pack.klist),

    def action(self, pack=pack, editor=editor):
       src = self.src
       #
       # note what's been chosen
       #
       self.chosen = src["cameras"]

    FindCameraPosDlg(quarkx.clickform, 'findcamerapos', editor, setup, action)

quarkpy.mapsearch.items.append(quarkpy.qmenu.item('Find Camera Positions', findClick, "|Find Camera Positions:\n\nThis finds all the camera positions.|intro.mapeditor.menu.html#searchmenu"))


#
# Prev/Next hotkey subversion
#
def camnextClick(m, editor=None, oldnext=quarkpy.mapselection.nextClick):
    if quarkx.keydown('C')==1:
        editor=mapeditor()
        if editor is None:
           return
        try:
            current=editor.currentcampos
        except (AttributeError):
            quarkx.msgbox("You need to set or store a view first for this to work", qutils.MT_INFORMATION, qutils.MB_OK)
            return
        successor = m.succ(current) # succ=prev or next, depending on key
        #
        # Skip over any non-camera stuff
        #
        while successor is not current and successor["macro"]!="cameraposition":
            successor=m.succ(successor)
        setView(successor,editor)
    else:
        oldnext(m,editor)

quarkpy.mapselection.nextItem.onclick=camnextClick
quarkpy.mapselection.prevItem.onclick=camnextClick
