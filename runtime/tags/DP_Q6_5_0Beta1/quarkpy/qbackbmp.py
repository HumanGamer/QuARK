"""   QuArK  -  Quake Army Knife

"Background image" dialog box for map views.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$



import quarkx
import qmacro
import qtoolbar
from qeditor import *

class BackBmpDlg(qmacro.dialogbox):

    #
    # dialog layout
    #

    dfsep = 0.5
    dlgflags = FWF_KEEPFOCUS
    size = (300,260)

    dlgdef = """
      {
        Style = "15"
        Caption = "Background image"
        info: = {Typ="S" Bold="0" Txt="use this feature to display a image"}
        info: = {Typ="S" Bold="0" Txt="from your scanner or from another program."}
        sep: = {Typ="S" Txt=""}
        filename: = {Typ="EP" DefExt="bmp" Txt="Background image file"}
        center: = {Typ="EF3" Txt="Coordinates of the center"}
        scale: = {Typ="EF1" Txt="Scale"}
        PolySelectNoFill: =
        {
        Txt = "Poly No Fill (map editor only)"
        Typ = "X"
        Hint = "Stops the filling of the selected Poly with color."$0D
               "Makes it see through."
        }
        NoFillSel: =
        {
        Txt = "Color Guide (map editor only)"
        Typ = "LI"
        Hint = "The selected Poly(s) outline color."
        }
        sep: = {Typ="S" Txt=""}
        ok:py = {Txt="Apply and view changes"}
        remove:py = {Txt="Remove background image"}
        no:py = {Txt="Close this dialog"}
      }
    """

    #
    # __init__ initialize the object
    #

    def __init__(self, form, view):
        ico_maped=ico_dict['ico_maped']
        self.view = view
        src = quarkx.newobj(":")
        if view.background is None:
            src["center"] = (0,0,0)
            src["scale"] = (1,)
            src["PolySelectNoFill"] = quarkx.setupsubset(SS_MAP, "Options")["PolySelectNoFill"]
            src["NoFillSel"] = quarkx.setupsubset(SS_MAP, "Colors").getint("NoFillSel")
        else:
            filename, center, scale = view.background
            src["filename"] = filename
            src["center"] = center.tuple
            src["scale"] = scale,
            src["PolySelectNoFill"] = quarkx.setupsubset(SS_MAP, "Options")["PolySelectNoFill"]
            src["NoFillSel"] = quarkx.setupsubset(SS_MAP, "Colors").getint("NoFillSel")
        qmacro.dialogbox.__init__(self, form, src,
           ok = qtoolbar.button(
              self.ok,
              "apply and view changes",
              ico_editor, 1,
              "Ok"),
           remove = qtoolbar.button(
              self.remove,
              "remove background image",
              ico_maped, 2,
              "No image"),
           no = qtoolbar.button(
              self.no,
              "close this dialog",
              ico_editor, 0,
              "Close"))

    def ok(self, m):
        if mapeditor() is not None:
            editor = mapeditor()
        else:
            quarkx.clickform = self.view.owner
            editor = mapeditor()
        quarkx.globalaccept()
        src = self.src
        filename = src["filename"]
        if filename:
            center = quarkx.vect(src["center"])
            scale, = src["scale"]
            PolySelectNoFill = src["PolySelectNoFill"]
            NoFillSel = src["NoFillSel"]
            self.view.background = filename, center, scale
          ### Save the settings...
            quarkx.setupsubset(SS_MAP, "Options")["PolySelectNoFill"] = PolySelectNoFill
            quarkx.setupsubset(SS_MAP, "Colors")["NoFillSel"] = NoFillSel
            editor.invalidateviews()
        else:
          ### Save the settings...
            quarkx.setupsubset(SS_MAP, "Options")["PolySelectNoFill"] = src["PolySelectNoFill"]
            quarkx.setupsubset(SS_MAP, "Colors")["NoFillSel"] = src["NoFillSel"]
            editor.invalidateviews()

    def remove(self, m):
        if mapeditor() is not None:
            editor = mapeditor()
        else:
            quarkx.clickform = self.view.owner
            editor = mapeditor()
        src = self.src
        self.view.background = None
        PolySelectNoFill = src["PolySelectNoFill"]
        NoFillSel = src["NoFillSel"]
          ### Save the settings...
        quarkx.setupsubset(SS_MAP, "Options")["PolySelectNoFill"] = PolySelectNoFill
        quarkx.setupsubset(SS_MAP, "Colors")["NoFillSel"] = NoFillSel
        editor.invalidateviews()

    def no(self, m):
        if mapeditor() is not None:
            editor = mapeditor()
        else:
            quarkx.clickform = self.view.owner
            editor = mapeditor()
        src = self.src
        PolySelectNoFill = src["PolySelectNoFill"]
        NoFillSel = src["NoFillSel"]
          ### Save the settings...
        quarkx.setupsubset(SS_MAP, "Options")["PolySelectNoFill"] = PolySelectNoFill
        quarkx.setupsubset(SS_MAP, "Colors")["NoFillSel"] = NoFillSel
        editor.invalidateviews()
        self.close()

# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.8  2006/05/19 17:10:03  cdunde
#To add new transparent poly options for viewing background image.
#
#Revision 1.7  2005/10/15 00:47:57  cdunde
#To reinstate headers and history
#
#Revision 1.4  2001/06/17 21:05:27  tiglari
#fix button captions
#
#Revision 1.3  2001/06/16 03:20:48  tiglari
#add Txt="" to separators that need it
#
#Revision 1.2  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#