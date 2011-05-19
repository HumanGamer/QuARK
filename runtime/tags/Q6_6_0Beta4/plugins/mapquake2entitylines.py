"""   QuArK  -  Quake Army Knife
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$

Info = {
   "plug-in":       "Quake-2 Arrow Extensions",
   "desc":          "Displays axis for rotating entities, func_rotating, func_door_rotating, and  Lazarus, func_rotating_dh, func_door_rot_dh, func_door_swinging, func_trackchange",
   "date":          "17 may 2008",
   "author":        "Decker",
   "author e-mail": "decker@post1.tele.dk",
   "quark":         "Version 6.0 Beta 1" }


from quarkpy.maputils import *
import quarkpy.mapentities
from quarkpy.qeditor import MapColor

DefaultDrawEntityLines = quarkpy.mapentities.DefaultDrawEntityLines
ObjectOrigin = quarkpy.mapentities.ObjectOrigin

import plugins.deckerutils
FindOriginFlagPolyPos = plugins.deckerutils.FindOriginFlagPolyPos

class Quake2DrawEntityLines(DefaultDrawEntityLines):

   def showoriginline(self, entity, xaxisbitvalue, yaxisbitvalue, view, color):
        orgpos = FindOriginFlagPolyPos(entity)
        if orgpos is not None:
            try:
                axisflags = int(entity["spawnflags"])
            except:
                axisflags = 0
            axisdist = quarkx.vect(0, 0, 0)
            if axisflags & xaxisbitvalue:
                axisdist = quarkx.vect(16, 0, 0) # 16 is just some appropriate value I choosed
            elif axisflags & yaxisbitvalue:
                axisdist = quarkx.vect(0, 16, 0)
            else:
                axisdist = quarkx.vect(0, 0, 16)
            cv = view.canvas()
            cv.pencolor = color
            cv.penwidth = 3 # So it the axis gets more visual
            pos1, pos2 = (orgpos + axisdist), (orgpos - axisdist)
            vpos1, vpos2 = view.proj(pos1), view.proj(pos2)
            cv.line(vpos1, vpos2)

   def drawentitylines(self, entity, org, view, entities, processentities):
        # Draw the default target/targetname/killtarget/light/_light arrows/ellipse
        DefaultDrawEntityLines.drawentitylines(self, entity, org, view, entities, processentities)
        # From here its Quake-2 special
        axiscolor = MapColor("Axis")
        rotcolor = 0xff00ff     # (magenta) rotation axis
        org1 = view.proj(org)
        if org1.visible:
            if entity.name == "func_rotating:b":
                self.showoriginline(entity, 4, 8, view, rotcolor) # func_rotating has different bitvalues for X-axis and Y-axis
            elif entity.name == "func_rotating_dh:b":
                self.showoriginline(entity, 4, 8, view, rotcolor)
            elif entity.name == "func_door_swinging:b":
                self.showoriginline(entity, 64, 128, view, rotcolor)
            elif entity.name == "func_trackchange:b":
                self.showoriginline(entity, 64, 128, view, rotcolor)
            elif entity.name == "func_door_rot_dh:b":
                self.showoriginline(entity, 64, 128, view, rotcolor)
            elif entity.name == "func_door_rotating:b":
                self.showoriginline(entity, 64, 128, view, rotcolor)

#
# Register this class with its gamename
#
quarkpy.mapentities.EntityLinesMapping.update({
  "Quake 2": Quake2DrawEntityLines()
})

# ----------- REVISION HISTORY ------------
#
# $Log$
# Revision 1.4  2005/10/15 00:51:24  cdunde
# To reinstate headers and history
#
# Revision 1.1  2001/01/06 18:34:22  decker_dk
# Was in quark 5.10
#
#
