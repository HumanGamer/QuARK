"""   QuArK  -  Quake Army Knife

Map editor mouse handles.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$



#
# This module manages the map "handles", i.e. the small active areas
# that can be grabbed and dragged by the user on the map views.
#
# Generic handles are implemented in qhandles.py. This modules has
# only the map-editor-specific handles.
#


import quarkx
import math
from qdictionnary import Strings
import qhandles
from maputils import *
import mapentities
import qmacro

#
# The handle classes.
#

class CenterHandle(qhandles.CenterHandle):
    "Like qhandles.CenterHandle, but specifically for the map editor."
    def menu(self, editor, view):
        #
        # FIXME: this is a pretty clunky way of making the
        #  clicked on view available to entity menus, mebbe
        #  should be cleaned up (view as 3rd parameter to entity
        #  menus, perhaps?)
        #
        try:
            editor.layout.clickedview = view
        except:
            editor.layout.clickedview = None
        return mapentities.CallManager("menu", self.centerof, editor) + self.OriginItems(editor, view)

class IconHandle(qhandles.IconHandle):
    "Like qhandles.IconHandle, but specifically for the map editor."
    def menu(self, editor, view):
        return mapentities.CallManager("menu", self.centerof, editor) + self.OriginItems(editor, view)


def CenterEntityHandle(o, view, handleclass=IconHandle, pos=None):
    if pos is None:
        pos = o.origin
    if pos is not None:
        #
        # Compute a handle for the entity angle.
        #
        h = []
        for spec, cls in mapentities.ListAngleSpecs(o):
            s = o[spec]
            if s:
                stov, vtos = cls.map
                try:
                    normal = stov(s)
                except:
                    continue
                h = [cls(pos, normal, view.scale(), o, spec)]
                break
        #
        # Build a "circle" icon handle at the object origin.
        #
        new = handleclass(pos, o)   # the "circle" icon would be qhandles.mapicons[10], but it looks better with the entity icon itself
        #
        # Set the hint as the entity classname in blue ("?").
        #
        new.hint = "?" + o.shortname + "||This point represents an entity, i.e. an object that appears and interacts in the game when you play the map. The exact kind of entity depends on its 'classname' (its name).\n\nThis handle lets you move the entity with the mouse. Normally, the mouvement is done by steps of the size of the grid : if the entity was not aligned on the grid before the movement, it will not be after it. Hold down Ctrl to force the entity to the grid."
        #
        # Return the handle
        #
        return h+[new]

    else:
        #
        # No "origin".
        #
        return []



class FaceHandleCursor:
    "Special class to compute the mouse cursor shape based on the visual direction of a face."

    def getcursor(self, view):
        n = view.proj(self.pos + self.face.normal) - view.proj(self.pos)
        dx, dy = abs(n.x), abs(n.y)
        if dx*2<=dy:
            if (dx==0) and (dy==0):
                return CR_ARROW
            else:
                return CR_SIZENS
        elif dy*2<=dx:
            return CR_SIZEWE
        elif (n.x>0)^(n.y>0):
            return CR_SIZENESW
        else:
            return CR_SIZENWSE


def completeredimage(face, new):
    #
    # Complete a red image with the whole polyhedron.
    # (red images cannot be reduced to a single face; even if
    #  we drag just a face, we want to see the whole polyhedron)
    #
    gr = []
    for src in face.faceof:
        if src.type == ":p":
            poly = quarkx.newobj("redimage:p")
            t = src
            while t is not None:
                for q in t.subitems:
                    if (q.type==":f") and not (q is face):
                         poly.appenditem(q.copy())
                t = t.treeparent
            poly.appenditem(new.copy())
            gr.append(poly)
    if len(gr):
        return gr
    else:
        return [new]



class FaceHandle(qhandles.GenericHandle):
    "Center of a face."

    undomsg = Strings[516]
    hint = "move this face (Ctrl key: force center to grid)||This handle lets you scroll this face, thus distort the polyhedron(s) that contain it.\n\nNormally, the face can be moved by steps of the size of the grid; holding down the Ctrl key will force the face center to be exactly on the grid."

    def __init__(self, pos, face):
        qhandles.GenericHandle.__init__(self, pos)
        self.face = face
        cur = FaceHandleCursor()
        cur.pos = pos
        cur.face = face
        self.cursor = cur.getcursor

    def menu(self, editor, view):
        self.click(editor)
        return mapentities.CallManager("menu", self.face, editor) + self.OriginItems(editor, view)

    def drag(self, v1, v2, flags, view):
        delta = v2-v1
        g1 = 1
        if flags&MB_CTRL:
            pos0 = self.face.origin
            if pos0 is not None:
                pos1 = qhandles.aligntogrid(pos0+delta, 1)
                delta = pos1 - pos0
                g1 = 0
        if g1:
            delta = qhandles.aligntogrid(delta, 0)
        self.draghint = vtohint(delta)
        if delta or (flags&MB_REDIMAGE):
            new = self.face.copy()
            if self.face.faceof[0].type == ":p":
                delta = self.face.normal * (self.face.normal*delta)  # projection of 'delta' on the 'normal' line
            new.translate(delta)
            if flags&MB_DRAGGING:    # the red image contains the whole polyhedron(s), not the single face
                new = completeredimage(self.face, new)
            else:
                new = [new]
        else:
            new = None
        return [self.face], new

    def leave(self, editor):
        src = self.face.faceof
        if (len(src)==1) and (src[0].type == ":p"):
            editor.layout.explorer.uniquesel = src[0]


class PFaceHandle(FaceHandle):
    "Center of a face, but unselected (as part of a selected poly)."

    def draw(self, view, cv, draghandle=None):
        p = view.proj(self.pos)
        if p.visible:
            cv.reset()
            cv.brushcolor = view.darkcolor
            cv.rectangle(p.x-3, p.y-3, p.x+4, p.y+4)

    def click(self, editor):
        editor.layout.explorer.uniquesel = self.face
        return "S"

    def leave(self, editor):
        pass



class MapRotateHandle(qhandles.Rotate3DHandle):
    "Like Rotate3DHandle, but specifically for the map editor."

    MODE = SS_MAP



class FaceNormalHandle(MapRotateHandle):
    "3D rotating handle, for faces."

    undomsg = Strings[517]
    hint = "rotate this face (Ctrl key: force to a common angle)||This handle lets you rotate the face around its center. Use it to distort the polyhedron(s).\n\nYou can set any angle unless you hold down the Ctrl key; in this case, you can only set 'round' angle values. See the Configuration dialog box, Map, Display."

    def __init__(self, center, vtx, face, scale1):
        MapRotateHandle.__init__(self, center, face.normal, scale1, qhandles.mapicons[11])
        self.face = face
        self.vtx = vtx

    def menu(self, editor, view):
        return qmenu.catmenus(MapRotateHandle.menu(self, editor, view),
          mapentities.CallManager("menu", self.face, editor))

    def draw(self, view, cv, draghandle=None):
        cv.reset()
        p1, p2 = view.proj(self.center), view.proj(self.pos)
        fromback = view.vector(self.center)*self.face.normal < 0
        if fromback:
            self.draw1(view, cv, p1, p2, 1)
            if p1.visible:
                cv.rectangle(p1.x-3, p1.y-3, p1.x+4, p1.y+4)
        else:
            oldpc = cv.pencolor
        cv.pencolor = YELLOW
        for v in self.vtx:
            p = view.proj(v)
            cv.line(p, p1)
        if not fromback:
            cv.pencolor = oldpc
            if p1.visible:
                cv.rectangle(p1.x-3, p1.y-3, p1.x+4, p1.y+4)
            self.draw1(view, cv, p1, p2, 0)
        view.drawmap(self.face, 0)

    def dragop(self, flags, av):
        new = None
        if av is not None:
            new = self.face.copy()
            new.distortion(av, self.center)
            if flags&MB_DRAGGING:    # the red image contains the whole polyhedron(s), not the single face
                new = completeredimage(self.face, new)
            else:
                new = [new]
        return [self.face], new, av



class Angles3DHandle(MapRotateHandle):
    "3D rotating handle, for 'angles'-like Specifics."

    hint = "entity pointing angle (any 3D direction)||Lets you set the direction the entity is 'looking' at. Hold down Ctrl to force the angle to some 'round' value."
    map = (qhandles.angles2vec, qhandles.vec2angles)
    ii = 12

    def __init__(self, pos, normal, scale1, entity, spec):
        MapRotateHandle.__init__(self, pos, normal, scale1, qhandles.mapicons[self.ii])
        self.entity = entity
        self.spec = spec

    def menu(self, editor, view):
        return qmenu.catmenus(MapRotateHandle.menu(self, editor, view),
          mapentities.CallManager("menu", self.entity, editor))

    def dragop(self, flags, av):
        new = None
        if av is not None:
            stov, vtos = self.map
            new = self.entity.copy()
            s = vtos(av, new[self.spec])
            av = stov(s)
            new[self.spec] = s
            new = [new]
        return [self.entity], new, av


class Angle2DHandle(Angles3DHandle):
    "2D rotating handle, for 'angle'-like Specifics."

    hint = "entity pointing angle (2D direction only, or up or down)||Lets you set the direction the entity is 'looking' at. This has various meaning for various entities : for most ones, it is the direction it is facing when the map starts; for buttons or doors, it is the direction the button or door moves.\n\nYou can set any horizontal angle, as well as 'up' and 'down'. Hold down Ctrl to force the angle to a 'round' value."
    map = (qhandles.angle2vec, qhandles.vec2angle)
    ii = 13



class PolyHandle(CenterHandle):
    "Center of polyhedron Handle."

    undomsg = Strings[515]
    hint = "move polyhedron (Ctrl key: force center to grid)||Lets you move this polyhedron.\n\nYou can move it by steps equal to the grid size. This means that if it is not on the grid now, it will not be after the move, either. You can force it on the grid by holding down the Ctrl key, but be aware that this forces its center to the grid, not all its faces. For cubic polyhedron, you may need to divide the grid size by two before you get the expected results."

    def __init__(self, pos, centerof):
        CenterHandle.__init__(self, pos, centerof, 0x202020, 1)

    def click(self, editor):
        if not self.centerof.selected:   # case of the polyhedron center handle if only a face is selected
            editor.layout.explorer.uniquesel = self.centerof
            return "S"



class VertexHandle(qhandles.GenericHandle):
    "A polyhedron vertex."

    undomsg = Strings[525]
    hint = "move vertex and distort polyhedron (Alt key: restricted to one face only)||By dragging this point, you can distort the polyhedron in a way that looks like you are moving the vertex of the polyhedron.\n\nBe aware that you might not always get the expected results, because you are not really dragging the vertex, but just rotating the adjacent faces in a way that simulates the vertex movement. If you move the vertex too far away, it might just disappear. Polyhedrons are always convex, so that you cannot do just anything you like with them.\n\nHolding down the Alt key to let only one face move. Holding down Ctrl will force the vertex to the grid."

    def __init__(self, pos, poly):
        qhandles.GenericHandle.__init__(self, pos)
        self.poly = poly
        self.cursor = CR_CROSSH

    def menu(self, editor, view):

        def forcegrid1click(m, self=self, editor=editor, view=view):
            self.Action(editor, self.pos, self.pos, MB_CTRL, view, Strings[560])

        def cutcorner1click(m, self=self, editor=editor, view=view):
            #
            # Find all edges and faces issuing from the given vertex.
            #
            edgeends = []
            faces = []
            for f in self.poly.faces:
                vertices = f.verticesof(self.poly)
                for i in range(len(vertices)):
                    if not (vertices[i]-self.pos):
                        edgeends.append(vertices[i-1])
                        edgeends.append(vertices[i+1-len(vertices)])
                        if not (f in faces):
                            faces.append(f)
            #
            # Remove duplicates.
            #
            edgeends1 = []
            for i in range(len(edgeends)):
                e1 = edgeends[i]
                for e2 in edgeends[:i]:
                    if not (e1-e2):
                        break
                else:
                    edgeends1.append(e1)
            #
            # Compute the mean point of edgeends1.
            # The new face will go through the point in the middle between this and the vertex.
            #
            pt = reduce(lambda x,y: x+y, edgeends1)/len(edgeends1)
            #
            # Compute the mean normal vector from the adjacent faces' normal vector.
            #
            n = reduce(lambda x,y: x+y, map(lambda f: f.normal, faces))
            #
            # Force "n" to be perpendicular to the screen direction.
            #
            vertical = view.vector(self.pos).normalized   # vertical vector at this point
            n = (n - vertical * (n*vertical)).normalized
            #
            # Find a "model" face for the new one.
            #
            bestface = faces[0]
            for f in faces[1:]:
                if abs(f.normal*vertical) < abs(bestface.normal*vertical):
                    bestface = f
            #
            # Build the new face.
            #
            newface = bestface.copy()
            newface.shortname = "corner"
            newface.distortion(n, self.pos)
            #
            # Move the face to its correct position.
            #
            delta = 0.5*(pt-self.pos)
            delta = n * (delta*n)
            newface.translate(delta)
            #
            # Insert the new face into the polyhedron.
            #
            undo = quarkx.action()
            undo.put(self.poly, newface)
            editor.ok(undo, Strings[563])

        return [qmenu.item("&Cut out corner", cutcorner1click, "|This command cuts out the corner of the polyhedron. It does so by adding a new face near the vertex you right-clicked on. The new face is always perpendicular to the view."),
                qmenu.sep,
                qmenu.item("&Force to grid", forcegrid1click,
                  "force vertex to grid")] + self.OriginItems(editor, view)


    def draw(self, view, cv, draghandle=None):
        p = view.proj(self.pos)
        if p.visible:
            cv.reset()
            cv.brushcolor = view.color
            cv.rectangle(p.x-0.501, p.y-0.501, p.x+2.499, p.y+2.499)


    def drag(self, v1, v2, flags, view):

        #### Vertex Dragging Code by Tim Smith ####

        #
        # compute the projection of the starting point? onto the
        # screen.
        #
        p0 = view.proj(self.pos)
        if not p0.visible: return

        #
        # save a copy of the original faces
        #
        orgfaces = self.poly.subitems

        #
        # first, loop through the faces to see if we are draging
        # more than one point at a time.  This loop uses the distance
        # between the projected screen position of the starting point
        # and the project screen position of the vertex.
        #
        dragtwo = 0
        for f in self.poly.faces:
            if f in orgfaces:
                if abs(self.pos*f.normal-f.dist) < epsilon:
                    foundcount = 0
                    for v in f.verticesof(self.poly):
                        p1 = view.proj(v)
                        if p1.visible:
                            dx, dy = p1.x-p0.x, p1.y-p0.y
                            d = dx*dx + dy*dy
                            if d < epsilon:
                                foundcount = foundcount + 1
                    if foundcount == 2:
                        dragtwo = 1

        #
        # if the ALT key is pressed
        #
        if (flags&MB_ALT) != 0:

            #
            # loop through the list of points looking for the edge
            # that is closest to the new position.
            #
            # WARNING - THIS CODE ASSUMES THAT THE VERTECIES ARE ORDERED.
            #   IT ASSUMES THAT V1->V2 MAKE AND EDGE, V2->V3 etc...
            #
            # Note by Armin: this assumption is correct.
            #
            delta = v2 - v1
            mindist = 99999999
            dv1 = self.pos + delta
            xface = -1
            xvert = -1
            for f in self.poly.faces:
                xface = xface + 1
                if f in orgfaces:
                    if abs(self.pos*f.normal-f.dist) < epsilon:
                        vl = f.verticesof (self.poly)
                        i = 0
                        while i < len (vl):
                            v = vl [i]
                            p1 = view.proj(v)
                            if p1.visible:
                                dx, dy = p1.x-p0.x, p1.y-p0.y
                                d = dx*dx + dy*dy
                                if d < epsilon:
                                    dv2 = v - vl [i - 1]
                                    if dv2:
                                        cp = (v - dv1) ^ dv2
                                        num = (cp.x * cp.x + cp.y * cp.y + cp.z * cp.z)
                                        den = (dv2.x * dv2.x + dv2.y * dv2.y + dv2.z * dv2.z)
                                        if num / den < mindist:
                                            mindist = num / den
                                            vtu1 = v
                                            vtu2 = vl [i - 1]
                                            xvert = i - 1
                                    dv2 = v - vl [i + 1 - len (vl)]
                                    if dv2:
                                        cp = (v - dv1) ^ dv2
                                        num = (cp.x * cp.x + cp.y * cp.y + cp.z * cp.z)
                                        den = (dv2.x * dv2.x + dv2.y * dv2.y + dv2.z * dv2.z)
                                        if num / den < mindist:
                                            mindist = num / den
                                            vtu1 = v
                                            vtu2 = vl [i + 1 - len (vl)]
                                            xvert = i
                            i = i + 1

            #
            # If a edge was found
            #
            if mindist < 99999999:
                #
                # Compute the orthogonal projection of the destination point onto the
                # edge.  Use the projection to compute a new value for delta.
                #
                temp = dv1 - vtu1
                if not temp:
                    vtu1, vtu2 = vtu2, vtu1
                temp = dv1 - vtu1
                vtu2 = vtu2 - vtu1
                k = (temp * vtu2) / (abs (vtu2) * abs (vtu2))
                projdv1 = k * vtu2
                temp = projdv1 + vtu1

                #
                # Compute the final value for the delta
                #
                if flags&MB_CTRL:
                    delta = qhandles .aligntogrid (temp, 1) - self .pos
                else:
                    delta = qhandles .aligntogrid (temp - self .pos, 0)

        #
        # Otherwise
        #
        else:
            #
            # if the control key is pressed, align the destination point to grid
            #
            if flags&MB_CTRL:
                v2 = qhandles.aligntogrid(v2, 1)

            #
            # compute the change in position
            #
            delta = v2-v1

            #
            # if the control is not pressed, align delta to the grid
            #
            if not (flags&MB_CTRL):
                delta = qhandles.aligntogrid(delta, 0)

        #
        # if we are dragging
        #
        self.draghint = vtohint(delta)
        if delta or (flags&MB_REDIMAGE):

            #
            # make a copy of the polygon being drug
            #
            new = self.poly.copy()

            #
            # loop through the faces
            #
            for f in self.poly.faces:

                #
                # if this face is part of the original group
                #
                if f in orgfaces:

                    #
                    # if the point is on the face
                    #
                    if abs(self.pos*f.normal-f.dist) < epsilon:

                        #
                        # collect a list of verticies on the face along
                        # with the distances from the destination point.
                        # also, count the number of vertices.  NOTE:
                        # this loop uses the actual distance between the
                        # two points and not the screen distance.
                        #
                        foundcount = 0
                        vlist = []
                        mvlist = []
                        for v in f.verticesof(self.poly):
                            p1 = view.proj(v)
                            if p1.visible:
                                dx, dy = p1.x-p0.x, p1.y-p0.y
                                d = dx*dx + dy*dy
                            else:
                                d = 1
                            if d < epsilon:
                                foundcount = foundcount + 1
                                mvlist .append (v)
                            else:
                                d = v - self .pos
                                vlist.append((abs (d), v))

                        #
                        # sort the list of vertecies, this places the
                        # most distant point at the end
                        #
                        vlist.sort ()
                        vmax = vlist [-1][1]

                        #
                        # if we are draging two vertecies
                        #
                        if dragtwo:

                            #
                            # if this face does not have more than one vertex
                            # selected, then skip
                            #
                            if foundcount != 2:
                                continue

                            #
                            # the rotational axis is between the two
                            # points being drug.  the reference point is
                            # the most distant point
                            #
                            rotationaxis = mvlist [0] - mvlist [1]
                            fixedpoints = vmax, vmax+rotationaxis
                  
                        #
                        # otherwise, we are draging one
                        #
                        else:

                            #
                            # if this face does not have any of the selected
                            # vertecies, then skip
                            #
                            if foundcount == 0:
                                continue

                            #
                            # sort the vertex list and use the last vertex as
                            # a rotational reference point
                            # (already done, seems to me)
                        #    vlist.sort()
                        #    vmax = vlist[-1][1]


                            #
                            # METHOD A: Using the two most distant points
                            # as the axis of rotation
                            #
                            if not (flags&MB_SHIFT):
                                rotationaxis = (vmax - vlist [-2] [1])
                                fixedpoints = vmax, vlist[-2][1]

                            #
                            # METHOD B: Using the most distant point, rotate
                            # along the perpendicular to the vector between
                            # the most distant point and the position
                            #
                            else:
                                rotationaxis = (vmax - self .pos) ^ f .normal
                                fixedpoints = vmax, vmax+rotationaxis

                        #
                        # apply the rotation axis to the face (requires that
                        # rotationaxis and vmax to be set)
                        #
                        newpoint = self.pos+delta
                        nf = new.subitem(orgfaces.index(f))
                        newnormal = rotationaxis ^ (self.pos+delta-vmax)
                        testnormal = rotationaxis ^ (self.pos-vmax)

                        if newnormal:
                            if testnormal * f.normal < 0.0:
                                newnormal = -newnormal
                            nf.distortion(newnormal.normalized, vmax)
#                            smallcorrection = nf.normal * (self.pos+delta) - nf.dist
#                            nf.translate(nf.normal * smallcorrection)

                        nf2 = nf.copy()
                        nf2.setthreepoints((newpoint,fixedpoints[0],fixedpoints[1]),0)
                        if nf2.normal*nf.normal<0.0:
                           nf2.swapsides
                        def project(p,along=nf2.normal,at=newpoint):
                            return projectpointtoplane(p,along,at,along)
                        ntp=tuple(map(project,nf.threepoints(2)))
                        nf2.setthreepoints(ntp,2)
                        nf = nf2

                #
                # if the face is not part of the original group
                #

                else:
                    if not (flags&MB_DRAGGING):
                        continue   # face is outside the polyhedron
                    nf = f.copy()   # put a copy of the face for the red image only
                    new.appenditem(nf)

        #
        # final code
        #
            new = [new]
        else:
            new = None
        return [self.poly], new



class MapEyeDirection(qhandles.EyeDirection):

    MODE = SS_MAP



class CyanLHandle(qhandles.GenericHandle):
    "Texture moving of faces : cyan L vertices."

    def __init__(self, n, tp4, face, texsrc):
        self.tp4 = tp4
        self.pos = tp4[n]
        self.n = n
        self.face = face
        self.cursor = (CR_DRAG, CR_LINEARV, CR_LINEARV, CR_CROSSH)[n]
        self.texsrc = texsrc
        self.undomsg = Strings[(598,617,617,618)[n]]
        self.hint = ("offset texture on face", "enlarge or distort 1st texture axis",
         "enlarge or distort 2nd texture axis", "rotate texture")[n] +   \
         "||Use the 4 handles at the corners of this 'L' to scroll or rotate the texture on the face.\n\nThe center of the 'L' lets you scroll the texture; the two ends lets you enlarge and distort the texture in the corresponding directions; the 4th point lets you rotate the texture."

    def drag(self, v1, v2, flags, view):
        view.invalidate(1)
        self.dynp4 = None
        delta = v2-v1

        # force into the face plane
        normal = self.face.normal
        if not (flags&MB_CTRL):
            delta = qhandles.aligntogrid(delta, 0)
        delta = delta - normal*(normal*delta)   # back into the plane

        if not delta:
            return None, None

        p1,p2,p3,p4 = self.tp4
        p2 = p2 - p1
        p3 = p3 - p1
        if self.n==0:
            p1 = p1 + delta
            if flags&MB_CTRL:
                p1 = qhandles.aligntogrid(p1, 1)
                p1 = p1 - normal*(normal*p1-self.face.dist)   # back into the plane
            self.draghint = vtohint(p1-self.tp4[0])
        elif self.n==1:
            p2 = p2 + delta
            if flags&MB_CTRL:
                p2 = qhandles.aligntogrid(p2, 1)
                p2 = p2 - normal*(normal*p2)   # back into the plane
            self.draghint = vtohint(p2-self.tp4[1])
        elif self.n==2:
            p3 = p3 + delta
            if flags&MB_CTRL:
                p3 = qhandles.aligntogrid(p3, 1)
                p3 = p3 - normal*(normal*p3)   # back into the plane
            self.draghint = vtohint(p3-self.tp4[2])
        else:   # n==3:
            # ---- texture rotation begin ----
            if not normal:
                return None, None
            texp4 = p2+p3
            m = qhandles.UserRotationMatrix(normal, texp4+qhandles.aligntogrid(delta, 0), texp4, flags&MB_CTRL)
            if m is None:
                return None, None
            p2 = m*p2
            p3 = m*p3
            self.draghint = "%d degrees" % (math.acos(m[0,0])*180.0/math.pi)
            # ---- texture rotation end ----

        l = max((abs(p2), abs(p3)))
        if abs(p2^p3) < l*l*0.1:
            return None, None    # degenerate

        self.dynp4 = (p1,p1+p2,p1+p3,p1+p2+p3)
        r = self.face.copy()
        r.setthreepoints((p1,p1+p2,p1+p3), 2, self.texsrc)
        return [self.face], [r]

    def getdrawmap(self):
        return self.face, qhandles.refreshtimertex


class CyanLHandle0(CyanLHandle):
    "Texture moving of faces : cyan L base."

    def __init__(self, tp4, face, texsrc, handles):
        CyanLHandle.__init__(self, 0, tp4, face, texsrc)
        self.friends = handles

    def draw(self, view, cv, draghandle=None):
        dyn = (draghandle is self) or (draghandle in self.friends)
        if dyn:
            pencolor = RED
            tp4 = draghandle.dynp4
        else:
            tp4 = None
        if tp4 is None:
            pencolor = 0xF0CAA6
            tp4 = self.tp4
        pt = map(view.proj, tp4)

        # draw a grid while dragging
        if dyn:
            view.drawgrid(pt[1]-pt[0], pt[2]-pt[0], MAROON, DG_LINES, 0, tp4[0])

        # draw the cyan L
        cv.reset()
        cv.pencolor = BLACK
        cv.penwidth = 5
        cv.line(pt[0], pt[2])
        cv.line(pt[3], pt[3])
        cv.pencolor = pencolor
        cv.penwidth = 3
        cv.line(pt[0], pt[2])
        cv.line(pt[3], pt[3])
        cv.pencolor = BLACK
        cv.penwidth = 5
        cv.line(pt[0], pt[1])
        cv.pencolor = pencolor
        cv.penwidth = 3
        cv.line(pt[0], pt[1])

#
# A version of LinHandlesManager for Bezier texture.
#

class BTLinHandlesManager(qhandles.LinHandlesManager):
    "Linear Box manager for Bezier texture."

    def t2p(self, p):
        w,h = self.scale
        return quarkx.vect(p.x*w, p.y*h, 0.0)

    def p2t(self, p):
        w,h = self.scale
        return quarkx.vect(p.x/w, p.y/h, 0.0)

    def linear(self, sender, obj, center, matrix):
        debug('lin')
        if obj.type==":b3":
            obj.vst = sender.dynst = map(self.p2t, map(lambda v,center=center,matrix=matrix: matrix*(v-center)+center, map(self.t2p, obj.vst)))
        else:
            def maprow(p,center=center,matrix=matrix,self=self):
                t = self.t2p(quarkx.vect(p.s, p.t, 0.0))
                t = self.p2t(matrix*(t-center)+center)
                return quarkx.vect(p.xyz + (t.x, t.y))
            tcp = []
            for row in obj.cp:
                tcp.append(map(maprow, row))
            obj.cp = sender.dynst = tcp

    def translate(self, sender, obj, delta, forcetogrid):
        if obj.type==":b3":
            obj.vst = sender.dynst = map(self.p2t, map(lambda v,delta=delta: v+delta, map(self.t2p, obj.vst)))
        else:
            def maprow(p, delta=delta, self=self):
                t = self.t2p(quarkx.vect(p.s, p.t, 0.0))
                t = self.p2t(t+delta)
                return quarkx.vect(p.xyz + (t.x, t.y))
            tcp = []
            for row in obj.cp:
                tcp.append(map(maprow, row))
            obj.cp = sender.dynst = tcp


class CyanBezier2Handle(qhandles.GenericHandle):
    "Texture moving of B�zier patches : cyan L vertices."

    undomsg = Strings[628]
    hint = "the shape is the fraction of the texture to map to the Bezier patch"

    def __init__(self, (i,j), cp, b2, scale):
        self.scale = scale
        qhandles.GenericHandle.__init__(self, self.t2p(cp[i][j]))
        self.b2 = b2
        self.ij = (i,j)
        self.hint = "Control Point (%d, %d)"%(i,j)
        self.cp = cp
        self.colormask = WHITE
        self.color = WHITE

    def t2p(self, p):
        w,h = self.scale
        return quarkx.vect(p.s*w, p.t*h, 0.0)

    def p2t(self, p, q):
        w,h = self.scale
        return quarkx.vect(q.xyz +(p.x/w, p.y/h))

    def drag(self, v1, v2, flags, view):
        view.invalidate(1)
        self.dynst = None
        delta = v2-v1
        if not (flags&MB_CTRL):
            delta = qhandles.aligntogrid(delta, 0)

        if flags&MB_CTRL:
            delta = qhandles.aligntogrid(self.pos + delta, 1) - self.pos
        if delta or (flags&MB_REDIMAGE):
            new = self.b2.copy()
            cp = map(list, self.b2.cp)
            i, j = self.ij
            w,h = self.scale
            td = quarkx.vect(0,0,0,delta.x/w,delta.y/h)
            moverow = (quarkx.keydown('\022')==1)  # ALT
            movecol = (quarkx.keydown('\020')==1)  # SHIFT
            from mapbezier import pointsToMove
            indexes = pointsToMove(moverow, movecol, i, j, len(cp), len(cp[0]))
            for m,n in indexes:
                cp[m][n] = cp[m][n]+td
                new.cp =cp


        if new is not None:
            self.dynst = new.cp
        return [self.b2], [new]

    def getdrawmap(self):
        return self.b2, qhandles.refreshtimertex

    def getcenter(self):
        cp = self.cp
        m, n = len(cp)-1, len(cp[0])-1
        return self.t2p(0.25*(cp[0][0]+cp[m][0]+cp[0][n]+cp[m][n]))



class CyanBezier2Handle0(CyanBezier2Handle):
    "Texture moving of B�zier patches : cyan L base."

    def __init__(self, cp, b2, handles, scale):
        CyanBezier2Handle.__init__(self, (0,0), cp, b2, scale)
        self.friends = handles

    def draw(self, view, cv, draghandle=None):
        dyn = (draghandle is self) or (draghandle in self.friends)
        if dyn:
            pencolor = RED
            try:
                cp = draghandle.dynst
            except (AttributeError):
                cp = None
        else:
            cp = None
        if cp is None:
            pencolor = 0xF0CAA6
            cp = self.cp
        pt = []
        for row in cp:
            pt.append(map(view.proj, map(self.t2p, row)))
        m, n = len(cp), len(cp[0])
        # draw the cyan shape
        cv.reset()
        def line(frm, to, bold, cv=cv, pencolor=pencolor):
            cv.pencolor = BLACK
            cv.penwidth = (3,5)[bold]
            cv.line(frm, to)
            cv.pencolor = pencolor
            cv.penwidth = (1,3)[bold]
            cv.line(frm, to)
        # vertical thin lines
        for i in range(m-1):
            for j in range(1, n-1):
                line(pt[i][j], pt[i+1][j], 0)
        # horizontal thin lines
        for i in range(1,m-1):
            for j in range(n-1):
                line(pt[i][j], pt[i][j+1], 0)
        # vertical bold lines
        for i in range(m-1):
            for j in (0,n-1):
                line(pt[i][j], pt[i+1][j], 1)
        # horizontal bold lines
        for i in (0,m-1):
            for j in range(n-1):
                line(pt[i][j], pt[i][j+1], 1)



#
# Functions to build common lists of handles.
#


def BuildHandles(editor, ex, view):
    "Build a list of handles to display on the map views."

    fs = ex.uniquesel
    if (fs is None) or editor.linearbox:
        #
        # Display a linear mapping box.
        #
        list = ex.sellist
        box = quarkx.boundingboxof(list)
        if box is None:
            h = []
        else:
            manager = qhandles.LinHandlesManager(MapColor("Linear"), box, list)
            h = manager.BuildHandles(editor.interestingpoint())
    else:
        #
        # Get the list of handles from the entity manager.
        #
        h = mapentities.CallManager("handles", fs, editor, view)
    #
    # Add the 3D view "eyes".
    #
    for v in editor.layout.views:
        if (v is not view) and (v.info["type"] == "3D"):
            h.append(qhandles.EyePosition(view, v))
            h.append(MapEyeDirection(view, v))
    return qhandles.FilterHandles(h, SS_MAP)


def BuildCyanLHandles(editor, face):
    "Build a list of handles to display a cyan L over a face' texture."

    tp = face.threepoints(2, editor.TexSource)
    if tp is None:
        return []
    tp4 = tp + (tp[1]+tp[2]-tp[0],)
    handles = [CyanLHandle(1,tp4,face,editor.TexSource), CyanLHandle(2,tp4,face,editor.TexSource), CyanLHandle(3,tp4,face,editor.TexSource)]
    return qhandles.FilterHandles([CyanLHandle0(tp4, face, editor.TexSource, handles)] + handles, SS_MAP)



#
# Drag Objects
#

class RectSelDragObject(qhandles.RectangleDragObject):
    "A red rectangle that selects the polyhedrons it touches."

    Hint = "rectangular selection of polyhedrons||After you click on this button, click and move the mouse on the map to draw a rectangle; all polyhedrons touching this rectangle will be selected.\n\nHold down Ctrl to prevent already selected polyhedron from being unselected first."

    def rectanglesel(self, editor, x,y, rectangle):
        if not ("T" in self.todo):
            editor.layout.explorer.uniquesel = None
        polylist = FindSelectable(editor.Root, ":p")
        lastsel = None
        for p in polylist:
            if rectangle.intersects(p):
                p.selected = 1
                lastsel = p
        if lastsel is not None:
            editor.layout.explorer.focus = lastsel
            editor.layout.explorer.selchanged()


#
# Mouse Clicking and Dragging on map views.
#

def MouseDragging(self, view, x, y, s, handle):
    "Mouse Drag on a Map View."

    #
    # qhandles.MouseDragging builds the DragObject.
    #

    if handle is not None:
        s = handle.click(self)
        if s and ("S" in s):
            self.layout.actionmpp()  # update the multi-pages-panel

    return qhandles.MouseDragging(self, view, x, y, s, handle, MapColor("GrayImage"))


def ClickOnView(editor, view, x, y):
    return view.clicktarget(editor.Root, x, y)


def MouseClicked(self, view, x, y, s, handle):
    "Mouse Click on a Map view."

    #
    # qhandles.MouseClicked manages the click but doesn't actually select anything
    #

    flags = qhandles.MouseClicked(self, view, x, y, s, handle)

    if "1" in flags:

        #
        # This mouse click must select something.
        #

        self.layout.setupdepth(view)
        choice = ClickOnView(self, view, x, y)
         # this is the list of polys & entities we clicked on
        if len(choice):
            choice.sort()   # list of (clickpoint,object) tuples - sort by depth
            last = qhandles.findlastsel(choice)
            if ("M" in s) and last:    # if Menu, we try to keep the currently selected objects
                return flags
            if "T" in s:    # if Multiple selection request
                obj = qhandles.findnextobject(choice)
                obj.togglesel()
                if obj.selected:
                    self.layout.explorer.focus = obj
                self.layout.explorer.selchanged()
            else:
                if last:  last = last - len(choice)
                self.layout.explorer.uniquesel = choice[last][1]
        else:
            if not ("T" in s):    # clear current selection
                self.layout.explorer.uniquesel = None
        return flags+"S"
    return flags


#
# Single face map view display for the Multi-Pages Panel.
#

def viewsingleface(editor, view, face):
    "Special code to view a single face with handles to move the texture."

    def drawsingleface(view, face=face, editor=editor):
        view.drawmap(face)   # textured face
        view.solidimage(editor.TexSource)
        #for poly in face.faceof:
        #    view.drawmap(poly, DM_OTHERCOLOR, 0x2584C9)   # draw the full poly contour
        view.drawmap(face, DM_REDRAWFACES|DM_OTHERCOLOR, 0x2584C9)   # draw the face contour
        editor.finishdrawing(view)
        # end of drawsingleface

    origin = face.origin
    if origin is None: return
    n = face.normal
    if not n: return

    h = []
     # add the vertices of the face
    for p in face.faceof:
        if p.type == ':p':
            for v in face.verticesof(p):
                h.append(VertexHandle(v, p))
    view.handles = qhandles.FilterHandles(h, SS_MAP) + BuildCyanLHandles(editor, face)

#DECKER - begin
    #FIXME - Put a check for an option-switch here, so people can choose which they want (fixed-zoom/scroll, or reseting-zoom/scroll)
    oldx, oldy, doautozoom = 0, 0, 0
    try:
        oldorigin = view.info["origin"]
        if not abs(origin - oldorigin):
            oldscale = view.info["scale"]
            if oldscale is None:
                doautozoom = 1
            oldx, oldy = view.scrollbars[0][0], view.scrollbars[1][0]
        else:
            doautozoom = 1
    except:
        doautozoom = 1

    if doautozoom:
        oldscale = 0.01
#DECKER - end

    v = orthogonalvect(n, editor.layout.views[0])
    view.flags = view.flags &~ (MV_HSCROLLBAR | MV_VSCROLLBAR)
    view.viewmode = "tex"
    view.info = {"type": "2D",
                 "matrix": ~ quarkx.matrix(v, v^n, -n),
                 "bbox": quarkx.boundingboxof([face] + map(lambda h: h.pos, view.handles)),
                 "scale": oldscale, #DECKER
                 "custom": singlefacezoom,
                 "origin": origin,
                 "noclick": None,
                 "mousemode": None }
    singlefacezoom(view, origin)
    if doautozoom: #DECKER
        singlefaceautozoom(view, face) #DECKER
    editor.setupview(view, drawsingleface, 0)
    if (oldx or oldy) and not doautozoom: #DECKER
        view.scrollto(oldx, oldy) #DECKER
    return 1


def singlefaceautozoom(view, face):
    scale1, center1 = AutoZoom([view], view.info["bbox"], margin=(36,34))
    if scale1 is None:
        return 0
    if scale1>1.0:
        scale1=1.0
    if abs(scale1-view.info["scale"])<=epsilon:
        return 0
    view.info["scale"] = scale1
    singlefacezoom(view, center1)
    return 1

    #for test in (0,1):
    #    scale1, center1 = AutoZoom([view], view.info["bbox"], margin=(36,34))
    #    if (scale1 is None) or (scale1>=1.0) or (abs(scale1-view.info["scale"])<=epsilon):
    #        return test
    #    view.info["scale"] = scale1
    #    singlefacezoom(view, center1)   # do it twice because scroll bars may disappear
    #return 1


def singlefacezoom(view, center=None):
    if center is None:
        center = view.screencenter
    view.setprojmode("2D", view.info["matrix"]*view.info["scale"], 0)
    bmin, bmax = view.info["bbox"]
    x1=y1=x2=y2=None
    for x in (bmin.x,bmax.x):   # all 8 corners of the bounding box
        for y in (bmin.y,bmax.y):
            for z in (bmin.z,bmax.z):
                p = view.proj(x,y,z)
                if (x1 is None) or (p.x<x1): x1=p.x
                if (y1 is None) or (p.y<y1): y1=p.y
                if (x2 is None) or (p.x>x2): x2=p.x
                if (y2 is None) or (p.y>y2): y2=p.y
    view.setrange(x2-x1+36, y2-y1+34, 0.5*(bmin+bmax))

     # trick : if we are far enough and scroll bars are hidden,
     # the code below clamb the position of "center" so that
     # the picture is completely inside the view.
    x1=y1=x2=y2=None
    for x in (bmin.x,bmax.x):   # all 8 corners of the bounding box
        for y in (bmin.y,bmax.y):
            for z in (bmin.z,bmax.z):
                p = view.proj(x,y,z)    # re-proj... because of setrange
                if (x1 is None) or (p.x<x1): x1=p.x
                if (y1 is None) or (p.y<y1): y1=p.y
                if (x2 is None) or (p.x>x2): x2=p.x
                if (y2 is None) or (p.y>y2): y2=p.y
    w,h = view.clientarea
    w,h = (w-36)/2, (h-34)/2
    x,y,z = view.proj(center).tuple
    t1,t2 = x2-w,x1+w
    if t2>=t1:
        if x<t1: x=t1
        elif x>t2: x=t2
    t1,t2 = y2-h,y1+h
    if t2>=t1:
        if y<t1: y=t1
        elif y>t2: y=t2
    view.screencenter = view.space(x,y,z)
    p = view.proj(view.info["origin"])
    view.depth = (p.z-0.1, p.z+100.0)

#
# Single bezier map view display for the Multi-Pages Panel.
#

def viewsinglebezier(view, layout, patch):
    cpts = patch.cp
    if cpts is None:
        return
    texlist = quarkx.texturesof([patch])
    ed = mapeditor()
    if len(texlist)==1:
#        tex = quarkx.loadtexture(texlist[0], layout.editor.TexSource)
        tex = quarkx.loadtexture(texlist[0], ed.TexSource)
        try:
            tex = tex.disktexture
            w,h = tex["Size"]
        except:
            pass
        else:
            if type==':b3':
                vst = patch.vst
            else:
                vst = []
                for row in patch.cp:
                    for p in row:
                        vst.append(quarkx.vect(p.s, p.t, 0))
            matrix = quarkx.matrix((1,0,0), (0,1,0), (0,0,1))
            xmin = xmax = vst[0].x
            ymin = ymax = vst[0].y
            for v in vst[1:]:
                if v.x<xmin: xmin=v.x
                if v.x>xmax: xmax=v.x
                if v.y<ymin: ymin=v.y
                if v.y>ymax: ymax=v.y
            destx, desty = view.clientarea
            scale = (destx-35) / ((xmax-xmin+0.05)*w)
            scaley = (desty-35) / ((ymax-ymin+0.05)*h)
            if scaley<scale: scale=scaley
            if scale<0.01: scale=0.01
            if scale>1.0: scale=1.0

            view.setprojmode("2D", matrix*scale)
            view.info = {"type": "2D",
                   "matrix": matrix,
                   "scale": scale,
                   "custom": singlebezierzoom,
                   "noclick": None,
                   "mousemode": None }
            def draw1(view, finish=layout.editor.finishdrawing, w=w, h=h):
                pt = view.space(quarkx.vect(0,0,0))
                pt = view.proj(quarkx.vect(math.floor(pt.x), math.floor(pt.y), 0))
                #view.canvas().painttexture(tex, (pt.x,pt.y)+view.clientarea, 0)
                view.drawgrid(quarkx.vect(w*view.info["scale"],0,0), quarkx.vect(0,h*view.info["scale"],0), MAROON, DG_LINES, 0, quarkx.vect(0,0,0))
                finish(view)
            view.ondraw = draw1
            view.onmouse = layout.editor.mousemap
            cp = patch.cp
            h2 = []
            m, n = len(cp), len(cp[0])
            for i in range(m):
                for j in range(n):
                    h2.append(CyanBezier2Handle((i,j), cp, patch, (w, h)))
            mainhandle = CyanBezier2Handle0(cp, patch, h2, (w,h))
            h2 = [mainhandle] + h2


            #
            # Display a linear mapping box.
            #
            manager = BTLinHandlesManager(MapColor("Linear"),
                  (quarkx.vect(w*xmin,h*ymin,0),quarkx.vect(w*xmax,h*ymax,0)), [patch])
            manager.scale = w,h
#
# Linear mapping in bez box, can't make it work
#
#            if layout.editor.linearbox:
#                minimal = None
#            else:
#                minimal = (view, layout.editor.gridstep or 32)
#            h1 = manager.BuildHandles(minimal=minimal)
#            getdrawmap1 = lambda patch=patch: (patch, qhandles.refreshtimertex)
#            for i in h1:
#                i.getdrawmap = getdrawmap1
#            mainhandle.friends = mainhandle.friends + h1
#            view.handles = h2 + h1
            view.handles = h2
            view.background = tex, quarkx.vect(0,0,0), 1.0
            view.screencenter = mainhandle.getcenter()
            return 1

def singlebezierzoom(view):
    sc = view.screencenter
    view.setprojmode("2D", view.info["matrix"]*view.info["scale"], 0)
    view.screencenter = sc
    
def GetUserCenter(obj):
    debug('type: '+`type(obj)`)
    if type(obj) is type([]):  # obj is list
        if len(obj)==1 and obj[0]["usercenter"] is not None:
            uc = obj[0]["usercenter"]
        else:
            box=quarkx.boundingboxof(obj)
            return (box[0]+box[1])/2
    else:
        uc = obj["usercenter"]
    if uc is None:
        uc = mapentities.ObjectOrigin(obj).tuple
    return quarkx.vect(uc)

def SetUserCenter(obj, v):
    obj["usercenter"] = v.tuple

def macro_usercenter(self):
    from qeditor import mapeditor
    editor=mapeditor()
    if editor is None: return
    dup = editor.layout.explorer.uniquesel
    if not dup: return
    undo = quarkx.action()
    from mapentities import ObjectOrigin
    tup = ObjectOrigin(dup).tuple
    debug('tup '+`tup`)
    undo.setspec(dup,'usercenter',tup)
    debug('set')
    editor.ok(undo,'add usercenter')
    debug('ok')
    editor.invalidateviews()
    
qmacro.MACRO_usercenter = macro_usercenter
class UserCenterHandle(CenterHandle):

    def __init__(self, dup):
        pos = GetUserCenter(dup)
        CenterHandle.__init__(self, pos, dup, MapColor("Axis"))


    def drag(self, v1, v2, flags, view):
        delta = v2-v1
        dup = self.centerof.copy()
        SetUserCenter(dup, GetUserCenter(dup)+delta)
        return [self.centerof], [dup]
    
# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.15  2001/04/02 21:09:44  tiglari
#fixes to getusercenter, ntp tuple-hood
#
#Revision 1.14  2001/04/02 09:23:11  tiglari
#stuck various things to try to nail down supposed fixpoint vertices in the
#vtx movement code
#
#Revision 1.13  2001/04/01 00:07:13  tiglari
#revisions to GetUserCenter
#
#Revision 1.12  2001/03/31 10:15:22  tiglari
#support for usercenter specific
#
#Revision 1.11  2001/03/01 19:14:58  decker_dk
#Fix for CyanBezier2Handle.drag 'if new:'. Now testing for 'if new is not None:'.
#
#Revision 1.10  2001/02/28 09:46:43  tiglari
#linear mapping handles removed from bez page
#
#Revision 1.9  2001/02/25 11:22:51  tiglari
#bezier page support, transplanted with permission from CryEd (CryTek)
#
#Revision 1.8  2001/02/07 18:40:47  aiv
#bezier texture vertice page started.
#
#Revision 1.7  2000/06/17 07:32:06  tiglari
#a slight change to clickedview
#
#Revision 1.6  2000/06/16 10:44:54  tiglari
#CenterHandle menu function adds clickedview to editor.layout
#(for support of perspective-driven curve creation in mb2curves.py)
#
#Revision 1.5  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#