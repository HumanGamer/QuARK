"""   QuArK  -  Quake Army Knife

Model editor pop-up menus.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header: /cvsroot/quark/runtime/quarkpy/mdlmenus.py,v 1.26 2008/01/26 23:28:55 cdunde Exp $



import quarkx
from qdictionnary import Strings
import qmenu
from mdlutils import *
import mdlcommands

### Setup for future use. See mapmenus.py for examples
MdlEditMenuCmds = []
MdlEditMenuShortcuts = {}


#
# Model Editor MdlQuickKey shortcuts
# The area below is for future def's for those MdlQuickKeys, see mapmenus.py for examples.



# Note: the function *names* are used to look up the key from Defaults.qrk
# See mapmenus.py file for examples of these key names def's.
# To start using function def are made in the above section.
# Each def becomes a keyname which is inserted in the MdlQuickKeys list below and
# in the Defaults.qrk file in the Keys:config section of Model:config.
MdlQuickKeys = []


def runimporter(m):
    from qmacro import mdlimport
    try:
        mdlf = mdlimport[m.text]
    except:
        return
    editor = mapeditor()
    files = quarkx.filedialogbox("Select File", m.text, mdlf[0], 0)
    ### Line below just runs the importer, take out after model is actually being imported below.
    mdlf[1](None, files[0], None)
    ### Line below will load the model.
  #  editor.Root = mdlf[1](None, files[0], None)
  #  print "mdlmenus line 52 Root",editor.Root
  #  model = mdlf[1](None, files[0], None)
  #  editor.Root.appenditem(model)
  #  for view in editor.layout.views:
  #      view.drawmap(model)

def runexporter(m):
    from qmacro import mdlexport
    try:
        mdlf = mdlexport[m.text]
    except:
        return
    editor = mapeditor()
    # See plugins\mapbotwaypointer.py file for example of line below for use.
    files = quarkx.filedialogbox("Save file as...", m.text, mdlf[0], 1)
    ### Line below just runs the exporter, take out after model is actually being exported below.
    mdlf[1](None, files[0], None)
    ### Line below will export the model. (none yet)

#
# Menu bar builder
#
def BuildMenuBar(editor):
    import mdlmgr
    import mdlcommands
    import mdltoolbars
    import mdloptions

    def modelimporters():
        from qmacro import mdlimport
        mdlimportmenu = []
        for menuitem in mdlimport:
            mdlimportmenu = mdlimportmenu + [qmenu.item(menuitem, runimporter, "load an "+str(menuitem))] 
        if mdlimportmenu == []:
            mdlimportmenu = mdlimportmenu + [qmenu.item("none available", None, "no importers available")] 
        return mdlimportmenu

    def modelexporters():
        from qmacro import mdlexport
        mdlexportmenu = []
        for menuitem in mdlexport:
            mdlexportmenu = mdlexportmenu + [qmenu.item(menuitem, runexporter, "load an "+str(menuitem))] 
        if mdlexportmenu == []:
            mdlexportmenu = mdlexportmenu + [qmenu.item("none available", None, "no exporters available")] 
        return mdlexportmenu
        
    File1, sc1 = qmenu.DefaultFileMenu()
    MdlImport = qmenu.popup("Model &Importers", modelimporters(), runimporter, "|Model Importers:\n\nList of all available Python plugins model importers to load a model.", "intro.modeleditor.menu.html#filemenu")
    MdlExport = qmenu.popup("&Model Exporters", modelexporters(), runexporter, "|Model Exporters:\n\nList of all available Python plugins model exporters to save a model.", "intro.modeleditor.menu.html#filemenu")
    NewFile1items = []
    for item in range(len(File1.items)):
        if File1.items[item] is None:
            NewFile1items = NewFile1items + [qmenu.sep]
        else:
            if File1.items[item].text == "&Open...":
                NewFile1items = NewFile1items + [File1.items[item]] + [qmenu.sep ,MdlImport, MdlExport, qmenu.sep]
            else:
                NewFile1items = NewFile1items + [File1.items[item]]
    File1.items = NewFile1items

    if editor.layout is None:
        l1 = []
        lcls = None
        lclick = None
    else:
        l1, sc2 = editor.layout.getlayoutmenu()
        sc1.update(sc2)   # merge shortcuts
        if len(l1):
            l1.append(qmenu.sep)
        lcls = editor.layout.__class__
        lclick = editor.layout.layoutmenuclick
    for l in mdlmgr.LayoutsList:
        m = qmenu.item('%s layout' % l.shortname, editor.setlayoutclick)
        m.state = (l is lcls) and qmenu.radiocheck
        m.layout = l
        l1.append(m)
    Layout1 = qmenu.popup("&Layout", l1, lclick)

    Edit1, sc2 = qmenu.DefaultEditMenu(editor)
    sc1.update(sc2)   # merge shortcuts
    l1 = MdlEditMenuCmds
    if len(l1):
        Edit1.items = Edit1.items + [qmenu.sep] + l1
    sc1.update(MdlEditMenuShortcuts)   # merge shortcuts

    Commands1, sc2 = mdlcommands.CommandsMenu()
    sc1.update(sc2)   # merge shortcuts

    Tools1, sc2 = mdltoolbars.ToolsMenu(editor, mdltoolbars.toolbars)
    sc1.update(sc2)   # merge shortcuts

    Options1, sc2 = mdloptions.OptionsMenu()
    sc1.update(sc2)   # merge shortcuts
    l1 = plugins.mdlgridscale.GridMenuCmds
    l2 = [qmenu.sep]
    l3 = plugins.mdltools.RulerMenuCmds
    l4 = [qmenu.sep]
    if len(l1):
        Options1.items = l1 + l2 + l3 + l4 + Options1.items
        sc1.update(sc2)   # merge shortcuts

    return [File1, Layout1, Edit1, quarkx.toolboxmenu, Commands1, Tools1, Options1], sc1



def MdlBackgroundMenu(editor, view=None, origin=None):
    "Menu that appears when the user right-clicks on nothing in one of the"
    "editor views or Skin-view or on something or nothing in the tree-view."

    import mdlhandles
    import mdlcommands
    import mdloptions

    File1, sc1 = qmenu.DefaultFileMenu()
    Commands1, sc2 = mdlcommands.CommandsMenu()
    sc1.update(sc2)   # merge shortcuts
    FaceSelOptions, VertexSelOptions = mdloptions.OptionsMenuRMB()

    undo, redo = quarkx.undostate(editor.Root)
    if undo is None:   # to undo
        Undo1 = qmenu.item(Strings[113], None)
        Undo1.state = qmenu.disabled
    else:
        Undo1 = qmenu.macroitem(Strings[44] % undo, "UNDO")
    if redo is None:
        extra = []
    else:
        extra = [qmenu.macroitem(Strings[45] % redo, "REDO")]
    if origin is None:
        paste1 = qmenu.item("Paste", editor.editcmdclick)
    else:
        paste1 = qmenu.item("Paste here", editor.editcmdclick, "paste objects at '%s'" % str(editor.aligntogrid(origin)))
        paste1.origin = origin
    paste1.cmd = "paste"
    paste1.state = not quarkx.pasteobj() and qmenu.disabled
    extra = extra + [qmenu.sep, paste1]

    if view is not None:
        if view.info["viewname"] != "skinview":
            import mdloptions
            mdlfacepop = qmenu.popup("Face Commands", mdlhandles.ModelFaceHandle(origin).menu(editor, view), hint="clicked x,y,z pos %s"%str(editor.aligntogrid(origin)))
            vertexpop = qmenu.popup("Vertex Commands", mdlhandles.VertexHandle(origin).menu(editor, view), hint="clicked x,y,z pos %s"%str(editor.aligntogrid(origin)))
            if editor.layout.explorer.sellist == [] or quarkx.setupsubset(SS_MODEL, "Options")["LinearBox"] == "1" or editor.layout.explorer.sellist[0].type != ":mf":
                vertexpop.state = qmenu.disabled
            def backbmp1click(m, view=view, form=editor.form):
                import qbackbmp
                qbackbmp.MdlBackBmpDlg(form, view)
            backbmp1 = qmenu.item("Background image...", backbmp1click, "|Background image:\n\nWhen selected, this will open a dialog box where you can choose a .bmp image file to place and display in the 2D view that the cursor was in when the RMB was clicked.\n\nClick on the 'InfoBase' button below for full detailed information about its functions and settings.|intro.mapeditor.rmb_menus.noselectionmenu.html#background")
            if editor.ModelFaceSelList != []:
                extra = extra + [qmenu.sep] + [mdlfacepop] + [vertexpop] + [Commands1] + [qmenu.sep] + [FaceSelOptions] + [VertexSelOptions] + [qmenu.sep] + TexModeMenu(editor, view) + [qmenu.sep, backbmp1]
            else:
                extra = extra + [qmenu.sep] + [vertexpop] + [Commands1] + [qmenu.sep] + [FaceSelOptions] + [VertexSelOptions] + [qmenu.sep] + TexModeMenu(editor, view) + [qmenu.sep, backbmp1]
        else:
            def resetSkinview(menu, editor=editor, view=view):
                viewWidth, viewHeight = view.clientarea
                texWidth, texHeight = editor.Root.currentcomponent.currentskin["Size"]
                if texWidth > texHeight:
                    view.info["scale"] = viewWidth / texWidth
                elif texWidth < texHeight:
                    view.info["scale"] = viewHeight / texHeight
                elif viewWidth > viewHeight:
                    view.info["scale"] = viewHeight / texHeight
                else:
                    view.info["scale"] = viewWidth / texWidth
                view.info["center"] = view.screencenter = quarkx.vect(0,0,0)
                setprojmode(view)

            ResetSkinView = qmenu.item("&Reset Skin-view", resetSkinview, "|Reset Skin-view:\n\nIf the model skinning image becomes 'lost', goes out of the Skin-view, you can use this function to reset the view and bring the model back to its starting position.|intro.modeleditor.skinview.html#funcsnmenus")
            skinviewcommands = qmenu.popup("Vertex Commands", mdlhandles.SkinHandle(origin, None, None, None, None, None, None).menu(editor, view), hint="clicked x,y,z pos %s"%str(editor.aligntogrid(origin)))
            skinviewoptions = qmenu.popup("Skin-view Options", mdlhandles.SkinHandle(origin, None, None, None, None, None, None).optionsmenu(editor, view), hint="clicked x,y,z pos %s"%str(editor.aligntogrid(origin)))
            extra = [qmenu.sep] + [ResetSkinView] + [qmenu.sep] + [skinviewcommands, skinviewoptions]
    return [Undo1] + extra



def set_mpp_page(btn):
    "Switch to another page on the Multi-Pages Panel."

    editor = mapeditor(SS_MODEL)
    if editor is None: return
    editor.layout.mpp.viewpage(btn.page)


#
# Entities pop-up menus.
#

def MultiSelMenu(sellist, editor):
    return BaseMenu(sellist, editor)



def BaseMenu(sellist, editor):
    "The base pop-up menu for a given list of objects."

    mult = len(sellist)>1 or (len(sellist)==1 and sellist[0].type==':g')
    Force1 = qmenu.item(("&Force to grid", "&Force everything to grid")[mult],
      editor.ForceEverythingToGrid)
    if not MldOption("GridActive"):
        Force1.state = qmenu.disabled

    Cut1 = qmenu.item("&Cut", editor.editcmdclick)
    Cut1.cmd = "cut"
    Copy1 = qmenu.item("Cop&y", editor.editcmdclick)
    Copy1.cmd = "copy"
    paste1 = qmenu.item("Paste", editor.editcmdclick)
    paste1.cmd = "paste"
    paste1.state = not quarkx.pasteobj() and qmenu.disabled
    Delete1 = qmenu.item("&Delete", editor.editcmdclick)
    Delete1.cmd = "del"

    return [Force1, qmenu.sep, Cut1, Copy1, paste1, qmenu.sep, Delete1]

# ----------- REVISION HISTORY ------------
#
#
#$Log: mdlmenus.py,v $
#Revision 1.26  2008/01/26 23:28:55  cdunde
#To compute for different texture and Skin-view sizes for Reset Skin-view function.
#
#Revision 1.25  2008/01/25 20:58:03  cdunde
#Setup function to reset Skin-view.
#
#Revision 1.24  2007/11/22 05:13:47  cdunde
#Separated editors background image dialogs and setup to save all of their settings.
#
#Revision 1.23  2007/10/06 20:15:00  cdunde
#Added Ruler Guides to Options menu for Model Editor.
#
#Revision 1.22  2007/10/04 01:50:48  cdunde
#To fix error if RMB is clicked in a view for the popup menu
#but nothing is selected in the tree-view.
#
#Revision 1.21  2007/09/16 18:16:17  cdunde
#To disable all forcetogrid menu items when a grid is inactive.
#
#Revision 1.20  2007/09/15 18:36:52  cdunde
#To make "Vertex Commands" RMB active only if a model frame is selected.
#
#Revision 1.19  2007/09/15 18:17:54  cdunde
#To turn off "Vertex Commands" menu when Linear Handle button is active.
#
#Revision 1.18  2007/09/11 00:09:37  cdunde
#Added paste to tree-view RMB menu when a component sub-folder is selected.
#
#Revision 1.17  2007/09/05 18:43:10  cdunde
#Minor comment addition and grammar corrections.
#
#Revision 1.16  2007/07/14 22:42:44  cdunde
#Setup new options to synchronize the Model Editors view and Skin-view vertex selections.
#Can run either way with single pick selection or rectangle drag selection in all views.
#
#Revision 1.15  2007/07/09 18:59:23  cdunde
#Setup RMB menu sub-menu "skin-view Options" and added its "Pass selection to Editor views"
#function. Also added Skin-view Options to editors main Options menu.
#
#Revision 1.14  2007/06/03 22:50:55  cdunde
#To add the model mesh Face Selection RMB menus.
#(To add the RMB Face menu items when the cursor is not over one of the selected model mesh faces)
#
#Revision 1.13  2007/05/16 19:39:46  cdunde
#Added the 2D views gridscale function to the Model Editor's Options menu.
#
#Revision 1.12  2007/04/27 17:27:42  cdunde
#To setup Skin-view RMB menu functions and possable future MdlQuickKeys.
#Added new functions for aligning, single and multi selections, Skin-view vertexes.
#To establish the Model Editors MdlQuickKeys for future use.
#
#Revision 1.11  2007/04/22 22:41:50  cdunde
#Renamed the file mdltools.py to mdltoolbars.py to clarify the files use and avoid
#confliction with future mdltools.py file to be created for actual tools for the Editor.
#
#Revision 1.10  2007/04/16 16:55:59  cdunde
#Added Vertex Commands to add, remove or pick a vertex to the open area RMB menu for creating triangles.
#Also added new function to clear the 'Pick List' of vertexes already selected and built in safety limit.
#Added Commands menu to the open area RMB menu for faster and easer selection.
#
#Revision 1.9  2006/11/30 01:19:34  cdunde
#To fix for filtering purposes, we do NOT want to use capital letters for cvs.
#
#Revision 1.8  2006/11/29 07:00:28  cdunde
#To merge all runtime files that had changes from DanielPharos branch
#to HEAD for QuArK 6.5.0 Beta 1.
#
#Revision 1.7.2.1  2006/11/28 00:55:35  cdunde
#Started a new Model Editor Infobase section and their direct function links from the Model Editor.
#
#Revision 1.7  2005/10/15 00:47:57  cdunde
#To reinstate headers and history
#
#Revision 1.4  2000/08/21 21:33:04  aiv
#Misc. Changes / bugfixes
#
#Revision 1.2  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#