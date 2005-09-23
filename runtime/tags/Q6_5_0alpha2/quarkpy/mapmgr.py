"""   QuArK  -  Quake Army Knife

Map editor Layout managers.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$



#
# This file defines the base class for Map Layout Managers.
# This is an abstract class that must be overridden in plug-ins
# (see e.g. mapclassiclayout.py). The instance of the current
# Map Layout Manager is stored in the map editor's "layout"
# attribute.
#
# Map Layouts mainly have the following attributes:
#
#  * editor  is the map editor
#  * explorer  is the tree view screen control. To get the list of
#              currently selected objects, use "explorer.sellist".
#  * views  lists all currently opened map views
#  * baseviews  lists only the main map views
#
# Map views display parameters are stored in "view.info", which is
# a dictionnary. It must contain at least the key "type", which can
# map to either "3D" for perspective view, or "2D", "XY", "XZ", ...
# 2D views have attributes "scale", "angle", and so on. If you change
# one of these attributes, you must call setprojmode to update the
# display. See setprojmode for more details.
#
# Note about hints : All hints used by buttons, controls, etc, may
# have a special syntax. Here are the main three possibilities :
#   "some description"   -- the description appears both in the hint
#                           panel (lower left) and when the mouse
#                           stays on the control for a while
#   "text1|text2"        -- text1 appears when the mouse stays on
#                           the control for a while, and text2
#                           appears in the hint panel
#   "text1||text2"       -- text1 appears when the mouse stays on
#                           the control for a while, and the hint
#                           panel displays "Press F1 for help".
#                           If the user then presses F1, he obtains
#                           text2 in a pop-up "help snippet" window,
#                           suitable for long explanations.
#


import math
import quarkx
import qtoolbar
import qmenu
from maputils import *
import mapbtns
import maphandles
import maptools
from qdictionnary import Strings
from qbasemgr import BaseLayout
from qbasemgr import MPPage


SFTexts   = ["Easy", "Medium", "Hard", "Deathmatch", "Coop", "Single"]
SFLetters = "emhdcs"


class MapLayout(BaseLayout):
    "An abstract base class for Map Editor screen layouts."

    MODE = SS_MAP
    MAXAUTOZOOM = 1.0

    def clearrefs(self):
        BaseLayout.clearrefs(self)
        self.dataform = None
        self.polyform = None
        self.polyview = None
        self.faceform = None
        self.faceview = None
        self.faceflags = None


    def readtoolbars(self, config):
        readtoolbars(maptools.toolbars, self, self.editor.form, config)



    def bs_dataform(self, panel):
        ico_maped=ico_dict['ico_maped']
        fp = panel.newpanel()
        sfskills = (256,512,1024,2048)   # default
        for q in quarkx.getqctxlist():
            s = q["SFSkills"]
            if type(s)==type(()):
                sfskills = s
        mnu = []
        for i in range(0, len(sfskills)):
            item = qmenu.item(SFTexts[i], self.spawnflagsclick)
            item.skill = int(sfskills[i])
            mnu.append(item)
        sfbtn = qtoolbar.menubutton(mnu, "skill levels||This button lets you control in which difficulty settings the entity should appear in the game. This lets you make a map harder by for example hiding some health boxes in the upper skill levels. You can also hide some entities in deatchmatch games, for example some doors, or a wall (this is the purpose of the func_wall entity).", ico_maped, 10)
        sfbtn.caption = SFLetters[:len(sfskills)]
        addspec = qtoolbar.button(self.plusminusclick, "insert an empty Specific/Arg pair", ico_maped, 11)
        addspec.cmd = 0
        deletespec = qtoolbar.button(self.plusminusclick, "delete a Specific/Arg pair", ico_maped, 12)
        deletespec.cmd = 1
        helpbtn = qtoolbar.button(self.helpbtnclick, "", ico_maped, 13)
        helpbtn.local = 1
        self.buttons.update({"help": helpbtn, "sf": sfbtn})
        bb = fp.newtoppanel(ico_maped_y,0).newbtnpanel([sfbtn, qtoolbar.widegap, addspec, deletespec, qtoolbar.widegap, helpbtn])
        bb.margins = (0,0)
        df = fp.newdataform()
        df.allowedit = 1
        df.addremaining = 1
        df.actionchanging = 512   # indexes in qdictionnary.Strings
        df.actiondeleting = 553
        df.actionrenaming = 566
        df.editnames = "classname"
        df.flags = DF_AUTOFOCUS
        df.bluehint = 1
        self.dataform = df
        return fp

    def texflags(self, txt):
        if self.editor.texflags:
            return [qtoolbar.button(self.flagsclick, "flags for this "+txt, ico_dict['ico_maped'], 22)]
        else:
            return []    # Quake1, Hexen II

    def bs_polyform(self, panel):
        ico_maped=ico_dict['ico_maped']
        fp = panel.newpanel()
        TexBtn = qtoolbar.button(mapbtns.texturebrowser, "choose texture", ico_maped, 0)
        NegBtn = qtoolbar.button(self.neg1click, "negative poly||When a polyhedron is marked as negative, it behaves like a hole : every polyhedron in the same group as this one is 'digged' by the overlapping part.\n\nUsing 'Brush subtraction' in the 'Commands' menu is the same as marking the polyhedron negative, except that digging is not performed immediately. This helps keep the map clear.\n\nNegative polyhedrons appear in pink on the map.", ico_maped, 23)
        self.buttons["negpoly"] = NegBtn
        tp = fp.newtoppanel(124)
        tp.newbottompanel(ico_maped_y,0).newbtnpanel([TexBtn, qtoolbar.widegap, NegBtn, qtoolbar.padright] + self.texflags("polyhedron"))
        self.polyform = tp.newdataform()
        self.polyform.header = 0
        self.polyform.sep = -79
        self.polyform.setdata([], quarkx.getqctxlist(':form', "Polyhedron")[-1])
        self.polyform.onchange = self.polyformchange
        self.polyview = fp.newmapview()
        self.polyview.color = NOCOLOR
        self.polyview.ondraw = self.polyviewdraw
        self.polyview.onmouse = self.polyviewmouse
        self.polyview.hint = "|click to select texture"
        return fp

    def bs_faceform(self, panel):
        ico_maped=ico_dict['ico_maped']
        fp = panel.newpanel()
        TexBtn = qtoolbar.button(mapbtns.texturebrowser, "choose texture", ico_maped, 1)
        ts1Btn = qtoolbar.button(self.resettexscale, "reset 1:1 texture scale|resets 'scales' and 'angles'", ico_maped, 17)
        ts1Btn.adjust = 0
        ts2Btn = qtoolbar.button(self.resettexscale, "adjust texture to fit the face", ico_maped, 18)
        ts2Btn.adjust = 1
        ts3Btn = qtoolbar.button(self.resettexscale, "adjust texture on face but keep scaling to a minimum|adjust texture with minimum scaling", ico_maped, 24)
        ts3Btn.adjust = 2
        prevface = qtoolbar.button(self.nextface, "previous face of poly.", ico_dict['ico_mapedsm'], 0)
        prevface.delta = -1
        nextface = qtoolbar.button(self.nextface, "next face of poly.", ico_dict['ico_mapedsm'], 1)
        nextface.delta = 1
        #facezoombtn = qtoolbar.doublebutton(self.zoomface1click, getzoommenu, "choose zoom factor / zoom to 1:1 and back", ico_maped, 14)
        #facezoombtn.caption = "zoom"
        facezoombtn = qtoolbar.menubutton(getzoommenu, "choose zoom factor", ico_maped, 14)
        facezoombtn.near = 1
        self.buttons.update({"facezoom": facezoombtn, "prevf": prevface, "nextf": nextface})
        tp = fp.newtoppanel(142)
        btnp = tp.newbottompanel(ico_maped_y,0).newbtnpanel([prevface, nextface, facezoombtn, qtoolbar.smallgap, TexBtn, ts1Btn, ts2Btn, ts3Btn] + self.texflags("face"))
        btnp.margins = (0,0)
        self.faceform = tp.newdataform()
        self.faceform.header = 0
        self.faceform.sep = -79
        self.faceform.setdata([], quarkx.getqctxlist(':form', "Face")[-1])
        self.faceform.onchange = self.faceformchange
        self.faceview = fp.newmapview()
        facezoombtn.views = [self.faceview]
        return fp

    def bs_bezierform(self, panel):
        ico_maped=ico_dict['ico_maped']
        fp = panel.newpanel()
        bezierzoombtn = qtoolbar.menubutton(getzoommenu, "choose zoom factor", ico_maped, 14)
        bezierzoombtn.near = 1
        TexBtn = qtoolbar.button(mapbtns.texturebrowser, "choose texture", ico_maped, 1)
        self.buttons["bezierzoom"] = bezierzoombtn
        tp = fp.newtoppanel(70)
        btnp = tp.newbottompanel(23,0).newbtnpanel([bezierzoombtn, qtoolbar.smallgap, TexBtn, qtoolbar.smallgap] + self.texflags("bezier patch"))
#        btnp = tp.newbottompanel(23,0).newbtnpanel([bezierzoombtn, TexBtn] + self.texflags("bezier patch"))
        btnp.margins = (0,0)
        self.bezierform = tp.newdataform()
        self.bezierform.header = 0
        self.bezierform.sep = -79
        self.bezierform.setdata([], quarkx.getqctxlist(':form', "Bezier")[-1])
        self.bezierform.onchange = self.bezierformchange
        self.bezierview = fp.newmapview()
        # bezierzoombtn.views = [self.bezierview]
        self.bezierview.color = NOCOLOR
        bezierzoombtn.views = [self.bezierview]
        return fp

    def bs_additionalpages(self, panel):
        "Builds additional pages for the multi-pages panel."
        thesepages = []
        page1 = qtoolbar.button(self.filldataform, "Specifics/Args-view||Specifics/Args-view:\n\nThis view displays the general parameters for the selected object(s).\n\nSee the infobase for a more detailed description and use of this view display.", ico_objects, iiEntity, "Specifics/Args-view", infobaselink='intro.mapeditor.dataforms.html#specsargsview')
        page1.pc = [self.bs_dataform(panel)]
        thesepages.append(page1)
        page2 = qtoolbar.button(self.fillpolyform, "Polyhedron-view||Polyhedron-view:\n\nThis display shows the parameters about the selected polyhedron(s).\n\nSee the infobase for a more detailed description and use of this view display.", ico_objects, iiPolyhedron, "Polyhedron-view", infobaselink='intro.mapeditor.dataforms.html#polyhedronview')
        page2.pc = [self.bs_polyform(panel)]
        thesepages.append(page2)
        page3 = qtoolbar.button(self.fillfaceform, "Face-view||Face-view:\n\nThis display shows the parameters about the selected face(s).\n\nSee the infobase for a more detailed description and use of this view display.", ico_objects, iiFace, "Face-view", infobaselink='intro.mapeditor.dataforms.html#faceview')
        page3.pc = [self.bs_faceform(panel)]
        page3.needangle = 1
        thesepages.append(page3)
        # only show the bezier-page, if the game supports bezierpatches
        beziersupport = quarkx.setupsubset()["BezierPatchSupport"]
        if (beziersupport is not None) and (beziersupport == "1"):
            page4 = qtoolbar.button(self.fillbezierform, Strings[-459], ico_objects, iiBezier)#, Strings[-409])
            page4.pc = [self.bs_bezierform(panel)]
            thesepages.append(page4)
        return thesepages, mppages

    def bs_userobjects(self, panel):
        "A panel with user-defined map objects."
        MapUserDataPanel(panel,
          "Drop your most commonly used prefabs and entities to this panel||This panel is a good place to put 'prefabs', that is, nice entities, polyhedrons, or whole groups.\n\nYou add prefabs to the panel by dragging them from the tree view; they become buttons on which you can click to re-insert them in your maps.\n\nApart from the first line of buttons, you can reorder them by dragging them around with the mouse, and remove them by dragging them to the 'trash' button below.|intro.mapeditor.userdata.html",
          "MapObjPanel.qrk", "UserData %s.qrk" % self.editor.gamecfg)


    def actionmpp(self):
        "Automatically switch the multi-pages-panel for the current selection."
        if (self.mpp.n<4) and not (self.mpp.lock.state & qtoolbar.selected):
            fs = self.explorer.focussel
            if fs is None:
                self.mpp.viewpage(0)
            elif fs.type == ':e':
                self.mpp.viewpage(1)
            elif fs.type == ':p':
                self.mpp.viewpage(2)
            elif fs.type == ':f':
                self.mpp.viewpage(3)

    def filldataform(self, reserved):
        import mapentities
        sl = self.explorer.sellist
        formobj = mapentities.LoadEntityForm(sl)
        self.dataform.setdata(sl, formobj)
        help = ((formobj is not None) and formobj["Help"]) or ""
        if help:
            help = "?" + help   # this trick displays a blue hint
        self.buttons["help"].hint = help + "||This button gives you the description of the selected entity, and how to use it.\n\nYou are given help in two manners : by simply moving the mouse over the button, a 'hint' text appears with the description; if you click the button, you are sent to an HTML document about the entity, if available, or you are shown the same text as previously, if nothing more is available.\n\nNote that there is currently not a lot of info available as HTML documents."
        sfbtn = self.buttons["sf"]
        if sl:
            icon = mapentities.EntityIconSel(sl[0])
            for s in sl[1:]:
                icon2 = mapentities.EntityIconSel(s)
                if not (icon is icon2):
                    icon = ico_objects[1][iiEntity]
                    break
            sfbtn.state = 0
            cap = ""
            for i in range(0, len(sfbtn.menu)):
                m = sfbtn.menu[i]
                if self.dataform.bitspec("spawnflags", m.skill):
                    m.state = 0
                else:
                    m.state = qmenu.checked
                    cap = cap + SFLetters[i]
            if not cap:
                cap = "----"
        else:
            sfbtn.state = qtoolbar.disabled
            cap = SFLetters[:len(sfbtn.menu)]
            icon = ico_objects[1][iiEntity]
        sfbtn.caption = cap
        btnlist = self.mpp.btnpanel.buttons
        if not (btnlist[1].icons[3] is icon):
            l = list(btnlist[1].icons)
            l[3] = icon
            l[4] = icon
            btnlist[1].icons = tuple(l)
            self.mpp.btnpanel.buttons = btnlist
        quarkx.update(self.editor.form)

    def getpolylists(self):
        slist = self.explorer.sellist
        for s in slist[:]:
            if s.type == ':f':
                slist.remove(s)
                slist = slist + s.faceof
        plist = []
        for s in slist:
            for p in s.findallsubitems("", ':p'):   # find all polyhedrons
                if not (p in plist):
                    plist.append(p)
        return plist

    def fillpolyform(self, reserved):
        self.polyview.invalidate(1)
        plist = self.getpolylists()

        NegBtn = self.buttons["negpoly"]
        if len(plist)==0:
            ns = qtoolbar.disabled
        else:
            for p in plist:
                if p["neg"]:
                    ns = qtoolbar.selected
                    break
            else:
                ns = 0
        NegBtn.state = ns
        quarkx.update(self.editor.form)

        q = quarkx.newobj(':')   # internal object
        if len(plist)==0:
            cap = Strings[145]
        elif len(plist)==1:
            cap = plist[0].error
            if cap:
                cap = cap.capitalize()
            else:
                cap = Strings[142]
        else:
            cap = Strings[143] % len(plist)
        q["header"] = cap
        cntf, cnti = 0, 0
        for p in plist:
            cnti = cnti + p.rebuildall()[1]
            cntf = cntf + len(p.faces)
        if cnti:
            cap = Strings[141] % (cntf, cnti)
        else:
            cap = Strings[140] % cntf
        q["faces"] = cap
        if len(plist)==1:
            cap = plist[0].origin
            if cap is not None:
                q["center"] = cap.tuple
        texlist = quarkx.texturesof(plist)
        texhint = "TEX?"
        for tex in texlist:
            texhint = texhint + tex + ";"
        if len(texlist)<=1:
            if len(texlist):
                cap = texlist[0]
            else:
                cap = ""
            texlist = quarkx.texturesof([self.editor.Root])  # all textures in the map
        else:
            cap = Strings[179] % len(texlist)
        q["texture"] = cap
        q["oldtex"] = cap
        q["texture$Items"] = quarkx.list2lines(texlist)
        q["texture$Hint"] = texhint
        if len(plist):
            test = plist[0].parent
            cap = test.shortname
            for p in plist:
                test2 = p.parent
                if not (test2 is test):
                    cap = Strings[144]
                    break
            q["ownedby"] = cap
        self.polyform.setdata(q, self.polyform.form)

    def polyformchange(self, src):
        plist = self.getpolylists()
        undo = quarkx.action()

        q = src.linkedobjects[0]
        ncenter = q["center"]
        if ncenter is not None:
            ncenter = quarkx.vect(ncenter)   # tuple->vect
            for p in plist:
                org = p.origin
                if (org is not None) and (ncenter-org):
                    new = p.copy()
                    new.translate(ncenter-org)
                    plist[plist.index(p)] = new
                    undo.exchange(p, new)
        ntex = q["texture"]
        applycount = 0
        if (ntex is not None) and (ntex!="") and (ntex!=q["oldtex"]):
            for p in plist:
                # this implicitely uses the 'undo' variable
                applycount = applycount + p.replacetex("", ntex, 1)
        if applycount:
            if applycount>1:
                txt = Strings[547] % applycount
            else:
                txt = Strings[546]
        else:
            txt = Strings[515]
        self.editor.ok(undo, txt)


    def polyviewdraw(self, view):
        texlist = quarkx.texturesof(self.explorer.sellist)
        if len(texlist)==1:
            tex = quarkx.loadtexture(texlist[0], self.editor.TexSource)
            if not (tex is None):
                view.canvas().painttexture(tex, (0,0)+view.clientarea, -1)
                return
        w,h = view.clientarea
        cv = view.canvas()
        cv.penstyle = PS_CLEAR
        cv.brushcolor = GRAY
        cv.rectangle(0,0,w,h)

    def polyviewmouse(self, view, x, y, flags, handle):
        if flags&MB_CLICKED:
            quarkx.clickform = view.owner
            mapbtns.texturebrowser()


    def getfacelists(self):
        "Find all selected faces."
        flist = []
        for s in self.explorer.sellist:
            for f in s.findallsubitems("", ':f'):   # find all faces
                if not (f in flist):
                    flist.append(f)
        return flist

    def getbezierlists(self):
        "Find all selected B�zier patches."
        blist = []
        b2list = []
        for s in self.explorer.sellist:
            for b in s.findallsubitems("",':b2'):
                if not (b in b2list):
                    b2list.append(b)
        return blist+b2list


    def zoomface1click(self, facezoombtn):
        flist = self.getfacelists()
        if len(flist)!=1: return
        if not maphandles.singlefaceautozoom(self.faceview, flist[0]):
            self.faceview.info["scale"] = 1.0
            maphandles.singlefacezoom(self.faceview)

    def resettexscale(self, btn):
        mapbtns.resettexscale(self.editor, self.getfacelists(), btn.adjust)

    def nextface(self, btn):
        "Implements the previous and next face buttons."
        flist = self.getfacelists()
        if len(flist)!=1:
            return
        face = flist[0]
        i = face.parent.subitems.index(face)   # face.parent in this case is the polyhedron containing this case
        self.explorer.uniquesel = face.parent.subitem(i + btn.delta)


    def fillfaceform(self, reserved):
        flist = self.getfacelists()
        q = quarkx.newobj(':')   # internal object
        self.faceview.handles = []
        self.faceview.ondraw = None
        self.faceview.onmouse = self.polyviewmouse
        self.faceview.color = NOCOLOR
        self.faceview.invalidate(1)
        facezoombtn = self.buttons["facezoom"]
        facezoombtn.state = qtoolbar.disabled
        if len(flist)==0:
            cap = Strings[129]
        elif len(flist)==1:
            if maphandles.viewsingleface(self.editor, self.faceview, flist[0]):
                facezoombtn.state = 0
            cap = Strings[134]
        else:
            cap = Strings[135] % len(flist)
        q["header"] = cap
        if self.faceview.ondraw is None:
            self.faceview.ondraw = self.polyviewdraw
            self.faceview.hint = "|click to select texture"
        else:
            self.faceview.hint = ""
        prevnext = 3
        if len(flist)==1:
            faceof = flist[0].faceof
            if not faceof:       # empty -> broken face
                cap = ""
            elif faceof[0] is flist[0]:  # face of itself ==> not used by anything else
                cap = Strings[133]
            elif flist[0].parent.type == ':p':   # face of a polyhedron ==> not shared
                cap = Strings[130]
                items = flist[0].parent.subitems
                i = items.index(flist[0])
                if i: prevnext = 2
                if i<len(items)-1: prevnext = prevnext - 2
            else:
                cap = Strings[131] % len(faceof)
            q["sharedby"] = cap
        self.buttons["prevf"].state = (prevnext&1) and qtoolbar.disabled
        self.buttons["nextf"].state = (prevnext&2) and qtoolbar.disabled
        texlist = quarkx.texturesof(flist)
        texhint = "TEX?"
        for tex in texlist:
            texhint = texhint + tex + ";"
        if len(texlist)<=1:
            if len(texlist):
                cap = texlist[0]
            else:
                cap = ""
            texlist = quarkx.texturesof([self.editor.Root])  # all textures in the map
        else:
            cap = Strings[179] % len(texlist)
        q["texture"] = cap
        q["oldtex"] = cap
        q["texture$Items"] = quarkx.list2lines(texlist)
        q["texture$Hint"] = texhint
        multiple = "?"
        org = sc = sa = None
        for f in flist:
            tp = f.threepoints(1)
            if tp is not None:
                if org is None:
                    org = tp[0]
                elif (org is not multiple) and (org-tp[0]):
                    org = multiple
                tp1, tp2 = tp[1]-tp[0], tp[2]-tp[0]
                nsc = (abs(tp1)/128, abs(tp2)/128)
                if sc is None:
                    sc = nsc
                elif (sc is not multiple) and (abs(sc[0]-nsc[0])+abs(sc[1]-nsc[1]) > epsilon):
                    sc = multiple
                n = f.normal
                if not n: continue
                v1 = orthogonalvect(n, self.views[0])
                v2 = n^v1
                nsa = (math.atan2(v2*tp1, v1*tp1), math.atan2(v2*tp2, v1*tp2))
                if sa is None:
                    sa = nsa
                elif (sa is not multiple) and ((abs(sa[0]-nsa[0]) > epsilon) or (abs(sa[1]-nsa[1]) > epsilon)):
                    sa = multiple

        if (org is not None) and (org is not multiple):
            q["origin"] = org.tuple
        if (sc is not None) and (sc is not multiple):
            q["scales"] = sc
        if (sa is not None) and (sa is not multiple):
            q["angles"] = (sa[0] * rad2deg, sa[1] * rad2deg)

        self.faceform.setdata(q, self.faceform.form)
        quarkx.update(self.editor.form)


    def faceformchange(self, src):
        flist = self.getfacelists()
        undo = quarkx.action()

        q = src.linkedobjects[0]
        norg = q["origin"]
        nsc = q["scales"]
        nsa = q["angles"]
        if norg is not None:
            norg = quarkx.vect(norg)   # tuple->vect
        if nsc is not None:
            if abs(nsc[0])<epsilon or abs(nsc[1])<epsilon:
                quarkx.msgbox("Texture scale cannot be zero.", MT_ERROR, MB_OK)
                return
        if nsa is not None:
            ang1, ang2 = nsa
            diff = (ang1-ang2)%180
            if diff<5 or diff>175:
                quarkx.msgbox("The two texture angles must be more different.", MT_ERROR, MB_OK)
                return
            ang1 = ang1 * deg2rad
            ang2 = ang2 * deg2rad
        for f in flist:
            tp = f.threepoints(1)
            if tp is not None:
                ntp = tp
                tp1, tp2 = tp[1]-tp[0], tp[2]-tp[0]
                if norg is not None:
                    delta = norg-tp[0]
                    if delta:
                        ntp = tuple(map(lambda v, delta=delta: v+delta, ntp))
                if nsa is not None:
                    n = f.normal
                    v1 = orthogonalvect(n, self.views[0])
                    v2 = n^v1
                    sa1, sa2 = math.atan2(v2*tp1, v1*tp1), math.atan2(v2*tp2, v1*tp2)
                    newangles = (abs(sa1-ang1)>epsilon) or (abs(sa2-ang2)>epsilon)
                else:
                    newangles = 0
                if newangles or (nsc is not None):
                    sc = (abs(tp1)/128, abs(tp2)/128)
                    if newangles:
                        if nsc is not None:
                            sc = nsc
                        ntp = (ntp[0],
                               ntp[0] + (v1*math.cos(ang1) + v2*math.sin(ang1)) * sc[0] * 128,
                               ntp[0] + (v1*math.cos(ang2) + v2*math.sin(ang2)) * sc[0] * 128)
                    elif abs(sc[0]-nsc[0])+abs(sc[1]-nsc[1]) > epsilon:
                        ntp = (ntp[0],
                               ntp[0] + (ntp[1]-ntp[0])*(nsc[0]/sc[0]),
                               ntp[0] + (ntp[2]-ntp[0])*(nsc[1]/sc[1]))
                if ntp is not tp:
                    new = f.copy()
                    new.setthreepoints(ntp, 3)
                    flist[flist.index(f)] = new
                    undo.exchange(f, new)
        ntex = q["texture"]
        applycount = 0
        if (ntex is not None) and (ntex!="") and (ntex!=q["oldtex"]):
            for f in flist:
                # this implicitely uses the 'undo' variable
                applycount = applycount + f.replacetex("", ntex, 1)
        if applycount:
            if applycount>1:
                txt = Strings[547] % applycount
            else:
                txt = Strings[546]
        else:
            txt = Strings[597]
        self.editor.ok(undo, txt)


    def fillbezierform(self, reserved):
        self.bezierview.handles = []
        self.bezierview.ondraw = None
        self.bezierview.onmouse = self.polyviewmouse
        self.bezierview.invalidate(1)
        self.bezierview.info = None
        bezierzoombtn = self.buttons["bezierzoom"]
        bezierzoombtn.state = qtoolbar.disabled
        blist = self.getbezierlists()
        # quarkx.update(self.editor.form)  -- done below

        q = quarkx.newobj(':')   # internal object
        if len(blist)==0:
            cap = Strings[128]
        elif len(blist)==1:
            if maphandles.viewsinglebezier(self.bezierview, self, blist[0]):
                bezierzoombtn.state = 0
            cap = Strings[126]
        else:
            cap = Strings[127] % len(blist)
        if self.bezierview.ondraw is None:
            self.bezierview.ondraw = self.polyviewdraw
            self.bezierview.hint = "|click to select texture"
        else:
            self.bezierview.hint = ""
        q["header"] = cap
        texlist = quarkx.texturesof(blist)
        texhint = "TEX?"
        for tex in texlist:
            texhint = texhint + tex + ";"
        if len(texlist)<=1:
            if len(texlist):
                cap = texlist[0]
            else:
                cap = ""
            texlist = quarkx.texturesof([self.editor.Root])  # all textures in the map
        else:
            cap = Strings[179] % len(texlist)
        q["texture"] = cap
        q["oldtex"] = cap
        q["texture$Items"] = quarkx.list2lines(texlist)
        q["texture$Hint"] = texhint

        self.bezierform.setdata(q, self.bezierform.form)
        quarkx.update(self.editor.form)


    def bezierformchange(self, src):
        blist = self.getbezierlists()
        undo = quarkx.action()

        q = src.linkedobjects[0]
        ntex = q["texture"]
        if ntex is None: ntex = ""
        applycount = 0
        if ntex!=q["oldtex"]:
            for b in blist:
                # this implicitely uses the 'undo' variable
                applycount = applycount + b.replacetex(None, ntex, 1)
        if applycount:
            if applycount>1:
                txt = Strings[547] % applycount
            else:
                txt = Strings[546]
        else:
            txt = Strings[628]
        self.editor.ok(undo, txt)


    def spawnflagsclick(self, m):
        self.dataform.togglebitspec("spawnflags", m.skill)

    def plusminusclick(self, m):
        self.dataform.useraction(m.cmd)

    def helpbtnclick(self, m):
        import mapentities
        sl = self.explorer.sellist
        formobj = mapentities.LoadEntityForm(sl)
        if formobj is not None:
            if formobj["HTML"]:
                formobj = formobj["HTML"]
            elif formobj["Help"] and hasattr(m, "local"):
                quarkx.helppopup(formobj["Help"])
                return
            else:
                formobj = None
        htmldoc(formobj)

    def neg1click(self, m):
        plist = self.getpolylists()
        if m.state & qtoolbar.selected:
            ns = None
        else:
            ns = "1"
        undo = quarkx.action()
        for p in plist:
            if p["neg"] != ns:
                new = p.copy()
                new["neg"] = ns
                undo.exchange(p, new)
        self.editor.ok(undo, Strings[621])

    def flagsclick(self, m):
        ff = self.faceflags
        form = None
        if ff is None:
            if mapeditor() is not self.editor: return
            flist = quarkx.getqctxlist(":form", "TextureFlags")
            if not len(flist):
                raise "TextureFlags form not found"
            form = flist[-1]
            ff = quarkx.clickform.newfloating(0, "Face Flags")
            x1,y1,x2,y2 = quarkx.screenrect()
            ff.windowrect = (x2-200, y1+100, x2-20, y2-20) #Decker 2002-04-07: Make the window bigger, as there are so many faceflags for Q2/SOF/SIN/KP!
            ff.onclose = self.faceflagsclose
            ff.begincolor = GREEN
            ff.endcolor = OLIVE
            df = ff.mainpanel.newdataform()
            df.actionchanging = 596
            df.header = 0
            df.sep = 0.39
            df.flags = DF_AUTOFOCUS | DF_LOCAL
            self.faceflags = ff
        self.loadfaceflags(form)
        ff.show()

    def faceflagsclose(self, sender):
        self.faceflags = None

    def loadtfflist(self, form=None):
        flist = self.getfacelists()
        txdict = {}
        texsrc = self.editor.TexSource
        #
        # Make a dict of texobjs indexed by texnames
        #
        for tex in quarkx.texturesof(flist):
            texobj = quarkx.loadtexture(tex, texsrc)
            if texobj is not None:
                try:
                    texobj = texobj.disktexture
                except quarkx.error:
                    continue
            txdict[tex] = texobj
        #
        # Handle the default values, is this really worth it, tiglari wonders
        #
        # FIXME(?): maybe this should be restricted to games
        #   where defaults for the specifics are useful, or to
        #   specifics whose name begins with _esp_.
        #
        #  Maybe there's a way to do all this in the Delphi
        #
        #  a specific is represented as a subitem of the form whose
        #    shortname is the name of the specific as normally understood,
        #    with the other stuff as specifics thereof.
        #
        # For each specific in the form, if it has a "Default", and if
        #   the faces have different values for that specific, and then
        #   for each texobj that lacks a value for the specific, replace
        #   it with a copy that has the default (whew).  All this to
        #   get the little question marks for disagreeing specifics in
        #   the texture-flags window.
        #
        if form is not None and len(flist)>1: # no clashes if only one face
            copied=0
            def getspecval(spec, f, texobj):
                val = f[spec]
                if val is None:
                    val = texobj[spec]
                return val

            for specific in form.subitems:
                if specific["Default"] is not None:
                    sname = specific.shortname
                    value = getspecval(sname, flist[0], txdict[flist[0].texturename])
                    for i in range(1, len(flist)):
                        f = flist[i]
                        value2 = getspecval(sname, f, txdict[f.texturename])
                        if value!=value2:
                            for texobj in txdict.values():
                                if not copied:
                                    texobj=texobj.copy()  # copy them all, God will recognize his own
                                    txdict[f.texturename] = texobj
                                    copied=1
                                if texobj[sname] is None:
                                    texobj[sname]=specific["Default"]
        #
        # Build the pairs list
        #
        for i in range(0, len(flist)):
            f = flist[i]
            try:
                texobj = txdict[f.texturename]
            except KeyError:
                continue
            flist[i] = (f, texobj)
        return flist


    def loadfaceflags(self, form=None):
        ff = self.faceflags
        df = ff.mainpanel.controls()[0]
        if form is None:
            form = df.form
        df.setdata(self.loadtfflist(form), form)


    def selchange(self):
        if self.faceflags is not None:
            self.loadfaceflags()
        self.mpp.resetpage()


    def NewItem1Click(self, m):
        quarkx.opentoolbox("New map items...")

    def cameramoved(self, view):
        self.update3Dviews()
        self.editor.oldcamerapos = view.cameraposition



#
# List of all screen layouts
# (the first one is the default one in case no other one is configured)
# This list must be filled by plug-ins !
#
LayoutsList = []


#
# List of additionnal pages of the Multi-Pages-Panel
# This list can be filled by plug-ins. (see mappage3d.py)
#
mppages = []

