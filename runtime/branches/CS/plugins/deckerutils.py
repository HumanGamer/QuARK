""" QuArK  -  Quake Army Knife

  Utility functions by Decker@post1.tele.dk
"""

import quarkx
import quarkpy.mapentities
ObjectOrigin = quarkpy.mapentities.ObjectOrigin

def FindOriginTexPolyPos(entity):
	"Find origin by searching for poly under entity which has the ORIGIN texture"
	subpolys = entity.findallsubitems("", ":p", ":g")
	for i in subpolys:
		subfaces = i.findallsubitems("",":f",":g");
		# Make sure that all faces on poly contains the ORIGIN texture
		foundoriginpoly=1
		for j in subfaces:
			if not j["tex"]=="ORIGIN": # If just one face does not contain the ORIGIN texture, its not an origin-poly
				foundoriginpoly=0
				break
		if foundoriginpoly==1:
			return ObjectOrigin(i) # give me the origin of the poly
	return None

def FindOriginFlagPolyPos(entity):
	"Find origin by searching for poly under entity which has the Origin-texture-flag set"
	subpolys = entity.findallsubitems("", ":p", ":g")
	for i in subpolys:
		subfaces = i.findallsubitems("",":f",":g");
		# Make sure that all faces on poly contains the Origin-texture-flag
		foundoriginpoly, flags = 1, 0
		for j in subfaces:
			try:
				flags = int(j["Contents"])
			except:
				flags = 0
			if not (flags & 16777216): # If just one face does not contain the Origin-texture-flag, its not an origin-poly
				foundoriginpoly=0
				break
		if foundoriginpoly==1:
			return ObjectOrigin(i) # give me the origin of the poly
	return None

def NewXYZCube(x,y,z,tex):
    p = quarkx.newobj("poly:p")
    x,y,z = x*0.5, y*0.5, z*0.5

    f = quarkx.newobj("east:f");   f["v"] = (x, -x, -x, x, 128-x, -x, x, -x, 128-x)
    f["tex"] = tex
    p.appenditem(f)

    f = quarkx.newobj("west:f");   f["v"] = (-x, -x, -x, -x, -x, 128-x, -x, 128-x, -x)
    f["tex"] = tex             ;   f["m"] = "1"
    p.appenditem(f)

    f = quarkx.newobj("north:f");  f["v"] = (-y, y, -y, -y, y, 128-y, 128-y, y, -y)
    f["tex"] = tex              ;  f["m"] = "1"
    p.appenditem(f)

    f = quarkx.newobj("south:f");  f["v"] = (-y, -y, -y, 128-y, -y, -y, -y, -y, 128-y)
    f["tex"] = tex
    p.appenditem(f)

    f = quarkx.newobj("up:f");     f["v"] = (-z, -z, z, 128-z, -z, z, -z, 128-z, z)
    f["tex"] = tex
    p.appenditem(f)

    f = quarkx.newobj("down:f");   f["v"] = (-z, -z, -z, -z, 128-z, -z, 128-z, -z, -z)
    f["tex"] = tex             ;   f["m"] = "1"
    p.appenditem(f)

    return p

def RegisterInToolbox(toolboxname, qtxfolder, obj):
# FIXME - Make so ':form' also can be added somewhere.
    for t in quarkx.findtoolboxes(toolboxname):
        for f in t[1].subitems:
            if (f.shortname == qtxfolder):
                # If object already is in toolbox, don't put it in again!
                o = f.findname(obj.name)
                if (o is None):
                    print "--adding"
                    f.appenditem(obj)
                return
        # Did not find a qtxfolder, create one
        newf = quarkx.newobj(qtxfolder+".qctx")
        print "--f"
        newf.appenditem(obj)
        print "--folder"
        t[1].parent.appenditem(newf)
        print "--folderadded"
        return
