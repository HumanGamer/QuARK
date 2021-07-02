"""   QuArK  -  Quake Army Knife

Basic map validity checking
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "Basic Checks",
   "desc":          "Basic map validity checking.",
   "date":          "26 dec 98",
   "author":        "Armin Rigo",
   "author e-mail": "arigo@planetquake.com",
   "quark":         "Version 5.3" }


import quarkx
from quarkpy.maputils import *
import quarkpy.qmenu
import quarkpy.mapsearch



def BasicCheck(menu=None):
    editor = mapeditor(SS_MAP)
    if editor is None: return
    err = {}
    errobj = []

    if editor.Root.name != "worldspawn:b":
        err["The top-level entity of the map should be called 'worldspawn'."] = 0
        errobj = errobj + [editor.Root]
    else:
        test = editor.Root.findallsubitems("worldspawn", ':b')[1:]    # ignore the top-level one
        if len(test):
            err["Only one 'worldspawn' is allowed in the map."] = 0
            errobj = errobj + test

    test = editor.Root.findallsubitems("info_player_start", ':e')
    if len(test)==0:
        if quarkx.setupsubset()["Code"] < "a":   # ignore the error in Quake 3 mode
            err["The map must contain at least one info_player_start."] = 0
    elif len(test)>1:
        err["The map should not contain several info_player_start."] = 0
        errobj = errobj + test

    MapLimits = quarkx.setupsubset(editor.MODE, "Display")["MapLimit"]
    if (quarkx.setupsubset()["MapLimit"]<>None):    # games can overide default setting
        MapLimits = quarkx.setupsubset()["MapLimit"]

    beziersupport = quarkx.setupsubset()["BezierPatchSupport"]

    test = editor.Root.findallsubitems("", ':b')
    for obj in test:
        if (beziersupport is not None) and (beziersupport == "1"):
            if len(obj.findallsubitems("", ':p') + obj.findallsubitems("", ':b2'))==0:
                err["Brush entities (e.g. doors and plats) are not valid without any attached polyhedron or bezier patch. Delete these empty entities in the tree view now or the game will crash."] = 0
                errobj.append(obj)
        else:
            if len(obj.findallsubitems("", ':p'))==0:
                err["Brush entities (e.g. doors and plats) are not valid without any attached polyhedron. Delete these empty entities in the tree view now or the game will crash."] = 0
                errobj.append(obj)
        bbox = quarkx.boundingboxof([obj])
        if (bbox[0].x < -MapLimits[0]) or (bbox[1].x > MapLimits[0]) or (bbox[0].y < -MapLimits[1]) or (bbox[1].y > MapLimits[1]) or (bbox[0].z < -MapLimits[2]) or (bbox[1].z > MapLimits[2]):
            err["Brush entities beyond the maplimit may not show in the game correctly."] = 0
            errobj.append(obj)

    import quarkpy.mapholes
    watery = quarkpy.mapholes.WateryChecker(editor)
    test = editor.Root.listpolyhedrons
    for obj in test:
        f = obj.faces
        for face in f:
            texp = face.threepoints(0)
            if texp is not None:
                texpt0 = texp[1]-texp[0]
                texpt1 = texp[2]-texp[0]
                #
                # The limit 273.1 is just a bit larger than what TXQBSP allows;
                # it would be 1E-6 if texpt0 and texpt1 where scaled down by a factor 128.
                #
                if abs((texpt0*texpt0)*(texpt1*texpt1)-(texpt0*texpt1)*(texpt0*texpt1)) < 273.1:
                    err["The scale of some textures is too small, or the textures are completely distorted."] = 0
                    errobj.append(face)
        w = not watery(face)
        for face in f[:-1]:
            if (not watery(face)) != w:
                err["Cannot mix watery and non-watery textures on a polyhedron."] = 0
                errobj.append(obj)
                break
        else:
            if not w:
                w = obj.faces[0].texturename
                for face in obj.faces[1:]:
                    if w != face.texturename:
                        err["Cannot mix different watery textures on the same polyhedron."] = 0
                        errobj.append(obj)
                        break

    if err != {}:
        return quarkpy.mapsearch.problem("\n".join(err.keys()), errobj)
    else:
        return quarkpy.mapsearch.noproblem(menu)



#--- add the new menu item into the "Search" menu ---

Basic1 = quarkpy.qmenu.item("&Basic checks", BasicCheck, "|Basic checks:\n\nThis function performs various checks on your map, to see if it can be compiled correctly, and function properly.", "intro.mapeditor.menu.html#searchmenu")
quarkpy.mapsearch.checkitems.append(Basic1)
