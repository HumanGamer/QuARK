"""   QuArK  -  Quake Army Knife

Convert hidden faces to nodraw
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "Convert hidden faces to nodraw",
   "desc":          'Finds all hidden faces and converts them to nodraw.',
   "date":          "Dec. 17, 2007",
   "author":        "Shine",
   "author e-mail": "",
   "quark":         "Version 6.6.0 Beta 1" }


import quarkx
import quarkpy.qmenu
import quarkpy.mapcommands
from quarkpy.maputils import *


def ConvertHiddenToNoDrawClick(m):
    editor = mapeditor()
    if editor is None:
        return

    worldspawn = editor.Root
    faces = worldspawn.findallsubitems("", ":f")

    for face in faces:
        if (face["Flags"] is not None and int(face["Flags"])&128) != 0:
            face.texturename  = "engine/nodraw"

    return


#--- add the new menu item into the "Commands" menu ---

# This 'if' section is for the Shine game engine even though QuArK does not support it at this time.
# Because of the contributions they have made to QuArK please leave this in - cdunde Dec. 17, 2007.
if quarkx.setupsubset(SS_GAMES)['GameCfg'] == "Shine":
    quarkpy.mapcommands.items.append(quarkpy.qmenu.sep)   # separator
    quarkpy.mapcommands.items.append(quarkpy.qmenu.item("Convert Hidden flag to NoDraw", ConvertHiddenToNoDrawClick))
