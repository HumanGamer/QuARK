"""   QuArK  -  Quake Army Knife

Core of the Map editor.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#
# This file defines a class, "MapEditor", whose instances are
# the currently opened map editors in QuArK. Don't assume that
# only one map editor can be opened at any given time. However
# there is a simple way to obtain the instance of the "current"
# map editor : call qeditor.mapeditor(SS_MAP).
#
# The main attributes of Map Editor objects :
#
#  * layout  contains an instance of MapLayout (see mapmgr.py).
#  * dragobject  while the user is dragging the mouse,
#                is an instance of DragObject (see qhandles.py).
#


import maphandles
import qhandles
import mapmgr
from qbaseeditor import BaseEditor
import mapbtns
import mapentities

from maputils import *
from qdictionnary import Strings



class MapEditor(BaseEditor):
    "The Map Editor."

    MODE = SS_MAP
    manager = mapmgr
    ObjectMgr = mapentities.CallManager
    HandlesModule = maphandles
    MouseDragMode = maphandles.RectSelDragObject
    Portals = []

    def OpenRoot(self):
        self.tmpsaved = None
        if IsBsp(self):
            self.Root = self.fileobject.structure
            if self.Root is not None:
                self.Root.flags = self.Root.flags &~ OF_MODIFIED
                self.TexSource = self.fileobject.texsource
        else:
            Root = self.fileobject['Root']
            if Root is not None:
                self.Root = self.fileobject.findname(Root)
        errors = quarkx.getmaperror()
        if errors:
            errors = errors.split('\\n')
            debug('Map Reading Errors: face and brush numbering starting from 0, hulls from 1:')
            for error in errors:
                debug(' '+error)
            quarkx.msgbox(Strings[5770], MT_WARNING, MB_OK)
        self.AutoSave(0)


    def FrozenDragObject(self, view, x, y, s, redcolor):
        #
        # Some code to emulate Q3R drag behavior here.
        #
        sel = self.layout.explorer.uniquesel
        if sel.type==":f":
           debug('facial selection')
           sel = self.visualselection()[0]
        if sel is None:
            debug('mapeditor.FrozenDragObject is sulking because there is no uniquesel, htf did that happen??')
        else: # drag the whole thing
            if view.clicktarget(sel,x,y):
                handle=maphandles.CenterHandle(sel.origin, sel, MapColor("Tag"))
                return qhandles.HandleDragObject(view, x, y, handle, redcolor)
            elif sel.type==":p": # if sel is a poly drag the side that's closed to 'facing' the click

                startloc = quarkx.vect(x, y, 0)
#                debug('startloc: '+`startloc`)
                closest = None
                for face in sel.faces:
                    #
                    # find the face whose projected normal is closest to
                    # parallel with the line from the center to the click
                    #
#                    debug('zero: '+`view.proj(quarkx.vect(0,0,0))`)
#                    debug('face '+`face.name`)
                    center = face.origin
                    center = view.proj(center)
#                    debug(' center: '+`center`)
                    normend = face.origin+face.normal
                    normend = view.proj(normend)
#                    debug(' normend: '+`normend`)
#                    debug(' abs: %4f'%abs(normend-center))
#                    debug(' startloc-center: '+`(startloc-center).normalized`)

                    if abs(normend-center)<.001:
                        continue
                    dot = (startloc-center).normalized*(normend-center).normalized
#                    debug(' dot: %2f'%dot)
                    if closest is None:
                        closest = face
                        biggest=dot
                    elif dot>biggest:
                        biggest = dot
                        closest = face
                handle=maphandles.FaceHandle(closest.origin, closest)
                return qhandles.HandleDragObject(view, x, y, handle, redcolor)


    def CloseRoot(self):
        if not (self.Root is None) and (IsBsp(self)):
            mod = self.Root.flags & OF_MODIFIED
            self.Root = None
            if mod:
                self.fileobject.reloadstructure()
            self.fileobject.closestructure()
        try:
            pending = self.pending
        except:
            pending = None
        if pending:
            quarkx.settimer(autosave, self, 0)
            del self.pending
        if self.tmpsaved:
            try:
                quarkx.setfileattr(self.tmpsaved, -1)
            except:
                pass
        quarkx.setupsubset(SS_MAP, "Options")['ConsoleLog'] = None


    def initmenu(self, form):
        "Builds the menu bar."
        import mapmenus
        form.menubar, form.shortcuts = mapmenus.BuildMenuBar(self)
        quarkx.update(form)
        self.initquickkeys(mapmenus.QuickKeys)



    def setupchanged(self, level):
        "Update the setup-dependent parameters."
        quarkx.setpoolobj("BoundingBoxes", None)
        BaseEditor.setupchanged(self, level)
        try:
            self.initmenu(self.form)
            quarkx.update(self.form)
        except:
            pass
        import mapmenus
        self.initquickkeys(mapmenus.QuickKeys)
        self.AutoSave(None)


    def AutoSave(self, now=1):
        if now:
            time1 = autosave(self)
            if time1 is None:
                time1 = 0.0
        else:
            time1 = autosavetime()
        try:
            pending = self.pending
        except:
            pending = 0.0
        if (now is not None) or (time1 != pending):
            quarkx.settimer(autosave, self, int(time1))
            self.pending = time1


    def onfilesave(self, form):
        if self.tmpsaved:
            try:
                quarkx.setfileattr(self.tmpsaved, -1)
            except:
                pass
            self.tmpsaved = None
        self.AutoSave(0)


    def buildhandles(self):
        "Build the handles for all map views."
        invpoly, invfaces = self.Root.rebuildall()
        for v in self.layout.views:
            v.handles = maphandles.BuildHandles(self, self.layout.explorer, v)


    def setupview(self, v, drawmap=None, flags=MV_AUTOFOCUS, copycol=1):
        BaseEditor.setupview(self, v, drawmap, flags, copycol)
        v.boundingboxes = loadbbox
        if v.info["type"] == "3D":
            if self.last3Dcameraposition is not None:
                v.cameraposition = self.last3Dcameraposition


    #
    # Function to check for broken polyhedrons and faces after an undoable action.
    #

    def ok(self, undo, msg, autoremove=[]):
        undo.ok(self.Root, msg)
        removeme = []
        for test in autoremove:
            list = test.findallsubitems("", ':p') + test.findallsubitems("", ':f')
            removeme = removeme + filter(lambda f: f.broken, list)
        if len(removeme):
            undo = quarkx.action()
            for f in removeme:
                undo.exchange(f, None)   # replace all broken faces/polys with None
                if f in autoremove:
                    autoremove.remove(f)
            undo.ok(self.Root, Strings[624])    # FIXME: join this undo operation with the previous one
            if self.layout is not None:
                self.layout.explorer.sellist = autoremove
        invpoly, invfaces = self.Root.rebuildall()
        if (invpoly or invfaces) and MapOption("DeleteFaces"):
            list = self.Root.findallsubitems("", ':p') + self.Root.findallsubitems("", ':f')
            list = filter(lambda f: f.broken, list)
            if not len(list):
                return
            if invpoly:
                if invfaces:
                    msg = Strings[161] % (invpoly, invfaces)
                elif invpoly==1:
                    msg = Strings[160] % list[0].error
                else:
                    msg = Strings[159] % invpoly
            else:
                if invfaces==1:
                    msg = Strings[158]
                else:
                    msg = Strings[157] % invfaces
            result = quarkx.msgbox(msg, MT_CONFIRMATION, MB_YES_NO_CANCEL)
            if result == MR_YES:
                undo = quarkx.action()
                for f in list:
                    undo.exchange(f, None)   # replace all broken faces/polys with None
                undo.ok(self.Root, Strings[602])
            elif result == MR_CANCEL:
                self.form.macro("UNDO")



    def dropmap(self, view, newlist, x, y, src):
        center = view.space(x, y, view.proj(view.screencenter).z)
        mapbtns.dropitemsnow(self, newlist, center=center)



    def explorermenu(self, reserved, view=None, origin=None):
        "The pop-up menu for the Explorer."

        import mapmenus
        sellist = self.layout.explorer.sellist
        if len(sellist)==0:
            return mapmenus.BackgroundMenu(self, view, origin)
        if view is None:
            extra = []
        else:
            extra = [qmenu.sep] + mapmenus.TexModeMenu(self, view)
        if len(sellist)==1:
            return mapentities.CallManager("menu", sellist[0], self) + extra
        return mapmenus.MultiSelMenu(sellist, self) + extra


    def explorerdrop(self, ex, list, text):
        return mapbtns.dropitemsnow(self, list, text)

    def explorerinsert(self, ex, list):
        for obj in list:
            mapbtns.prepareobjecttodrop(self, obj)

    def explorerundo(self, ex, undo):
        pass

    def editcmdclick(self, m):
        # dispatch the command to mapbtns' "edit_xxx" procedure
        getattr(mapbtns, "edit_" + m.cmd)(self, m)

    def deleteitems(self, list):
        mapbtns.deleteitems(self.Root, list)


    def AllEntities(self):
        "A list of all entities in the map."
        return self.Root.findallsubitems("", ':e') + self.Root.findallsubitems("", ':b')

    def visualselection(self):
        "Returns a list of all selected items, replacing a face with the whole polyhedron."
        #
        # If the multi-pages panel is not on the 1st page (tree view)
        #
        if self.layout.mpp.n:
            #
            # then call the handles' "leave" method to bring the selection back
            # from a face to the whole polyhedron. This is done for commands that
            # are usually used on whole polyhedrons instead of single faces, like
            # copy/paste, brush subtraction, and so on.
            #
            for h in self.layout.views[0].handles:
                h.leave(self)
        #
        # Return the selection list now.
        #
        return self.layout.explorer.sellist


    def ForceEverythingToGrid(self, m):
        mapbtns.ForceToGrid(self, self.gridstep, self.layout.explorer.sellist)

    def moveby(self, text, delta):
        mapbtns.moveselection(self, text, delta)



def loadbbox(sender):
    "Load Bounding Boxes information."
    bbox = LoadPoolObj("BoundingBoxes", quarkx.getqctxlist, ":form")
    sender.boundingboxes = bbox
    return bbox

def autosavetime():
    minutes, = quarkx.setupsubset(SS_MAP, "Building")["AutoSave"]
    return minutes * 60000.0

def autosave(editor):
    if (editor.Root is not None) and (editor.fileobject.flags & OF_MODIFIED):
        progress = quarkx.progressbar(0,0)
        try:
            try:
                tmp = editor.fileobject.conversion(".qkm")
            except:
                pass
            else:
                if not editor.tmpsaved:
                    editor.tmpsaved = editor.fileobject.tempfilename
                tmp.savefile(editor.tmpsaved, 0)
                del tmp
        finally:
            progress.close()
    time1 = autosavetime()
    if time1 > 0.0:
        return time1
