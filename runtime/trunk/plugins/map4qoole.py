"""   QuArK  -  Quake Army Knife

Plug-in which define the 4-views Qoole Style screen layout.
"""
#
# Copyright (C) 2021 DanielPharos
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "4-Views Layout (Qoole Style)",
   "desc":          "4-views Screen Layouts. (Qoole Style)",
   "date":          "12 November 2021",
   "author":        "DanielPharos",
   "author e-mail": "danielpharos@users.sourceforge.net",
   "quark":         "Version 6.6" }


from quarkpy.mapmgr import *
from plugins.map4viewslayout import FourViewsLayout

class FourViewsLayoutQoole(FourViewsLayout):

    shortname = "4 views (Qoole Style)"

    def buildscreen(self, form):

        #
        # Build the base.
        #

        self.buildbase(form)

        #
        # Divide the main panel into 4 sections.
        # horizontally, 2 sections split at 45% of the width
        # vertically, 2 sections split at 50% of the height
        #

        form.mainpanel.sections = ((0.45, ), (0.5,))

        # Put the top view in the top-left section
        self.ViewXY.section = (0,0)

        # Put the side view in the bottom-right section
        self.ViewXZ.section = (1,1)

        # Put the front (back) view in the bottom-left section
        self.ViewYZ.section = (0,1)

        # The 3D view is in the top-right section
        self.View3D.section = (1,0)

        #
        # Link the horizontal position of the XY view to that of the
        # YZ view, and the vertical position of the YZ and XZ views,
        # and remove the extra scroll bars.
        #

        self.sblinks.append((0, self.ViewXY, 0, self.ViewYZ))
        self.sblinks.append((1, self.ViewYZ, 1, self.ViewXZ))
        self.sblinks.append((1, self.ViewXY, 0, self.ViewXZ))
        self.ViewYZ.flags = self.ViewYZ.flags &~ (MV_HSCROLLBAR | MV_VSCROLLBAR)
        self.ViewXZ.flags = self.ViewXZ.flags &~ MV_HSCROLLBAR



#
# Register the new layout.
#

LayoutsList.append(FourViewsLayoutQoole)
