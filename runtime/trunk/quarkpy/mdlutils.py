"""   QuArK  -  Quake Army Knife

Various Model editor utility functions.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$

import quarkx
import qutils
from qeditor import *
from math import *

### Globals
keyframesrotation = 0

###############################
#
# Operational functions
#
###############################



def checkinlist(tri, toberemoved):
  for tbr in toberemoved:
    if (tri == tbr):
      return 1
  return 0


#
# Is a given object still in the tree view = 1, or was it removed = 0 ?
#
def checktree(root, obj):
    while obj is not root:
        t = obj.parent
        if t is None or not (obj in t.subitems):
            return 0
        obj = t
    return 1


#
# The UserDataPanel class, overridden to be model-specific.
#
class MdlUserDataPanel(UserDataPanel):

    def btnclick(self, btn):
        #
        # Send the click message to the module mdlbtns.
        #
        import mdlbtns
        mdlbtns.mdlbuttonclick(btn)


    #def drop(self, btnpanel, list, i, source):
        #if len(list)==1 and list[0].type == ':g':
        #    quarkx.clickform = btnpanel.owner
        #    editor = mapeditor()
        #    if editor is not None and source is editor.layout.explorer:
        #        choice = quarkx.msgbox("You are about to create a new button from this group. Do you want the button to display a menu with the items in this group ?\n\nYES: you can pick up individual items when you click on this button.\nNO: you can insert the whole group in your map by clicking on this button.", MT_CONFIRMATION, MB_YES_NO_CANCEL)
        #        if choice == MR_CANCEL:
        #            return
        #        if choice == MR_YES:
        #            list = [group2folder(list[0])]
        #UserDataPanel.drop(self, btnpanel, list, i, source)



def find2DTriangles(comp, tri_index, ver_index):
    "This function returns triangles and their index of a component's"
    "mesh that have a common vertex position of the 2D drag view."
    "This is primarily used for the Skin-view mesh drag option."
    "See the mdlhandles.py file class SkinHandle, drag function for its use."
    tris = comp.triangles
    tris_out = {}
    i = 0
    for tri in tris:
        for vtx in tri:
            if str(vtx) == str(tris[tri_index][ver_index]):
              if i == tri_index:
                  break
              else:
                  tris_out[i] = tri
                  break
        i = i + 1
    return tris_out


#
# Checks all values, in the same list position, of two tuples
# and returns 1 if they are all nearly the same.
# Used for comparing vectors for possible dragging together.
#
def checktuplepos(tuple1, tuple2):
    for i in range(len(tuple1)):
        if abs(tuple1[i] - tuple2[i]) < 0.0001:
            if i == len(tuple1)-1:
                return 1
            continue
        else:
            return 0



#
# Calculate Position of a Point along the vector AC, Keeping L (Length)
# This function is used to calculate the new position of a "Bone" drag handle
# to keep a bone the same length during and after a drag movement.
#
def ProjectKeepingLength(A,C,L):
    def NormaliseVect(v1, v2):
        le = sqrt( pow(v2.x - v1.x, 2) + 
                   pow(v2.y - v1.y, 2) + 
                   pow(v2.z - v1.z, 2) )
        if (le <> 0):
            v = quarkx.vect( \
                (v2.x - v1.x) / le, \
                (v2.y - v1.y) / le, \
                (v2.z - v1.z) / le  )
        else:
            v = quarkx.vect(0,0,0)
        return v
    n = NormaliseVect(A, C)
    xxx = quarkx.vect(
        A.x + (L * n.x),
        A.y + (L * n.y),
        A.z + (L * n.z)
        )
    return xxx


#
# Checks triangle for vertex [index]
#
def checkTriangle(tri, index):
    for c in tri:
        if (c[0] == index): # c[0] is the 'vertexno'
            return 1
    return 0


#
#  Find a triangle based on the 3 vertex indexs that are given.
#  DanielPharos: Make sure v1, v2 and v3 are different!
#
def findTriangle(comp, v1, v2, v3):
    tris = comp.triangles
    index = -1
    for tri in tris:
        index = index + 1
        b = 0
        v1found = 0
        v2found = 0
        v3found = 0
        for c in tri:
            if v1found == 0:
                if (v1 == c[0]):
                    v1found = 1
                    b = b + 1
            if v2found == 0:
                if (v2 == c[0]):
                    v2found = 1
                    b = b + 1
            if v3found == 0:
                if (v3 == c[0]):
                    v3found = 1
                    b = b + 1
            if b == 3:
                return index
    return None


#
# Find other triangles containing a vertex at the same location
# as the one selected creating a VertexHandle instance.
# ONLY returns the triangle objects themselves, but NOT their tri_index numbers.
# To get both use the findTrianglesAndIndex function below this one.
# For example call this function like this (for clarity):
#    component = editor.layout.explorer.uniquesel
#    handlevertex = self.index
#    if component.name.endswith(":mc"):
#        tris = findTriangles(component, handlevertex)
# or like this (to be brief):
#    comp = editor.layout.explorer.uniquesel
#    if comp.name.endswith(":mc"):
#        tris = findTriangles(comp, self.index)
#
def findTriangles(comp, index):
    tris = comp.triangles
    tris_out = [ ]
    for tri in tris:
        found_com_vtx_pos_tri = checkTriangle(tri, index)
        if (found_com_vtx_pos_tri == 1):
            tris_out = tris_out + [ tri ]
    return tris_out


#
# Find and return other triangles (AND their tri_index and ver_index_order_pos numbers)
# containing a vertex at the same location as the one selected creating a VertexHandle instance.
# Also returns each triangles vertex, vert_index and vert_pos for the following complete list items.
###|--- contence ---|-------- format -------|----------------------- discription -----------------------|
#   Editor vertexes  (frame_vertices_index, view.proj(pos), tri_index, ver_index_order_pos, (tri_vert0,tri_vert1,tri_vert2))
#                    Created using:    editor.Root.currentcomponent.currentframe.vertices
#                                         (see Infobase docs help/src.quarkx.html#objectsmodeleditor)
#                               item 0: Its "Frame" "vertices" number, which is the same number as a triangles "ver_index" number.
#                               item 1: Its 3D grid pos "projected" to a x,y 2D view position.
#                                       The "pos" needs to be a projected position for a decent size application
#                                       to the "Skin-view" when a new triangle is made in the editor.
#                               item 2: The Model component mesh triangle number this vertex is used in (usually more then one triangle).
#                               item 3: The ver_index_order_pos number is its order number position of the triangle points, either 0, 1 or 2.
#                               item 4: All 3 of the triangles vertexes data (ver_index, u and v (or x,y) projected texture 2D Skin-view positions)
#
def findTrianglesAndIndexes(comp, vert_index, vert_pos):
    tris = comp.triangles
    tris_out = [ ]
    for tri_index in range(len(tris)):
        found_com_vtx_pos_tri = checkTriangle(tris[tri_index], vert_index)
        if (found_com_vtx_pos_tri == 1):
            if vert_index == tris[tri_index][0][0]:
                tris_out = tris_out + [[vert_index, vert_pos, tri_index, 0, tris[tri_index]]]
            elif vert_index == tris[tri_index][1][0]:
                tris_out = tris_out + [[vert_index, vert_pos, tri_index, 1, tris[tri_index]]]
            else:
                tris_out = tris_out + [[vert_index, vert_pos, tri_index, 2, tris[tri_index]]]
    return tris_out



# 'index' the vertex index number that is being deleted and is used in the triangle 'tri'.
# This funciton fixes the vert_index number for one particular triangle.
def fixTri(tri, index):
    new_tri = [ ]
    for c in tri:
        v = 0
        if ( c[0] > index):
            v = c[0]-1
        else:
            v = c[0]
        s = c[1]
        t = c[2]
        new_tri = new_tri + [(v,s,t)]
    return (new_tri[0], new_tri[1], new_tri[2])


#
# 'index' is a vertex index number that is being deleted and is used in the triangle 'tri'.
# This funciton fixes the vert_index numbers for all triangles in the list 'tris'.
# Goes through tri list: if greaterthan index then takes 1 away from vertexno.
#
def fixUpVertexNos(tris, index):
    new_tris = [ ]
    for tri in tris:
         x = fixTri(tri, index)
         new_tris = new_tris + [x]
    return new_tris



###############################
#
# Vertex functions
#
###############################


#
# Add a vertex to the currently selected model component or frame(s)
# at the position where the cursor was when the RMB was clicked.
#
def addvertex(editor, comp, pos):
    new_comp = comp.copy()
    compframes = new_comp.findallsubitems("", ':mf')   # find all frames
    for compframe in compframes:
        vtxs = compframe.vertices
        vtxs = vtxs + [pos]
        compframe.vertices = vtxs
        compframe.compparent = new_comp # To allow frame relocation after editing.
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    editor.ok(undo, "add vertex")


#
# Updates (drags) a vertex or vertexes in the 'editor.SkinVertexSelList' list, or similar list,
#    of the currently selected model component or frame(s),
#    to the same position of the 1st item in the 'editor.SkinVertexSelList' list.
# The 'editor.SkinVertexSelList' list is a group of lists within a list.
# If 'option 1' is used for the Skin-view then
# each group list must be created in the manner below then added to the 'editor.SkinVertexSelList' list:
#    editor.SkinVertexSelList + [[self.pos, self, self.tri_index, self.ver_index]]
# if 'option 0' is used for the Model Editor then
# each group list must be created in the manner below then added to the 'editor.ModelVertexSelList' list:
#    editor.ModelVertexSelList + [[frame_vertices_index, view.proj(pos)]]
#
def replacevertexes(editor, comp, vertexlist, flags, view, undomsg, option=1, method=1):
    "option=0 uses the ModelVertexSelList for the editor."
    "option=1 uses the SkinVertexSelList for the Skin-view."
    "option=2 uses the ModelVertexSelList for the editor and merges two, or more, selected vertexes."
    "method=1 other selected vertexes move to the 'Base' vertex position of each tree-view selected 'frame', only applies to option=0."
    "method=2 other selected vertexes move to the 'Base' vertex position of the 1st tree-view selected 'frame', only applies to option=0."

    new_comp = comp.copy()

    if option == 0:
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            for listframe in editor.layout.explorer.sellist:
                if compframe.name == listframe.name:
                    old_vtxs = compframe.vertices
                    if quarkx.setupsubset(SS_MODEL, "Options")['APVexs_Method1'] == "1":
                        newpos = old_vtxs[vertexlist[0][0]]
                    elif quarkx.setupsubset(SS_MODEL, "Options")['APVexs_Method2'] == "1":
                        newpos = editor.layout.explorer.sellist[0].vertices[vertexlist[0][0]]
                    else:
                        newpos = old_vtxs[vertexlist[0][0]]
                    for vtx in vertexlist:
                        if vtx == vertexlist[0]:
                            continue
                        old_vtxs[vtx[0]] = newpos
                        compframe.vertices = old_vtxs
            compframe.compparent = new_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)

    elif option == 1:
        tris = new_comp.triangles
        try:
            tex = comp.currentskin
            texWidth,texHeight = tex["Size"]
        except:
            texWidth,texHeight = view.clientarea

        if comp.currentskin is not None:
            newpos = vertexlist[0][0] + quarkx.vect(texWidth*.5, texHeight*.5, 0)
        else:
            newpos = vertexlist[0][0] + quarkx.vect(int((texWidth*.5) +.5), int((texHeight*.5) -.5), 0)

        for triindex in range(len(tris)):
            tri = tris[triindex]
            for item in vertexlist:
                if triindex == item[2]:
                    for j in range(len(tri)):
                        if j == item[3]:
                            if j == 0:
                                newtriangle = ((tri[j][0], int(newpos.tuple[0]), int(newpos.tuple[1])), tri[1], tri[2])
                            elif j == 1:
                                newtriangle = (tri[0], (tri[j][0], int(newpos.tuple[0]), int(newpos.tuple[1])), tri[2])
                            else:
                                newtriangle = (tri[0], tri[1], (tri[j][0], int(newpos.tuple[0]), int(newpos.tuple[1])))
                            tris[triindex] = newtriangle
        new_comp.triangles = tris
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            compframe.compparent = new_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)

    elif option == 2:
        tris = new_comp.triangles
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        unusedvtxs = []
        for vtx in range(len(vertexlist)):
            if vtx == 0:
                continue
            unusedvtxs = unusedvtxs + [vertexlist[vtx][0]]
        newvertnumbers = []
        newvertoffset = 0
        old_vtxs = comp.currentframe.vertices
        for v in range(len(old_vtxs)):
            if v == vertexlist[0][0]:
                newindex = v + newvertoffset
            if v in unusedvtxs:
                newvertoffset = newvertoffset - 1
            newvertnumbers = newvertnumbers + [v + newvertoffset]
        for v in range(len(vertexlist)):
            newvertnumbers[vertexlist[v][0]] = newindex
        for triindex in range(len(tris)):
            tri = tris[triindex]
            newtriangle = ((newvertnumbers[tri[0][0]], tri[0][1], tri[0][2]), (newvertnumbers[tri[1][0]], tri[1][1], tri[1][2]), (newvertnumbers[tri[2][0]], tri[2][1], tri[2][2]))
            if newtriangle[0][0] == newtriangle[1][0] or newtriangle[1][0] == newtriangle[2][0] or newtriangle[2][0] == newtriangle[0][0]:
                quarkx.msgbox("Improper Selection!\n\nYou can not merge two\nvertexes of the same triangle.", MT_ERROR, MB_OK)
                return None, None
            tris[triindex] = newtriangle
        unusedvtxs.sort()
        unusedvtxs.reverse()
        vtxs = []
        for compframe in compframes:
            old_vtxs = compframe.vertices
            for index in range(len(unusedvtxs)):
                vtxs = old_vtxs[:unusedvtxs[index]] + old_vtxs[unusedvtxs[index]+1:]
                old_vtxs = vtxs

            compframe.vertices = vtxs
            compframe.compparent = new_comp # To allow frame relocation after editing.

        new_comp.triangles = tris
        editor.ModelVertexSelList = []
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)


#
# remove a vertex from a component
#
def removevertex(comp, index, all3=0):
    editor = mapeditor()
    if editor is None:
        return

    new_comp = comp.copy() # create a copy to edit (we store the old one in the undo list)
    tris = new_comp.triangles
    #### 1) find all triangles that use vertex 'index' and delete them.
    if all3 == 1:
        index = editor.ModelVertexSelList[0][0]
    toBeRemoved = findTriangles(comp, index)
    new_tris = []
    for tri in tris:
        p = checkinlist(tri, toBeRemoved)
        if (p==0):
            new_tris = new_tris + [ tri ]
    
    if all3 == 1:
        new_tris = []
        for tri in tris:
            if (editor.ModelVertexSelList[0][0] == tri[0][0]) and (editor.ModelVertexSelList[1][0] == tri[1][0]) and (editor.ModelVertexSelList[2][0] == tri[2][0]):
                index = editor.ModelVertexSelList[0][0]
                continue
            elif (editor.ModelVertexSelList[0][0] == tri[0][0]) and (editor.ModelVertexSelList[2][0] == tri[1][0]) and (editor.ModelVertexSelList[1][0] == tri[2][0]):
                index = editor.ModelVertexSelList[0][0]
                continue
            elif (editor.ModelVertexSelList[1][0] == tri[0][0]) and (editor.ModelVertexSelList[2][0] == tri[1][0]) and (editor.ModelVertexSelList[0][0] == tri[2][0]):
                index = editor.ModelVertexSelList[1][0]
                continue
            elif (editor.ModelVertexSelList[1][0] == tri[0][0]) and (editor.ModelVertexSelList[0][0] == tri[1][0]) and (editor.ModelVertexSelList[2][0] == tri[2][0]):
                index = editor.ModelVertexSelList[1][0]
                continue
            elif (editor.ModelVertexSelList[2][0] == tri[0][0]) and (editor.ModelVertexSelList[1][0] == tri[1][0]) and (editor.ModelVertexSelList[0][0] == tri[2][0]):
                index = editor.ModelVertexSelList[2][0]
                continue
            elif (editor.ModelVertexSelList[2][0] == tri[0][0]) and (editor.ModelVertexSelList[0][0] == tri[1][0]) and (editor.ModelVertexSelList[1][0] == tri[2][0]):
                index = editor.ModelVertexSelList[2][0]
                continue
            else:
                new_tris = new_tris + [ tri ]

    #### 2) loop through all frames and delete unused vertex(s).
    if all3 == 1:
        vertexestoremove = []
        for vertex in editor.ModelVertexSelList:
            vtxcount = 0
            for tri in tris:
                for vtx in tri:
                    if vtx[0] == vertex[0]:
                        vtxcount = vtxcount + 1
            if vtxcount > 1:
                pass
            else:
                vertexestoremove = vertexestoremove + [vertex]
        compframes = new_comp.findallsubitems("", ':mf')   # find all frames
        for unusedvertex in vertexestoremove:
            unusedindex = unusedvertex[0]
            for compframe in compframes: 
                old_vtxs = compframe.vertices
                vtxs = old_vtxs[:unusedindex]
                compframe.vertices = vtxs
                compframe.compparent = new_comp # To allow frame relocation after editing.
        new_tris = fixUpVertexNos(new_tris, index)
        new_comp.triangles = new_tris
    else:
        enew_tris = fixUpVertexNos(new_tris, index)
        new_comp.triangles = enew_tris
        compframes = new_comp.findallsubitems("", ':mf')   # find all frames
        for compframe in compframes: 
            old_vtxs = compframe.vertices
            vtxs = old_vtxs[:index] + old_vtxs[index+1:]
            compframe.vertices = vtxs
            compframe.compparent = new_comp # To allow frame relocation after editing.

    #### 3) re-build all views
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    if all3 == 1:
        editor.ok(undo, "remove triangle")
        editor.ModelVertexSelList = []
    else:
        editor.ok(undo, "remove vertex")
        editor.ModelVertexSelList = []



###############################
#
# Triangle & Face functions
#
###############################


#
# Add a triangle to a given component
#
def addtriangle(editor):
    comp = editor.Root.currentcomponent
    if (comp is None):
        return

    v1 = editor.ModelVertexSelList[0][0]
    v2 = editor.ModelVertexSelList[1][0]
    v3 = editor.ModelVertexSelList[2][0]

    from mdlhandles import SkinView1
    if quarkx.setupsubset(SS_MODEL, "Options")['SkinFrom3Dview'] == "1" or SkinView1 is None:
        for v in editor.layout.views:
            if v.info["viewname"] == "editors3Dview":
                cordsview = v
    else:

        try:
            tex = comp.currentskin
            texWidth,texHeight = tex["Size"]
            if quarkx.setupsubset(SS_MODEL, "Options")['UseSkinViewScale'] == "1":
                SkinViewScale = SkinView1.info["scale"]
            else:
                SkinViewScale = 1
        except:
            texWidth,texHeight = SkinView1.clientarea
            SkinViewScale = 1
    if quarkx.setupsubset(SS_MODEL, "Options")['SkinFrom3Dview'] == "1" or SkinView1 is None:
        s1 = int(cordsview.proj(editor.ModelVertexSelList[0][1]).tuple[0])*.025
        t1 = -int(cordsview.proj(editor.ModelVertexSelList[0][1]).tuple[1])*.025
        s2 = int(cordsview.proj(editor.ModelVertexSelList[1][1]).tuple[0])*.025
        t2 = -int(cordsview.proj(editor.ModelVertexSelList[1][1]).tuple[1])*.025
        s3 = int(cordsview.proj(editor.ModelVertexSelList[2][1]).tuple[0])*.025
        t3 = -int(cordsview.proj(editor.ModelVertexSelList[2][1]).tuple[1])*.025
    else:
        s1 = int(editor.ModelVertexSelList[0][1].tuple[0]+int(texWidth*.5))*SkinViewScale
        t1 = int(editor.ModelVertexSelList[0][1].tuple[1]-int(texHeight*.5))*SkinViewScale
        s2 = int(editor.ModelVertexSelList[1][1].tuple[0]+int(texWidth*.5))*SkinViewScale
        t2 = int(editor.ModelVertexSelList[1][1].tuple[1]-int(texHeight*.5))*SkinViewScale
        s3 = int(editor.ModelVertexSelList[2][1].tuple[0]+int(texWidth*.5))*SkinViewScale
        t3 = int(editor.ModelVertexSelList[2][1].tuple[1]-int(texHeight*.5))*SkinViewScale

    if findTriangle(comp, v1, v2, v3) is not None:
        quarkx.msgbox("Improper Selection!\n\nA triangle using these 3 vertexes already exist.\n\nSelect at least one different vertex\nto make a new triangle with.\n\nTo 'Un-pick' a vertex from the 'Pick' list\nplace your cursor over that vertex,\nRMB click and select 'Pick Vertex'.\nThen you can pick another vertex to replace it.", MT_ERROR, MB_OK)
        return

    tris = comp.triangles

    tris = tris + [((v1,s1,t1),(v2,s2,t2),(v3,s3,t3))] # This is where the 'actual' texture positions s and t are needed to add to the triangles vertexes.

    new_comp = comp.copy()
    new_comp.triangles = tris
    new_comp.currentskin = editor.Root.currentcomponent.currentskin
    new_comp.currentframe = editor.Root.currentcomponent.currentframe
    compframes = new_comp.findallsubitems("", ':mf')   # get all frames
    for compframe in compframes:
        compframe.compparent = new_comp # To allow frame relocation after editing.
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    editor.Root.currentcomponent = new_comp
    editor.ok(undo, "add triangle")
    if SkinView1 is not None:
        SkinView1.invalidate()


#
# Remove a triangle ,using its triangle index, from the current component
#
def removeTriangle(editor, comp, index):
    if (index is None):
        return
    todo = quarkx.msgbox("Do you also want to\nremove the 3 vertexes?",MT_CONFIRMATION, MB_YES_NO_CANCEL)
    if todo == MR_CANCEL:
        return
    if todo == MR_YES:
        vertexestoremove = []
        for vertex in editor.ModelVertexSelList:
            vtxcount = 0
            tris = comp.triangles
            for tri in tris:
                for vtx in tri:
                    if vtx[0] == vertex[0]:
                        vtxcount = vtxcount + 1
            if vtxcount > 1:
                pass
            else:
                vertexestoremove = vertexestoremove + [vertex]
        if len(vertexestoremove) == 0:
            pass
        else:
            removevertex(comp, index, 1)
            return
    new_comp = comp.copy()
    old_tris = new_comp.triangles
    tris = old_tris[:index] + old_tris[index+1:]
    new_comp.triangles = tris
    compframes = new_comp.findallsubitems("", ':mf')   # get all frames
    for compframe in compframes:
        compframe.compparent = new_comp # To allow frame relocation after editing.
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    editor.ok(undo, "remove triangle")


#
# Remove a triangle ,using its vertexes, from the current component
#
def removeTriangle_v3(editor):
    comp = editor.Root.currentcomponent
    v1 = editor.ModelVertexSelList[0][0]
    v2 = editor.ModelVertexSelList[1][0]
    v3 = editor.ModelVertexSelList[2][0]
    removeTriangle(editor, comp, findTriangle(comp, v1,v2,v3))


#
# The 'option' value of 1 COPIES the currently selected faces of a component to another component (that is not Hidden).
# The 'option' value of 2 MOVES the currently selected faces of a component to another component (that is not Hidden).
# This function will also remove the selected faces and unused vertexes from the original component.
# The 'option' value of 3 DELETES the currently selected faces of a component.
# This function will also remove any unused vertexes of those faces from that component.
#
def movefaces(editor, movetocomponent, option=2):
    comp = editor.Root.currentcomponent

    # This section does a selection test and gives an error message box if needed.
    for item in editor.layout.explorer.sellist:
        if item.parent.parent.name != comp.name:
            quarkx.msgbox("IMPROPER SELECTION !\n\nYou need to select a frame && faces from\none component to move them to another component.\n\nYou have selected items that are not\npart of the ''"+editor.Root.currentcomponent.shortname+"'' Frames group.\nPlease un-select these items.\n\nAction Canceled.", MT_ERROR, MB_OK)
            return

    # These are things that we need to setup first for use later on.
    temp_list = []
    remove_triangle_list = []
    remove_vertices_list = []

    # Now we start creating our data copies to work with and the final "ok" swapping function at the end.
    tris = comp.triangles
    change_comp = comp.copy()
    if option < 3:
        new_comp = editor.Root.dictitems[movetocomponent + ':mc'].copy()

    # This section creates the "remove_triangle_list" from the ModelFaceSelList which is already
    #    in ascending numerical order but may have duplicate tri_index numbers that need to be removed.
    # The order also needs to be descending so when triangles are removed from another list it
    #    does not select an improper triangle due to list items shifting forward numerically.
    # The "remove_triangle_list" is used to re-create the current component.triangles and new_comp.triangles.
    for tri_index in reversed(editor.ModelFaceSelList):
        if tri_index in remove_triangle_list:
            pass
        else:
            remove_triangle_list = remove_triangle_list + [tri_index]

    # This section creates the "remove_vertices_list" to be used
    #    to re-create the current component's frame.vertices.
    # It also skips over any duplicated vertex_index numbers of the triangles to be moved
    #    to the new_comp and\or removed from the original component if 'option' calls to.
    for tri_index in remove_triangle_list:
        for vtx in range(len(tris[tri_index])):
            if tris[tri_index][vtx][0] in temp_list:
                pass
            else:
                temp_list.append(tris[tri_index][vtx][0])

    # This section sorts the "remove_vertices_list" numerically in ascending order then
    # recreates it in descending order for the same reason that the triangles above were done.
    temp_list.sort()
    for item in reversed(temp_list):
        remove_vertices_list.append(item)

    ###### NEW COMPONENT SECTION ######
    if option < 3:

    # This first part adds the new triangles, which are the ones that have been selected,
    #    to the "moveto" new_comp.triangles using the "remove_triangle_list" which are also
    #    the same ones to be removed from the original component if 'option' calls to.
        newtris = []
        for tri_index in range(len(remove_triangle_list)):
            newtris = newtris + [comp.triangles[remove_triangle_list[tri_index]]]

    # This second part adds the NEW vertices to end of each frames "frame.vertices"
    #    to construct the new triangles that are being added just below this section.
        nbr_of_new_comp_vtxs_before_adding = len(new_comp.dictitems['Frames:fg'].subitems[0].vertices)
        for frame in range(len(comp.dictitems['Frames:fg'].subitems)):
            newframe_vertices = new_comp.dictitems['Frames:fg'].subitems[frame].vertices
            for vert_index in range(len(remove_vertices_list)):
                newframe_vertices = newframe_vertices + [comp.dictitems['Frames:fg'].subitems[frame].vertices[remove_vertices_list[vert_index]]]
            new_comp.dictitems['Frames:fg'].subitems[frame].vertices = newframe_vertices

    # This third part fixes up the 'new_comp.triangles', NEW triangles vertex index numbers
    #    to coordinate with those frame.vertices lists updated above.
        temptris = []
        for tri in range(len(newtris)):
            for index in range(len(newtris[tri])):
                for vert_index in range(len(remove_vertices_list)):
                    if newtris[tri][index][0] == remove_vertices_list[vert_index]:
                        if index == 0:
                            tri0 = (nbr_of_new_comp_vtxs_before_adding + vert_index, newtris[tri][index][1], newtris[tri][index][2])
                            break
                        elif index == 1:
                            tri1 = (nbr_of_new_comp_vtxs_before_adding + vert_index, newtris[tri][index][1], newtris[tri][index][2])
                            break
                        else:
                            tri2 = (nbr_of_new_comp_vtxs_before_adding + vert_index, newtris[tri][index][1], newtris[tri][index][2])
                            temptris = temptris + [(tri0, tri1, tri2)]
                            break
        new_comp.triangles = new_comp.triangles + temptris

    # This last part updates the "moveto" component finishing the process for that.
        undo = quarkx.action()
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            compframe.compparent = new_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(editor.Root.dictitems[movetocomponent + ':mc'], None)
        undo.put(editor.Root, new_comp)
        if option == 1:
            editor.ok(undo, "faces copied to " + new_comp.shortname)
        else:
            editor.ok(undo, "faces moved to " + new_comp.shortname)

    ###### ORIGINAL COMPONENT SECTION ######
    if option > 1:

    # This section checks and takes out, from the remove_vertices_list, any vert_index that is being used by a
    #    triangle that is not being removed, in the remove_triangle_list, to avoid any invalid triangle errors.
        dumylist = remove_vertices_list
        for tri in range(len(change_comp.triangles)):
            if tri in remove_triangle_list:
                continue
            else:
                for vtx in range(len(change_comp.triangles[tri])):
                    if change_comp.triangles[tri][vtx][0] in dumylist:
                        dumylist.remove(change_comp.triangles[tri][vtx][0])
        remove_vertices_list = dumylist

    # This section uses the "remove_triangle_list" to recreate the original
    #    component.triangles without the selected faces.
        old_tris = change_comp.triangles
        remove_triangle_list.sort()
        remove_triangle_list = reversed(remove_triangle_list)
        for index in remove_triangle_list:
            old_tris = old_tris[:index] + old_tris[index+1:]
        change_comp.triangles = old_tris

    # This section uses the "remove_vertices_list" to recreate the
    #    original component's frames without any unused vertexes.
        new_tris = change_comp.triangles
        compframes = change_comp.findallsubitems("", ':mf')   # find all frames
        for index in remove_vertices_list:
            enew_tris = fixUpVertexNos(new_tris, index)
            new_tris = enew_tris
            for compframe in compframes: 
                old_vtxs = compframe.vertices
                vtxs = old_vtxs[:index] + old_vtxs[index+1:]
                compframe.vertices = vtxs
        change_comp.triangles = new_tris

    # This updates the original component finishing the process for that.
        compframes = change_comp.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            compframe.compparent = change_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(comp, None)
        undo.put(editor.Root, change_comp)
        if option == 2:
            editor.ok(undo, "faces moved from " + change_comp.shortname)
        else:
            editor.ok(undo, "faces deleted from " + change_comp.shortname)



###############################
#
# Conversion functions
#
###############################



#
# Creates a QuArK Internal Group Object which consist of QuArK internal Poly Objects
# created from each selected vertex in the
# option=0 uses the ModelVertexSelList for the editor and
# option=1 uses the SkinVertexSelList for the Skin-view
# that can be manipulated by some function using QuArK Internal Poly Objects
# such as the Linear Handle functions.
# "otherlist" does NOT apply for the Skin-view, only the editor and it will
# use the list supplied and not the default ModelVertexSelList list above.
#
def MakeEditorVertexPolyObject(editor, option=0, otherlist=None, name=None):
    "Creates a QuArK Internal Group Object of Poly Objects for vertex drags."

    if editor.Root.currentcomponent is None:
        componentnames = []
        for item in editor.Root.dictitems:
            if item.endswith(":mc"):
                componentnames.append(item)
        componentnames.sort()
        editor.Root.currentcomponent = editor.Root.dictitems[componentnames[0]]
        
    if option == 0:
        if editor.ModelVertexSelList == [] and otherlist is None:
            return []
        elif otherlist is not None:
            VertexList = otherlist
        else:
            VertexList = editor.ModelVertexSelList
        from qbaseeditor import currentview
        polylist = []
        if name is None:
            group = quarkx.newobj("selected:g");
        else:
            group = quarkx.newobj(name + ":g");
        for vtx in range (len(editor.Root.currentcomponent.currentframe.vertices)):
            for ver_index in range (len(VertexList)):
                if vtx == VertexList[ver_index][0]:
                    vertex = editor.Root.currentcomponent.currentframe.vertices[vtx]
                    p = quarkx.newobj(str(vtx)+":p");
                    face = quarkx.newobj("east:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(1.0,0.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,1.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(1.0,0.0,1.0)/currentview.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("west:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(-1.0,0.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(-1.0,-1.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(-1.0,0.0,1.0)/currentview.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("north:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,1.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(-1.0,1.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,1.0,1.0)/currentview.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("south:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,-1.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,-1.0,0.0)/currentview.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,-1.0,1.0)/currentview.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("up:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,0.0,1.0)/currentview.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,0.0,1.0)/currentview.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,1.0,1.0)/currentview.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("down:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,0.0,-1.0)/currentview.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,0.0,-1.0)/currentview.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,-1.0,-1.0)/currentview.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    group.appenditem(p)

        polylist = polylist + [group]
        return polylist
    
    if option == 1:
        from mdlhandles import SkinView1
        import mdlhandles
        from qbaseeditor import currentview
        polylist = []
        group = quarkx.newobj("selected:g");
        for vtx in range (len(SkinView1.handles)):
            if (isinstance(SkinView1.handles[vtx], mdlhandles.LinRedHandle)) or (isinstance(SkinView1.handles[vtx], mdlhandles.LinSideHandle)) or (isinstance(SkinView1.handles[vtx], mdlhandles.LinCornerHandle)):
                continue
            for handle in range (len(editor.SkinVertexSelList)):
                tri_index = int(editor.SkinVertexSelList[handle][2])
                ver_index = int(editor.SkinVertexSelList[handle][3])
                handlevtx = (tri_index * 3) + ver_index
                if vtx == handlevtx:
                    vertex = SkinView1.handles[vtx].pos
                    p = quarkx.newobj(str(tri_index)+","+str(ver_index)+":p");
                    face = quarkx.newobj("east:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(1.0,0.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,1.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(1.0,0.0,1.0)/SkinView1.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("west:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(-1.0,0.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(-1.0,-1.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(-1.0,0.0,1.0)/SkinView1.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("north:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,1.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(-1.0,1.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,1.0,1.0)/SkinView1.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("south:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,-1.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,-1.0,0.0)/SkinView1.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,-1.0,1.0)/SkinView1.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("up:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,0.0,1.0)/SkinView1.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,0.0,1.0)/SkinView1.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,1.0,1.0)/SkinView1.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    face = quarkx.newobj("down:f")
                    vtx0X, vtx0Y, vtx0Z = (vertex + quarkx.vect(0.0,0.0,-1.0)/SkinView1.info["scale"]*2).tuple
                    vtx1X, vtx1Y, vtx1Z = (vertex + quarkx.vect(1.0,0.0,-1.0)/SkinView1.info["scale"]*2).tuple
                    vtx2X, vtx2Y, vtx2Z = (vertex + quarkx.vect(0.0,-1.0,-1.0)/SkinView1.info["scale"]*2).tuple
                    face["v"] = (vtx0X, vtx0Y, vtx0Z, vtx1X, vtx1Y, vtx1Z, vtx2X, vtx2Y, vtx2Z)
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    p.appenditem(face)
                    group.appenditem(p)

        polylist = polylist + [group]
        return polylist


#
# Does the opposite of the 'MakeEditorVertexPolyObject' (just above this function) to convert a list
#   of a group of polys that have been manipulated by some function using QuArK Internal Poly Objects.
# The 'new' objects list in the functions 'ok' section is passed to here where it is converted back to
# usable model component mesh vertexes and the final 'ok' function is performed.
# option=0 does the conversion for the Editor.
# option=1 does the conversion for the Skin-view.
# option=2, called from mdlhandles.py class LinRedHandle, ok function
#   is for the editor's selected edges vertexes extrusion function.
#
def ConvertVertexPolyObject(editor, newobjectslist, flags, view, undomsg, option=0):
    "Does the opposite of the 'MakeEditorVertexPolyObject' (just above this function) to convert a list"
    "of a group of polys that have been manipulated by some function using QuArK Internal Poly Objects."
    
    if option == 0:
        comp = editor.Root.currentcomponent
        new_comp = comp.copy()
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        if len(newobjectslist) > 1:
            for compframe in compframes:
                for newobject in range(len(newobjectslist)):
                    for poly in range(len(newobjectslist[newobject].subitems)):
                        for listframe in editor.layout.explorer.sellist:
                            if compframe.name == listframe.name:
                                old_vtxs = compframe.vertices
                                if listframe == editor.layout.explorer.sellist[0]:
                                    vtxnbr = int(newobjectslist[newobject].subitems[poly].shortname)
                                    face = newobjectslist[newobject].subitems[poly].subitems[0]
                                    vertex = quarkx.vect(face["v"][0] , face["v"][1], face["v"][2]) - quarkx.vect(1.0,0.0,0.0)/view.info["scale"]*2
                                    delta = vertex - old_vtxs[vtxnbr]
                                    old_vtxs[vtxnbr] = vertex
                                else:
                                    vtxnbr = int(newobjectslist[newobject].subitems[poly].shortname)
                                    old_vtxs[vtxnbr] = old_vtxs[vtxnbr] + delta
                                compframe.vertices = old_vtxs
                compframe.compparent = new_comp # To allow frame relocation after editing.
        else:
            for poly in range(len(newobjectslist[0].subitems)):
                for compframe in compframes:
                    for listframe in editor.layout.explorer.sellist:
                        if compframe.name == listframe.name:
                            old_vtxs = compframe.vertices
                            if listframe == editor.layout.explorer.sellist[0]:
                                vtxnbr = int(newobjectslist[0].subitems[poly].shortname)
                                face = newobjectslist[0].subitems[poly].subitems[0]
                                vertex = quarkx.vect(face["v"][0] , face["v"][1], face["v"][2]) - quarkx.vect(1.0,0.0,0.0)/view.info["scale"]*2
                                delta = vertex - old_vtxs[vtxnbr]
                                old_vtxs[vtxnbr] = vertex
                            else:
                                vtxnbr = int(newobjectslist[0].subitems[poly].shortname)
                                old_vtxs[vtxnbr] = old_vtxs[vtxnbr] + delta
                            compframe.vertices = old_vtxs
                    compframe.compparent = new_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)

    if option == 1:
        from qbaseeditor import currentview
        comp = editor.Root.currentcomponent
        new_comp = comp.copy()
        tris = new_comp.triangles
        try:
            tex = comp.currentskin
            texWidth,texHeight = tex["Size"]
        except:
            texWidth,texHeight = currentview.clientarea
        for poly in range(len(newobjectslist[0].subitems)):
            polygon = newobjectslist[0].subitems[poly]
            face = polygon.subitems[0]
            if comp.currentskin is not None:
                newpos = quarkx.vect(face["v"][0] , face["v"][1], face["v"][2]) + quarkx.vect(texWidth*.5, texHeight*.5, 0)
            else:
                newpos = quarkx.vect(face["v"][0] , face["v"][1], face["v"][2]) + quarkx.vect(int((texWidth*.5) +.5), int((texHeight*.5) -.5), 0)    
            tuplename = tuple(str(s) for s in polygon.shortname.split(','))
            tri_index, ver_index = tuplename
            tri_index = int(tri_index)
            ver_index = int(ver_index)
            tri = tris[tri_index]
            for j in range(len(tri)):
                if j == ver_index:
                    if j == 0:
                        newtriangle = ((tri[j][0], int(newpos.tuple[0]), int(newpos.tuple[1])), tri[1], tri[2])
                    elif j == 1:
                        newtriangle = (tri[0], (tri[j][0], int(newpos.tuple[0]), int(newpos.tuple[1])), tri[2])
                    else:
                        newtriangle = (tri[0], tri[1], (tri[j][0], int(newpos.tuple[0]), int(newpos.tuple[1])))
                    tris[tri_index] = newtriangle
        new_comp.triangles = tris
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            compframe.compparent = new_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)
    
    if option == 2:
        comp = editor.Root.currentcomponent
        new_comp = comp.copy()
        newtris = new_comp.triangles
        newtri_index = len(comp.triangles)
        newvertexselection = []
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        currentvertices = len(compframes[0].vertices)
        for compframe in range(len(compframes)):
            if compframes[compframe].name == comp.currentframe.name:
                current = compframe
                break
        for poly in range(len(newobjectslist[0].subitems)):
            old_vtxs = compframes[current].vertices
            vtxnbr = int(newobjectslist[0].subitems[poly].shortname)
            newver_index = currentvertices + poly
            face = newobjectslist[0].subitems[poly].subitems[0]
            newvertex = quarkx.vect(face["v"][0] , face["v"][1], face["v"][2]) - quarkx.vect(1.0,0.0,0.0)/view.info["scale"]*2
            delta = newvertex - old_vtxs[vtxnbr]
            newvertexselection = newvertexselection + [(newver_index, view.proj(newvertex))]
            for compframe in compframes:
                old_vtxs = compframe.vertices
                newvertex = old_vtxs[vtxnbr] + delta
                old_vtxs = old_vtxs + [newvertex]
                compframe.vertices = old_vtxs
                compframe.compparent = new_comp # To allow frame relocation after editing.

        from mdlhandles import SkinView1
        if quarkx.setupsubset(SS_MODEL, "Options")['SkinFrom3Dview'] == "1" or SkinView1 is None:
            for v in editor.layout.views:
                if v.info["viewname"] == "editors3Dview":
                    cordsview = v
        else:
            try:
                tex = comp.currentskin
                texWidth,texHeight = tex["Size"]
                if quarkx.setupsubset(SS_MODEL, "Options")['UseSkinViewScale'] == "1":
                    SkinViewScale = SkinView1.info["scale"]
                else:
                    SkinViewScale = 1
            except:
                texWidth,texHeight = SkinView1.clientarea
                SkinViewScale = 1
        for tri in editor.SelCommonTriangles:
            if len(tri) == 3:
                oldtri, oldver1 ,oldver0 = tri
            else:
                oldtri, oldver1 ,oldver0 ,oldver2 = tri
            for poly in range(len(newobjectslist[0].subitems)):
                if int(newobjectslist[0].subitems[poly].shortname) == oldver1:
                    newver_index0 = currentvertices + poly
                    if quarkx.setupsubset(SS_MODEL, "Options")['SkinFrom3Dview'] == "1" or SkinView1 is None:
                        newuv0u = int(cordsview.proj(compframes[current].vertices[newver_index0]).tuple[0])
                        newuv0v = int(cordsview.proj(compframes[current].vertices[newver_index0]).tuple[1])
                        olduv0u = int(cordsview.proj(compframes[current].vertices[oldver0]).tuple[0])
                        olduv0v = int(cordsview.proj(compframes[current].vertices[oldver0]).tuple[1])
                    else:
                        newuv0u = int(compframes[current].vertices[newver_index0].tuple[0]-int(texWidth*.5))*SkinViewScale
                        newuv0v = int(compframes[current].vertices[newver_index0].tuple[1]-int(texHeight*.5))*SkinViewScale
                        olduv0u = int(compframes[current].vertices[oldver0].tuple[0]+int(texWidth*.5))*SkinViewScale
                        olduv0v = int(compframes[current].vertices[oldver0].tuple[1]+int(texHeight*.5))*SkinViewScale
                if int(newobjectslist[0].subitems[poly].shortname) == oldver0:
                    newver_index1 = currentvertices + poly
                    if quarkx.setupsubset(SS_MODEL, "Options")['SkinFrom3Dview'] == "1" or SkinView1 is None:
                        newuv1u = int(cordsview.proj(compframes[current].vertices[newver_index1]).tuple[0])
                        newuv1v = int(cordsview.proj(compframes[current].vertices[newver_index1]).tuple[1])
                        olduv1u = int(cordsview.proj(compframes[current].vertices[oldver1]).tuple[0])
                        olduv1v = int(cordsview.proj(compframes[current].vertices[oldver1]).tuple[1])
                    else:
                        newuv1u = int(compframes[current].vertices[newver_index1].tuple[0]+int(texWidth*.5))*SkinViewScale
                        newuv1v = int(compframes[current].vertices[newver_index1].tuple[1]-int(texHeight*.5))*SkinViewScale
                        olduv1u = int(compframes[current].vertices[oldver1].tuple[0]-int(texWidth*.5))*SkinViewScale
                        olduv1v = int(compframes[current].vertices[oldver1].tuple[1]+int(texHeight*.5))*SkinViewScale
                if len(tri) == 4:
                    if int(newobjectslist[0].subitems[poly].shortname) == oldver2:
                        newver_index2 = currentvertices + poly
                        if quarkx.setupsubset(SS_MODEL, "Options")['SkinFrom3Dview'] == "1" or SkinView1 is None:
                            newuv2u = int(cordsview.proj(compframes[current].vertices[newver_index2]).tuple[0])
                            newuv2v = int(cordsview.proj(compframes[current].vertices[newver_index2]).tuple[1])
                            olduv2u = int(cordsview.proj(compframes[current].vertices[oldver2]).tuple[0])
                            olduv2v = int(cordsview.proj(compframes[current].vertices[oldver2]).tuple[1])
                        else:
                            newuv2u = int(compframes[current].vertices[newver_index2].tuple[0]+int(texWidth*.5))*SkinViewScale
                            newuv2v = int(compframes[current].vertices[newver_index2].tuple[1]-int(texHeight*.5))*SkinViewScale
                            olduv2u = int(compframes[current].vertices[oldver2].tuple[0]-int(texWidth*.5))*SkinViewScale
                            olduv2v = int(compframes[current].vertices[oldver2].tuple[1]+int(texHeight*.5))*SkinViewScale

            newtris = newtris + [((newver_index0, newuv0u, newuv0v), (newver_index1, newuv1u, newuv1v), (oldver0, olduv0u, olduv0v))]
            newtris = newtris + [((newver_index0, newuv0u, newuv0v), (oldver0, olduv0u, olduv0v), (oldver1, olduv1u, olduv1v))]
        new_comp.triangles = newtris

        if quarkx.setupsubset(SS_MODEL, "Options")["ExtrudeBulkHeads"] is not None:
            undomsg = "editor-linear all edges extrusion"
        else:
            undomsg = "editor-linear outside edges extrusion"

        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)
        editor.ModelVertexSelList = newvertexselection



def MakeEditorFaceObject(editor, option=0):
    "Creates a single QuArK Internal Face Object from 3 selected vertexes in the ModelVertexSelList"
    "or list of Face Objects by using the ModelFaceSelList 'tri_index' items in the list directly."

    editor.EditorObjectList = []
    comp = editor.Root.currentcomponent
    tris = comp.triangles  # A list of all the triangles of the current component if there is more than one.
                           # If NONE of the sub-items of a models component(s) have been selected,
                           # then it uses the 1st item of each sub-item, of the 1st component of the model.
                           # For example, the 1st skin, the 1st frame and so on, of the 1st component.
    if option == 0: # Returns one QuArK Internal Object (a face), identified by the currentcomponent's 'shortname' and tri_index,
                    # for each tri_index item in the ModelFaceSelList.
                    # These Objects can then be used with other Map Editor and Quarkx functions.
                    # They can also be easily converted back to the Model Editor's needed format using the Object's shortname and tri_index.
        for trinbr in range(len(tris)):  # Iterates, goes through, the above list, starting with a count number of zero, 0, NOT 1.
            for tri_index in range(len(editor.ModelFaceSelList)):
                if trinbr == editor.ModelFaceSelList[tri_index]:
                    face = quarkx.newobj(comp.shortname+","+str(trinbr)+","+str(tris[trinbr][0][0])+","+str(tris[trinbr][1][0])+","+str(tris[trinbr][2][0])+":f")
                    if editor.Root.currentcomponent.currentskin is not None:
                        face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                    else:
                        face["tex"] = "None"
                    # Here we need to use the triangles 3 vertex_index numbers to maintain their proper order to create the face Object.
                    # The last 3 amount are usually for texture positioning on a face, but can not be used for the Model Editor's format.
                    vtxindexes = (float(tris[trinbr][0][0]), float(tris[trinbr][1][0]), float(tris[trinbr][2][0]), 0.0, 0.0, 0.0)
                    face["tv"] = (vtxindexes)                                  # They don't really give usable values for texture positioning.
                    verts = editor.Root.currentcomponent.currentframe.vertices # The list of vertex positions of the current component's
                                                                               # current animation frame selected, if any, if not then its 1st frame.
                    vect0X ,vect0Y, vect0Z = verts[tris[trinbr][0][0]].tuple # Gives the actual 3D vector x,y and z positions of the triangle's 1st vertex.
                    vect1X ,vect1Y, vect1Z = verts[tris[trinbr][1][0]].tuple # Gives the actual 3D vector x,y and z positions of the triangle's 2nd vertex.
                    vect2X ,vect2Y, vect2Z = verts[tris[trinbr][2][0]].tuple # Gives the actual 3D vector x,y and z positions of the triangle's 3rd vertex.
                    vertexlist = (vect0X ,vect0Y, vect0Z, vect1X ,vect1Y, vect1Z, vect2X ,vect2Y, vect2Z)
                    face["v"] = vertexlist
                    editor.EditorObjectList = editor.EditorObjectList + [face]
        return editor.EditorObjectList
    if option != 2:
        editor.ModelFaceSelList = []
        editor.SelCommonTriangles = []
        editor.SelVertexes = []
    v0 = editor.ModelVertexSelList[0][0] # Gives the index number of the 1st vertex in the list.
    v1 = editor.ModelVertexSelList[1][0] # Gives the index number of the 2nd vertex in the list.
    v2 = editor.ModelVertexSelList[2][0] # Gives the index number of the 3rd vertex in the list.
    
    if option == 1: # Returns only one object (face) & tri_index for the 3 selected vertexes used by the same triangle.
                    # This object can then be used with other Map Editor and Quarkx functions.
        for trinbr in range(len(tris)):  # Iterates, goes through, the above list, starting with a count number of zero, 0, NOT 1.

            # Compares all of the triangle's vertex index numbers, in their proper order, to the above 3 items.
            # Thus insuring it will return the actual single triangle that we want.
            if (tris[trinbr][0][0] == v0 or tris[trinbr][0][0] == v1 or tris[trinbr][0][0] == v2) and (tris[trinbr][1][0] == v0 or tris[trinbr][1][0] == v1 or tris[trinbr][1][0] == v2) and (tris[trinbr][2][0] == v0 or tris[trinbr][2][0] == v1 or tris[trinbr][2][0] == v2):
                tri_index = trinbr  # The iterating count number (trinbr) IS the tri_index number.
                face = quarkx.newobj(comp.shortname+" face\\tri "+str(tri_index)+":f")
                if editor.Root.currentcomponent.currentskin is not None:
                    face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                else:
                    face["tex"] = "None"
                # Here we need to use the triangles vertexes to maintain their proper order.
                vtxindexes = (float(tris[trinbr][0][0]), float(tris[trinbr][1][0]), float(tris[trinbr][2][0]), 0.0, 0.0, 0.0) # We use this triangle's 3 vertex_index numbers here just to create the face object.
                face["tv"] = (vtxindexes)                                  # They don't really give usable values for texture positioning.
                verts = editor.Root.currentcomponent.currentframe.vertices # The list of vertex positions of the current component's
                                                                           # current animation frame selected, if any, if not then its 1st frame.
                vect00 ,vect01, vect02 = verts[tris[trinbr][0][0]].tuple # Gives the actual 3D vector x,y and z positions of the triangle's 1st vertex.
                vect10 ,vect11, vect12 = verts[tris[trinbr][1][0]].tuple # Gives the actual 3D vector x,y and z positions of the triangle's 2nd vertex.
                vect20 ,vect21, vect22 = verts[tris[trinbr][2][0]].tuple # Gives the actual 3D vector x,y and z positions of the triangle's 3rd vertex.
                vertexlist = (vect00 ,vect01, vect02, vect10 ,vect11, vect12, vect20 ,vect21, vect22)
                face["v"] = vertexlist
                editor.EditorObjectList = editor.EditorObjectList + [[face, tri_index]]
                editor.ModelFaceSelList = editor.ModelFaceSelList + [tri_index]
                return editor.EditorObjectList

    elif option == 2: # Returns an object (face) & tri_index for each triangle that shares the 1st vertex of the 3 selected vertexes used by the same triangle.
                      # Meaning, any triangle (face) using this 'common' vertex will be returned.
                      # Its 1st vertex must be selected by itself first, then its other 2 vertexes in any order.
                      # These objects can then be used with other Map Editor and Quarkx functions.
        for trinbr in range(len(tris)):  # Iterates, goes through, the above list, starting with a count number of zero, 0, NOT 1.
            if (tris[trinbr][0][0] == v0 or tris[trinbr][0][0] == v1 or tris[trinbr][0][0] == v2) and (tris[trinbr][1][0] == v0 or tris[trinbr][1][0] == v1 or tris[trinbr][1][0] == v2) and (tris[trinbr][2][0] == v0 or tris[trinbr][2][0] == v1 or tris[trinbr][2][0] == v2):
                tri_index = trinbr
                break

        for trinbr in range(len(tris)):  # Iterates, goes through, the above list, starting with a count number of zero, 0, NOT 1.
            if tris[trinbr][0][0] == v0 or tris[trinbr][1][0] == v0 or tris[trinbr][2][0] == v0:
                face = quarkx.newobj(comp.shortname+" face\\tri "+str(trinbr)+":f")
                if editor.Root.currentcomponent.currentskin is not None:
                    face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                else:
                    face["tex"] = "None"
                vtxindexes = (float(tris[trinbr][0][0]), float(tris[trinbr][1][0]), float(tris[trinbr][2][0]), 0.0, 0.0, 0.0) # We use each triangle's 3 vertex_index numbers here just to create it's face object.
                face["tv"] = (vtxindexes)                                                                                     # They don't really give usable values for texture positioning.
                verts = editor.Root.currentcomponent.currentframe.vertices # The list of vertex positions of the current component's
                                                                           # current animation frame selected, if any, if not then its 1st frame.
                vect00 ,vect01, vect02 = verts[tris[trinbr][0][0]].tuple # Gives the actual 3D vector x,y and z positions of this triangle's 1st vertex.
                vect10 ,vect11, vect12 = verts[tris[trinbr][1][0]].tuple # Gives the actual 3D vector x,y and z positions of this triangle's 2nd vertex.
                vect20 ,vect21, vect22 = verts[tris[trinbr][2][0]].tuple # Gives the actual 3D vector x,y and z positions of this triangle's 3rd vertex.
                vertexlist = (vect00 ,vect01, vect02, vect10 ,vect11, vect12, vect20 ,vect21, vect22)
                face["v"] = vertexlist
                editor.EditorObjectList = editor.EditorObjectList + [[face, tri_index]]
        return editor.EditorObjectList
        
    elif option == 3: # Returns an object & tri_index for each triangle that shares the 1st and one other vertex of our selected triangle's vertexes.
                      # These objects can then be used with other Map Editor and Quarkx functions.
        for trinbr in range(len(tris)):  # Iterates, goes through, the above list, starting with a count number of zero, 0, NOT 1.
            if (tris[trinbr][0][0] == v0 or tris[trinbr][0][0] == v1 or tris[trinbr][0][0] == v2) and (tris[trinbr][1][0] == v0 or tris[trinbr][1][0] == v1 or tris[trinbr][1][0] == v2) and (tris[trinbr][2][0] == v0 or tris[trinbr][2][0] == v1 or tris[trinbr][2][0] == v2):
                tri_index = trinbr
                break

        for trinbr in range(len(tris)):  # Iterates, goes through, the above list, starting with a count number of zero, 0, NOT 1.
            if (tris[trinbr][0][0] is v0 or tris[trinbr][0][0] is v1 or tris[trinbr][0][0] is v2) and ((tris[trinbr][1][0] is v0 or tris[trinbr][1][0] is v1 or tris[trinbr][1][0] is v2) or (tris[trinbr][2][0] is v0 or tris[trinbr][2][0] is v1 or tris[trinbr][2][0] is v2)):
                face = quarkx.newobj(comp.shortname+" face\\tri "+str(trinbr)+":f")
                if editor.Root.currentcomponent.currentskin is not None:
                    face["tex"] = editor.Root.currentcomponent.currentskin.shortname
                else:
                    face["tex"] = "None"
                vtxindexes = (float(tris[trinbr][0][0]), float(tris[trinbr][1][0]), float(tris[trinbr][2][0]), 0.0, 0.0, 0.0) # We use each triangle's 3 vertex_index numbers here just to create it's face object.
                face["tv"] = (vtxindexes)                                                                                     # They don't really give usable values for texture positioning.
                verts = editor.Root.currentcomponent.currentframe.vertices # The list of vertex positions of the current component's
                                                                           # current animation frame selected, if any, if not then its 1st frame.
                vect00 ,vect01, vect02 = verts[tris[trinbr][0][0]].tuple # Gives the actual 3D vector x,y and z positions of this triangle's 1st vertex.
                vect10 ,vect11, vect12 = verts[tris[trinbr][1][0]].tuple # Gives the actual 3D vector x,y and z positions of this triangle's 2nd vertex.
                vect20 ,vect21, vect22 = verts[tris[trinbr][2][0]].tuple # Gives the actual 3D vector x,y and z positions of this triangle's 3rd vertex.
                vertexlist = (vect00, vect01, vect02, vect10, vect11, vect12, vect20, vect21, vect22)
                face["v"] = vertexlist
                editor.EditorObjectList = editor.EditorObjectList + [[face, trinbr]]
                editor.ModelFaceSelList = editor.ModelFaceSelList + [trinbr]
        return editor.EditorObjectList


#
# Does the opposite of the 'MakeEditorFaceObject' (just above this function) to convert
#   a list of faces that have been manipulated by some function using QuArK Internal Face Objects.
# The 'new' objects list in the functions 'ok' section is passed to here where it is converted back
#   to usable model component mesh vertexes of those faces and the final 'ok' function is performed.
# option=0 is the function for the Model Editor.
# option=1 is the function for the Skin-view.
# option=2, called from mdlhandles.py class LinRedHandle, ok function
#   is for the editor's selected faces extrusion function.
#
def ConvertEditorFaceObject(editor, newobjectslist, flags, view, undomsg, option=0):
    "Does the opposite of the 'MakeEditorFaceObject' (just above this function) to convert"
    "a list of faces that have been manipulated by some function using QuArK Internal Face Objects."

    if option == 0:
        comp = editor.Root.currentcomponent
        new_comp = comp.copy()
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        for face in newobjectslist:
            VertToMove = []
            tuplename = tuple(str(s) for s in face.shortname.split(','))
            compname, tri_index, ver_index0, ver_index1, ver_index2 = tuplename
            VertToCheck0 = [int(ver_index0), quarkx.vect(face["v"][0], face["v"][1], face["v"][2]) - quarkx.vect(1.0,0.0,0.0)/view.info["scale"]*2]
            VertToCheck1 = [int(ver_index1), quarkx.vect(face["v"][3], face["v"][4], face["v"][5]) - quarkx.vect(1.0,0.0,0.0)/view.info["scale"]*2]
            VertToCheck2 = [int(ver_index2), quarkx.vect(face["v"][6], face["v"][7], face["v"][8]) - quarkx.vect(1.0,0.0,0.0)/view.info["scale"]*2]
            if not (VertToCheck0 in VertToMove):
                VertToMove = VertToMove + [VertToCheck0]
            if not (VertToCheck1 in VertToMove):
                VertToMove = VertToMove + [VertToCheck1]
            if not (VertToCheck2 in VertToMove):
                VertToMove = VertToMove + [VertToCheck2]
            for Vert in VertToMove:
                for compframe in compframes:
                    for listframe in editor.layout.explorer.sellist:
                        if compframe.name == listframe.name:
                            old_vtxs = compframe.vertices
                            if listframe == editor.layout.explorer.sellist[0]:
                                delta = Vert[1] - old_vtxs[Vert[0]]
                                old_vtxs[Vert[0]] = Vert[1]
                            else:
                                old_vtxs[Vert[0]] = old_vtxs[Vert[0]] + delta
                            compframe.vertices = old_vtxs
                    compframe.compparent = new_comp # To allow frame relocation after editing.
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)

    # for test reference only - def replacevertexes(editor, comp, vertexlist, flags, view, undomsg):
    if option == 1:
        comp = editor.Root.currentcomponent
        vertexlist = []
        for face in newobjectslist:
            tuplename = tuple(str(s) for s in face.shortname.split(','))
            vtxpos0 = quarkx.vect(face["v"][0] , face["v"][1], face["v"][2])
            vtxpos1 = quarkx.vect(face["v"][3] , face["v"][4], face["v"][5])
            vtxpos2 = quarkx.vect(face["v"][6] , face["v"][7], face["v"][8])
            pos0X, pos0Y, pos0Z = view.proj(vtxpos0).tuple
            pos1X, pos1Y, pos1Z = view.proj(vtxpos1).tuple
            pos2X, pos2Y, pos2Z = view.proj(vtxpos2).tuple
            pos0 = quarkx.vect(pos0Y, pos0Z, 0)
            pos1 = quarkx.vect(pos1Y, pos1Z, 0)
            pos2 = quarkx.vect(pos2Y, pos2Z, 0)
            compname, tri_index, ver_index0, ver_index1, ver_index2 = tuplename
            tri_index = int(tri_index)
            ver_index0 = int(ver_index0)
            ver_index1 = int(ver_index1)
            ver_index2 = int(ver_index2)
            vertex0 = editor.Root.currentcomponent.currentframe.vertices[ver_index0]
            vertex1 = editor.Root.currentcomponent.currentframe.vertices[ver_index1]
            vertex2 = editor.Root.currentcomponent.currentframe.vertices[ver_index2]
            if vertexlist == []:
                vertexlist = vertexlist + [[pos0, vertex0, tri_index, ver_index0]] + [[pos1, vertex1, tri_index, ver_index1]] + [[pos2, vertex2, tri_index, ver_index2]]
            else:
                for item in range(len(vertexlist)):
                    if vertexlist[item][2] == int(tuplename[1]):
                        break
                    if item == len(vertexlist)-1:
                        vertexlist = vertexlist + [[pos0, vertex0, tri_index, ver_index0]] + [[pos1, vertex1, tri_index, ver_index1]] + [[pos2, vertex2, tri_index, ver_index2]]

        replacevertexes(editor, comp, vertexlist, flags, view, undomsg, option=option)

    if option == 2:
        comp = editor.Root.currentcomponent
        new_comp = comp.copy()
        newtris = new_comp.triangles
        newtri_index = len(comp.triangles)
        newfaceselection = []
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        currentvertices = len(compframes[0].vertices)

        for selface in editor.ModelFaceSelList:
            netvtxs = []
            for vtx in comp.triangles[selface]:
                if vtx in netvtxs:
                    pass
                else:
                    netvtxs = netvtxs + [vtx[0]]
        newvtxsneeded = len(netvtxs)

        old_vtxs = []
        old_vtx_nbrs = []
        editor.ModelFaceSelList.sort()

        # This section computes the net delta vertex movement for the extrusion drag.
        face = newobjectslist[0]
        tuplename = tuple(str(s) for s in face.shortname.split(','))
        compname, tri_index, ver_index0, ver_index1, ver_index2 = tuplename
        old_ver0 = comp.currentframe.vertices[int(ver_index0)]
        new_ver0 = quarkx.vect(face["v"][0], face["v"][1], face["v"][2])
        delta = new_ver0 - old_ver0

        for face in newobjectslist:
            tuplename = tuple(str(s) for s in face.shortname.split(','))
            compname, tri_index, ver_index0, ver_index1, ver_index2 = tuplename
            tri_index = int(tri_index)
            ver_index0 = int(ver_index0)
            ver_index1 = int(ver_index1)
            ver_index2 = int(ver_index2)

            # This section makes the new vertexes of the editor's selected faces extrusion function.
            if ver_index0 in old_vtx_nbrs:
                pass
            else:
                old_vtxs = old_vtxs + [quarkx.vect(face["v"][0], face["v"][1], face["v"][2])]
                old_vtx_nbrs = old_vtx_nbrs + [ver_index0]
            if ver_index1 in old_vtx_nbrs:
                pass
            else:
                old_vtxs = old_vtxs + [quarkx.vect(face["v"][3], face["v"][4], face["v"][5])]
                old_vtx_nbrs = old_vtx_nbrs + [ver_index1]
            if ver_index2 in old_vtx_nbrs:
                pass
            else:
                old_vtxs = old_vtxs + [quarkx.vect(face["v"][6], face["v"][7], face["v"][8])]
                old_vtx_nbrs = old_vtx_nbrs + [ver_index2]

            # This section calculates the new selected triangle's (face) vertex index numbers.
            vtx0,u0,v0 = comp.triangles[tri_index][0]
            vtx1,u1,v1 = comp.triangles[tri_index][1]
            vtx2,u2,v2 = comp.triangles[tri_index][2]
            for oldnbr in range(len(old_vtx_nbrs)):
                if vtx0 == old_vtx_nbrs[oldnbr]:
                    newvtx0 = currentvertices + oldnbr
                if vtx1 == old_vtx_nbrs[oldnbr]:
                    newvtx1 = currentvertices + oldnbr
                if vtx2 == old_vtx_nbrs[oldnbr]:
                    newvtx2 = currentvertices + oldnbr

            # This section makes the new 'side' triangles for the extruded faces.
            vtx01 = vtx12 = vtx20 = 1
            for selface in editor.ModelFaceSelList:
                vtxs = []
                for vtx in comp.triangles[selface]:
                    vtxs = vtxs + [vtx[0]]
                if selface == tri_index or len(editor.ModelFaceSelList) == 1:
                    pass
                else:
                    if (vtx0 in vtxs and vtx1 in vtxs):
                        vtx01 = 0
                    if (vtx1 in vtxs and vtx2 in vtxs):
                        vtx12 = 0
                    if (vtx2 in vtxs and vtx0 in vtxs):
                        vtx20 = 0

            if vtx01 == 1:
                newtris = newtris + [((newvtx0,u0,v0), (comp.triangles[tri_index][0][0],u0,v0), (newvtx1,u1,v1))]
                newtris = newtris + [((newvtx1,u1,v1), (comp.triangles[tri_index][0][0],u0,v0), (comp.triangles[tri_index][1][0],u1,v1))]
                newtri_index = newtri_index + 2
            if vtx12 == 1:
                newtris = newtris + [((newvtx2,u2,v2), (newvtx1,u1,v1), (comp.triangles[tri_index][1][0],u1,v1))]
                newtris = newtris + [((newvtx2,u2,v2), (comp.triangles[tri_index][1][0],u1,v1), (comp.triangles[tri_index][2][0],u2,v2))]
                newtri_index = newtri_index + 2
            if vtx20 == 1:
                newtris = newtris + [((newvtx2,u2,v2), (comp.triangles[tri_index][0][0],u0,v0), (newvtx0,u0,v0))]
                newtris = newtris + [((newvtx2,u2,v2), (comp.triangles[tri_index][2][0],u2,v2), (comp.triangles[tri_index][0][0],u0,v0))]
                newtri_index = newtri_index + 2
            # This section makes the new selected faces being dragged.
            newtris = newtris + [((newvtx0,u0,v0), (newvtx1,u1,v1), (newvtx2,u2,v2))]

            if quarkx.setupsubset(SS_MODEL, "Options")["ExtrudeBulkHeads"] is not None:
                # This line leaves the 'bulkheads' in between extrusion drags.
                newfaceselection = newfaceselection + [newtri_index]
            else:
                # This line, and the two noted below, remove the 'bulkheads' between extrusion drags.
                newfaceselection = newfaceselection + [newtri_index-len(editor.ModelFaceSelList)]

            newtri_index = newtri_index + 1

        if quarkx.setupsubset(SS_MODEL, "Options")["ExtrudeBulkHeads"] is not None:
            undomsg = "editor-linear face extrusion w/bulkheads"
        else:
            # These lines, and the one noted above, remove the 'bulkheads' between extrusion drags.
            undomsg = "editor-linear face extrusion"
            for tri_index in reversed(editor.ModelFaceSelList):
                newtris = newtris[:tri_index] + newtris[tri_index+1:]

        # This updates (adds) the new vertices to each frame.
        for compframe in compframes:
            if compframe.name == comp.currentframe.name:
                compframe.vertices = compframe.vertices + old_vtxs
            else:
                new_vtxs = []
                for old_nbr in old_vtx_nbrs:
                    new_vtxs = new_vtxs + [compframe.vertices[old_nbr] + delta]
                compframe.vertices = compframe.vertices + new_vtxs
            compframe.compparent = new_comp # To allow frame relocation after editing.

        # This updates (adds) the new triangles to the component.
        new_comp.triangles = newtris

        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.ok(undo, undomsg)
        editor.ModelFaceSelList = newfaceselection

        # Sets these lists up for the Linear Handle drag lines to be drawn.
        editor.SelCommonTriangles = []
        editor.SelVertexes = []
        if quarkx.setupsubset(SS_MODEL, "Options")['NFDL'] is None:
            for tri in editor.ModelFaceSelList:
                for vtx in range(len(comp.triangles[tri])):
                    if comp.triangles[tri][vtx][0] in editor.SelVertexes:
                        pass
                    else:
                        editor.SelVertexes = editor.SelVertexes + [comp.triangles[tri][vtx][0]] 
                    editor.SelCommonTriangles = editor.SelCommonTriangles + findTrianglesAndIndexes(comp, comp.triangles[tri][vtx][0], None)

        MakeEditorFaceObject(editor)



###############################
#
# Component & Sub-item Creation functions
#
###############################


#
# The 'option' value of 1 MAKES a "clean" brand new component with NO triangles or frame.vertecies, only frames.
# The 'option' value of 2 ADDS a new component to the model using currently selected faces of another component.
#    This function will also remove the selected faces and unused vertexes from the original component.
#
def addcomponent(editor, option=2):
    comp = editor.Root.currentcomponent

    # This section does a few selection test and gives an error message box if needed.
    if option == 2:
        for item in editor.layout.explorer.sellist:
            if item.parent.parent.name != comp.name:
                quarkx.msgbox("IMPROPER SELECTION !\n\nYou need to select a frame && faces from\none component to make a new component.\n\nYou have selected items that are not\npart of the ''"+editor.Root.currentcomponent.shortname+"'' Frames group.\nPlease un-select these items.\nYou can add other component faces\nafter the new component is created.\n\nAction Canceled.", MT_ERROR, MB_OK)
                return
        if editor.ModelFaceSelList == []:
            quarkx.msgbox("You need to select a group of faces\nto make a new component from.", MT_ERROR, MB_OK)
            return
    else:
        for item in editor.layout.explorer.sellist:
            if item.parent.parent.name != comp.name:
                quarkx.msgbox("IMPROPER SELECTION !\n\nYou need to select a frame from\none component to make a new clean component.\n\nYou have selected items that are not\npart of the ''"+editor.Root.currentcomponent.shortname+"'' Frames group.\nPlease un-select these items.\nYou can add other component faces\nafter the new clean component is created.\n\nAction Canceled.", MT_ERROR, MB_OK)
                return

    # These are things that we need to setup first for use later on.
    if option == 2:
        temp_list = []
        remove_triangle_list = []
        remove_vertices_list = []

    # Now we start creating our data copies to work with and the final "ok" swapping function at the end.
    # But first we check for any other "new component"s, if so we name this one 1 more then the largest number.
    if option == 2:
        tris = comp.triangles
        change_comp = comp.copy()
    new_comp = comp.copy()
    new_comp.shortname = "None"
    comparenbr = 0
    if option == 2:
        for item in editor.Root.dictitems:
            if editor.Root.dictitems[item].shortname.startswith('new component'):
                getnbr = editor.Root.dictitems[item].shortname
                getnbr = getnbr.replace('new component', '')
                if getnbr == "":
                   nbr = 0
                else:
                    nbr = int(getnbr)
                if nbr > comparenbr:
                    comparenbr = nbr
                nbr = comparenbr + 1
                new_comp.shortname = "new component " + str(nbr)
        if new_comp.shortname != "None":
            pass
        else:
            new_comp.shortname = "new component 1"
    else:
        for item in editor.Root.dictitems:
            if editor.Root.dictitems[item].shortname.startswith('new clean component'):
                getnbr = editor.Root.dictitems[item].shortname
                getnbr = getnbr.replace('new clean component', '')
                if getnbr == "":
                   nbr = 0
                else:
                    nbr = int(getnbr)
                if nbr > comparenbr:
                    comparenbr = nbr
                nbr = comparenbr + 1
                new_comp.shortname = "new clean component " + str(nbr)
        if new_comp.shortname != "None":
            pass
        else:
            new_comp.shortname = "new clean component 1"

    ###### NEW COMPONENT SECTION ######

    # This section creates the "remove_triangle_list" from the ModelFaceSelList which is already
    #    in ascending numerical order but may have duplicate tri_index numbers that need to be removed.
    # The order also needs to be descending so when triangles are removed from another list it
    #    does not select an improper triangle due to list items shifting forward numerically.
    # The "remove_triangle_list" is used to re-create the current component.triangles and new_comp.triangles.
    if option == 2:
        for tri_index in reversed(editor.ModelFaceSelList):
            if tri_index in remove_triangle_list:
                pass
            else:
                remove_triangle_list = remove_triangle_list + [tri_index]

    # This section creates the "remove_vertices_list" to be used
    #    to re-create the current component's frame.vertices.
    # It also skips over any vertexes of the triangles to be removed but should not be included
    #    because they are "common" vertexes and still being used by other remaining triangles.
        for tri_index in remove_triangle_list:
            for vtx in range(len(tris[tri_index])):
                if tris[tri_index][vtx][0] in temp_list:
                    pass
                else:
                    temp_list.append(tris[tri_index][vtx][0])
        temp_list.sort()
        for item in reversed(temp_list):
            remove_vertices_list.append(item)

    # This creates the new component and places it under the main Model Root with the other components.
    ## This first part sets up the new_comp.triangles, which are the ones that have been selected, using the
    ##    "remove_triangle_list" which are also the same ones to be removed from the original component.
        newtris = []
        for tri_index in range(len(remove_triangle_list)):
            newtris = newtris + [comp.triangles[remove_triangle_list[tri_index]]]
        new_comp.triangles = newtris

    ## This second part reconstructs each frames "frame.vertices" to consist
    ##    of only those that are needed, removing any that are unused.
    ## Then it fixes up the new_comp.triangles vertex index numbers
    ##    to coordinate with those frame.vertices lists.
        for compframe in range(len(comp.dictitems['Frames:fg'].subitems)):
            newframe_vertices = []
            for vert_index in range(len(remove_vertices_list)):
                newframe_vertices = newframe_vertices + [comp.dictitems['Frames:fg'].subitems[compframe].vertices[remove_vertices_list[vert_index]]]
            new_comp.dictitems['Frames:fg'].subitems[compframe].vertices = newframe_vertices

        newtris = []
        for tri in range(len(new_comp.triangles)):
            for index in range(len(new_comp.triangles[tri])):
                for vert_index in range(len(remove_vertices_list)):
                    if new_comp.triangles[tri][index][0] == remove_vertices_list[vert_index]:
                        if index == 0:
                            tri0 = (vert_index, new_comp.triangles[tri][index][1], new_comp.triangles[tri][index][2])
                            break
                        elif index == 1:
                            tri1 = (vert_index, new_comp.triangles[tri][index][1], new_comp.triangles[tri][index][2])
                            break
                        else:
                            tri2 = (vert_index, new_comp.triangles[tri][index][1], new_comp.triangles[tri][index][2])
                            newtris = newtris + [(tri0, tri1, tri2)]
                            break
        new_comp.triangles = newtris
    else:
        new_comp.triangles = []
        for compframe in range(len(new_comp.dictitems['Frames:fg'].subitems)):
            new_comp.dictitems['Frames:fg'].subitems[compframe].vertices = []
        new_comp.dictitems['Skeleton:bg'] = []

    ## This last part places the new component into the editor and the model.
    compframes = new_comp.findallsubitems("", ':mf')   # get all frames
    for compframe in compframes:
        compframe.compparent = new_comp # To allow frame relocation after editing.
    undo = quarkx.action()
    undo.put(editor.Root, new_comp)
    editor.ok(undo, new_comp.shortname + " created")
    if option == 1:
        return

    ###### ORIGINAL COMPONENT SECTION ######

    # This section checks and takes out, from the remove_vertices_list, any vert_index that is being used by a
    # triangle that is not being removed, in the remove_triangle_list, to avoid any invalid triangle errors.
    dumylist = remove_vertices_list
    for tri in range(len(change_comp.triangles)):
        if tri in remove_triangle_list:
            continue
        else:
            for vtx in range(len(change_comp.triangles[tri])):
                if change_comp.triangles[tri][vtx][0] in dumylist:
                    dumylist.remove(change_comp.triangles[tri][vtx][0])
    remove_vertices_list = dumylist

    # This section uses the "remove_triangle_list" to recreate the original
    # component.triangles without the selected faces.
    old_tris = change_comp.triangles
    remove_triangle_list.sort()
    remove_triangle_list = reversed(remove_triangle_list)
    for index in remove_triangle_list:
        old_tris = old_tris[:index] + old_tris[index+1:]
    change_comp.triangles = old_tris

    # This section uses the "remove_vertices_list" to recreate the
    # original component's frames without any unused vertexes.
    new_tris = change_comp.triangles
    compframes = change_comp.findallsubitems("", ':mf')   # find all frames
    for index in remove_vertices_list:
        enew_tris = fixUpVertexNos(new_tris, index)
        new_tris = enew_tris
        for compframe in compframes: 
            old_vtxs = compframe.vertices
            vtxs = old_vtxs[:index] + old_vtxs[index+1:]
            compframe.vertices = vtxs
    change_comp.triangles = new_tris

    # This last section updates the original component finishing the process for it.
    compframes = change_comp.findallsubitems("", ':mf')   # get all frames
    for compframe in compframes:
        compframe.compparent = change_comp # To allow frame relocation after editing.
    undo = quarkx.action()
    undo.exchange(comp, None)
    undo.put(editor.Root, change_comp)
    editor.ok(undo, change_comp.shortname + " updated")


#
# Add a frame to a given component (ie duplicate last one)
#
def addframe(editor):
    comp = editor.Root.currentcomponent
    if (editor.layout.explorer.uniquesel is None) or (editor.layout.explorer.uniquesel.type != ":mf"):
        quarkx.msgbox("You need to select a single frame to duplicate.\n\nFor multiple frames use 'Duplicate' on the 'Edit' menu.", MT_ERROR, MB_OK)
        return

    newframe = editor.layout.explorer.uniquesel.copy()
    new_comp = comp.copy()
    compframes = new_comp.dictitems['Frames:fg'].subitems   # all frames
    itemdigit = None

    if newframe.shortname[len(newframe.shortname)-1].isdigit():
        itemdigit = ""
        count = len(newframe.shortname)-1
        while count >= 0:
            if newframe.shortname[count] == " ":
                count = count - 1
            elif newframe.shortname[count].isdigit():
                itemdigit = str(newframe.shortname[count]) + itemdigit
                count = count - 1
            else:
                break
        itembasename = newframe.shortname.split(itemdigit)[0]
    else:
        itembasename = newframe.shortname

    name = None
    comparenbr = 0
    count = 0
    stopcount = 0
    for compframe in compframes:
        if not itembasename.endswith(" ") and compframe.shortname.startswith(itembasename + " "):
            if stopcount == 0:
                count = count + 1
            continue
        if compframe.shortname.startswith(itembasename):
            stopcount = 1
            getnbr = compframe.shortname.replace(itembasename, '')
            if getnbr == "":
                nbr = 0
            else:
                nbr = int(getnbr)
            if nbr > comparenbr:
                comparenbr = nbr
                count = count + 1
            nbr = comparenbr + 1
            name = itembasename + str(nbr)
        if stopcount == 0:
            count = count + 1
    if name is not None:
        pass
    else:
        name = newframe.shortname
    newframe.shortname = name
    # Places the new frame at the end of its group of frames of the same name.
    new_comp.dictitems['Frames:fg'].insertitem(count, newframe)
    compframes = new_comp.dictitems['Frames:fg'].subitems   # all frames
    # To allow frame relocation after editing.
    for compframe in compframes:
        compframe.compparent = new_comp
    undo = quarkx.action()
    undo.exchange(comp, None)
    undo.put(editor.Root, new_comp)
    editor.ok(undo, "add frame")



###############################
#
# Skeleton & Bone functions
#
###############################



#
# This function adds a :bone-object to the skeleton-group of comp at position pos
#
def addbone(editor, comp, pos):
    name = None
    comparenbr = 0
    compbones = comp.findallsubitems("", ':bone')      # get all bones
    for item in compbones:
        if item.shortname.startswith('NewBone'):
            getnbr = item.shortname
            getnbr = getnbr.replace('NewBone', '')
            if getnbr == "":
                nbr = 0
            else:
                nbr = int(getnbr)
            if nbr > comparenbr:
                comparenbr = nbr
            nbr = comparenbr + 1
            name = "NewBone" + str(nbr)
    if name is None:
        name = "NewBone1"
    new_o_bone = quarkx.newobj(name + ":bone")
    new_o_bone['start_point'] = pos.tuple
    endpoint = pos + quarkx.vect(8,2,2)
    new_o_bone['end_point'] = endpoint.tuple
    new_o_bone['bone_length'] = (8,2,2)
    new_o_bone['start_scale'] = (1.0,)
    new_o_bone['end_scale'] = (1.0,)
    new_o_bone['start_color'] = new_o_bone['end_color'] = MapColor("BoneHandles", SS_MODEL)
    new_o_bone['start_offset'] = (0, 0, 0)
    new_o_bone['end_offset'] = (0, 0, 0)
    new_comp = comp.copy()
    compskeleton = new_comp.findallsubitems("", ':bg')[0]
    compskeleton.appenditem(new_o_bone)
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    editor.Root.currentcomponent = new_comp
    editor.ok(undo, "add bone")

#
# This function creates a new bone at the start or end (s_or_e) of bone
#
def continue_bone(editor, bone, s_or_e = 0):
    compskeleton = bone.parent  # get the bones group
    name = None
    comparenbr = 0
    compbones = compskeleton.findallsubitems("", ':bone')      # get all bones
    for item in compbones:
        if item.shortname.startswith('NewBone'):
            getnbr = item.shortname
            getnbr = getnbr.replace('NewBone', '')
            if getnbr == "":
                nbr = 0
            else:
                nbr = int(getnbr)
            if nbr > comparenbr:
                comparenbr = nbr
            nbr = comparenbr + 1
            name = "NewBone" + str(nbr)
    if name is None:
        name = "NewBone1"
    new_o_bone = quarkx.newobj(name + ":bone")
    if s_or_e == 0:
        new_o_bone['start_point'] = bone['start_point']
    else:
        new_o_bone['start_point'] = bone['end_point']
    endpoint = quarkx.vect(new_o_bone['start_point']) + quarkx.vect(8,2,2)
    new_o_bone['end_point'] = endpoint.tuple
    new_o_bone['bone_length'] = (8,2,2)
    new_o_bone['start_scale'] = (1.0,)
    new_o_bone['end_scale'] = (1.0,)
    new_o_bone['start_color'] = new_o_bone['end_color'] = MapColor("BoneHandles", SS_MODEL)
    new_o_bone['start_offset'] = (0, 0, 0)
    new_o_bone['end_offset'] = (0, 0, 0)
    common_handles_list, s_or_e_list = find_common_bone_handles(editor, new_o_bone.dictspec['start_point'])
    for bone in range(len(common_handles_list)):
        if common_handles_list[bone] == new_o_bone:
            continue
        if s_or_e_list[bone] == 0 and common_handles_list[bone].dictspec.has_key('start_vtx_pos'):
            new_o_bone['start_vtx_pos'] = common_handles_list[bone].dictspec['start_vtx_pos']
        elif common_handles_list[bone].dictspec.has_key('end_vtx_pos'):
            new_o_bone['start_vtx_pos'] = common_handles_list[bone].dictspec['end_vtx_pos']
    undo = quarkx.action()
    undo.put(compskeleton, new_o_bone)
    editor.ok(undo, "continue bone")

#
# This function attaches bone2 start_point to bone1 end_point.
#
def attach_start2end(editor, bone1, bone2):
    new_o_bone = bone2.copy()
    new_o_bone['start_point'] = bone1['end_point']
    new_o_bone['bone_length'] = ((quarkx.vect(new_o_bone.dictspec['start_point']) - quarkx.vect(new_o_bone.dictspec['end_point']))*-1).tuple
    common_handles_list, s_or_e_list = find_common_bone_handles(editor, new_o_bone.dictspec['start_point'])
    for bone in range(len(common_handles_list)):
        if common_handles_list[bone] == new_o_bone:
            continue
        if s_or_e_list[bone] == 0 and common_handles_list[bone].dictspec.has_key('start_vtx_pos'):
            new_o_bone['start_vtx_pos'] = common_handles_list[bone].dictspec['start_vtx_pos']
        elif common_handles_list[bone].dictspec.has_key('end_vtx_pos'):
            new_o_bone['start_vtx_pos'] = common_handles_list[bone].dictspec['end_vtx_pos']
    undo = quarkx.action()
    undo.exchange(bone2, new_o_bone)
    editor.ok(undo, "attach start2end handles")

#
# This function attaches bone2 start_point to bone1 start_point.
#
def attach_bones_starts(editor, bone1, bone2):
    new_o_bone = bone2.copy()
    new_o_bone['start_point'] = bone1['start_point']
    new_o_bone['bone_length'] = ((quarkx.vect(new_o_bone.dictspec['start_point']) - quarkx.vect(new_o_bone.dictspec['end_point']))*-1).tuple
    common_handles_list, s_or_e_list = find_common_bone_handles(editor, new_o_bone.dictspec['start_point'])
    for bone in range(len(common_handles_list)):
        if common_handles_list[bone] == new_o_bone:
            continue
        if s_or_e_list[bone] == 0 and common_handles_list[bone].dictspec.has_key('start_vtx_pos'):
            new_o_bone['start_vtx_pos'] = common_handles_list[bone].dictspec['start_vtx_pos']
        elif common_handles_list[bone].dictspec.has_key('end_vtx_pos'):
            new_o_bone['start_vtx_pos'] = common_handles_list[bone].dictspec['end_vtx_pos']
    undo = quarkx.action()
    undo.exchange(bone2, new_o_bone)
    editor.ok(undo, "attach start handles")

#
# This function detaches bone1 and bone2.
#
def detach_bones(editor, bone1, bone2):
    if (checktuplepos(bone1['start_point'], bone2['start_point']) == 1):
        undo = quarkx.action()
        if bone2.dictspec.has_key('start_vtx_pos') and not (bone2.dictspec.has_key('start_vtxlist')):
            new_o_bone = bone2.copy()
            new_o_bone['start_point'] = (quarkx.vect(bone2['start_point']) + quarkx.vect(.01,.01,.01)).tuple
            new_o_bone['start_vtx_pos'] = ''
            undo.exchange(bone2, new_o_bone)
        else:
            new_o_bone = bone1.copy()
            new_o_bone['start_point'] = (quarkx.vect(bone1['start_point']) + quarkx.vect(.01,.01,.01)).tuple
            new_o_bone['start_vtx_pos'] = ''
            undo.exchange(bone1, new_o_bone)
        editor.ok(undo, "detach bones")
    elif checktuplepos(bone1['end_point'], bone2['start_point']) == 1:
        undo = quarkx.action()
        if bone2.dictspec.has_key('start_vtx_pos') and not (bone2.dictspec.has_key('start_vtxlist')):
            new_o_bone = bone2.copy()
            new_o_bone['start_point'] = (quarkx.vect(bone2['start_point']) + quarkx.vect(.01,.01,.01)).tuple
            if new_o_bone.dictspec.has_key('start_vtx_pos'):
                new_o_bone['start_vtx_pos'] = ''
            undo.exchange(bone2, new_o_bone)
        else:
            new_o_bone = bone1.copy()
            new_o_bone['end_point'] = (quarkx.vect(bone1['end_point']) + quarkx.vect(.01,.01,.01)).tuple
            if new_o_bone.dictspec.has_key('end_vtx_pos'):
                new_o_bone['end_vtx_pos'] = ''
            undo.exchange(bone1, new_o_bone)
        editor.ok(undo, "detach bones")
    elif checktuplepos(bone1['start_point'], bone2['end_point']) == 1:
        undo = quarkx.action()
        if bone1.dictspec.has_key('start_vtx_pos') and not (bone1.dictspec.has_key('start_vtxlist')):
            new_o_bone = bone1.copy()
            new_o_bone['start_point'] = (quarkx.vect(bone1['start_point']) + quarkx.vect(.01,.01,.01)).tuple
            if new_o_bone.dictspec.has_key('start_vtx_pos'):
                new_o_bone['start_vtx_pos'] = ''
            undo.exchange(bone1, new_o_bone)
        else:
            new_o_bone = bone2.copy()
            new_o_bone['end_point'] = (quarkx.vect(bone2['end_point']) + quarkx.vect(.01,.01,.01)).tuple
            if new_o_bone.dictspec.has_key('end_vtx_pos'):
                new_o_bone['end_vtx_pos'] = ''
            undo.exchange(bone2, new_o_bone)
        editor.ok(undo, "detach bones")
    try:
        new_o_bone['bone_length'] = ((quarkx.vect(new_o_bone.dictspec['start_point']) - quarkx.vect(new_o_bone.dictspec['end_point']))*-1).tuple
    except:
        quarkx.msgbox("INVALID SELECTION !\n\nThe two selected bones\n" + bone1.shortname + " and " + bone2.shortname + "\nare not attached\nand therefore can not be detached.", qutils.MT_WARNING, qutils.MB_OK)
        return

#
# This function aligns bone2 start_point to bone1 end_point.
#
def align_start2end(editor, bone1, bone2):
    new_o_bone = bone2.copy()
    newpoint = quarkx.vect(bone1['end_point']) + quarkx.vect(.01,.01,.01)
    new_o_bone['start_point'] = newpoint.tuple
    new_o_bone['bone_length'] = ((quarkx.vect(new_o_bone.dictspec['start_point']) - quarkx.vect(new_o_bone.dictspec['end_point']))*-1).tuple
    undo = quarkx.action()
    undo.exchange(bone2, new_o_bone)
    editor.ok(undo, "align start2end handles")

#
# This function aligns the two selected bones start_points.
#
def align_bones_starts(editor, bone1, bone2):
    new_o_bone = bone2.copy()
    newpoint = quarkx.vect(bone1['start_point']) + quarkx.vect(.01,.01,.01)
    new_o_bone['start_point'] = newpoint.tuple
    new_o_bone['bone_length'] = ((quarkx.vect(new_o_bone.dictspec['start_point']) - quarkx.vect(new_o_bone.dictspec['end_point']))*-1).tuple
    undo = quarkx.action()
    undo.exchange(bone2, new_o_bone)
    editor.ok(undo, "align start handles")

#
# This function aligns the two selected bones end_points.
#
def align_bones_ends(editor, bone1, bone2):
    new_o_bone = bone2.copy()
    newpoint = quarkx.vect(bone1['end_point']) + quarkx.vect(.01,.01,.01)
    new_o_bone['end_point'] = newpoint.tuple
    new_o_bone['bone_length'] = ((quarkx.vect(new_o_bone.dictspec['start_point']) - quarkx.vect(new_o_bone.dictspec['end_point']))*-1).tuple
    undo = quarkx.action()
    undo.exchange(bone2, new_o_bone)
    editor.ok(undo, "align end handles")

#
# This function does the rotation movement of all bones between two selected "Key frames".
#
def keyframes_rotation(editor, bonesgroup, frame1, frame2):
    global keyframesrotation
    import qhandles
    comp = editor.Root.currentcomponent
    new_comp = comp.copy()
    framesgroup = new_comp.dictitems['Frames:fg']
    count = 0
    framecount = 0
    keyframesrotation = 1
    for frame in framesgroup.subitems:
        if frame.name == frame1.name:
            startframe = count
        count = count + 1
        if frame.name == frame2.name:
            break
        if frame.name == frame1.name or framecount != 0:
            framecount = framecount + 1
    for bone in bonesgroup.subitems:
        # Gives us just bones with vertexes assigned to their start handle.
        if bone.dictspec.has_key('start_vtxlist') and bone.dictspec.has_key('start_vtx_pos') and bone.dictspec['start_vtx_pos'] is not None:
            common_handles_list, s_or_e_list = find_common_bone_handles(editor, bone['start_point'])
            for common_handle in range(len(common_handles_list)):
                if s_or_e_list[common_handle] == 1:
                    basebonehandle = common_handles_list[common_handle].start_handle
                    import mdlhandles
                    for item in basebonehandle:
                        if isinstance(item, mdlhandles.LinBoneCornerHandle):
                            handle = item
                            break
                    view = editor.layout.views[0]
                    handle.groupselection = 1
                    handle.start_drag(view, 0, 0, 1)
                    break
                else:
                    basebonehandle = common_handles_list[common_handle].end_handle
                    import mdlhandles
                    for item in basebonehandle:
                        if isinstance(item, mdlhandles.LinBoneCornerHandle):
                            handle = item
                            break
                    view = editor.layout.views[0]
                    handle.groupselection = 1
                    handle.start_drag(view, 0, 0, 1)
                    break
            vtxlist = bone.dictspec['start_vtx_pos']
            vtxlist = vtxlist.split(" ")
            frame1_start_vtxpos = frame2_start_vtxpos = quarkx.vect(0, 0, 0)
            for start_vtx in vtxlist:
                frame1_start_vtxpos = frame1_start_vtxpos + frame1.vertices[int(start_vtx)]
                frame2_start_vtxpos = frame2_start_vtxpos + frame2.vertices[int(start_vtx)]
            frame1_start_vtxpos = frame1_start_vtxpos/ float(len(vtxlist))
            frame2_start_vtxpos = frame2_start_vtxpos/ float(len(vtxlist))
            if str(frame1_start_vtxpos) != str(frame2_start_vtxpos):
                vex_diff = frame2_start_vtxpos - frame1_start_vtxpos
                vex_diff = vex_diff.tuple
                factor = 1-(framecount/framecount+1)
                delta_diff = quarkx.vect(vex_diff[0]*factor, vex_diff[1]*factor, vex_diff[2]*factor)  # This way avoids division by zero errors.
                count = 1
                while count != framecount:
                    delta = delta_diff * count
                    frame = framesgroup.subitems[startframe + count]
                    v1 = handle.pos
                    v2 = v1 + delta
                    flags = 2056
                    oldobjectslist, newobjectslist = handle.drag(v1, v2, flags, view)
                    change1 = frame1_start_vtxpos - handle.mgr.center
                    change2 = frame2_start_vtxpos - handle.mgr.center
                    changeaxis = change1 ^ change2   # Cross product
                    m = qhandles.UserRotationMatrix(changeaxis.normalized, change2, change1, 0, float(count) / float(framecount))
                    if m is None:
                        m = quarkx.matrix(quarkx.vect(1, 0, 0), quarkx.vect(0, 1, 0), quarkx.vect(0, 0, 1))
                    vtxs = []
                    old_vtxs = frame1.vertices
                    for item in newobjectslist:
                        if item.type == ':g':
                            for poly in item.subitems:
                                vtx_index = int(poly.shortname)
                                vtx_pos = (m * (old_vtxs[vtx_index] - handle.mgr.center)) + handle.mgr.center
                ### 3 lines below gives a straight delta drag, use for straight Keyframe movement code.
                #                newvtxlist = frame.vertices[vtx_index] + delta
                #                vtxs = old_vtxs[:vtx_index] + [quarkx.vect(newvtxlist.tuple)] + old_vtxs[vtx_index+1:]
                ### 1 line below gives a vertex rotation drag, use for rotation Keyframe movement code.
                                vtxs = old_vtxs[:vtx_index] + [vtx_pos] + old_vtxs[vtx_index+1:]
                                old_vtxs = vtxs
                    frame.vertices = vtxs
                    count = count + 1
    for frame in framesgroup.subitems:
        frame.compparent = new_comp # To allow frame relocation after editing.
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    editor.ok(undo, "key frames rotation")
    keyframesrotation = 0

#
# This function finds all bone handles start_points and end_points that are
# the same as the handle_pos provided, primarily used for specific settings drags.
#
def find_common_bone_handles(editor, handle_pos):
    common_handles_list = []
    s_or_e_list = []
    compbones = editor.Root.currentcomponent.findallsubitems("", ':bone')      # get all bones
    for bone in compbones:
        # Handles the "Start of Bone".
        if checktuplepos(bone.dictspec['start_point'], handle_pos) == 1:
            common_handles_list = common_handles_list + [bone]
            s_or_e_list = s_or_e_list + [0]
        # Handles the "End of Bone".
        elif checktuplepos(bone.dictspec['end_point'], handle_pos) == 1:
            common_handles_list = common_handles_list + [bone]
            s_or_e_list = s_or_e_list + [1]
    return common_handles_list, s_or_e_list



###############################
#
# Selection functions
#
###############################



def SkinVertexSel(editor, sellist):
    "Used when a single or multiple vertexes are selected in the Skin-view"
    "by 'picking' them individually or by using the Red Rectangle Selector."
    "The selected Skin vertexes will be added, if not already selected, to the SkinVertexSelList."
    "The first Skin vertex in the SkinVertexSelList will always be used as the Skin-view's 'base' vertex."
    "You will need to call to redraw the Skin-view for this list once it is updated to display the selections."

    # Equivalent of skinpick_cleared in mdlhandles.py file.
    if sellist == []:
        editor.SkinVertexSelList = []
        return

    if len(sellist) > 1:
        setup = quarkx.setupsubset(SS_MODEL, "Options")
        if not setup["SingleVertexDrag"]:
    # Compares the 1st Skin-view vertex position in the sellist to all others 3D position (pos) and places the
    #    last one that matches at the front of the sellist as the 'base vertex' to be drawn so it can be seen.
            holditem = sellist[0]
            for item in range (len(sellist)):
                if item == 0:
                    pass
                else:
                    if holditem[0] == sellist[item][0]:
                        holditem = sellist[item]
            dupe = holditem
            sellist.remove(dupe)
            sellist = [holditem] + sellist
        else:
            newlist = []
            for item in range (len(sellist)):
                holditem = sellist[item]
                if newlist == []:
                    newlist = newlist + [holditem]
                    continue
                compaircount = -1
                for compairitem in newlist:
                    compaircount = compaircount + 1
                    if str(holditem[0]) == str(compairitem[0]):
                        break
                if compaircount == len(newlist)-1:
                    newlist = newlist + [holditem]
            sellist = newlist
    # Compares the 1st Skin-view vertex position in the sellist to all others 3D position (pos) and places the
    #    last one that matches at the front of the sellist as the 'base vertex' to be drawn so it can be seen.
            holditem = sellist[0]
            for item in range (len(sellist)):
                if item == 0:
                    pass
                else:
                    if holditem[0] == sellist[item][0]:
                        holditem = sellist[item]
            dupe = holditem
            sellist.remove(dupe)
            sellist = [holditem] + sellist

  # Checks for and removes any duplications of items in the list.
    for vertex in sellist:
        itemcount = 0
        if editor.SkinVertexSelList == []:
            editor.SkinVertexSelList = editor.SkinVertexSelList + [vertex]
            if len(sellist) == 1:
                return
        else:
            for item in editor.SkinVertexSelList:
                itemcount = itemcount + 1
                if vertex[2] == item[2] and  vertex[3] == item[3]:
                    editor.SkinVertexSelList.remove(item)
                    break
                elif itemcount == len(editor.SkinVertexSelList):
                    editor.SkinVertexSelList = editor.SkinVertexSelList + [vertex]



def PassSkinSel2Editor(editor):
    "For passing selected vertexes(faces) from the Skin-view to the Editor's views."
    "After you call this function you will need to also call to draw the handels in the views."
    "This uses the SkinVertexSelList for passing to the ModelVertexSelList."
    "How to convert from the SkinVertexSelList to the ModelVertexSelList using tri_index and ver_index."
    " tri_index = tris[vtx[2]] this is the 3rd item in a SkinVertexSelList item."
    " ver_index = tris[vtx[2]][vtx[3]][0] this is the 4th item in a SkinVertexSelList item."
    "The above indexes are used to find the corresponding triangle vertex index in the model meshes triangles."
    "Also see the explanation of 'PassEditorSel2Skin' below for further detail."

    tris = editor.Root.currentcomponent.triangles
    for vtx in editor.SkinVertexSelList:
        if editor.ModelVertexSelList == []:
            editor.ModelVertexSelList = editor.ModelVertexSelList + [[tris[vtx[2]][vtx[3]][0], vtx[0]]]
        else:
            for vertex in range(len(editor.ModelVertexSelList)):
                if tris[vtx[2]][vtx[3]][0] == editor.ModelVertexSelList[[vertex][0]][0]:
                    break
                if vertex == len(editor.ModelVertexSelList)-1:
                    editor.ModelVertexSelList = editor.ModelVertexSelList + [[tris[vtx[2]][vtx[3]][0], vtx[0]]]



def PassEditorSel2Skin(editor, option=1):
    "For passing selected vertexes(faces) from the Editor's views to the Skin-view."
    "After you call this function you will need to also call to draw the handels in the Skin-view."
    "The 'option' value of 1 uses the ModelVertexSelList for passing individual selected vertexes to the Skin-view."
    "The 'option' value of 2 uses the ModelFaceSelList for passing selected 'faces' vertexes to the Skin-view."
    "The 'option' value of 3 uses the SkinFaceSelList for passing selected 'faces' vertexes but retains its own data"
    "which is used to draw the highlighted outlines of the Skin-view selected faces in the qbaseeditor.py 'finishdrawing' function."
    "All three will be applied to the Skin-view's SkinVertexSelList of 'existing' vertex selection, if any."
    " See the mdleditor.py file (very beginning) for each individual item's, list of items-their format."
    "     tri_index (or editor_tri_index in the case below) = tris[tri]"
    "     tri being the sequential number (starting with zero) as it iterates (counts)"
    "     through the list of 'component triangles'."

    "     ver_index = tris[tri][vertex][0]"
    "     [vertex] being each vertex 'item' of the triangle as we iterate through all 3 of them"
    "     and [0] being the 1st item in each of the triangles vertex 'items'. That is ...(see below)"

    "     Each triangle vertex 'item' is another list of items, the 1st item being its ver_index,"
    "     where this vertex lies in a 'frames vertices' list of vertexes."
    "     Each 'frame' has its own list that gives every vertex point of the models mesh for that frame."
    "     Or, each of the 'frame vertices' is the actual 3D position of that triangles vertex 'x,y,z point'."

    "     (see skinvtx_index below, the models mesh and skin mesh vertex formats are not the same.)"
    "     The Skin-view has no triangles, it only uses a list of vertices."
    "     That list of vertices is made up in the same order that the 'frame vertices' lists are."
    "     Which is starting with the 1st vertex of the 1st triangle"
    "     and ending with the last vertex of the last triangle. This list make up the Skin-view view.handles."
    "     Therefore, you can call for a specific triangles Skin-view vertex"
    "     by using that triangles 'item' ver_index number."
    "     The 1st item in the models mesh ver_index is that vertexe's position in the 'Frame objects vertices' list"
    "     AND the Skin-view's view.handles list."

    "     All 3 of the items in the models 'skin mesh' (or view.handles)"
    "     are in the same 'order' of the triangle (0, 1, 2) vertexes."
    "     So for each model components mesh triangle in the Editor,"
    "     there are 3 vertex view.handles in the Skin-view mesh"
    "     and why we need to iterate through the Skin-view view.handles"
    "     to match up its corresponding triangle vertex."

    "     Another way to call a triangles Skin-view 'view.handles' would be with the following formula:"
    "     (tri_index * 3) + its vertex position number, either 0, 1 or 2. For example to get the 3 view.handles of tri_index 5:"
    "         from mdlhandles import SkinView1                   "
    "         if SkinView1 is not None:                          "
    "             vertex0 = SkinView1.handles[(tri_index*3)+0]   "
    "             vertex1 = SkinView1.handles[(tri_index*3)+1]   "
    "             vertex2 = SkinView1.handles[(tri_index*3)+2]   "

    tris = editor.Root.currentcomponent.triangles
    from mdlhandles import SkinView1
    import mdlhandles
    skinhandle = None

    if option == 1:
        vertexlist = editor.ModelVertexSelList
        if editor.Root.currentcomponent is None:
            componentnames = []
            for item in editor.Root.dictitems:
                if item.endswith(":mc"):
                    componentnames.append(item)
            componentnames.sort()
            editor.Root.currentcomponent = editor.Root.dictitems[componentnames[0]]
        comp = editor.Root.currentcomponent
        commontris = []
        for vert in vertexlist:
            commontris = commontris + findTrianglesAndIndexes(comp, vert[0], vert[1])

    if option == 2:
        vertexlist = []
        for tri_index in editor.ModelFaceSelList:
            for vertex in range(len(tris[tri_index])):
                vtx = tris[tri_index][vertex][0]
                vertexlist = vertexlist + [[vtx, tri_index]]

    if option == 3:
        vertexlist = []
        for tri_index in editor.SkinFaceSelList:
            for vertex in range(len(tris[tri_index])):
                vtx = tris[tri_index][vertex][0]
                vertexlist = vertexlist + [[vtx, tri_index]]

    if option == 1:
        for vert in commontris:
            editor_tri_index = vert[2]
            skinvtx_index = vert[3]
            if SkinView1 is not None:
                if editor.SkinVertexSelList == []:
                    for handle in SkinView1.handles:
                        if (isinstance(handle, mdlhandles.LinRedHandle)) or (isinstance(handle, mdlhandles.LinSideHandle)) or (isinstance(handle, mdlhandles.LinCornerHandle)):
                            continue
                        # Here we compair the Skin-view handle (in its handles list) tri_index item
                        #    to the editor_tri_index we got above to see if they match.
                        # The same applies to the comparison of the Skin-view handel ver_index and skinvtx_index.
                        try:
                            if handle.tri_index == editor_tri_index and handle.ver_index == skinvtx_index:
                                skinhandle = handle
                                break
                        except:
                            return
                    if skinhandle is not None:
                        editor.SkinVertexSelList = editor.SkinVertexSelList + [[skinhandle.pos, skinhandle, skinhandle.tri_index, skinhandle.ver_index]]
                else:
                    for handle in SkinView1.handles:
                        if (isinstance(handle, mdlhandles.LinRedHandle)) or (isinstance(handle, mdlhandles.LinSideHandle)) or (isinstance(handle, mdlhandles.LinCornerHandle)):
                            continue
                        if handle.tri_index == editor_tri_index and handle.ver_index == skinvtx_index:
                            skinhandle = handle
                            break
                    if skinhandle is not None:
                        for vertex in range(len(editor.SkinVertexSelList)):
                            if editor.SkinVertexSelList[vertex][2] == skinhandle.tri_index and editor.SkinVertexSelList[vertex][3] == skinhandle.ver_index:
                               break
                            if vertex == len(editor.SkinVertexSelList)-1:
                                editor.SkinVertexSelList = editor.SkinVertexSelList + [[skinhandle.pos, skinhandle, skinhandle.tri_index, skinhandle.ver_index]]

    if option == 2 or option == 3:
        editor_tri_index = None
        for vtx in vertexlist:
            ver_index = vtx[0]
            if editor.SkinVertexSelList == []:
                for vertex in range(len(tris[vtx[1]])):
                    if ver_index == tris[vtx[1]][vertex][0]:
                        editor_tri_index = vtx[1]
                        skinvtx_index = vertex
                        break
                if editor_tri_index is None:
                    continue
                if SkinView1 is None:
                    pass
                else:
                    for handle in SkinView1.handles:
                        if (isinstance(handle, mdlhandles.LinRedHandle)) or (isinstance(handle, mdlhandles.LinSideHandle)) or (isinstance(handle, mdlhandles.LinCornerHandle)):
                            continue
                        # Here we compair the Skin-view handle (in its handles list) tri_index item
                        #    to the editor_tri_index we got above to see if they match.
                        # The same applies to the comparison of the Skin-view handel ver_index and skinvtx_index.
                        try:
                            if handle.tri_index == editor_tri_index and handle.ver_index == skinvtx_index:
                                skinhandle = handle
                                break
                        except:
                            return
                    if skinhandle is not None:
                        editor.SkinVertexSelList = editor.SkinVertexSelList + [[skinhandle.pos, skinhandle, skinhandle.tri_index, skinhandle.ver_index]]
            else:
                for vertex in range(len(tris[vtx[1]])):
                    if ver_index == tris[vtx[1]][vertex][0]:
                        editor_tri_index = vtx[1]
                        skinvtx_index = vertex
                        break
                if editor_tri_index is None: continue
                for handle in SkinView1.handles:
                    if (isinstance(handle, mdlhandles.LinRedHandle)) or (isinstance(handle, mdlhandles.LinSideHandle)) or (isinstance(handle, mdlhandles.LinCornerHandle)):
                        continue
                    if handle.tri_index == editor_tri_index and handle.ver_index == skinvtx_index:
                        skinhandle = handle
                        break
                if skinhandle is not None:
                    for vertex in range(len(editor.SkinVertexSelList)):
                        if editor.SkinVertexSelList[vertex][2] == skinhandle.tri_index and editor.SkinVertexSelList[vertex][3] == skinhandle.ver_index:
                            break
                        if vertex == len(editor.SkinVertexSelList)-1:
                            editor.SkinVertexSelList = editor.SkinVertexSelList + [[skinhandle.pos, skinhandle, skinhandle.tri_index, skinhandle.ver_index]]

    # Compares the 1st Skin-view vertex position in the sellist to all others 3D position (pos) and places the
    #    last one that matches at the front of the sellist as the 'base vertex' to be drawn so it can be seen.
    if len(editor.SkinVertexSelList) > 1:
        holditem = editor.SkinVertexSelList[0]
        for item in range (len(editor.SkinVertexSelList)):
            if item == 0:
                pass
            else:
                if holditem[0] == editor.SkinVertexSelList[item][0]:
                    holditem = editor.SkinVertexSelList[item]
        dupe = holditem
        editor.SkinVertexSelList.remove(dupe)
        editor.SkinVertexSelList = [holditem] + editor.SkinVertexSelList



###############################
#
# Texture handling functions
#
###############################


#
# Changes the selected faces (triangles), in the ModelFaceSelList of the editor,
# u and v skinning coords based on the editor3Dview positions
# which also changes their layout in the Skin-view causing a
# "re-mapping" of those selected faces skin positions.
#
def skinremap(editor):
    comp = editor.Root.currentcomponent
    if (comp is None) or (comp.currentframe is None) or (editor.ModelFaceSelList == []):
        quarkx.msgbox("Improper Action !\n\nYou need to select at least one\nface of a component to be re-skinned\nto activate this function.\n\nPress 'F1' for InfoBase help\nof this function for details.\n\nAction Canceled.", MT_ERROR, MB_OK)
        return
    new_comp = comp.copy()
    framevtxs = comp.currentframe.vertices

    # Sets the editors 3D view to get the new u,v co-ordinances from.
    for v in editor.layout.views:
        if v.info["viewname"] == "editors3Dview":
            cordsview = v

    # Changes the old u,v Skin-view position values for each selected face
    # to the new ones and replaces those old triangles with the updated ones.
    for tri_index in editor.ModelFaceSelList:
        # Because the original list can not be changed, we use a dummy list copy
        # then pass the updated values back to the original list, and so on, in a loop.
        newtris = new_comp.triangles
        for vtx in range(len(comp.triangles[tri_index])):
            u = int(cordsview.proj(framevtxs[comp.triangles[tri_index][vtx][0]]).tuple[0])
            v = int(cordsview.proj(framevtxs[comp.triangles[tri_index][vtx][0]]).tuple[1])
            if vtx == 0:
                vtx0 = (comp.triangles[tri_index][vtx][0], u, v)
            elif vtx == 1:
                vtx1 = (comp.triangles[tri_index][vtx][0], u, v)
            else:
                vtx2 = (comp.triangles[tri_index][vtx][0], u, v)
        tri = (vtx0, vtx1, vtx2)
        newtris[tri_index:tri_index+1] = [tri]
        new_comp.triangles = newtris

        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        for compframe in compframes:
            compframe.compparent = new_comp # To allow frame relocation after editing.

    # Finally the undo exchange is made and ok called to finish the function.
    undo = quarkx.action()
    undo.exchange(comp, new_comp)
    editor.ok(undo, "Skin-view remap")
    for view in editor.layout.views:
        if view.viewmode != "wire":
            view.invalidate(1)


#
# view = current view that the cursor is in.
# If one of the editor's views:
#    object = triangleface = a single item list containing the triangle face that the cursor is over.
#    Returns TWO lists (of integers) WITHIN another list, of a texture's pixel u, v
#        position on a triangle where the cursor is located at in any of the views.
#    The first sub-list is used for any of the editor's views.
#       It gives the actual pixel location on the skin texture itself.
#       This sub-list is then used for any of the quarkx 'Texture Functions'
#        to locate and\or change a pixel on a texture, or textures palette if one exist.
#    The second sub-list is strictly used, if desired, to pass to and draw something
#        in the Skin-view, using it's 'canvas()' function, at the same time and
#        pixel location when the cursor is in one of the other editor's views, for example:
#            returnedlist = [[pixU, pixV], [skinpixU, skinpixV]]
#            skinpixU, skinpixV = returnedlist[1]
#            if SkinView1 is not None:
#                texWidth, texHeight = modelfacelist[0][1].currentskin["Size"]
#                skinpix = quarkx.vect(skinpixU-int(texWidth*.5), skinpixV-int(texHeight*.5), 0)
#                skinviewX, skinviewY, skinviewZ = SkinView1.proj(skinpix).tuple
#                skincv = SkinView1.canvas()
#                svs = round(SkinView1.info['scale']*.5)
#                brushwidth = float(quarkx.setupsubset(SS_MODEL, "Options")["Paint_BrushWidth"])
#                svs = int(brushwidth * svs)
#                skincv.rectangle(int(skinviewX)-svs,int(skinviewY)-svs,int(skinviewX)+svs,int(skinviewY)+svs)
#      If the cursor is currently in the Skin-view use as described below.
# If the Skin-view:
#    object (not needed)
#    Returns a single list containing two integers, the texture's pixel u, v position in the Skin-view.
# x and y = the position where the cursor is at in the view as a 'projected' 2D screen view.
#
def TexturePixelLocation(editor, view, x, y, object=None):
    if view.info["viewname"] != "skinview":
        triangleface = object
        if triangleface != []:
            trivtx0, trivtx1, trivtx2 = triangleface[0][1].triangles[triangleface[0][2]]

            facevtx0 = triangleface[0][1].currentframe.vertices[triangleface[0][1].triangles[triangleface[0][2]][0][0]]
            facevtx1 = triangleface[0][1].currentframe.vertices[triangleface[0][1].triangles[triangleface[0][2]][1][0]]
            facevtx2 = triangleface[0][1].currentframe.vertices[triangleface[0][1].triangles[triangleface[0][2]][2][0]]
            
            pixpos = view.space(quarkx.vect(x, y, 0)) # Where the cursor is pointing in the view.

            vectorZ = view.vector("z").normalized
            facenormal = ((facevtx1 - facevtx0) ^ (facevtx2 - facevtx0)).normalized
            pixpos = pixpos - ((((pixpos - facevtx0) * facenormal) / (vectorZ * facenormal)) * vectorZ)

            # Adapted from http://www.blackpawn.com/texts/pointinpoly/default.html
            # Formula to compute u and v for a point on a triangle face:
            # ==========================================================
            # We use trivtx0 as our base, for it's U,V values to multiply our two factors by
            # and get the U,V values for pixpos (where our cursor is at in the 3D view).

            P = pixpos
            A = facevtx0
            B = facevtx1
            C = facevtx2
            # (what we are computing to get) u texture position value
            # (what we are computing to get) v texture position value


            v0 = (C - A)
            v1 = (B - A)
            v2 = (P - A)
            
            dot00 = v0 * v0
            dot01 = v0 * v1
            dot02 = v0 * v2
            dot11 = v1 * v1
            dot12 = v1 * v2

            invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
            V = (dot11 * dot02 - dot01 * dot12) * invDenom
            U = (dot00 * dot12 - dot01 * dot02) * invDenom

            # To draw, by pixel location, in Skin-view using it's 'canvase()' function.
            skinpixU = int((1 - U - V) * trivtx0[1] + U * trivtx1[1] + V * trivtx2[1])+.5
            skinpixV = int((1 - U - V) * trivtx0[2] + U * trivtx1[2] + V * trivtx2[2])+.5

            # The actual pixel location on the skin texture itself.
            pixU = int(skinpixU-.5)
            pixV = int(skinpixV-.5)

            # This section corrects for texture tiling in the editor's views.
            texWidth, texHeight = editor.Root.currentcomponent.currentskin["Size"]
            cursorXpos = pixU
            cursorYpos = pixV

            if cursorXpos >= texWidth-1:
                Xstart = int(cursorXpos / texWidth)
                pixU = int(cursorXpos - (texWidth * Xstart))
            elif cursorXpos < -texWidth:
                Xstart = int(abs(cursorXpos / (texWidth+.5)))
                pixU = int(cursorXpos + (texWidth * Xstart) + texWidth)
            else:
                if cursorXpos >= 1:
                    pixU = cursorXpos
                if cursorXpos <= -1:
                    pixU = cursorXpos + texWidth
                if cursorXpos == 0:
                    pixU = 0

            while pixU >= texWidth:
                pixU = pixU - 1
            while pixU <= -1:
                pixU = texWidth - 1
            pixU = int(pixU)

            if cursorYpos >= texHeight-1:
                Ystart = int(cursorYpos / texHeight)
                pixV = int(cursorYpos - (texHeight * Ystart))
            elif cursorYpos < -texHeight:
                Ystart = int(abs(cursorYpos / (texHeight+.5)))
                pixV = int(cursorYpos + (texHeight * Ystart) + texHeight)
            else:
                if cursorYpos >= 1:
                    pixV = cursorYpos
                if cursorYpos <= -1:
                    pixV = cursorYpos + texHeight
                if cursorYpos == 0:
                    pixV = 0

            while pixV >= texHeight:
                pixV = pixV - 1
            while pixV <= -1:
                pixV = texHeight - 1
            pixV = int(pixV)

            return [[pixU, pixV], [skinpixU, skinpixV]]

    else:
        # This section computes the proper pixU, pixV position values for tiling in the Skin-view.
        texWidth, texHeight = editor.Root.currentcomponent.currentskin["Size"]
        list = view.space(quarkx.vect(x, y, 0)).tuple
        cursorXpos = int(list[0])
        cursorYpos = int(list[1])
        if cursorXpos >= (texWidth * .5):
            Xstart = int((cursorXpos / texWidth) -.5)
            Xpos = -texWidth + cursorXpos - (texWidth * Xstart)
        elif cursorXpos <= (-texWidth * .5):
            Xstart = int((cursorXpos / texWidth) +.5)
            Xpos = texWidth + cursorXpos + (texWidth * -Xstart) - 1
        else:
            if cursorXpos > 0:
                Xpos = cursorXpos
            if cursorXpos < 0:
                Xpos = cursorXpos - 1
            if cursorXpos == 0:
                cursorXpos = list[0]
                if cursorXpos < 0:
                    Xpos = -1
                else:
                    Xpos = 0

        pixU = Xpos + (texWidth * .5)
        while pixU >= texWidth:
            pixU = pixU - 1
        while pixU <= -texWidth:
            pixU = pixU + 1
        pixU = int(pixU)

        if cursorYpos >= (texHeight * .5):
            Ystart = int((cursorYpos / texHeight) -.5)
            Ypos = -texHeight + cursorYpos - (texHeight * Ystart)
        elif cursorYpos <= (-texHeight * .5):
            Ystart = int((cursorYpos / texHeight) +.5)
            Ypos = texHeight + cursorYpos + (texHeight * -Ystart) -1
        else:
            if cursorYpos > 0:
                Ypos = cursorYpos
            if cursorYpos < 0:
                Ypos = cursorYpos - 1
            if cursorYpos == 0:
                cursorYpos = list[1]
                if cursorYpos < 0:
                    Ypos = -1
                else:
                    Ypos = 0

        pixV = Ypos + (texHeight * .5)
        while pixV >= texHeight:
            pixV = pixV - 1
        while pixV <= -texHeight:
            pixV = pixV + 1
        pixV = int(pixV)

        return [pixU, pixV]



###############################
#
# General Editor functions
#
###############################



def Update_Editor_Views(editor, option=4):
    "Updates the Editors views once something has chaged in the Skin-view,"
    "such as synchronized or added 'skin mesh' vertex selections."
    "It can also be used to just update all of the Editor's views or just its 2D views."
    "Various 'option' items are shown below in their proper order of sequence."
    "This is done to increase drawing speed, only use what it takes to do the job."

    import mdleditor
    import mdlhandles
    import qhandles
    import mdlmgr
    mdlmgr.treeviewselchanged = 1
    editorview = editor.layout.views[0]
    newhandles = mdlhandles.BuildHandles(editor, editor.layout.explorer, editorview)
    for v in editor.layout.views:
        if v.info["viewname"] == "skinview":
            pass
        if (option == 6 and v.info["viewname"] == "editors3Dview") or (option == 6 and v.info["viewname"] == "3Dwindow"):
            pass
        else:
            if option == 1:
                v.invalidate(1)
            if option <= 6:
                mdleditor.setsingleframefillcolor(editor, v)
            if option <= 6:
                v.repaint()
            if option <= 6:
                plugins.mdlgridscale.gridfinishdrawing(editor, v)
                plugins.mdlaxisicons.newfinishdrawing(editor, v)
            if option <= 6 or option == 5:
                if v.info["viewname"] == "editors3Dview" and quarkx.setupsubset(SS_MODEL, "Options")["Options3Dviews_nohandles1"] == "1":
                    v.handles = []
                elif v.info["viewname"] == "XY" and quarkx.setupsubset(SS_MODEL, "Options")["Options3Dviews_nohandles2"] == "1":
                    v.handles = []
                elif v.info["viewname"] == "YZ" and quarkx.setupsubset(SS_MODEL, "Options")["Options3Dviews_nohandles3"] == "1":
                    v.handles = []
                elif v.info["viewname"] == "XZ" and quarkx.setupsubset(SS_MODEL, "Options")["Options3Dviews_nohandles4"] == "1":
                    v.handles = []
                elif v.info["viewname"] == "3Dwindow" and quarkx.setupsubset(SS_MODEL, "Options")["Options3Dviews_nohandles5"] == "1":
                    v.handles = []
                else:
                    v.handles = newhandles
                if editor.ModelFaceSelList != []:
                    mdlhandles.ModelFaceHandle(qhandles.GenericHandle).draw(editor, v, editor.EditorObjectList)
                if v.handles is None:
                    v.handles = []
                if v.handles == []:
                    pass
                else:
                    cv = v.canvas()
                    for h in v.handles:
                       h.draw(v, cv, h)
                if quarkx.setupsubset(SS_MODEL, "Options")["MAIV"] == "1":
                    mdleditor.modelaxis(v)



def ReverseFaces(editor):
    "Reverses or mirrors the selected faces, in the ModelFaceSelList, vertexes"
    "making turning the face in the opposite direction."
    comp = editor.Root.currentcomponent
    if (len(editor.ModelFaceSelList) < 1) or (comp is None):
        quarkx.msgbox("No selection has been made\n\nYou must first select some faces of a\nmodel component to flip their direction", MT_ERROR, MB_OK)
        return
    new_tris = comp.triangles
    for tri in editor.ModelFaceSelList:
        vtxs = comp.triangles[tri]
        if vtxs[1][0] > vtxs[2][0]:
            new_tris[tri] = (vtxs[1],vtxs[0],vtxs[2])
        else:
            new_tris[tri] = (vtxs[2],vtxs[1],vtxs[0])
    comp.triangles = new_tris
    Update_Editor_Views(editor)



def SubdivideFaces(editor, pieces=None):
    "Splits the selected faces, in the ModelFaceSelList, into the number of new triangles given as 'pieces'."
    comp = editor.Root.currentcomponent
    if (len(editor.ModelFaceSelList) < 1) or (comp is None):
        quarkx.msgbox("No selection has been made\n\nYou must first select some faces of a\nmodel component to subdivide those faces.", MT_ERROR, MB_OK)
        return

    new_comp = comp.copy()
    new_tris = new_comp.triangles
    newtri_index = len(comp.triangles)-1
    newfaceselection = []
    compframes = new_comp.findallsubitems("", ':mf')   # get all frames
    currentvertices = len(compframes[0].vertices)-1
    curframe = comp.currentframe
    curframeNR = 0
    for frames in comp.findallsubitems("", ':mf'):
        if frames == curframe:
            break
        curframeNR = curframeNR + 1

    if pieces == 2:
        # This updates (adds) the new vertices to each frame.
        commonvtxs = []
        commonvtxnbr = []
        for tri in editor.ModelFaceSelList:
            for vtx in comp.triangles[tri]:
                if not (curframe.vertices[vtx[0]] in commonvtxs):
                    commonvtxs = commonvtxs + [curframe.vertices[vtx[0]]]
                    commonvtxnbr = commonvtxnbr + [vtx[0]]
        for tri in editor.ModelFaceSelList:
            trivtxs = comp.triangles[tri]
            # Line for vertex 0 and vertex 1 will be split because it is the longest side.
            if (abs(curframe.vertices[trivtxs[0][0]] - curframe.vertices[trivtxs[1][0]]) > abs(curframe.vertices[trivtxs[1][0]] - curframe.vertices[trivtxs[2][0]])) and (abs(curframe.vertices[trivtxs[0][0]] - curframe.vertices[trivtxs[1][0]]) > abs(curframe.vertices[trivtxs[2][0]] - curframe.vertices[trivtxs[0][0]])):
                sidecenter = (curframe.vertices[trivtxs[0][0]] + curframe.vertices[trivtxs[1][0]])*.5
                for vtx in range(len(commonvtxs)):
                    if str(sidecenter) == str(commonvtxs[vtx]):
                        newvtx_index0 = commonvtxnbr[vtx]
                        newvtx0u = (trivtxs[0][1] + trivtxs[1][1])*.5
                        newvtx0v = (trivtxs[0][2] + trivtxs[1][2])*.5
                        new_tris[tri] = ((newvtx_index0,newvtx0u,newvtx0v), trivtxs[2], trivtxs[0])
                        new_tris = new_tris + [((newvtx_index0,newvtx0u,newvtx0v), trivtxs[1], trivtxs[2])]
                        newtri_index = newtri_index + 1
                        newfaceselection = newfaceselection + [newtri_index]
                        break
                    if vtx == len(commonvtxs)-1:
                        currentvertices = currentvertices + 1
                        newvtx_index0 = currentvertices
                        newvtx0u = (trivtxs[0][1] + trivtxs[1][1])*.5
                        newvtx0v = (trivtxs[0][2] + trivtxs[1][2])*.5
                        new_tris[tri] = ((newvtx_index0,newvtx0u,newvtx0v), trivtxs[2], trivtxs[0])
                        new_tris = new_tris + [((newvtx_index0,newvtx0u,newvtx0v), trivtxs[1], trivtxs[2])]
                        newtri_index = newtri_index + 1
                        newfaceselection = newfaceselection + [newtri_index]
                        commonvtxs = commonvtxs + [sidecenter]
                        commonvtxnbr = commonvtxnbr + [newvtx_index0]
                        for compframe in compframes:
                            old_vtxs = compframe.vertices
                            sidecenter = (compframe.vertices[trivtxs[0][0]] + compframe.vertices[trivtxs[1][0]])*.5
                            old_vtxs = old_vtxs + [sidecenter]
                            compframe.vertices = old_vtxs
                            compframe.compparent = new_comp
            # Line for vertex 1 and vertex 2 will be split because it is the longest side.
            elif (abs(curframe.vertices[trivtxs[1][0]] - curframe.vertices[trivtxs[2][0]]) > abs(curframe.vertices[trivtxs[0][0]] - curframe.vertices[trivtxs[1][0]])) and (abs(curframe.vertices[trivtxs[1][0]] - curframe.vertices[trivtxs[2][0]]) > abs(curframe.vertices[trivtxs[2][0]] - curframe.vertices[trivtxs[0][0]])):
                sidecenter = (curframe.vertices[trivtxs[1][0]] + curframe.vertices[trivtxs[2][0]])*.5
                for vtx in range(len(commonvtxs)):
                    if str(sidecenter) == str(commonvtxs[vtx]):
                        newvtx_index0 = commonvtxnbr[vtx]
                        newvtx0u = (trivtxs[1][1] + trivtxs[2][1])*.5
                        newvtx0v = (trivtxs[1][2] + trivtxs[2][2])*.5
                        new_tris[tri] = ((newvtx_index0,newvtx0u,newvtx0v), trivtxs[2], trivtxs[0])
                        new_tris = new_tris + [((newvtx_index0,newvtx0u,newvtx0v), trivtxs[0], trivtxs[1])]
                        newtri_index = newtri_index + 1
                        newfaceselection = newfaceselection + [newtri_index]
                        break
                    if vtx == len(commonvtxs)-1:
                        currentvertices = currentvertices + 1
                        newvtx_index0 = currentvertices
                        newvtx0u = (trivtxs[1][1] + trivtxs[2][1])*.5
                        newvtx0v = (trivtxs[1][2] + trivtxs[2][2])*.5
                        new_tris[tri] = ((newvtx_index0,newvtx0u,newvtx0v), trivtxs[2], trivtxs[0])
                        new_tris = new_tris + [((newvtx_index0,newvtx0u,newvtx0v), trivtxs[0], trivtxs[1])]
                        newtri_index = newtri_index + 1
                        newfaceselection = newfaceselection + [newtri_index]
                        commonvtxs = commonvtxs + [sidecenter]
                        commonvtxnbr = commonvtxnbr + [newvtx_index0]
                        for compframe in compframes:
                            old_vtxs = compframe.vertices
                            sidecenter = (compframe.vertices[trivtxs[1][0]] + compframe.vertices[trivtxs[2][0]])*.5
                            old_vtxs = old_vtxs + [sidecenter]
                            compframe.vertices = old_vtxs
                            compframe.compparent = new_comp
            # Line for vertex 2 and vertex 0 will be split because it is the longest side.
            else:
                sidecenter = (curframe.vertices[trivtxs[2][0]] + curframe.vertices[trivtxs[0][0]])*.5
                for vtx in range(len(commonvtxs)):
                    if str(sidecenter) == str(commonvtxs[vtx]):
                        newvtx_index0 = commonvtxnbr[vtx]
                        newvtx0u = (trivtxs[2][1] + trivtxs[0][1])*.5
                        newvtx0v = (trivtxs[2][2] + trivtxs[0][2])*.5
                        new_tris[tri] = ((newvtx_index0,newvtx0u,newvtx0v), trivtxs[0], trivtxs[1])
                        new_tris = new_tris + [((newvtx_index0,newvtx0u,newvtx0v), trivtxs[1], trivtxs[2])]
                        newtri_index = newtri_index + 1
                        newfaceselection = newfaceselection + [newtri_index]
                        break
                    if vtx == len(commonvtxs)-1:
                        currentvertices = currentvertices + 1
                        newvtx_index0 = currentvertices
                        newvtx0u = (trivtxs[2][1] + trivtxs[0][1])*.5
                        newvtx0v = (trivtxs[2][2] + trivtxs[0][2])*.5
                        new_tris[tri] = ((newvtx_index0,newvtx0u,newvtx0v), trivtxs[0], trivtxs[1])
                        new_tris = new_tris + [((newvtx_index0,newvtx0u,newvtx0v), trivtxs[1], trivtxs[2])]
                        newtri_index = newtri_index + 1
                        newfaceselection = newfaceselection + [newtri_index]
                        commonvtxs = commonvtxs + [sidecenter]
                        commonvtxnbr = commonvtxnbr + [newvtx_index0]
                        for compframe in compframes:
                            old_vtxs = compframe.vertices
                            sidecenter = (compframe.vertices[trivtxs[2][0]] + compframe.vertices[trivtxs[0][0]])*.5
                            old_vtxs = old_vtxs + [sidecenter]
                            compframe.vertices = old_vtxs
                            compframe.compparent = new_comp

        # This updates (adds) the new triangles to the component.
        new_comp.triangles = new_tris
        new_comp.currentskin = editor.Root.currentcomponent.currentskin
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        new_comp.currentframe = compframes[curframeNR]
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.Root.currentcomponent = new_comp
        editor.ok(undo, "face Subdivision 2")
        editor.ModelFaceSelList = editor.ModelFaceSelList + newfaceselection
        newfaceselection = []
        import mdlhandles
        from mdlhandles import SkinView1
        if SkinView1 is not None:
            q = editor.layout.skinform.linkedobjects[0]
            q["triangles"] = str(len(editor.Root.currentcomponent.triangles))
            editor.layout.skinform.setdata(q, editor.layout.skinform.form)
            SkinView1.invalidate()

    elif pieces == 3:
        # This updates (adds) the new vertices to each frame.
        for tri_index in editor.ModelFaceSelList:
            currentvertices = currentvertices + 1
            for compframe in compframes:
                old_vtxs = compframe.vertices
                faceCenter = (old_vtxs[new_tris[tri_index][0][0]] + old_vtxs[new_tris[tri_index][1][0]] + old_vtxs[new_tris[tri_index][2][0]]) / 3
                compframe.vertices = old_vtxs + [faceCenter]
                compframe.compparent = new_comp
            faceCenterU = int((new_tris[tri_index][0][1] + new_tris[tri_index][1][1] + new_tris[tri_index][2][1]) / 3)
            faceCenterV = int((new_tris[tri_index][0][2] + new_tris[tri_index][1][2] + new_tris[tri_index][2][2]) / 3)
            newtri1 = ((currentvertices, faceCenterU, faceCenterV), (new_tris[tri_index][1][0], new_tris[tri_index][1][1], new_tris[tri_index][1][2]), (new_tris[tri_index][2][0], new_tris[tri_index][2][1], new_tris[tri_index][2][2]))
            newtri2 = ((currentvertices, faceCenterU, faceCenterV), (new_tris[tri_index][2][0], new_tris[tri_index][2][1], new_tris[tri_index][2][2]), (new_tris[tri_index][0][0], new_tris[tri_index][0][1], new_tris[tri_index][0][2]))
            new_tris[tri_index] = ((currentvertices, faceCenterU, faceCenterV), (new_tris[tri_index][0][0], new_tris[tri_index][0][1], new_tris[tri_index][0][2]), (new_tris[tri_index][1][0], new_tris[tri_index][1][1], new_tris[tri_index][1][2]))
            new_tris = new_tris + [newtri1] + [newtri2]
            newfaceselection = newfaceselection + [newtri_index+1] + [newtri_index+2]
            newtri_index = newtri_index+2

        # This updates (adds) the new triangles to the component.
        new_comp.triangles = new_tris
        new_comp.currentskin = editor.Root.currentcomponent.currentskin
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        new_comp.currentframe = compframes[curframeNR]
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.Root.currentcomponent = new_comp
        editor.ok(undo, "face Subdivision 3")
        editor.ModelFaceSelList = editor.ModelFaceSelList + newfaceselection
        newfaceselection = []
        import mdlhandles
        from mdlhandles import SkinView1
        if SkinView1 is not None:
            q = editor.layout.skinform.linkedobjects[0]
            q["triangles"] = str(len(editor.Root.currentcomponent.triangles))
            editor.layout.skinform.setdata(q, editor.layout.skinform.form)
            SkinView1.invalidate()

    elif pieces == 4:
        # This updates (adds) the new vertices to each frame.
        commonvtxs = []
        commonvtxnbr = []
        for tri in editor.ModelFaceSelList:
            for vtx in comp.triangles[tri]:
                if not (curframe.vertices[vtx[0]] in commonvtxs):
                    commonvtxs = commonvtxs + [curframe.vertices[vtx[0]]]
                    commonvtxnbr = commonvtxnbr + [vtx[0]]
        for tri in editor.ModelFaceSelList:
            newsidecenter = []
            trivtxs = comp.triangles[tri]
            side01center = (curframe.vertices[trivtxs[0][0]] + curframe.vertices[trivtxs[1][0]])*.5
            newvtx3u = (trivtxs[0][1] + trivtxs[1][1])*.5
            newvtx3v = (trivtxs[0][2] + trivtxs[1][2])*.5
            for vtx in range(len(commonvtxs)):
                if str(side01center) == str(commonvtxs[vtx]):
                    newvtx_index3 = commonvtxnbr[vtx]
                    break
                if vtx == len(commonvtxs)-1:
                    currentvertices = currentvertices + 1
                    newvtx_index3 = currentvertices
                    commonvtxs = commonvtxs + [side01center]
                    commonvtxnbr = commonvtxnbr + [newvtx_index3]
                    newsidecenter = newsidecenter + [0]
            newvtx3 = (newvtx_index3,newvtx3u,newvtx3v)
            side12center = (curframe.vertices[trivtxs[1][0]] + curframe.vertices[trivtxs[2][0]])*.5
            newvtx4u = (trivtxs[1][1] + trivtxs[2][1])*.5
            newvtx4v = (trivtxs[1][2] + trivtxs[2][2])*.5
            for vtx in range(len(commonvtxs)):
                if str(side12center) == str(commonvtxs[vtx]):
                    newvtx_index4 = commonvtxnbr[vtx]
                    break
                if vtx == len(commonvtxs)-1:
                    currentvertices = currentvertices + 1
                    newvtx_index4 = currentvertices
                    commonvtxs = commonvtxs + [side12center]
                    commonvtxnbr = commonvtxnbr + [newvtx_index4]
                    newsidecenter = newsidecenter + [1]
            newvtx4 = (newvtx_index4,newvtx4u,newvtx4v)
            side20center = (curframe.vertices[trivtxs[2][0]] + curframe.vertices[trivtxs[0][0]])*.5
            newvtx5u = (trivtxs[2][1] + trivtxs[0][1])*.5
            newvtx5v = (trivtxs[2][2] + trivtxs[0][2])*.5
            for vtx in range(len(commonvtxs)):
                if str(side20center) == str(commonvtxs[vtx]):
                    newvtx_index5 = commonvtxnbr[vtx]
                    break
                if vtx == len(commonvtxs)-1:
                    currentvertices = currentvertices + 1
                    newvtx_index5 = currentvertices
                    commonvtxs = commonvtxs + [side20center]
                    commonvtxnbr = commonvtxnbr + [newvtx_index5]
                    newsidecenter = newsidecenter + [2]
            newvtx5 = (newvtx_index5,newvtx5u,newvtx5v)

            new_tris[tri] = (newvtx5, trivtxs[0], newvtx3)
            new_tri1 = (newvtx4, newvtx3, trivtxs[1])
            new_tri2 = (newvtx5, newvtx3, newvtx4)
            new_tri3 = (newvtx5, newvtx4, trivtxs[2])
            new_tris = new_tris + [new_tri1] + [new_tri2] + [new_tri3]
            newfaceselection = newfaceselection + [newtri_index+1] + [newtri_index+2] + [newtri_index+3]
            newtri_index = newtri_index+3

            for compframe in compframes:
                old_vtxs = compframe.vertices
                if 0 in newsidecenter:
                    side01center = (compframe.vertices[trivtxs[0][0]] + compframe.vertices[trivtxs[1][0]])*.5
                    old_vtxs = old_vtxs + [side01center]
                if 1 in newsidecenter:
                    side12center = (compframe.vertices[trivtxs[1][0]] + compframe.vertices[trivtxs[2][0]])*.5
                    old_vtxs = old_vtxs + [side12center]
                if 2 in newsidecenter:
                    side20center = (compframe.vertices[trivtxs[2][0]] + compframe.vertices[trivtxs[0][0]])*.5
                    old_vtxs = old_vtxs + [side20center]
                compframe.vertices = old_vtxs
                compframe.compparent = new_comp

        # This updates (adds) the new triangles to the component.
        new_comp.triangles = new_tris
        new_comp.currentskin = editor.Root.currentcomponent.currentskin
        compframes = new_comp.findallsubitems("", ':mf')   # get all frames
        new_comp.currentframe = compframes[curframeNR]
        undo = quarkx.action()
        undo.exchange(comp, new_comp)
        editor.Root.currentcomponent = new_comp
        editor.ok(undo, "face Subdivision 4")
        editor.ModelFaceSelList = editor.ModelFaceSelList + newfaceselection
        newfaceselection = []
        import mdlhandles
        from mdlhandles import SkinView1
        if SkinView1 is not None:
            q = editor.layout.skinform.linkedobjects[0]
            q["triangles"] = str(len(editor.Root.currentcomponent.triangles))
            editor.layout.skinform.setdata(q, editor.layout.skinform.form)
            SkinView1.invalidate()



# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.87  2008/10/15 00:01:30  cdunde
#Setup of bones individual handle scaling and Keyframe matrix rotation.
#Also removed unneeded code.
#
#Revision 1.86  2008/10/08 20:00:45  cdunde
#Updates for Model Editor Bones system.
#
#Revision 1.85  2008/10/04 05:48:06  cdunde
#Updates for Model Editor Bones system.
#
#Revision 1.84  2008/09/15 04:47:46  cdunde
#Model Editor bones code update.
#
#Revision 1.83  2008/08/08 05:02:11  cdunde
#Rearranged all functions into groups to organize and make locating easer.
#
#Revision 1.82  2008/08/08 04:55:06  cdunde
#To add new functions by DanielPharos and cdunde.
#
#Revision 1.81  2008/07/25 22:57:23  cdunde
#Updated component error checking and added frame matching and\or
#duplicating with independent names to avoid errors with other functions.
#
#Revision 1.80  2008/07/24 23:34:12  cdunde
#To fix non-ASCII character from causing python depreciation errors.
#
#Revision 1.79  2008/05/01 19:15:22  danielpharos
#Fix treeviewselchanged not updating.
#
#Revision 1.78  2008/05/01 13:52:31  danielpharos
#Removed a whole bunch of redundant imports and other small fixes.
#
#Revision 1.77  2008/02/23 04:41:11  cdunde
#Setup new Paint modes toolbar and complete painting functions to allow
#the painting of skin textures in any Model Editor textured and Skin-view.
#
#Revision 1.76  2008/02/13 08:55:24  cdunde
#To replace lost code of last change due to text editor.
#
#Revision 1.75  2008/02/13 08:49:29  cdunde
#Extended the TexturePixelLocation function for special Skin-view needs.
#
#Revision 1.74  2008/02/11 00:47:30  cdunde
#To fix text editor error.
#
#Revision 1.73  2008/02/11 00:39:51  cdunde
#Added new function to get the u, v texture position of any
#triangle where the cursor is pointing in any view.
#
#Revision 1.72  2008/02/07 13:19:48  danielpharos
#Fix findTriangle triggering on invalid triangles
#
#Revision 1.71  2007/12/08 07:40:01  cdunde
#Minor comment update.
#
#Revision 1.70  2007/12/08 07:20:56  cdunde
#To get the face extrusion functions to apply movement based on frame animation positions.
#
#Revision 1.69  2007/12/05 04:45:57  cdunde
#Added two new function methods to Subdivide selected faces into 3 and 4 new triangles each.
#
#Revision 1.68  2007/12/02 06:47:11  cdunde
#Setup linear center handle selected vertexes edge extrusion function.
#
#Revision 1.67  2007/11/24 01:46:01  cdunde
#To get all of the vertex and face Linear Handle movements
#to work properly for selected frames with animation differences.
#
#Revision 1.66  2007/11/22 07:31:04  cdunde
#Setup to allow merging of a base vertex and other multiple selected vertexes.
#
#Revision 1.65  2007/11/20 02:27:55  cdunde
#Added check to stop merging of two vertexes of the same triangle.
#
#Revision 1.64  2007/11/19 20:17:03  cdunde
#To try and stop vertex merging from crashing if last vertex is the base vertex.
#
#Revision 1.63  2007/11/19 07:45:55  cdunde
#Minor corrections for option number and activating menu item.
#
#Revision 1.62  2007/11/19 01:09:17  cdunde
#Added new function "Merge 2 Vertexes" to the "Vertex Commands" menu.
#
#Revision 1.61  2007/11/16 18:48:23  cdunde
#To update all needed files for fix by DanielPharos
#to allow frame relocation after editing.
#
#Revision 1.60  2007/11/15 22:08:24  danielpharos
#Fix the frame-won't-drag problem after a subdivide face action.
#
#Revision 1.59  2007/11/14 04:34:48  cdunde
#To stop duplicate handle redrawing after face subdivision.
#
#Revision 1.58  2007/11/14 00:11:13  cdunde
#Corrections for face subdivision to stop models from drawing broken apart,
#update Skin-view "triangles" amount displayed and proper full redraw
#of the Skin-view when a component is un-hidden.
#
#Revision 1.57  2007/11/13 19:36:09  cdunde
#To fix error if Skin-view has not been opened at least once and
#remove integer u,v conversion plus some file cleanup.
#
#Revision 1.56  2007/11/13 07:20:59  cdunde
#Update to the way Subdivision, face splitting, works to greatly increase speed.
#
#Revision 1.55  2007/11/12 00:53:23  cdunde
#To remove test print statements.
#
#Revision 1.54  2007/11/12 00:29:18  cdunde
#Fixed Linear Handle for selected faces and frames to draw
#face vertexes locations properly for animation movement.
#
#Revision 1.53  2007/11/11 11:41:50  cdunde
#Started a new toolbar for the Model Editor to support "Editing Tools".
#
#Revision 1.52  2007/11/04 00:33:33  cdunde
#To make all of the Linear Handle drag lines draw faster and some selection color changes.
#
#Revision 1.51  2007/10/25 17:25:47  cdunde
#To fix some small typo errors.
#
#Revision 1.50  2007/10/24 14:58:12  cdunde
#To activate all Movement toolbar button functions for the Model Editor.
#
#Revision 1.49  2007/10/22 02:22:08  cdunde
#To speed up conversion code.
#
#Revision 1.48  2007/10/21 04:52:27  cdunde
#Added a "Snap Shot" function and button to the Skin-view to allow the re-skinning
#of selected faces in the editor based on their position in the editor's 3D view.
#
#Revision 1.47  2007/10/08 16:19:42  cdunde
#Missed a change item.
#
#Revision 1.46  2007/10/06 20:14:31  cdunde
#Added function option to just update the editors 2D views.
#
#Revision 1.45  2007/09/15 19:19:15  cdunde
#To fix if sometimes the model component it lost.
#
#Revision 1.44  2007/09/13 01:04:59  cdunde
#Added a new function, to the Faces RMB menu, for a "Empty Component" to start fresh from.
#
#Revision 1.43  2007/09/12 05:25:51  cdunde
#To move Make New Component menu function from Commands menu to RMB Face Commands menu and
#setup new function to move selected faces from one component to another.
#
#Revision 1.42  2007/09/11 00:09:20  cdunde
#Small update.
#
#Revision 1.41  2007/09/10 01:33:19  cdunde
#To speed up "Make new component" function.
#
#Revision 1.40  2007/09/07 23:55:29  cdunde
#1) Created a new function on the Commands menu and RMB editor & tree-view menus to create a new
#     model component from selected Model Mesh faces and remove them from their current component.
#2) Fixed error of "Pass face selection to Skin-view" if a face selection is made in the editor
#     before the Skin-view is opened at least once in that session.
#3) Fixed redrawing of handles in areas that hints show once they are gone.
#
#Revision 1.39  2007/09/01 20:32:06  cdunde
#Setup Model Editor views vertex "Pick and Move" functions with two different movement methods.
#
#Revision 1.38  2007/09/01 19:36:40  cdunde
#Added editor views rectangle selection for model mesh faces when in that Linear handle mode.
#Changed selected face outline drawing method to greatly increase drawing speed.
#
#Revision 1.37  2007/08/24 00:33:08  cdunde
#Additional fixes for the editor vertex selections and the View Options settings.
#
#Revision 1.36  2007/08/20 19:58:23  cdunde
#Added Linear Handle to the Model Editor's Skin-view page
#and setup color selection and drag options for it and other fixes.
#
#Revision 1.35  2007/08/08 21:07:47  cdunde
#To setup red rectangle selection support in the Model Editor for the 3D views using MMB+RMB
#for vertex selection in those views.
#Also setup Linear Handle functions for multiple vertex selection movement using same.
#
#Revision 1.34  2007/08/02 08:33:44  cdunde
#To get the model axis to draw and other things to work corretly with Linear handle toolbar button.
#
#Revision 1.33  2007/08/01 07:36:35  cdunde
#Notation change only.
#
#Revision 1.32  2007/07/28 23:11:26  cdunde
#Needed to fix the MakeEditorFaceObject function to maintain the face vertexes in their proper order.
#Also expanded the function to create a list of QuArK Internal Objects (faces) directly from the
#ModelFaceSelList for use with the newly added ModelEditorLinHandlesManager class and its related classes
#to the mdlhandles.py file to use for editing movement of model faces, vertexes and bones (in the future).
#Also changed those Object face names to include their component name, tri_index and vertex_index(s) for
#extraction to convert the Object face back into usable vertexes and triangles in the models mesh using
#a new function added to this file called 'ConvertEditorFaceObject'.
#
#Revision 1.31  2007/07/16 12:20:24  cdunde
#Commented info update.
#
#Revision 1.30  2007/07/15 21:22:46  cdunde
#Added needed item updates when a new triangle is created.
#
#Revision 1.29  2007/07/15 01:20:49  cdunde
#To fix error for trying to pass selected vertex(es) that do not belong to a triangle
#(new ones or leftovers from any delete triangles) to the Skin-view.
#
#Revision 1.28  2007/07/14 22:42:43  cdunde
#Setup new options to synchronize the Model Editors view and Skin-view vertex selections.
#Can run either way with single pick selection or rectangle drag selection in all views.
#
#Revision 1.27  2007/07/11 20:48:23  cdunde
#Opps, forgot a couple of things with the last change.
#
#Revision 1.26  2007/07/11 20:00:55  cdunde
#Setup Red Rectangle Selector in the Model Editor Skin-view for multiple selections.
#
#Revision 1.25  2007/07/09 18:59:23  cdunde
#Setup RMB menu sub-menu "skin-view Options" and added its "Pass selection to Editor views"
#function. Also added Skin-view Options to editors main Options menu.
#
#Revision 1.24  2007/07/02 22:49:43  cdunde
#To change the old mdleditor "picked" list name to "ModelVertexSelList"
#and "skinviewpicked" to "SkinVertexSelList" to make them more specific.
#Also start of function to pass vertex selection from the Skin-view to the Editor.
#
#Revision 1.23  2007/06/11 19:52:31  cdunde
#To add message box for proper vertex order of selection to add a triangle to the models mesh.
#and changed code for deleting a triangle to stop access violation errors and 3D views graying out.
#
#Revision 1.22  2007/05/28 23:46:26  cdunde
#To remove unneeded view invalidations.
#
#Revision 1.21  2007/05/18 02:16:48  cdunde
#To remove duplicate definition of the qbaseeditor.py files def invalidateviews function called
#for in some functions and not others. Too confusing, unnecessary and causes missed functions.
#Also fixed error message when in the Skin-view after a new triangle is added.
#
#Revision 1.20  2007/04/27 17:27:42  cdunde
#To setup Skin-view RMB menu functions and possable future MdlQuickKeys.
#Added new functions for aligning, single and multi selections, Skin-view vertexes.
#To establish the Model Editors MdlQuickKeys for future use.
#
#Revision 1.19  2007/04/22 23:02:17  cdunde
#Fixed slight error in Duplicate current frame, was coping incorrect frame.
#
#Revision 1.18  2007/04/22 21:06:04  cdunde
#Model Editor, revamp of entire new vertex and triangle creation, picking and removal system
#as well as its code relocation to proper file and elimination of unnecessary code.
#
#Revision 1.17  2007/04/19 03:20:06  cdunde
#To move the selection retention code for the Skin-view vertex drags from the mldhandles.py file
#to the mdleditor.py file so it can be used for many other functions that cause the same problem.
#
#Revision 1.16  2007/04/17 16:01:25  cdunde
#To retain selection of original animation frame when duplicated.
#
#Revision 1.15  2007/04/17 12:55:34  cdunde
#Fixed Duplicate current frame function to stop Model Editor views from crashing
#and updated its popup help and Infobase link description data.
#
#Revision 1.14  2007/04/16 16:55:59  cdunde
#Added Vertex Commands to add, remove or pick a vertex to the open area RMB menu for creating triangles.
#Also added new function to clear the 'Pick List' of vertexes already selected and built in safety limit.
#Added Commands menu to the open area RMB menu for faster and easer selection.
#
#Revision 1.13  2007/04/10 06:00:36  cdunde
#Setup mesh movement using common drag handles
#in the Skin-view for skinning model textures.
#
#Revision 1.12  2007/03/29 15:25:34  danielpharos
#Cleaned up the tabs.
#
#Revision 1.11  2006/12/06 04:05:59  cdunde
#For explanation comment on how to use def findTriangles function.
#
#Revision 1.10  2005/10/15 00:47:57  cdunde
#To reinstate headers and history
#
#Revision 1.7  2001/03/15 21:07:49  aiv
#fixed bugs found by fpbrowser
#
#Revision 1.6  2001/02/01 22:03:15  aiv
#RemoveVertex Code now in Python
#
#Revision 1.5  2000/10/11 19:07:47  aiv
#Bones, and some kinda skin vertice viewer
#
#Revision 1.4  2000/08/21 21:33:04  aiv
#Misc. Changes / bugfixes
#
#Revision 1.2  2000/06/02 16:00:22  alexander
#added cvs headers
#
#