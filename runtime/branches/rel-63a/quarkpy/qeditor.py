<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!-- saved from url=(0060)http://groups.yahoo.com/group/quark/files/PATCHES/qeditor.py -->
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=windows-1252">
<META content="MSHTML 5.50.4134.600" name=GENERATOR></HEAD>
<BODY><XMP>"""   QuArK  -  Quake Army Knife

Various constants and Screen Controls for editors.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$


import quarkx
import qtoolbar
import qmacro
import qmenu
from qutils import *
import math
import string

#qmacro.qeditor_loaded=1

pi2 = 2.0 * math.pi
epsilon = 0.00001
deg2rad = math.pi / 180.0
rad2deg = 180.0 / math.pi


# drawmap flags
DM_NORMAL      = 0
DM_GRAYOOV     = 1     # gray out of view
DM_HIDEOOV     = 2     # hide out of view
DM_MASKOOV     = DM_GRAYOOV | DM_HIDEOOV
DM_SELECTED    = 4     # draw as selected (solid and textured views only: alternate color is the 3rd parameter to drawmap)
DM_BACKGROUND  = 8     # draw only the object background, using the "darkcolor"
DM_OTHERCOLOR  = 16    # alternate color is the 3rd parameter to drawmap (default: the view's background color)
DM_BBOX        = 32    # bounding boxes
DM_DONTDRAWSEL = 64    # don't draw selected objects
DM_REDRAWFACES = 128   # draw faces (usually they are only drawn as part of a polyhedron, when the polyhedron is drawn)
DM_COMPUTEPOLYS= 256   # compute negative polyhedrons in textured views

# map view flags
MV_HSCROLLBAR   = 1
MV_VSCROLLBAR   = 2
MV_CROSSDRAG    = 4    # the mouse cursor turns into a cross when you drag
MV_AUTOFOCUS    = 8    # focused simply by moving the mouse over it
MV_NOSCROLLBAR  = 16   # overrides the settings of flags 1 and 2
MV_TOPREDLINE   = 32   # display the top red line
MV_BOTTOMREDLINE= 64   # display the bottom red line

texturedmodes = ("tex", "opengl")    # textured modes for map views

# explorer flags
EF_AUTOFOCUS    = 8    # see MV_AUTOFOCUS
EF_NOKEYBDELAY  = 16   # no delay between movements in the tree from the keyboard and screen updates

# dataform flags
DF_LOCAL        = 1    # prevents screen flashes if changes in this box don't affect anything else
DF_AUTOFOCUS    = 8    # see MV_AUTOFOCUS

# drawgrid flags
DG_LINES            = 0x10000      # lines instead of dots
DG_ONLYHIGHLIGHTED  = 0x20000      # omit the non-highlighted dots and draw the other ones using the 1st color instead

# onmouse and onkey flags (for MapView objects)
MB_SHIFT        = 1
MB_ALT          = 2
MB_CTRL         = 4
MB_LEFTBUTTON   = 8
MB_RIGHTBUTTON  = 16
MB_MIDDLEBUTTON = 32
MB_DOUBLECLICK  = 64
MB_CLICKED      = 256
MB_DRAGSTART    = 512
MB_DRAGGING     = 1024
MB_DRAGEND      = 2048
MB_KEYDOWN      = 4096
MB_KEYUP        = 8192
MB_MOUSEMOVE    = 16384

MB_NOGRID       = 65536
MB_REDIMAGE     = MB_DRAGGING|MB_CTRL


# mouse cursors
CR_CROSSH      = 8
CR_LINEARV     = 9
CR_LEFTARROW   = 10
CR_RIGHTARROW  = 11
CR_DEFAULT     = 0
CR_NONE        = -1
CR_ARROW       = -2
CR_CROSS       = -3
CR_IBEAM       = -4
CR_SIZE        = -5
CR_SIZENESW    = -6
CR_SIZENS      = -7
CR_SIZENWSE    = -8
CR_SIZEWE      = -9
CR_UPARROW     = -10
CR_HOURGLASS   = -11
CR_DRAG        = -12
CR_NODROP      = -13
CR_HSPLIT      = -14
CR_VSPLIT      = -15
CR_MULTIDRAG   = -16
CR_SQLWAIT     = -17
CR_NO          = -18
CR_APPSTART    = -19
CR_HELP        = -20

# brush styles
BS_SOLID       = 0
BS_CLEAR       = 1
BS_HORIZONTAL  = 2
BS_VERTICAL    = 3
BS_FDIAGONAL   = 4
BS_BDIAGONAL   = 5
BS_CROSS       = 6
BS_DIAGCROSS   = 7

# pen styles
PS_SOLID       = 0
PS_DASH        = 1
PS_DOT         = 2
PS_DASHDOT     = 3
PS_DASHDOTDOT  = 4
PS_CLEAR       = 5
PS_INSIDEFRAME = 6



def ftoss(f):
    "Turns a signed float into a string."
    if f<=0:
        return quarkx.ftos(f)
    else:
        return "+"+quarkx.ftos(f)

def vtohint(v):
    "Turns a signed vector into a string."
    return "dragging  " + ftoss(v.x)+" "+ftoss(v.y)+" "+ftoss(v.z)


def mouseflags(flags):
    "Returns a string with the mouse button name and the Drag, Shift or Ctrl state."
    if flags & MB_RIGHTBUTTON:
        if flags & MB_LEFTBUTTON:
            s = "Middle"
        else:
            s = "Right"
    else:
        if flags & MB_MIDDLEBUTTON:
            s = "Middle"
        else:
            s = "Left"
    if flags & MB_DRAGSTART:
        s = s + "Drag"
    if flags & MB_CTRL:
        s = s + "Ctrl"
    elif flags & MB_SHIFT:
        s = s + "Shift"
    return s


def MiddleDepth(view):
    "Returns a mean depth for the current mode of the map view."
    min, max = view.depth
    return (min+max)*0.5

#
# The coordinate axes
#

X_axis = quarkx.vect(1,0,0)
Y_axis = quarkx.vect(0,1,0)
Z_axis = quarkx.vect(0,0,1)


#
# Standard Matrix computation
#
def matrix_rot_z(rad):
    sin, cos = math.sin(rad), math.cos(rad)
    return quarkx.matrix(
       (cos, -sin, 0),
       (sin,  cos, 0),
       ( 0 ,   0,  1))

def matrix_rot_x(rad):
    sin, cos = math.sin(rad), math.cos(rad)
    return quarkx.matrix(
       (1,  0,    0 ),
       (0, cos, -sin),
       (0, sin,  cos))

def matrix_rot_y(rad):
    sin, cos = math.sin(rad), math.cos(rad)
    return quarkx.matrix(
       (cos, 0, -sin),
       (0,   1,   0 ),
       (sin, 0,  cos))

def matrix_sym(coord):    # coord = 'x', 'y' or 'z'
    return quarkx.matrix(
       ((1,-1)[coord=='x'], 0, 0),
       (0, (1,-1)[coord=='y'], 0),
       (0, 0, (1,-1)[coord=='z']))

def matrix_zoom(f):
    return quarkx.matrix(
       (f, 0, 0),
       (0, f, 0),
       (0, 0, f))

def matrix_xy_view(scale):    # matrix for XY view
    return quarkx.matrix(
       (scale, 0, 0),
       (0, -scale, 0),
       (0, 0, -scale))

def matrix_xz_view(scale):    # matrix for XZ view
    return quarkx.matrix(
       (scale, 0, 0),
       (0, 0, -scale),
       (0, scale, 0))

def matrix_yz_view(scale):    # matrix for YZ view
    return quarkx.matrix(
       (0, -scale, 0),
       (0, 0, -scale),
       (scale, 0, 0))

viewtype = {"XY": matrix_xy_view,
            "XZ": matrix_xz_view,
            "YZ": matrix_yz_view,
            "2D": matrix_xz_view}

#
# "setprojmode" updates the display of a map view based on the
# view's "info" dictionnary.
#

def setprojmode(view):
    "Update the projection set based on attributes in 'view.info'."
    #
    # Some views require a custom function to do this.
    #
    try:
        spm1 = view.info["custom"]     # custom version of setprojmode
    except KeyError:
        spm1 = defsetprojmode          # default version
    spm1(view)


def defsetprojmode(view):
    #
    # Default behaviour for setprojmode.
    #
    if view.info["type"]=="3D":
        #
        # 3D view
        #
        view.setprojmode("3D")
    else:
        #
        # 2D view : compute the matrix based on "type", "angle", "vangle", and "scale".
        #
        #matrix = matrix_rot_x(view.info["vangle"]) * viewtype[view.info["type"]](view.info["scale"]) * matrix_rot_z(view.info["angle"])
        matrix = viewtype[view.info["type"]](view.info["scale"]) * matrix_rot_x(view.info["vangle"]) * matrix_rot_z(view.info["angle"])
        view.setprojmode("2D", matrix)


def setviews(list, attr, value):
    "Update a projection attribute for all views in 'list'."
    nothing = 1
    for view in list:
        try:
            if view.info[attr] != value:
                #
                # Change the attribute
                #
                view.info[attr] = value
                #
                # Update the display
                #
                setprojmode(view)
                nothing = 0

        except KeyError:
            pass

    if nothing:
        return
    #
    # Maybe there is a callback function to be called when
    # this attribute is modified.
    #
    try:
        callback = list[0].info["onset"+attr]
    except KeyError:
        return    # no callback found
    #
    # Call the callback function.
    #
    callback(list[0])



def orthogonalvect(vect, view=None):
    "Returns a normalized vector orthogonal to the given one and horizontal."
    v = quarkx.vect(-vect.y, vect.x, 0)
    #
    # If vect was vertical, v will be zero. Otherwise, we can return v.
    #
    if v: return v.normalized
    #
    # vect was vertical, so any horizontal vector will do.
    #
    try:
        angle = -view.info["angle"]    # preferentially use the view's "angle"
    except:
        angle = 0       # if view is None, or if view has no "angle", use a default value
    return quarkx.vect(math.cos(angle), math.sin(angle), 0)

def bestaxes(n, view=None):
  v1 = orthogonalvect(n, view)
  v2 = (n^v1).normalized
  return v1, v2



def Arrow(canvas, view, p1, p2, text=None):
    "Draws an arrow from the 3D point p1 to the 3D point p2."

    pp2 = view.proj(p2)
    canvas.line(view.proj(p1), pp2)
    p3 = p2-p1
    if p3:
        p3 = p3.normalized
        eye = view.vector(p2).normalized   # vector from p2 pointing to the eye
        arrowx, arrowy = quarkx.setupsubset(SS_MAP, "Display")["ArrowSize"]
        p4 = arrowy*(eye ^ p3)    # cross product
        p5 = p2 - arrowx*p3
        canvas.line(pp2, view.proj(p5+p4))
        canvas.line(pp2, view.proj(p5-p4))


def quakecolor(v):     # v must be vector (x,y,z for color components)
    v = v*255.0
    return quarkx.rnd(v.x) | (quarkx.rnd(v.y)<<8) | (quarkx.rnd(v.z)<<16)

def colorquake(i):     # i must be a color as an integer
    v = quarkx.vect(i & 255, (i>>8) & 255, (i>>16) & 255)
    return v/255.0

def makeRGBcolor(r,g,b):
    return quarkx.rnd(r) | (quarkx.rnd(g)<<8) | (quarkx.rnd(b)<<16)

def readfloats(s):     # reads a space-separated string of floats
    try:
        return map(float, string.split(s))
    except:
        return []


def AutoZoom(views, bbox, margin=(20,18), scale1=1.0):
    "Computes the best scale and center point for 'views' relative to the bounding box 'bbox'."
    if bbox is None: return None, None
    bmin, bmax = bbox
    box1 = []     # all 8 corners of the bounding box
    for x in (bmin.x,bmax.x):
        for y in (bmin.y,bmax.y):
            for z in (bmin.z,bmax.z):
                box1.append(quarkx.vect(x,y,z))
    # scale1 = 1.0
    for v in views:
        if v.info["type"]!="3D":
            bx1=by1=bx2=by2=None
            for b in box1:
                p = v.proj(b)
                if (bx1 is None) or (p.x<bx1): bx1=p.x
                if (by1 is None) or (p.y<by1): by1=p.y
                if (bx2 is None) or (p.x>bx2): bx2=p.x
                if (by2 is None) or (p.y>by2): by2=p.y
            scale = v.info["scale"]
            #print v.redlinesrect, scale, bx1, by1, bx2, by2
            x1,y1,x2,y2 = v.redlinesrect
            if bx2-bx1>0.1:
                bx = scale * (x2-x1-margin[0])/(bx2-bx1)
                if bx>0.01 and bx<scale1: scale1=bx
            if by2-by1>0.1:
                by = scale * (y2-y1-margin[1])/(by2-by1)
                if by>0.01 and by<scale1: scale1=by
    return scale1, (bmin+bmax)*0.5


def commonscale(views):
    "Returns the scale common to all the 'views', or 0 otherwise."
    scale = 0
    for v in views:
        if v.info["type"]!="3D":
            scale1=v.info["scale"]
            if scale==0:
                scale = scale1
            elif scale!=scale1:
                return 0
    return scale


#
# Dialog boxes
#

class SimpleCancelDlgBox(qmacro.dialogbox):
    "A simple dialog box with only a Cancel button."

    def __init__(self, form, src):
        qmacro.dialogbox.__init__(self, form, src,
          cancel = qtoolbar.button(self.cancel, "close this box", ico_editor, 0, "Cancel"))

    def cancel(self, m):
        self.src = None
        self.close()

    def datachange(self, df):
        self.close()   # "OK" is automatic when the user changed the data.

    def onclose(self, dlg):
        if self.src is not None:
            self.ok()
        qmacro.dialogbox.onclose(self, dlg)



class XYZDialog(SimpleCancelDlgBox):
    "A simple dialog box to enter a x, y, z vector."

    endcolor = AQUA
    size = (330,120)
    dfsep = 0.45
    dlgdef = """
      {
        Style = "9"
        Caption = "Enter position"
        sep: = {Typ="S" Txt=" "}    // some space
        pos: = {
          Txt=" Enter the new position :"
          Typ="EF3"
          SelectMe="1"
        }
        sep: = {Typ="S" Txt=" "}    // some space
        sep: = {Typ="S" Txt=""}    // a separator line
        cancel:py = {Txt="" }
      }
    """

    def __init__(self, form, onchange, initialvalue=None):
        src = quarkx.newobj(":")
        if initialvalue is not None:
            src["pos"] = initialvalue.tuple
        SimpleCancelDlgBox.__init__(self, form, src)
        self.onchange = onchange

    def ok(self):
        pos = self.src["pos"]
        if pos is not None:
            self.onchange(quarkx.vect(pos))



class CustomGridDlgBox(SimpleCancelDlgBox):
    "The Custom Grid dialog box."

    #
    # Dialog box shape
    #

    endcolor = SILVER
    size = (300,120)
    dlgdef = """
      {
        Style = "9"
        Caption = "Custom grid step"
        sep: = {Typ="S" Txt=" "}    // some space
        gridstep: = {
          Txt=" Enter the grid step :"
          Typ="EF1"
          Min='0'
          SelectMe="1"       // WARNING: be careful when using this
        }
        sep: = {Typ="S" Txt=" "}    // some space
        sep: = {Typ="S" Txt=""}    // a separator line
        cancel:py = {Txt="" }
      }
    """

    def __init__(self, form, src, editor):
        SimpleCancelDlgBox.__init__(self, form, src)
        self.editor = editor

    def ok(self):
        #
        # The user entered a new value...
        #
        grid = self.src["gridstep"]
        if grid is not None:
            #
            # Update the grid step in the editor.
            #
            if (self.editor.grid == grid[0]) and (self.editor.gridstep == grid[0]):
                return
            self.editor.grid = self.editor.gridstep = grid[0]
            self.editor.gridchanged()


def CustomGrid(editor):
    "Displays the Custom Grid dialog box."

    src = quarkx.newobj(":")   # new object to store the data displayed in the dialog box
    src["gridstep"] = editor.gridstep,
    CustomGridDlgBox(editor.form, src, editor)



class CustomZoomDlgBox(SimpleCancelDlgBox):
    "Custom Zoom Dialog Box."

    #
    # Dialog box shape
    #

    endcolor = LIME
    size = (300,186)
    dlgdef = """
      {
        Style = "9"
        Caption = "Custom zoom"
        sep: = {Typ="S" Txt=" "}    // some space
        zoom: = {
          Txt=" Enter the zoom factor :"
          Typ="EF1"
          Min='0.02'
          Max='100'
          SelectMe="1"       // WARNING: be careful when using this
        }
        sep: = {Typ="S" Txt=" "}    // some space
        info: = {Typ="S" Bold="0" Txt="Note that the middle mouse button can be used to"}
        info: = {Typ="S" Bold="0" Txt="zoom in and out. With a 2-buttons mouse, hold"}
        info: = {Typ="S" Bold="0" Txt="down the shift key and use the right button,"}
        info: = {Typ="S" Bold="0" Txt="or press and hold down both buttons together."}
        //sep: = {Typ="S" Txt=" "}    // some space
        sep: = {Typ="S" Txt=""}    // a separator line
        cancel:py = {Txt="" }     // the cancel button
      }
    """

    def __init__(self, form, src, views):
        SimpleCancelDlgBox.__init__(self, form, src)
        self.views = views

    def ok(self):
        #
        # The user changed the zoom factor...
        #
        scale = self.src["zoom"]
        if scale is not None:
            #
            # Update it in all views.
            #
            setviews(self.views, "scale", scale[0])


def CustomZoom(views):
    "Display the Custom Zoom dialog box."

    src = quarkx.newobj(":")   # new object to store the data displayed in the dialog box
    scale = commonscale(views)
    if scale!=0:
        src["zoom"] = (scale,)
    CustomZoomDlgBox(quarkx.clickform, src, views)


def getzoommenu(zoombtn):
    def zoomclick(m, views=zoombtn.views):
        setviews(views, "scale", m.scale)
    def customzoom(m, views=zoombtn.views):
        CustomZoom(views)
    if zoombtn.near:
        # For mdl-editor
        zoomlist = (( 0.5, "1:2\tfar away"),
                    ( 1.0, "1:1\tone for one"),
                    ( 2.0, "2:1\tmiddle"),
                    ( 4.0, "4:1\tnear"),
                    ( 8.0, "8:1\tnearer"),
                    (16.0, "16:1\tnearest"))
    else:
        # For map-editor
        zoomlist = (( 0.1,  "1:10\tvery far away"),
                    ( 0.25, "1:4\tfar away"),
                    ( 0.5,  "1:2\tmiddle"),
                    ( 1.0,  "1:1\tnear"),
                    ( 2.0,  "2:1\tnearer"),
                    (10.0,  "10:1\tmegazoom"))
    scale = commonscale(zoombtn.views)
    items = []
    otherstate = qmenu.radiocheck
    for s,txt in zoomlist:
        m = qmenu.item(txt, zoomclick)
        m.scale = s
        if s==scale:
            m.state = qmenu.radiocheck
            otherstate = 0
        items.append(m)
    items.append(qmenu.sep)
    m = qmenu.item("(%.2f)\tOther..." % scale, customzoom)
    m.state = otherstate
    items.append(m)
    return items


def notimplemented(*any):
    quarkx.msgbox("This command is not implemented yet.", MT_ERROR, MB_OK)


#def foreachcontrol(callback):
#    def test(panel, callback=callback):
#        for c in panel.controls():
#            callback(c)
#            if type(c)==quarkx.panel_type:
#                test(c)
#    if quarkx.clickform is not None:
#        test(quarkx.clickform.mainpanel)


#
# Common Editor objects
#

def ImageWrapper(self, desc, *extra):
    try:
        self.Images = apply(LoadPoolObj, (desc, quarkx.loadimages) + extra)
        return 1
    except:
        quarkx.msgbox("QuArK ran out of system resources loading the file '%s'. The %s will not be displayed." % (extra[0], desc),
          MT_ERROR, MB_OK)


class Compass:
    "Wrapper for a compass ImageCtrl."

    def __init__(self, views, panel, result=None):
        self.views = views
        self.angle = 0
        self.i = 0     # index of the image to display
        if ImageWrapper(self, "compass", "images\\compass.bmp", 96):
            self.ctrl = panel.newimagectrl(self.Images[0])
            self.ctrl.onclick = self.CompassClick
            self.ctrl.hint = "Rotate the views||The Compass lets you rotate the map views and view your map from any angle. This is why QuArK displays only two views by default, and not three, unlike most other 3D editors.\n\nSee the Layouts menu for other screen layouts. See the configuration dialog box to show or hide the angle and axis indications."
            if result is not None:
                result.append(self.ctrl)
        else:
            self.ctrl = None

    def CompassClick(self, ctrl, x, y, flags):

        #
        # Recenter the user click
        #

        x = x - 48
        y = 48 - y
        if x*x + y*y > 10:

            #
            # Compute the image index corresponding to the mouse click.
            #

            imgcount = len(self.Images)
            i = int((math.atan2(y,x) * imgcount / pi2 + 0.5) % imgcount)

            #
            # Compute the corresponding angle.
            #

            angle1 = i*pi2/imgcount
            if angle1 != self.angle:

                # Animate the Compass.

                start = 0
                if (i-self.i)%imgcount <= imgcount/2:
                    #
                    # Counterclockwise
                    #
                    while i != self.i:
                        self.i = (self.i + 1) % imgcount   # next image
                        start = quarkx.wait(10, start)
                        ctrl.image = self.Images[self.i]
                else:
                    #
                    # Clockwise
                    #
                    while i != self.i:
                        self.i = (self.i - 1) % imgcount   # next image
                        start = quarkx.wait(10, start)
                        ctrl.image = self.Images[self.i]

                #
                # Update the map views with the new angle.
                #

                self.Update(angle1)
                setviews(self.views, 'angle', self.angle)

        return 1    # to CompassClick again if dragging


    def Update(self, angle1):
        #
        # Update the compass based on the required angle.
        #
        if self.ctrl is None:
            return
        self.angle = angle1
        try:
            imgcount = len(self.Images)
        except:
            return
        i = quarkx.rnd(angle1*imgcount/pi2) % imgcount
        if i!=self.i:
            self.i = i
            self.ctrl.image = self.Images[self.i]


    def AngleChanged(self, view):
        "Called when the angle of the map views changed for any reason."
        self.Update(view.info["angle"])

    def setupchanged(self, mode):
        if self.ctrl is None:
            return
        if MapOption("CompassNumbers", mode):
            self.ctrl.ondraw = self.DrawAngles
        else:
            self.ctrl.ondraw = None
        self.ctrl.invalidate()

    def DrawAngles(self, ctrl):
        cv = ctrl.canvas()
        cv.transparent = 1
        angle1 = self.i*pi2/len(self.Images)
        dx, dy = 40*math.cos(angle1), 45*math.sin(angle1)
        def angle(x,y,s, cv=cv):
            size = cv.textsize(s)
            x = x - size[0]/2
            y = y - size[0]/2
            maxx = 95 - size[0]
            if x>maxx:
                x = maxx
            elif x<0:
                x = 0
            if y>82:
                y = 82
            elif y<0:
                y = 0
            cv.textout(x,y,s)
        cv.fontname = "Small Fonts"
        cv.fontsize = 5
        cv.fontcolor = 0xCCFCFB
        cv.fontname = "MS Serif"
        cv.fontbold = 1
        angle(48+0.46*dx, 48-0.46*dy, "X")
        angle(48-0.23*dy, 48-0.23*dx, "Y")
        cv.fontcolor = 0x2020B0
        cv.fontsize = 8
        angle(48+dx, 47-dy, "O")
        cv.fontcolor = BLACK
        angle(48-dy, 48-dx, "90")
        angle(48-dx, 48+dy, "180")
        angle(48+dy, 48+dx, "270")



class ZoomBar:
    "Wrapper for a zoom bar ImageCtrl."

    INITIALSCALE = 0.25
    CENTER       = 0.6
    PIXELSCALE   = 0.06

    def __init__(self, views, panel, mode=SS_MAP, result=None):
        if mode == SS_MODEL:
            self.INITIALSCALE = 2.0
            self.CENTER       = 3.0
        self.views = views
        self.scale = self.INITIALSCALE
        self.i = self.scale2i(self.scale)
        if ImageWrapper(self, "zoom bar", "images\\zoombar.bmp", 16, (16,0)):
            self.ctrl = panel.newimagectrl(self.Images[0])
            self.ctrl.onclick = self.ZoomClick
            self.ctrl.ondraw = self.ZoomDraw
            self.ctrl.hint = "Zoom in/out"
            if result is not None:
                result.append(self.ctrl)

    def i2scale(self, i):
        #
        # Computes the scale corresponding to the visual position i.
        #
        return math.exp(i*self.PIXELSCALE)*self.CENTER

    def scale2i(self, scale):
        #
        # Computes the visual position corresponding to the scale.
        #
        return quarkx.rnd(math.log(scale/self.CENTER)/self.PIXELSCALE)

    def clampi(self, i):
        #
        # Clamp 'i' to the valid interval.
        #
        if i<-38:  return -38
        if i>40:   return 40
        return i

    def ZoomClick(self, ctrl, x, y, flags):
        #
        # Mouse click, compute the required scale.
        #
        scale1 = self.i2scale(self.clampi(y-47))
        if self.scale != scale1:
            #
            # Update the map views with the new scale.
            #
            self.Update(scale1)
            setviews(self.views, 'scale', self.scale)

        return 1    # to ZoomClick again if dragging


    def Update(self, scale1):
        #
        # Compute the visual position corresponding to the new scale.
        #
        self.scale = scale1
        i = self.clampi(self.scale2i(scale1))
        if i!=self.i:
            #
            # Redraw if visually modified.
            #
            self.i = i
            try:
                self.ctrl.repaint()
            except:
                pass


    def ZoomDraw(self, ctrl):
        #
        # Draw the "handle" over the background image at the current location.
        #
        cv = ctrl.canvas()
        cv.draw(self.Images[1], 0, self.i)


    def ScaleChanged(self, view):
        "Called when the scale of the map views changed for any reason."
        self.Update(view.info["scale"])



class VBar:
    "Wrapper for a Vertical Angle bar ImageCtrl."

    ANGLEMAX = math.pi / 2
    SNAPANGLE = math.pi / 12

    def __init__(self, views, panel, result=None):
        self.views = views
        self.angle = 0
        self.i = 0
        self.middlei = 37
        if ImageWrapper(self, "vertical rotation bar", "images\\vbar.bmp", 36, (36,0)):
            self.ctrl = panel.newimagectrl(self.Images[0])
            self.ctrl.onclick = self.VBarClick
            self.ctrl.ondraw = self.VBarDraw
            self.ctrl.hint = "View up/down"
            if result is not None:
                result.append(self.ctrl)

    def i2angle(self, i):
        return i * self.ANGLEMAX / self.middlei

    def angle2i(self, angle):
        return angle * self.middlei / self.ANGLEMAX

    def clampi(self, y):
        if y > self.middlei:  return self.middlei
        if y < -self.middlei: return -self.middlei
        return y

    def VBarClick(self, ctrl, x, y, flags):
        y = self.clampi(y-48)
        angle1 = quarkx.rnd(self.i2angle(y)/self.SNAPANGLE)*self.SNAPANGLE
        if self.angle != angle1:
            self.Update(angle1)
            setviews(self.views, 'vangle', self.angle)
        return 1    # to VBarClick again if dragging

    def VBarDraw(self, ctrl):
        cv = ctrl.canvas()
        cv.draw(self.Images[1], 0, self.i)

    def Update(self, angle1):
        self.angle = angle1
        i = self.clampi(self.angle2i(angle1))
        if i!=self.i:
            self.i = i
            try:
                self.ctrl.repaint()
            except:
                pass

    def VAngleChanged(self, view):
        "Called when the vangle of the map views changed for any reason."
        self.Update(view.info["vangle"])


#
# A Multi-Pages Panel implements code to show and hide controls
# based on the page selected by the user.
#

class MultiPanesPanel:
    "Wrapper for a multi-pages panel."

    def __init__(self, panel, pagebtns, n):
        top = quarkx.setupsubset(SS_GENERAL, "Display")["MppTopBtns"]
        line = []
        lines = [line]
        pagebtns = pagebtns[:]
        for b in pagebtns[:]:
            if b is None:
                line = []
                lines.append(line)
                pagebtns.remove(None)
            else:
                b.n = pagebtns.index(b)
                b.onclick1 = b.onclick
                b.onclick = self.pagebtnclick
                b.onenddrag = self.pagebtnenddrag
                line.append(b)
        self.pagebtns = pagebtns
        if top:
            ntp = panel.newtoppanel
        else:
            ntp = panel.newbottompanel
       #   try:
       #      y = lines[0][0].icons[0].size[1]
       #  except:
       #      try:
       #          y = lines[0][0]._icons[0].size[1]
       #      except:
       #          y = 16
       #  ntp = ntp((y+7)*len(lines), 0)
        ntp = ntp(23*len(lines), 0)
        ntp.sections = ((), tuple(map(lambda i,f=-1.0/len(lines): i*f, range(1,len(lines)))))
        for i in range(len(lines)):
            line = lines[i]
            btp = ntp.newbtnpanel(line)
            btp.section = (0,i)
            btp.pagetabs = 2
            lines[i] = btp
        self.lines = lines
        self.btnpanel = btp
        if top:
            self.btnpanel.pagetabs = 1
        self.viewpage(n)

    def clear(self):
        self.pagebtns = []

    def viewpage(self, n, closefloating=0):
        self.n = n
        btn = self.pagebtns[n]
        if hasattr(btn, "floating") and closefloating:
            f = btn.floating
            del btn.floating
            f.onclose = None
            for c in btn.pc:
                c.hide()
                if c.parent is f.mainpanel:
                    c.parent = self.btnpanel.parent.parent
            f.close()
        self.resetpage()
        for c in btn.pc:
            c.show()
        btn.state = qtoolbar.selected
        for b in self.pagebtns:
            if b is not btn:
                if not hasattr(b, "floating"):
                    for c in b.pc:
                        c.hide()
                b.state = 0
        self.btnpanel.update()
        if not (btn in self.btnpanel.buttons):
            self.btnpanel.pagetabs = 2
            while 1:
                self.lines = self.lines[-1:] + self.lines[:-1]
                self.btnpanel = self.lines[-1]
                if btn in self.btnpanel.buttons:
                    break
            for i in range(len(self.lines)):
                self.lines[i].section = (0,i)
            self.btnpanel.pagetabs = 1
            self.btnpanel.update()

    def resetpage(self):
        btn = self.pagebtns[self.n]
        if btn.onclick1 is not None:
            btn.onclick1(btn)
        for b in self.pagebtns:
            if (b is not btn) and hasattr(b, "floating") and (b.onclick1 is not None):
                b.onclick1(b)

    def pagebtnclick(self, btn):
        self.viewpage(btn.n, 1)

    def currentpage(self):
        return self.pagebtns[self.n]

    def pagebtnenddrag(self, btn, x, y):
        if hasattr(btn, "floating"):
            btn.floating.close()
        f = self.btnpanel.owner.newfloating(0, btn.getcaption())
        basepanel = self.btnpanel.parent.parent
        w,h = basepanel.clientarea
        x = x-w/2
        f.windowrect = x, y-8, x+w+6, y+h-26

        def fclose(f, btn=btn, basepanel=basepanel, self=self):
            del btn.floating
            for c in btn.pc:
                c.hide()
                if c.parent is f.mainpanel:
                    c.parent = basepanel
            if self.n == btn.n:
                self.viewpage(btn.n, 0)

        f.onclose = fclose
        btn.floating = f
        for c in btn.pc:
            if c.parent is basepanel:
                c.parent = f.mainpanel
            c.show()
        self.resetpage()
        f.show()


#
# Objects that should be considered as folders and pop up menus and submenus :
#
foldertypes = ('.qtxfolder', '.wad', '.txlist')


class UserDataPanelButton(qtoolbar.button):
    "A ToolBar button that represents a map object that can be dragged and put into maps."

    def __init__(self, click, panel, udp, objectlist, hint, iconlist, iconindex):
        if (len(objectlist)==1) and (objectlist[0].type in foldertypes):
            self.menu = UDPBMenu
            self.click1 = click
            click = None
        qtoolbar.button.__init__(self, click, hint, iconlist, iconindex)
        self.udp = udp
        self.panel = panel
        self.dragobject = objectlist


def UDPBMenuO(onclick, parent):
    items = []
    for o in parent.subitems:
        s = quarkx.menuname(o.shortname)
        if o.type in foldertypes:
            #new = qmenu.popup(s, UDPBMenuO(onclick, o))
            new = qmenu.popup(s, [], UDPBSubMenu)
            new.ock = onclick
            new.p = o
        else:
            new = qmenu.item(s, onclick)
            new.dragobject = [o]
        new.menuicon = o.geticon(1)
        items.append(new)
    if items:
        return items
    new = qmenu.item("(empty)", None)
    new.state = qmenu.disabled
    return [new]


def UDPBSubMenu(item):
    item.items = UDPBMenuO(item.ock, item.p)

def UDPBMenu(self):
    return UDPBMenuO(self.click1, self.dragobject[0])



class UserDataPanel:
    "Wrapper for a panel that accepts user object drag and drops."

    def __init__(self, panel, hint, filename, sourcename, result=None):
        self.sourcename = sourcename
        self.filename = filename
        ud = LoadPoolObj(sourcename, quarkx.openfileobj, sourcename)
        self.objlist = ud.findname(filename).subitems
        btnpanel = panel.newbtnpanel()
        btnpanel.buttons = self.buildbuttons(btnpanel)
        btnpanel.info = self
        btnpanel.ondrop = self.objectdrop2
        btnpanel.hint = hint
        if result is not None:
            result.append(btnpanel)

    def btnclick(self, btn):
        pass   # abstract

    def needicons(self, list):
        icons = None
        for obj in list:
            ico0, ico1 = obj.geticon(0), obj.geticon(1)
            if icons is None:
                icons = ico0, ico1
            elif not (icons[0] is ico0 and icons[1] is ico1):
                icons = None
                break
        if icons is None:
            obj = quarkx.newobj('.qtxfolder')       # default icon
            icons = obj.geticon(0), obj.geticon(1)
        return icons

    def newbutton(self, p, btnpanel, icon=None):
        list = p.subitems
        if len(list)==1 and ("PixelSet" in list[0].classes):
            hint = "TEX?" + p.shortname + "|" + p.shortname
        else:
            hint = p.shortname
        if icon is None:
            icon = self.needicons(list)
        btn = UserDataPanelButton(self.btnclick, btnpanel, self, list, hint, icon, None)
        btn.p = p
        btn.ondrop = self.objectdrop1
        return btn

    def buildbuttons(self, btnpanel):
        # mapicons = LoadPoolObj("ico_usermap", LoadIconSet1, "usermap16", 1.0)
        Btns = []
        for p in self.objlist:
            Btns.append(self.newbutton(p, btnpanel))
        return Btns

    def objectdrop1(self, button, list, x, y, source):
        self.drop(button.panel, list, self.objlist.index(button.p), source)

    def objectdrop2(self, btnpanel, list, x, y, source):
        self.drop(btnpanel, list, len(self.objlist), source)

    def drop(self, btnpanel, list, i, source):
        ol = self.objlist
        for p in ol:
            if p.itemcount == len(list):
                for j in range(0, len(list)):
                    if p.subitem(j) is not list[j]:
                        break
                else:    # the user moves a button inside the panel
                    ol.remove(p)
                    ol.insert(i, p)
                    break
        else:  # drop a new button with the given objects
            if len(list):
                s = string.join(map(lambda obj: obj.shortname, list), ", ")
                p = quarkx.newobj(s + ":")
                for obj in list:
                    p.appenditem(obj.copy())
                ol.insert(i, p)
        btnpanel.buttons = self.buildbuttons(btnpanel)
        self.save()

    def deletebutton(self, btn):
        try:
            self.objlist.remove(btn.p)
        except:
            return
        btn.panel.buttons = self.buildbuttons(btn.panel)
        self.save()

    def save(self):
        file = LoadPoolObj(self.sourcename, quarkx.openfileobj, self.sourcename)
        ud = file.findname(self.filename)
        for i in range(ud.itemcount-1, -1, -1):
            ud.removeitem(i)
        for p in self.objlist:
            ud.appenditem(p)
        file.savefile()



#
# The base ToolBar class can be overridden to define new toolbars.
# Add the attribute "Caption" with the caption of the toolbar,
# and a method buildbuttons(self, layout) that is called to put
# the buttons on the toolbar.
#

class ToolBar:
    "Base class for tool bars."

    #
    # The default position and docking.
    # (floatingrect, dock, dockpos, dockrow, visible)
    #
    DefaultPos = ((0,0,0,0), "topdock", 1, 0, 1)

    def __init__(self, layout, form):
        self.tb = form.newtoolbar(self.Caption, self.buildbuttons(layout), 1)
    #     self.tb.onshowhide = self.visiblechanged
    #
    # def visiblechanged(self, tb, layout=None):
    #     try:
    #         btn = self.triggerbtn
    #         if layout is None:
    #             editor = mapeditor()
    #         else:
    #             editor = layout.editor
    #         btn = editor.layout.buttons[btn]
    #     except:
    #         return
    #     nstate = tb.visible and qtoolbar.selected
    #     if btn.state != nstate:
    #         btn.state = nstate
    #         quarkx.update(editor.form)


#
# Read and write toolbar position in the setup.
#

def readtoolbars(toolbars, layout, form, config):
    #if config is not None:
    #    config = config.findshortname("Toolbars")
    for cap, cls in toolbars.items():
        try:
            tb = layout.toolbars[cap]
        except KeyError:
            tb = cls(layout, form)
            layout.toolbars[cap] = tb
        if config is None:
            v = None
        else:
            v = config[cap]
        if v:
            v = eval(v)
        else:
            v = cls.DefaultPos
        tb = tb.tb
        tb.floatrect, tb.dock, tb.dockpos, tb.dockrow, tb.visible = v

def writetoolbars(layout, config):
    for cap, tb in layout.toolbars.items():
        tb = tb.tb
        config[cap] = `(tb.floatrect, tb.dock, tb.dockpos, tb.dockrow, tb.visible)`


#
# Functions to manage the "Toolbars" menu.
#

def tb1click(mnu):
    "View or hide the given toolbar."
    editor = mapeditor()
    if editor is None: return
    try:
        tb = editor.layout.toolbars[mnu.caption]
    except KeyError:
        return
    tb = tb.tb
    tb.visible = not tb.visible


def tools1click(mnu):
    "Set checks on the menu items that correspond to visible toolbars."
    editor = mapeditor()
    if editor is None: return
    for i in mnu.items:
        try:
            v = editor.layout.toolbars[i.caption].tb.visible
        except KeyError:
            v = 0
        i.state = v and qmenu.checked


def ToolsMenu(editor, toolbars):
    "The Tools menu, with its shortcuts."
    items = []
    for cap, cls in toolbars.items():
        i = qmenu.item(cls.Caption, tb1click)
        i.caption = cap
        items.append(i)
    return qmenu.popup("Tool&bars", items, tools1click), {}





#
# Icons for the layout of the Map/Model Editor
#
ico_dict['ico_maped'] = LoadIconSet1("maped", 1.0)
ico_mdled = LoadIconSet1("mdled", 1.0)
ico_dict['ico_mapedsm'] = LoadIconSet1("mapedsm", 0.5)    # small
ico_maped_y = ico_dict['ico_maped'][0][0].size[1] + 7


#
# Set the "Red lines" icons
#
quarkx.redlinesicons = (ico_dict['ico_maped'][0][5],
  ico_dict['ico_maped'][1][5], ico_dict['ico_maped'][2][5],
   ico_dict['ico_maped'][0][4], ico_dict['ico_maped'][1][4],
   ico_dict['ico_maped'][2][4])


#
# Functions to read common setup entries.
#

def MapColor(tag, mode=SS_MAP):
    return quarkx.setupsubset(mode, "Colors").getint(tag)

def MapOption(tag, mode=SS_MAP):
    return quarkx.setupsubset(mode, "Options")[tag]

def SetMapOption(tag, value=None, mode=SS_MAP):   # default is to toggle value
    setup = quarkx.setupsubset(mode, "Options")
    if value is None:
        value=not setup[tag]
    if value:
        setup[tag] = "1"
    else:
        setup[tag] = ""


def maptogglebtn(btn):
    "Toggles the state of a MapOption button."
    btn.state = btn.state ^ qtoolbar.selected
    quarkx.update()
    SetMapOption(btn.tag, btn.state & qtoolbar.selected, btn.mode)


def rectabs2rel(x1,y1,x2,y2):
    sx1,sy1,sx2,sy2 = quarkx.screenrect()
    return float(x1-sx1)/(sx2-sx1), float(y1-sy1)/(sy2-sy1), float(x2-sx1)/(sx2-sx1), float(y2-sy1)/(sy2-sy1)

def rectrel2abs(x1,y1,x2,y2):
    sx1,sy1,sx2,sy2 = quarkx.screenrect()
    return sx1+x1*(sx2-sx1), sy1+y1*(sy2-sy1), sx1+x2*(sx2-sx1), sy1+y2*(sy2-sy1)


#
# Call this to retrive to current map or model editor.
#

def mapeditor(mode=None):
    "The map editor from which we clicked a button or menu item."
    try:
        info = quarkx.clickform.info
    except:
        return None

    import qbaseeditor
    if not isinstance(info, qbaseeditor.BaseEditor):
        return None
    if (mode is None) or (mode == info.MODE):
        return info
    return None



def TexModeMenu(editor, view):
    "Menu items to set the textured mode of 'view'."

    def setviewmode(menu, editor=editor, view=view):
        view.viewmode = menu.mode
        editor.lastscale = 0    # force a call to buildhandles()

    if view.viewmode == "opengl":
        modhint = "the mode is fixed to OpenGL"
    else:
        import qbasemgr
        modhint = qbasemgr.ModesHint + "\n\nThe commands in this menu lets you select the mode for the view you right-clicked on. You can set the mode for all views at once in the 'Layouts' menu."
    Mod1 = qmenu.item("&Wireframe", setviewmode, modhint)
    Mod1.mode = "wire"
    Mod2 = qmenu.item("&Solid", setviewmode, modhint)
    Mod2.mode = "solid"
    Mod3 = qmenu.item("&Textured", setviewmode, modhint)
    Mod3.mode = "tex"
    List = [Mod1, Mod2, Mod3]
    for menu in List:
        if view.viewmode == "opengl":
            menu.state = qmenu.disabled
        else:
            menu.state = menu.mode==view.viewmode and qmenu.radiocheck
    return List


#
# Call this to open an HTML help document.
#
def htmldoc(doc):
    if not doc:
        flist = quarkx.getqctxlist()
        flist.reverse()
        for f in flist:
            doc = f["HTML"]
            if doc:
                break
        else:
            quarkx.msgbox("No help document available.", MT_ERROR, MB_OK)
            return
    if (doc[:7] == "http://" or doc[:7] == "HTTP://"):
        quarkx.htmldoc(doc)
    else:
        quarkx.htmldoc(quarkx.exepath + doc)



def Help1():
    editor = mapeditor()
    if (editor is None) or (editor.layout is None):
        htmldoc(None)
    else:
        editor.layout.helpbtnclick(None)

def Help2():
    htmldoc("help/index.html") # Assumes the infobase have been installed in the ./HELP folder

def Help3():
    htmldoc("help/intro.html") # Assumes the infobase have been installed in the ./HELP folder


#
# Retrieves all objects with a given type, excluding VF_CANTSELECT groups.
#

def FindSelectable(root, singletype=None, types=None):
    if types is None:
        types = (singletype,)
    result = []
    def fltr(o, result=result, types=types):
        if o.type in types:
            result.append(o)
            return 0
        try:
            return not (int(o[";view"]) & VF_CANTSELECT)
        except:
            return 1
    lst = [root]
    while lst:
        lst1 = []
        for o in lst:
            lst1 = lst1 + filter(fltr, o.subitems)
        lst = lst1
    return result

# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.10  2001/10/22 10:28:20  tiglari
#live pointer hunt, revise icon loading
#
#Revision 1.9  2001/08/07 23:37:09  tiglari
#X_, Y_, Z_, axis constants added
#
#Revision 1.8  2001/06/17 21:05:27  tiglari
#fix button captions
#
#Revision 1.7  2001/06/16 03:20:48  tiglari
#add Txt="" to separators that need it
#
#Revision 1.6  2001/03/02 19:35:02  decker_dk
#Changed Help2()/Help3() to direct to the infobase files.
#
#Revision 1.5  2001/01/26 19:06:35  decker_dk
#Better layout of zoom-list texts.
#
#Revision 1.4  2000/12/17 12:35:02  decker_dk
#- Changed [Quarkpy\qeditor] help3() to "help\\faq\\index.html", and some stuff to quarkx.htmldoc()
#
#Revision 1.3  2000/08/21 21:33:04  aiv
#Misc. Changes / bugfixes
#
#Revision 1.2  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#
</XMP></BODY></HTML>
