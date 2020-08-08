"""   QuArK  -  Quake Army Knife

Fix Slash Textures
"""
#
# Copyright (C) 1996-2015 The QuArK Community
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "Fix Slash Textures",
   "desc":          "Fix slash in texture names.",
   "date":          "8 August 2020",
   "author":        "DanielPharos",
   "author e-mail": "danielpharos@users.sourceforge.net",
   "quark":         "Version 6" }

#Based on: mapfindreptex


import quarkx
import quarkpy.qmacro
import quarkpy.qtoolbar
import quarkpy.mapsearch
from quarkpy.maputils import *

class FixSlashTextureDlg(quarkpy.qmacro.dialogbox):

    #
    # dialog layout
    #

    size = (300, 180)
    dfsep = 0.4        # separation at 40% between labels and edit boxes
    dlgflags = FWF_KEEPFOCUS

    dlgdef = """
      {
        Style = "15"
        Caption = "Convert slash textures"
        slash: = {
          Typ = "C"
          Txt = "Replace with:"
          Items = "\\"$0D"/"
          Values = "\\"$0D"/"
        }
        scope: = {
          Typ = "CL"
          Txt = "Search in:"
          Items = "%s"
          Values = "%s"
        }
        sep: = {Typ="S" Txt=" "}
        ReplaceAll:py = {Txt=""}
        close:py = {Txt=""}
      }
    """

    #
    # __init__ initialize the object
    #

    def __init__(self, form, editor):

        #
        # General initialization of some local values
        #

        self.editor = editor
        uniquesel = editor.layout.explorer.uniquesel
        self.sellist = self.editor.visualselection()

        #
        # Create the data source
        #

        src = quarkx.newobj(":")

        #
        # Based on the textures in the map, initialize the
        # slash-to-convert-to setting
        #

        texlist = quarkx.texturesof(editor.Root.findallsubitems("", ':f'))
        CountSlashes = [0, 0] #Forward, backward
        for texturename in texlist:
            if texturename.find("/") != -1:
                CountSlashes[0] += 1
            if texturename.find("\\") != -1:
                CountSlashes[1] += 1
        if CountSlashes[1] > CountSlashes[0]: #If we have lots of backward slashes, we probably want to convert to forward slashes.
            src["slash"] = "/"
        else:
            src["slash"] = "\\"

        #
        # Based on the selection, populate the range combo box
        #

        if len(self.sellist) == 0:
            src["scope"] = "W"
            src["scope$Items"] = "Whole map"
            src["scope$Values"] = "W"
        else:
            src["scope"] = "S"
            src["scope$Items"] = "Selection\nWhole map"
            src["scope$Values"] = "S\nW"

        #
        # Create the dialog form and the buttons
        #

        quarkpy.qmacro.dialogbox.__init__(self, form, src,
           close      = quarkpy.qtoolbar.button(self.close, "Close this box", ico_editor, 0, "Close", 1),
           ReplaceAll = quarkpy.qtoolbar.button(self.ReplaceAll, "Convert slashes textures", ico_editor, 2, "Convert slashes", 1)
        )


    def deepsearch(self, objs, newsellist):
        # Performs a recursive search of ':f' objects, and appends them to a list
        for o in objs:
            if o.type == ':f':
                newsellist.append(o)
            else:
                if len(o.subitems) > 0:
                    self.deepsearch(o.subitems, newsellist)

    def ReplaceAll(self, btn):

        #
        # commit any pending changes in the dialog box
        #

        quarkx.globalaccept()

        #
        # read back data from the dialog box
        #

        whole = self.src["scope"] == "W"
        slash = self.src["slash"]

        list = None
        if whole:
            list = self.editor.Root.findallsubitems("", ':f')
        else:
            list = []
            self.deepsearch(self.sellist, list)

        changes = 0
        undo = quarkx.action()

        for o in list: # loop through the list
            print(o)
            orig_texturename = o.texturename
            new_texturename = orig_texturename.replace("/", slash).replace("\\", slash)
            if orig_texturename != new_texturename:
                o.texturename = new_texturename
                changes += 1
        txt = None
        if changes:
            txt = "%d textures converted" % changes
            mb = MB_OK_CANCEL
        else:
            txt = "No textures converted"
            mb = MB_CANCEL
        result = quarkx.msgbox(txt, MT_INFORMATION, mb)

        #
        # commit or cancel the undo action
        #

        if result == MR_OK:
            undo.ok(self.editor.Root, "convert slash textures")   # note: calling undo.ok() when nothing has actually been done is the same as calling undo.cancel()
            #
            # Sorry, we have to close the dialog box, because the selection changed.
            #
            self.close()
        else:
            undo.cancel()

#
# Function to start the fix slash dialog
#

def FixSlashTexClick(m):
    editor = mapeditor()

    if editor is None:
        return
    FixSlashTextureDlg(quarkx.clickform, editor)

#
# Register the fix slash texture menu item
#

quarkpy.mapsearch.items.append(quarkpy.qmenu.item("Convert slash textures...", FixSlashTexClick, "|Convert slash textures:\n\nThis function can convert the slashes in all used texture names.", "intro.mapeditor.menu.html#searchmenu"))
