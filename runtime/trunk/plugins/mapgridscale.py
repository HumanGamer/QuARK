"""   QuArK  -  Quake Army Knife

Map editor views, grid scale numbering feature.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "Display grid scale",
   "desc":          "Displays the grid scale in the 2D viewing windows. Activate from the 'Options' menu",
   "date":          "Dec. 13 2003",
   "author":        "cdunde",
   "author e-mail": "cdunde1@comcast.net",
   "quark":         "Version 6" }


import quarkpy.mapoptions
from quarkpy.maputils import *


#
# -------- grid numbering routines
#

def NumberGrid(cv, view, text):
    "function to place numbers on grid"
    editor = mapeditor()
    cv.textout(view.y, view.z, text)

#
# This part is a magical incantation.
# First the normal arguments for
#  finishdrawing, then the oldfinish=... stuff,
#  which has the effect of storing the current
#  finishdrawing method inside this function as
#  the value of the oldfinish variable.
# These def statements are executed as the plugins are being
#  loaded, but not reexecuted in later operations
#  of the map editor, only the functions they define are.
#

def gridfinishdrawing(editor, view, gridoldfinish=quarkpy.mapeditor.MapEditor.finishdrawing):

    #
    # execute the old method
    #

    gridoldfinish(editor, view)

    def MyMakeScroller(layout, view):
        sbviews = [None, None]
        for ifrom, linkfrom, ito, linkto in layout.sblinks:
            if linkto is view:
                sbviews[ito] = (ifrom, linkfrom)
        def scroller(x, y, view=view, hlink=sbviews[0], vlink=sbviews[1]):
            view.scrollto(x, y)
            if hlink is not None:
                if hlink[0]:
                    hlink[1].scrollto(None, x)
                else:
                    hlink[1].scrollto(x, None)
            if vlink is not None:
                if vlink[0]:
                    vlink[1].scrollto(None, y)
                else:
                    vlink[1].scrollto(y, None)
            if not MapOption("All2DviewsScale") and not MapOption("AllScalesCentered") and not MapOption("XviewScale") and not MapOption("XyScaleCentered") and not MapOption("XzScaleCentered") and not MapOption("YviewScale") and not MapOption("YxScaleCentered") and not MapOption("YzScaleCentered") and not MapOption("ZviewScale") and not MapOption("ZxScaleCentered") and not MapOption("ZyScaleCentered"):
                view.update()
            else:
                view.repaint()
        return scroller
    quarkpy.qhandles.MakeScroller = MyMakeScroller


# The following sets the canvas function to draw the images.

    cv = view.canvas()

    grid = editor.gridstep         # Gives grid setting
    if grid == 0.0:
        return
    gridunits = quarkx.ftos(grid)  # Converts float nbr to string
    type = view.info["type"]       # These type values are set
                                   #  in the layout-defining plugins.

# ===============
# X view settings
# ===============

    if type == "YZ":

        if not MapOption("All2DviewsScale") and not MapOption("AllScalesCentered") and not MapOption("XviewScale") and not MapOption("XyScaleCentered") and not MapOption("XzScaleCentered"):
            return

        cv.brushstyle = BS_CLEAR
        cv.fontname = "Terminal"
        cv.fontcolor = RED
        cv.fontsize = 8

        Ypixels, Zpixels = view.clientarea
        highlight = int(quarkx.setupsubset(SS_MAP, "Display")["GridHighlight"])
        Ygroupsize = grid * highlight
        Zgroupsize = grid * highlight
        Ygrouppixels = Ygroupsize * view.scale()
        Zgrouppixels = Zgroupsize * view.scale()
        Ygroups = Ypixels / Ygrouppixels
        Zgroups = Zpixels / Zgrouppixels
        while Ygroups < 4.0: #Not enough groups
            Ygroupsize = Ygroupsize / 2
            Ygrouppixels = Ygrouppixels / 2
            Ygroups = Ygroups * 2
        while Ygrouppixels < 40: #Too close together
            Ygroupsize = Ygroupsize * 2
            Ygrouppixels = Ygrouppixels * 2
            Ygroups = Ygroups / 2
        while Zgroups < 4.0: #Not enough groups
            Zgroupsize = Zgroupsize / 2
            Zgrouppixels = Zgrouppixels / 2
            Zgroups = Zgroups * 2
        while Zgrouppixels < 20: #Too close together
            Zgroupsize = Zgroupsize * 2
            Zgrouppixels = Zgrouppixels * 2
            Zgroups = Zgroups / 2


        if not MapOption("XyScaleCentered") and not MapOption("AllScalesCentered"):
            if not MapOption("AxisXYZ"):
                Yviewcenter = 6
            else:
                Yviewcenter = 48
        else:
            Ygroups = Ygroups / 2
            if not MapOption("All2DviewsScale") and not MapOption("XviewScale"):
                Yviewcenter = (Ypixels/2)+4
            else:
                Yviewcenter = 0
        if not MapOption("XzScaleCentered") and not MapOption("AllScalesCentered"):
            Zviewcenter = (Zpixels)-12
        else:
            Zgroups = Zgroups / 2
            Zviewcenter = (Zpixels/2)-4


        Ygroup1 = Yviewcenter+2
        Zgroup1 = Zviewcenter
        Ystring = quarkx.ftos(0)
        Zstring = quarkx.ftos(0)
        cv.textout(Yviewcenter, 2, "Y " + Ystring)
        cv.textout(Yviewcenter, 16, "  |")      # for mark line
        cv.textout(0, Zviewcenter, " Z " + Zstring + " --") # for mark line

        Ztotal = 0
        for Zcounter in range(1, int(Zgroups)):
            Ztotal = Ztotal + Zgroupsize
            Zstring = quarkx.ftos(Ztotal)
            Znextgroupup = Zgroup1 - (Zgrouppixels * Zcounter)
            cv.textout(0, int(Znextgroupup), " " + Zstring + " --")
            if MapOption("XzScaleCentered") or MapOption("AllScalesCentered"):
                Znextgroupdown = Zgroup1 + (Zgrouppixels * Zcounter)
                cv.textout(0, int(Znextgroupdown), "-" + Zstring + " --")

        Ytotal = 0
        for Ycounter in range(1, int(Ygroups)):
            Ytotal = Ytotal + Ygroupsize
            Ystring = quarkx.ftos(Ytotal)
            if MapOption("XyScaleCentered") or MapOption("AllScalesCentered"):
                Ynextgroupleft = Ygroup1 - (Ygrouppixels * Ycounter)
                cv.textout(int(Ynextgroupleft)-2, 2, Ystring)
                cv.textout(int(Ynextgroupleft)-2, 16, "  |")
            Ynextgroupright = Ygroup1 + (Ygrouppixels * Ycounter)
            cv.textout(int(Ynextgroupright)+4, 2, "-" + Ystring)
            cv.textout(int(Ynextgroupright)-2, 16, "  |")

# ===============
# Y view settings
# ===============

    elif type == "XZ":

        if not MapOption("All2DviewsScale") and not MapOption("AllScalesCentered") and not MapOption("YviewScale") and not MapOption("YxScaleCentered") and not MapOption("YzScaleCentered"):
            return

        cv.brushstyle = BS_CLEAR
        cv.fontname = "Terminal"
        cv.fontcolor = RED
        cv.fontsize = 8

        Xpixels, Zpixels = view.clientarea
        highlight = int(quarkx.setupsubset(SS_MAP, "Display")["GridHighlight"])
        Xgroupsize = grid * highlight
        Zgroupsize = grid * highlight
        Xgrouppixels = Xgroupsize * view.scale()
        Zgrouppixels = Zgroupsize * view.scale()
        Xgroups = Xpixels / Xgrouppixels
        Zgroups = Zpixels / Zgrouppixels
        while Xgroups < 4.0: #Not enough groups
            Xgroupsize = Xgroupsize / 2
            Xgrouppixels = Xgrouppixels / 2
            Xgroups = Xgroups * 2
        while Xgrouppixels < 40: #Too close together
            Xgroupsize = Xgroupsize * 2
            Xgrouppixels = Xgrouppixels * 2
            Xgroups = Xgroups / 2
        while Zgroups < 4.0: #Not enough groups
            Zgroupsize = Zgroupsize / 2
            Zgrouppixels = Zgrouppixels / 2
            Zgroups = Zgroups * 2
        while Zgrouppixels < 20: #Too close together
            Zgroupsize = Zgroupsize * 2
            Zgrouppixels = Zgrouppixels * 2
            Zgroups = Zgroups / 2


        if not MapOption("YxScaleCentered") and not MapOption("AllScalesCentered"):
            if not MapOption("AxisXYZ"):
                Xviewcenter = 16
            else:
                Xviewcenter = 48
        else:
            Xgroups = Xgroups / 2
            if not MapOption("All2DviewsScale") and not MapOption("YviewScale"):
                Xviewcenter = (Xpixels/2)+4
            else:
                Xviewcenter = 0
        if not MapOption("YzScaleCentered") and not MapOption("AllScalesCentered"):
            Zviewcenter = (Zpixels)-12
        else:
            Zgroups = Zgroups / 2
            Zviewcenter = (Zpixels/2)-4


        Xgroup1 = Xviewcenter+2
        Zgroup1 = Zviewcenter
        Xstring = quarkx.ftos(0)
        Zstring = quarkx.ftos(0)
        cv.textout(Xviewcenter, 2, "X " + Xstring)
        cv.textout(Xviewcenter, 16, "  |")      # for mark line
        if MapOption("RedLines2") and not MapOption("AllScalesCentered") and not MapOption("YzScaleCentered"):
            cv.textout(10, Zviewcenter, " Z " + Zstring + " --")
        else:
            cv.textout(0, Zviewcenter, " Z " + Zstring + " --")

        Ztotal = 0
        for Zcounter in range(1, int(Zgroups)):
            Ztotal = Ztotal + Zgroupsize
            Zstring = quarkx.ftos(Ztotal)
            Znextgroupup = Zgroup1 - (Zgrouppixels * Zcounter)
            cv.textout(0, int(Znextgroupup), " " + Zstring + " --")
            if MapOption("YzScaleCentered") or MapOption("AllScalesCentered"):
                Znextgroupdown = Zgroup1 + (Zgrouppixels * Zcounter)
                cv.textout(0, int(Znextgroupdown), "-" + Zstring + " --")

        Xtotal = 0
        for Xcounter in range(1, int(Xgroups)):
            Xtotal = Xtotal + Xgroupsize
            Xstring = quarkx.ftos(Xtotal)
            if MapOption("YxScaleCentered") or MapOption("AllScalesCentered"):
                Xnextgroupleft = Xgroup1 - (Xgrouppixels * Xcounter)
                cv.textout(int(Xnextgroupleft)-2, 2, "-" + Xstring)
                cv.textout(int(Xnextgroupleft)-2, 16, "  |") # new for line
            Xnextgroupright = Xgroup1 + (Xgrouppixels * Xcounter)
            cv.textout(int(Xnextgroupright)+4, 2, Xstring)
            cv.textout(int(Xnextgroupright)-2, 16, "  |")  # for mark line

# ===============
# Z view settings
# ===============

    elif type == "XY":

        if not MapOption("All2DviewsScale") and not MapOption("AllScalesCentered") and not MapOption("ZviewScale") and not MapOption("ZxScaleCentered") and not MapOption("ZyScaleCentered"):
            return

        cv.brushstyle = BS_CLEAR
        cv.fontname = "Terminal"
        cv.fontcolor = RED
        cv.fontsize = 8

        Xpixels, Ypixels = view.clientarea
        highlight = int(quarkx.setupsubset(SS_MAP, "Display")["GridHighlight"])
        Xgroupsize = grid * highlight
        Ygroupsize = grid * highlight
        Xgrouppixels = Xgroupsize * view.scale()
        Ygrouppixels = Ygroupsize * view.scale()
        Xgroups = Xpixels / Xgrouppixels
        Ygroups = Ypixels / Ygrouppixels
        while Xgroups < 4.0: #Not enough groups
            Xgroupsize = Xgroupsize / 2
            Xgrouppixels = Xgrouppixels / 2
            Xgroups = Xgroups * 2
        while Xgrouppixels < 40: #Too close together
            Xgroupsize = Xgroupsize * 2
            Xgrouppixels = Xgrouppixels * 2
            Xgroups = Xgroups / 2
        while Ygroups < 4.0: #Not enough groups
            Ygroupsize = Ygroupsize / 2
            Ygrouppixels = Ygrouppixels / 2
            Ygroups = Ygroups * 2
        while Ygrouppixels < 20: #Too close together
            Ygroupsize = Ygroupsize * 2
            Ygrouppixels = Ygrouppixels * 2
            Ygroups = Ygroups / 2


        if not MapOption("ZxScaleCentered") and not MapOption("AllScalesCentered"):
            if not MapOption("AxisXYZ"):
                Xviewcenter = 16
            else:
                Xviewcenter = 48
        else:
            Xgroups = Xgroups / 2
            if not MapOption("All2DviewsScale") and not MapOption("ZviewScale"):
                Xviewcenter = (Xpixels/2)+4
            else:
                Xviewcenter = 0
        if not MapOption("ZyScaleCentered") and not MapOption("AllScalesCentered"):
            Yviewcenter = (Ypixels)-12
        else:
            Ygroups = Ygroups / 2
            Yviewcenter = (Ypixels/2)-4


        Xgroup1 = Xviewcenter+2
        Ygroup1 = Yviewcenter
        Xstring = quarkx.ftos(0)
        Ystring = quarkx.ftos(0)
        cv.textout(Xviewcenter, 2, "X " + Xstring)
        cv.textout(Xviewcenter, 16, "  |")      # new for mark line
        if not MapOption("AllScalesCentered") and not MapOption("ZyScaleCentered"):
            cv.textout(10, Yviewcenter, " Y " + Ystring + " --") # for mark line
        else:
            cv.textout(0, Yviewcenter, " Y " + Ystring + " --")  # for mark line

        Ytotal = 0
        for Ycounter in range(1, int(Ygroups)):
            Ytotal = Ytotal + Ygroupsize
            Ystring = quarkx.ftos(Ytotal)
            Ynextgroupup = Ygroup1 - (Ygrouppixels * Ycounter)
            cv.textout(0, int(Ynextgroupup), " " + Ystring + " --")
            if MapOption("ZyScaleCentered") or MapOption("AllScalesCentered"):
                Ynextgroupdown = Ygroup1 + (Ygrouppixels * Ycounter)
                cv.textout(0, int(Ynextgroupdown), "-" + Ystring + " --")

        Xtotal = 0
        for Xcounter in range(1, int(Xgroups)):
            Xtotal = Xtotal + Xgroupsize
            Xstring = quarkx.ftos(Xtotal)
            if MapOption("ZxScaleCentered") or MapOption("AllScalesCentered"):
                Xnextgroupleft = Xgroup1 - (Xgrouppixels * Xcounter)
                cv.textout(int(Xnextgroupleft)-2, 2, "-" + Xstring)
                cv.textout(int(Xnextgroupleft)-2, 16, "  |")      # for mark line
            Xnextgroupright = Xgroup1 + (Xgrouppixels * Xcounter)
            cv.textout(int(Xnextgroupright)+4, 2, Xstring)
            cv.textout(int(Xnextgroupright)-2, 16, "  |")     # for mark line

    else:
       return

#
# Now set our new function as the finishdrawing method.
#

quarkpy.mapeditor.MapEditor.finishdrawing = gridfinishdrawing


# ********* This creates the Options menu 2D grid items ***************


def All2DviewsClick(m):
    editor = mapeditor()
    if not MapOption("All2DviewsScale"):
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XyScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XzScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YxScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YzScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZxScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZyScaleCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
    editor.invalidateviews()

def All2DviewsScalesCentered(m):
    editor = mapeditor()
    if not MapOption("AllScalesCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XzScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XyScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YxScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YzScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZxScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZyScaleCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    editor.invalidateviews()

def XviewScaleClick(m):
    editor = mapeditor()
    if not MapOption("XviewScale"):
        quarkx.setupsubset(SS_MAP, "Options")['XviewScale'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['XyScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['XzScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['XviewScale'] = None
    editor.invalidateviews()

def XviewYScaleCentered(m):
    editor = mapeditor()
    if not MapOption("XyScaleCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['XyScaleCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['XviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['XyScaleCentered'] = None
    editor.invalidateviews()

def XviewZScaleCentered(m):
    editor = mapeditor()
    if not MapOption("XzScaleCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['XzScaleCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['XviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['XzScaleCentered'] = None
    editor.invalidateviews()

def YviewScaleClick(m):
    editor = mapeditor()
    if not MapOption("YviewScale"):
        quarkx.setupsubset(SS_MAP, "Options")['YviewScale'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['YxScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['YzScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['YviewScale'] = None
    editor.invalidateviews()

def YviewXScaleCentered(m):
    editor = mapeditor()
    if not MapOption("YxScaleCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['YxScaleCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['YviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['YxScaleCentered'] = None
    editor.invalidateviews()

def YviewZScaleCentered(m):
    editor = mapeditor()
    if not MapOption("YzScaleCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['YzScaleCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['YviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['YzScaleCentered'] = None
    editor.invalidateviews()

def ZviewScaleClick(m):
    editor = mapeditor()
    if not MapOption("ZviewScale"):
        quarkx.setupsubset(SS_MAP, "Options")['ZviewScale'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['ZxScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['ZyScaleCentered'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['ZviewScale'] = None
    editor.invalidateviews()

def ZviewXScaleCentered(m):
    editor = mapeditor()
    if not MapOption("ZxScaleCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['ZxScaleCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['ZviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['ZxScaleCentered'] = None
    editor.invalidateviews()

def ZviewYScaleCentered(m):
    editor = mapeditor()
    if not MapOption("ZyScaleCentered"):
        quarkx.setupsubset(SS_MAP, "Options")['ZyScaleCentered'] = "1"
        quarkx.setupsubset(SS_MAP, "Options")['ZviewScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['All2DviewsScale'] = None
        quarkx.setupsubset(SS_MAP, "Options")['AllScalesCentered'] = None
    else:
        quarkx.setupsubset(SS_MAP, "Options")['ZyScaleCentered'] = None
    editor.invalidateviews()




def View2DgridMenu(editor):

    X0 = quarkpy.qmenu.item("All 2D views", All2DviewsClick, "|All 2D views:\n\nIf this menu item is checked, it will display a scale of the current grid setting in all 2D views and deactivate this menu's individual items.|intro.mapeditor.menu.html#optionsmenu")

    X1 = quarkpy.qmenu.item("   all scales centered", All2DviewsScalesCentered, "|all scales centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in all 2D views and deactivate this menu's individual items.|intro.mapeditor.menu.html#optionsmenu")

    X2 = quarkpy.qmenu.item("X-Back 2D view", XviewScaleClick, "|X-Back 2D view:\n\nIf this menu item is checked, it will display a scale of the current grid setting in the ' X - Back ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X3 = quarkpy.qmenu.item("   y scale centered", XviewYScaleCentered, "|y scale centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in the ' X - Face ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X4 = quarkpy.qmenu.item("   z scale centered", XviewZScaleCentered, "|z scale centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in the ' X - Face ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X5 = quarkpy.qmenu.item("Y-Side 2D view", YviewScaleClick, "|Y-Side 2D view:\n\nIf this menu item is checked, it will display a scale of the current grid setting in the ' Y-Side ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X6 = quarkpy.qmenu.item("   x scale centered", YviewXScaleCentered, "|x scale centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in the ' Y-Side ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X7 = quarkpy.qmenu.item("   z scale centered", YviewZScaleCentered, "|z scale centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in the ' Y-Side ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X8 = quarkpy.qmenu.item("Z-Top 2D view", ZviewScaleClick, "|Z-Top 2D view:\n\nIf this menu item is checked, it will display a scale of the current grid setting in the ' Z-Top ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X9 = quarkpy.qmenu.item("   x scale centered", ZviewXScaleCentered, "|x scale centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in the ' Z-Top ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")

    X10 = quarkpy.qmenu.item("   y scale centered", ZviewYScaleCentered, "|y scale centered:\n\nIf this menu item is checked, it will display a scale of the current grid setting centered in the ' Z-Top ' 2D view and deactivate this menu's conflicting item(s) such as  'All 2D views'  if they are currently checked.|intro.mapeditor.menu.html#optionsmenu")


    menulist = [X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10]

    items = menulist
    X0.state = quarkx.setupsubset(SS_MAP,"Options").getint("All2DviewsScale")
    X1.state = quarkx.setupsubset(SS_MAP,"Options").getint("AllScalesCentered")
    X2.state = quarkx.setupsubset(SS_MAP,"Options").getint("XviewScale")
    X3.state = quarkx.setupsubset(SS_MAP,"Options").getint("XyScaleCentered")
    X4.state = quarkx.setupsubset(SS_MAP,"Options").getint("XzScaleCentered")
    X5.state = quarkx.setupsubset(SS_MAP,"Options").getint("YviewScale")
    X6.state = quarkx.setupsubset(SS_MAP,"Options").getint("YxScaleCentered")
    X7.state = quarkx.setupsubset(SS_MAP,"Options").getint("YzScaleCentered")
    X8.state = quarkx.setupsubset(SS_MAP,"Options").getint("ZviewScale")
    X9.state = quarkx.setupsubset(SS_MAP,"Options").getint("ZxScaleCentered")
    X10.state = quarkx.setupsubset(SS_MAP,"Options").getint("ZyScaleCentered")

    return menulist


# ******************Creates the Popup menu********************

def ViewAmendMenu1click(m):
    editor = mapeditor(SS_MAP)
    if editor is None: return
    m.items = View2DgridMenu(editor)


GridMenuCmds = [quarkpy.qmenu.popup("Grid scale in 2D views", [], ViewAmendMenu1click, "|Grid scale in 2D views:\n\nThese functions allow you to display a scale of the current grid setting in any one, combination, or all of the 2D views of the Editor.", "intro.mapeditor.menu.html#optionsmenu")]
