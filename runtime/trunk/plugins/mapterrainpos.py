
########################################################
#
#               Terrain Generator Dialogs Plugin
#
#
#                  by cdunde1@comcast.net
#     
#
#   You may freely distribute modified & extended versions of
#   this plugin as long as you give due credit to cdunde &
#   Rowdy. (It's free software, just like QuArK itself.)
#
##########################################################

Info = {
   "plug-in":       "Terrain Generator Dialogs",
   "desc":          "Terrain Generator Dialogs",
   "date":          "July 9, 2005",
   "author":        "cdunde and Rowdy",
   "author e-mail": "cdunde1@comcast.net",
   "quark":         "Version 6.4" }

import math
import quarkx
import quarkpy.dlgclasses
from quarkpy.maputils import *
import quarkpy.mapeditor
import quarkpy.mapcommands
import plugins.mapterrainmodes


### Start of Basic Selector Dialog ###

### Needed Globals for below Dialog to pass data on to another file,
### plugins\mapmovetrianglevertex.py in this case.
scalex, scaley, tilt, shear, flat = None, None, None, None, quarkx.setupsubset(SS_MAP, "Options")["Selector1_force"]

class Selector1Dlg(quarkpy.dlgclasses.LiveEditDlg):
    "The Terrain Generator Basic Selector dialog box."
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (215,155)
    dlgflags = FWF_KEEPFOCUS   # keeps dialog box open
    dfsep = 0.50    # sets 50% for labels and the rest for edit boxes

    dlgdef = """
        {
        Style = "13"
        Caption = "Basic Selector Dialog"
        scale: = 
        {
        Txt = "Top of Section"
        Typ = "EQ"
        Min="-5.0"
        Max="5.0"
        Hint = "This effects only the faces that meet at the very 'top' of the selection."$0D
               "These values can be set to negative as well as positive"$0D
               "to create more movement in that direction."$0D
               "    IMPORTANT: If either one is set to zero, the other amount will"$0D
               "               have NO effect and NO distortion will take place."$0D$0D
               "  The first amount is the distortion percentage factor that will be used"$0D
               "    and is set by using the left and right arrows on the button."$0D$0D
               "  The second amount is the number of units of movement that will be"$0D
               "    applied and is set by using the up and down arrows on the button."
        }
        sep: = {Typ="S" Txt=""}
        offset: =
        {
        Txt = "Base of Section"
        Typ = "EQ"
        Hint = "This effects all faces below the ones at the very 'top' of the selection."$0D
               "These values can be set to negative as well as positive"$0D
               "to create more movement in that direction."$0D
               "    IMPORTANT: If either one is set to zero, the other amount will"$0D
               "               have NO effect and NO distortion will take place."$0D$0D
               "  The first amount is the distortion percentage factor that will be used"$0D
               "    and is set by using the left and right arrows on the button."$0D$0D
               "  The second amount is the number of units of movement that will be"$0D
               "    applied and is set by using the up and down arrows on the button."
        }
        sep: = { Typ="S" Txt=""}
        force: =
        {
        Txt = "Force Move"
        Typ = "X1"
        Cap="on/off"
        Hint = "Checking this box will effect faces that other wise would not be movable."$0D
               "Both of the adjustors above will influence the faces using this function."$0D
               "Also use this feature for any 'Imported Terrain' that will not move."
        }
        exit:py = {Txt="" }
    }
    """

def Selector1Click(m):
    editor = mapeditor()
    if editor is None: return
    for view in editor.layout.views:
        type = view.info["type"]
        if type == "3D":
            view.invalidate(1)
    editor.layout.explorer.selchanged()
  
    def setup(self):
        editor.selector1dlg=self

      ### To populate settings...
        if quarkx.setupsubset(SS_MAP, "Options")["Selector1_scale"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Selector1_scale"] = (.5, 1)
        if quarkx.setupsubset(SS_MAP, "Options")["Selector1_offset"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Selector1_offset"] = (.5, 1)
        if quarkx.setupsubset(SS_MAP, "Options")["Selector1_force"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Selector1_force"] = "0"

        global scalex, scaley, tilt, shear, flat
        scalex, scaley = quarkx.setupsubset(SS_MAP, "Options")["Selector1_scale"]
        tilt, shear = quarkx.setupsubset(SS_MAP, "Options")["Selector1_offset"]
        flat = quarkx.setupsubset(SS_MAP, "Options")["Selector1_force"]

        self.src["scale"] = "%.1f %.1f" % (scalex, scaley)
        self.src["offset"] = "%.1f %.1f" % (tilt, shear)
        self.src["force"] = flat

    def action(self, editor=editor):
        global scalex, scaley, tilt, shear, flat
        scalex, scaley = read2vec(self.src["scale"])
        tilt, shear = read2vec(self.src["offset"])
        flat = self.src["force"]

      ### Save the settings...
        quarkx.setupsubset(SS_MAP, "Options")["Selector1_scale"] = (scalex, scaley)
        quarkx.setupsubset(SS_MAP, "Options")["Selector1_offset"] = (tilt, shear)
        quarkx.setupsubset(SS_MAP, "Options")["Selector1_force"] = flat

        self.src["scale"] = None
        self.src["offset"] = None
        self.src["force"] = flat


    def onclosing(self, editor=editor):

        for view in editor.layout.views:
            type = view.info["type"]
            if type == "3D":
                view.invalidate(1)


    Selector1Dlg(quarkx.clickform, 'selector1dlg', editor, setup, action, onclosing)



### Start of Paint Brush Dialog ### used maptexpos.py as a guide.

### Globals only used in this Dialog
facetex = org = sc = sa = None

class PaintBrushDlg(quarkpy.dlgclasses.LiveEditDlg):
    "The Terrain Generator Paint Brush dialog box."
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (215,355)
    dlgflags = FWF_KEEPFOCUS   # keeps dialog box open
    dfsep = 0.42    # sets 42% for labels and the rest for edit boxes
    dlgdef = """
        {
        Style = "13"
        Caption = "Touch-up & Paint Brush"
        tex: = 
        {
        Txt = "Texture"
        Typ = "ET"
        SelectMe = "1"
        Hint = "Select the texture to apply here"
        }

        sep: = {Typ="S" Txt=""}

        origin: = 
        {
        Txt = "Origin"
        Typ = "EQ"
        Hint = "This setting takes two values X and Y, Z is constant for texture."$0D$0D
               "This sets the starting location of the texture pattern and will"$0D
               "remain the same for all the faces that it is applied to so that"$0D
               "a continuous appearance will be maintained."
        }

        sep: = {Typ="S" Txt=""}

        retain: =
        {
        Txt = "Retain"
        Typ = "X1"
        Cap="on/off"
        Hint = "Checking this box will cause the origin that presently exist"$0D
               "or entered to remain unchanged if the texture of another"$0D
               "face is selected to replace the current texture being used."$0D$0D
               "If UN-checked when painting each face will have a chopped up look."
        }

        sep: = {Typ="S" Txt=""}

        scale: =
        {
        Txt = "Scale size"
        Typ = "EQ"
        Hint = "Use this to set the scale size of the texture as you apply it."$0D
               "The 'Default' setting needs to be 100 100 if texture looks solid,"$0D
               "or just click the 'Reset' button below to make this correction."$0D$0D
               "This takes two values and can be set by either entering the"$0D
               "amounts or by using the pad to the right. The Left and Right arrows"$0D
               "set the first value, the Up and Down arrows set the second value."$0D$0D
               "These scale factors stretch and elongate the textures appearance."
        }

        sep: = { Typ="S" Txt=""}

        angles: =
        {
        Txt = "Angles"
        Typ = "EQ"
        Hint = "This will apply an angle to the texture to give it a distorted appearance."$0D
               "This takes two values and can be set by either entering the amounts"$0D
               "or by using the pad to the right. The Left and Right arrows set the"$0D
               "first value, the Up and Down arrows set the second value."$0D$0D
               "Distortion is used to achieve different effects such as for wood grains."
        }

        sep: = { Typ="S" Txt=""}

        color: =
        {
        Txt = "Color Guide"
        Typ = "X1"
        Cap="on/off"
        Hint = "Un-checking this box will turn off the color highlighting"$0D
               "that takes place when moving the cursor over the"$0D
               "'paintable' faces prior to applying texture."$0D
               "Also works in conjunction with"$0D"'3D views Options' color guides."
        }

        sep: = { Typ="S" Txt=""}

        sidestoo: =
        {
        Txt = "Sides Too"
        Typ = "X1"
        Cap="on/off"
        Hint = "Checking this box will cause the sides"$0D
               "of the poly(s) to be painted ALSO."
        }

        sidesonly: =
        {
        Txt = "Sides Only"
        Typ = "X1"
        Cap="on/off"
        Hint = "Checking this box will cause the sides"$0D
               "of the poly(s) to be painted ONLY."
        }

        sep: = {Typ="S" Txt=""}

        variance: =
        {
        Txt = "Variance"
        Typ = "EU"
        Hint = "This box only applies to the 'Touch-up Tool'."$0D
               "It allows you to set an acceptable distance"$0D
               "between the 'primary (yellow) face vertex and any"$0D
               "other common face vertex that will be moved with it."$0D
               "The default setting is 0.0001, but you can use any amount."
        }

        sep: = {Typ="S" Txt=""}

        Reset: =       // Reset button
        {
          Cap = "Reset to defaults"      // button caption
          Typ = "B"                     // "B"utton
          Hint = "Reset all the default settings"$0D"for 'Retain' and all below"
          Delete: =
          {
            retain = "1"         // the button resets these items to these amounts
            scale = "100 100"
            angles = "0 90"
            color = "1"
            sidestoo = "0"
            sidesonly = "0"
            variance = "0.0001"
          }
        }

        sep: = { Typ="S" Txt=""}

        exit:py = {Txt="" }
    }
    """


def PaintBrushClick(m):
    editor = mapeditor()
    if editor is None: return

    def setup(self):
        self.editor = editor

      ### To populate settings...
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_tex"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_tex"] = quarkx.setupsubset()["DefaultTexture"]
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_origin"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_origin"] = (0.0, 0.0, -32.0)
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_retain"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_retain"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_scale"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_scale"] = (100.0, 100.0)
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_angles"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_angles"] = (0.0, 90.0)
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_color"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_color"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidestoo"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidestoo"] = "0"
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidesonly"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidesonly"] = "0"
        if quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_variance"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_variance"] = "0.0001"

        global facetex, org, sc, sa
        facetex = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_tex"]
        org = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_origin"]
        keep = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_retain"]
        sc = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_scale"]
        sa = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_angles"]
        guide = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_color"]
        sidetoo = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidestoo"]
        sideonly = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidesonly"]
        variable = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_variance"]


        # If a single face is selected then replaces
        # current texture name with face texture name
        # and its detail if the 'Dialog Button' is clicked.
        uniquesel = editor.layout.explorer.uniquesel
        if uniquesel is not None and uniquesel.type==":f":
            texlist = quarkx.texturesof(editor.layout.explorer.sellist)
            if len(texlist) == 1:
                facetex = texlist[0]
                f = uniquesel
                tp = f.threepoints(1)
                if tp is not None:
                    if keep == "0":
                        org = tp[0]
                    tp1, tp2 = tp[1]-tp[0], tp[2]-tp[0]
                    nsc = (abs(tp1)/1.28, abs(tp2)/1.28)
                    if sc is None:
                        sc = nsc
                    n = f.normal
                    v1 = orthogonalvect(n, editor.layout.views[0])
                    v2 = n^v1
                if sa is None:
                    sa = ((math.atan2(v2*tp1, v1*tp1))*rad2deg, (math.atan2(v2*tp2, v1*tp2))*rad2deg)

        originX, originY, originZ = org
        scaleX, scaleY = sc
        angleX, angleY = sa
        self.originZ = originZ

        self.src["tex"] = facetex
        self.src["origin"] = "%.0f %.0f" % (originX, originY)
        self.src["retain"] = keep
        self.src["scale"] = "%.1f %.1f" % (scaleX, scaleY)
        self.src["angles"] = "%.0f %.0f" % (angleX, angleY)
        self.src["color"] = guide
        self.src["sidestoo"] = sidetoo
        self.src["sidesonly"] = sideonly
        self.src["variance"] = variable

    def action(self, editor=editor):
        global facetex, org, sc, sa

        texname = self.src["tex"]
        originX, originY = read2vec(self.src["origin"])
        originZ = self.originZ
        keep = self.src["retain"]
        scaleX, scaleY = read2vec(self.src["scale"])
        angleX, angleY = read2vec(self.src["angles"])
        guide = self.src["color"]
        sidetoo = self.src["sidestoo"]
        sideonly = self.src["sidesonly"]
        variable = self.src["variance"]

        if sidetoo == "1":
            sideonly = "0"
        #if sideonly == "1":
        #    sidetoo = "0"


        curtexname = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_tex"]
        curkeep = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_retain"]
        curguide = quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_color"]


      ### Save the settings...
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_tex"] = texname
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_origin"] = originX, originY, originZ
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_retain"] = keep
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_scale"] = scaleX, scaleY
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_angles"] = angleX, angleY
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_color"] = guide
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidestoo"] = sidetoo
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_sidesonly"] = sideonly
        quarkx.setupsubset(SS_MAP, "Options")["PaintBrush_variance"] = variable


        self.src["tex"] = None
        self.src["origin"] = None
        self.src["retain"] = keep
        self.src["scale"] = None
        self.src["angles"] = None
        self.src["color"] = guide
        self.src["sidestoo"] = sidetoo
        self.src["sidesonly"] = sideonly
        self.src["variance"] = variable


        facetex = org = sc = sa = None

        if texname is None:
            quarkx.msgbox("Improper Data Entry!\n\nYou must select a texture.", MT_ERROR, MB_OK)
            return

        if keep != curkeep: return
        if guide != curguide: return

        uniquesel = editor.layout.explorer.uniquesel
        if uniquesel is not None and uniquesel.type==":f":
            face = uniquesel

            tx1 = face.texturename
            if texname == curtexname:
                tx2 = face.texturename
            else:
                tx2 = texname
            face.replacetex(tx1, tx2)

            f2 = face.copy()

    # This part gets the "Actual" texture image size.
            tex = face.texturename
            texobj = quarkx.loadtexture(tex, editor.TexSource)
            if texobj is not None:
                try:
                    texobj = texobj.disktexture # this gets "linked"
                except quarkx.error:    # and non-linked textures size
                    texobj = None
            texX, texY = texobj['Size']
            scaleX = scaleX * texX * .01
            scaleY = scaleY * texY * .01

            angleY = angleX - angleY*-1
            angleY = angleX - angleY
            angleX, angleY = angleX*deg2rad, angleY*deg2rad
            p0 = quarkx.vect(originX, originY, originZ)
            n = face.normal   # 1 0 0 or x,y,z direction textured side of face is facing - = opposite direction
            v1, v2 = bestaxes(n, editor.layout.views[0])

            p1 = p0 + (v1*math.cos(angleX) + v2*math.sin(angleX))*scaleX
            p2 = p0 + (v1*math.cos(angleY*-1) + v2*math.sin(angleY*-1))*scaleY

            f2.setthreepoints((p0, p1, p2), 2) # Applies distortion. 2nd augment "2" only
                                             # applies to positioning texture on the face.

            undo_exchange(editor, face, f2, "terrain texture movement")

            uniquesel = editor.layout.explorer.uniquesel = f2
            editor.layout.explorer.selchanged()
            editor.invalidateviews()

            for view in editor.layout.views:
                type = view.info["type"]
                if type == "3D":
                    view.invalidate(1)


    def onclosing(self, editor=editor):

        for view in editor.layout.views:
            type = view.info["type"]
            if type == "3D":
                view.invalidate(1)

        plugins.mapterrainmodes.clickedbutton(editor)


    PaintBrushDlg(quarkx.clickform, 'paintbrushdlg', editor, setup, action, onclosing)



### Start of 3D views Options Dialog ###

class Options3DviewsDlg(quarkpy.dlgclasses.LiveEditDlg):
    "The Terrain Generator 3D views Options dialog box."
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (130,270)
    dlgflags = FWF_KEEPFOCUS   # keeps dialog box open
    dfsep = 0.55    # sets 55% for labels and the rest for edit boxes
    dlgdef = """
        {
        Style = "13"
        Caption = "3D views Options"
        sep: = {
        Typ="S"
        Txt="Editors 3D view"
               }

        noicons1: =
        {
        Txt = "No icons"
        Typ = "X1"
        Hint = "No camera position icons"$0D"Effects ALL QuArK selectors"
        }

        drag1: =
        {
        Txt = "Drag"
        Typ = "X1"
        Hint = "Dragging can be done"$0D"and handles will be shown"
        }

        redfaces1: =
        {
        Txt = "Red faces"
        Typ = "X1"
        Hint = "Red faces can be displayed"
        }

        color1: =
        {
        Txt = "Color Guide"
        Typ = "X1"
        Hint = "Outlines faces prior to applying texture"
        }

      sep: = { Typ="S" Txt="" }

      sep: = {
        Typ="S"
        Txt="Full 3D view"
             }

        noicons2: =
        {
        Txt = "No icons"
        Typ = "X1"
        Hint = "No camera position icons"$0D"Effects ALL QuArK selectors"
        }

        drag2: =
        {
        Txt = "Drag"
        Typ = "X1"
        Hint = "Dragging can be done"$0D"and handles will be shown"
        }

        redfaces2: =
        {
        Txt = "Red faces"
        Typ = "X1"
        Hint = "Red faces can be displayed"
        }

        color2: =
        {
        Txt = "Color Guide"
        Typ = "X1"
        Hint = "Outlines faces prior to applying texture"
        }

      sep: = { Typ="S" Txt="" }

        Reset: =       // Reset button
        {
          Cap = "defaults"      // button caption
          Typ = "B"                     // "B"utton
          Hint = "Resets all views to"$0D"their default settings"
          Delete: =
          {            // the button resets to these amounts
        noicons1 = "0"
        drag1 = "1"
        redfaces1 = "1"
        color1 = "1"
        noicons2 = "0"
        drag2 = "1"
        redfaces2 = "1"
        color2 = "1"
          }
        }

        sep: = { Typ="S" Txt=""}

        exit:py = {Txt="Close" }
    }
    """


def Options3DviewsClick(m):
    editor = mapeditor()
    if editor is None: return

    plugins.mapterrainmodes.clickedbutton(editor)

    def setup(self):
      ### To populate settings...
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons1"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons1"] = "0"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag1"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag1"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces1"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces1"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color1"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color1"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons2"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons2"] = "0"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag2"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag2"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces2"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces2"] = "1"
        if quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color2"] is None:
            quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color2"] = "1"


        onenoicons = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons1"]
        onedrag = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag1"]
        oneredfaces = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces1"]
        onecolor = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color1"]
        twonoicons = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons2"]
        twodrag = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag2"]
        tworedfaces = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces2"]
        twocolor = quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color2"]


        self.src["noicons1"] = onenoicons
        self.src["drag1"] = onedrag
        self.src["redfaces1"] = oneredfaces
        self.src["color1"] = onecolor
        self.src["noicons2"] = twonoicons
        self.src["drag2"] = twodrag
        self.src["redfaces2"] = tworedfaces
        self.src["color2"] = twocolor


    def action(self, editor=editor):
        onenoicons = self.src["noicons1"]
        onedrag = self.src["drag1"]
        oneredfaces = self.src["redfaces1"]
        onecolor = self.src["color1"]
        twonoicons = self.src["noicons2"]
        twodrag = self.src["drag2"]
        tworedfaces = self.src["redfaces2"]
        twocolor = self.src["color2"]

      ### Save the settings...
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons1"] = onenoicons
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag1"] = onedrag
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces1"] = oneredfaces
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color1"] = onecolor
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_noicons2"] = twonoicons
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_drag2"] = twodrag
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_redfaces2"] = tworedfaces
        quarkx.setupsubset(SS_MAP, "Options")["Options3Dviews_color2"] = twocolor

        self.src["noicons1"] = onenoicons
        self.src["drag1"] = onedrag
        self.src["redfaces1"] = oneredfaces
        self.src["color1"] = onecolor
        self.src["noicons2"] = twonoicons
        self.src["drag2"] = twodrag
        self.src["redfaces2"] = tworedfaces
        self.src["color2"] = twocolor

        for view in editor.layout.views:
            type = view.info["type"]
            if type == "3D":
                view.invalidate(1)

        plugins.mapterrainmodes.clickedbutton(editor)


    def onclosing(self, editor=editor):

        for view in editor.layout.views:
            type = view.info["type"]
            if type == "3D":
                view.invalidate(1)

        plugins.mapterrainmodes.clickedbutton(editor)


    Options3DviewsDlg(quarkx.clickform, 'options3Dviewsdlg', editor, setup, action, onclosing)
