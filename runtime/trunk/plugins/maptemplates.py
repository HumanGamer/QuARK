"""   QuArK  -  Quake Army Knife

Plug-in which adds template functionality.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

Info = {
   "plug-in":       "Templates",
   "desc":          "Adds template functionality",
   "date":          "21 December 2007",
   "author":        "Shine team, Nazar and vodkins",
   "author e-mail": "",
   "quark":         "Version 6.5.0 Beta 4" }


import os
import quarkx
import quarkpy.mapcommands
import quarkpy.mapentities
import quarkpy.qmenu
from quarkpy.qutils import *

def PutItemFolder(Folder, Item):
    ItemName = Item

    CurrentFolder = Folder
    nChar=ItemName.find("/")

    while nChar != -1:
        FolderName = ItemName[:nChar]
        ItemName = ItemName[nChar+1:]
        nChar=ItemName.find("/")

        bFound = 0
        for iFolder in CurrentFolder.subitems:
            if iFolder.shortname==FolderName:
                CurrentFolder = iFolder
                bFound = 1
                break

        if bFound == 0:
            NewFolder = quarkx.newobj(FolderName + ".qtxfolder")
            CurrentFolder.appenditem(NewFolder)
            CurrentFolder = NewFolder

    return CurrentFolder


def FindTemplateNames(PrefabDir):
    TemplateNamesListLocal = []
    for FileName in os.listdir(PrefabDir):
        if FileName.endswith(".qkm"):
            TemplateFile = quarkx.openfileobj(PrefabDir + "\\" + FileName)
            ItemList = []

            worldspawn = None
            for worldspawn in TemplateFile.subitems:
                if worldspawn.shortname == "worldspawn":
                    break
            for item in worldspawn.subitems:
                if item.type == ":g" and item.shortname != "group" and (item[";view"] is None or item[";view"] == "0") and item.shortname[0]!="$":
                    szDescription = ""
                    if item["Description"] is not None:
                        szDescription = item["Description"]
                    ItemI = item.shortname, szDescription
                    ItemList.append(ItemI)
            LevelDescription = ""
            if worldspawn["LevelInfo.Description"] is not None:
                LevelDescription = worldspawn["LevelInfo.Description"]
            if len(ItemList) > 0:
                FileItem = FileName, LevelDescription, ItemList
                TemplateNamesListLocal.append(FileItem)
    return TemplateNamesListLocal

def BuildTemplatesListClick(m):
    PrefabDir = quarkx.setupsubset()["Templates"]
    if PrefabDir is None:
        if quarkx.msgbox("The 'Directory of Templates' has not been\nchosen in this 'Games' configuration section.\nYou can not use any templates until\nyou select a folder to keep them in.\n\nWould you like to go there now to do so?", MT_CONFIRMATION, MB_YES | MB_NO) == MR_YES:
            quarkx.openconfigdlg(":")
        return

    TemplateNames = FindTemplateNames(PrefabDir)
    if len(TemplateNames) == 0:
        quarkx.msgbox("No templates found in template folder:\n" + PrefabDir, MT_ERROR, MB_OK)
        return
    TemplateFileName = "Addons\\" + quarkx.setupsubset(SS_GAMES)['GameCfg'].replace(' ', '_') + "\\" + quarkx.setupsubset(SS_GAMES)['GameCfg'] + "Templates.qrk"
    TemplateFile = quarkx.newfileobj(TemplateFileName)
    TemplateFile.filename = TemplateFileName

    r_tbx = quarkx.newobj("Toolbox Folders.qtx")
    r_tbx["Toolbox"] = "New map items..."
    r_tbx.flags = r_tbx.flags | OF_TVSUBITEM
    TemplateFile.appenditem(r_tbx)

#    e_tbx = quarkx.newobj("Gorge Tour prefabs.qtxfolder")
    e_tbx = quarkx.newobj(quarkx.setupsubset(SS_GAMES)['GameCfg'] + " Templates.qtxfolder")
#    e_tbx[";desc"] = "Created from "
    r_tbx.appenditem(e_tbx)

    r_tbx["Root"] = e_tbx.name

    f_tbx = quarkx.newobj("Entity forms.qctx")
    f_tbx.flags = f_tbx.flags | OF_TVSUBITEM
    TemplateFile.appenditem(f_tbx)

#  Writing entities
    PrefabDir = quarkx.setupsubset()["Templates"]
    for PrefabFile in TemplateNames:
        FileName, LevelDescription, Prefabs = PrefabFile
        Folder = quarkx.newobj(FileName + ".qtxfolder")
        Folder[";desc"] = LevelDescription
        e_tbx.appenditem(Folder)
        for Prefab in Prefabs:
            PrefabName, PrefabDescription = Prefab
            ItemFolder = PutItemFolder(Folder, PrefabName)
            PrefabItem = quarkx.newobj(PrefabName+":d")
            PrefabItem[";desc"] = PrefabDescription
            PrefabItem["origin"] = "0 0 0"
            PrefabItem["scale"] = "1 1 1"
            PrefabItem["mangle"] = "0 0 0"
            PrefabItem["macro"] = "Template"
            PrefabItem["templatefilename"] = PrefabDir + "\\" + FileName
            ItemFolder.appenditem(PrefabItem)

    TemplateFile.refreshtv()
    TemplateFile.savefile(TemplateFileName, 1)
    return

BuildPrefabsListItem = quarkpy.qmenu.item("Build templates list", BuildTemplatesListClick, "|This function will build a list of all .qkm files that exist in the templates folder (if any) and place that list on 'New map items...' to select from.\n\nEach game can have its own templates and list, which this function also creates as a Templates.qrk file with the current game mode name in front of it and places that file in this games 'addons' folder.|intro.mapeditor.misctools.html#templates")

quarkpy.mapcommands.items.append(quarkpy.qmenu.sep)   # separator
quarkpy.mapcommands.items.append(BuildPrefabsListItem)

#---

# For templates

def refreshTemplateClick(m):
    editor=m.editor
    item=m.item
    editor.layout.explorer.uniquesel = item.parent
    newitem = item.copy()
    undo = quarkx.action()
    undo.exchange(item, newitem)
    undo.ok(editor.Root, "")

def RefreshTemplate(item, editor):
    if item.type != ":d":
        return

    if item["macro"] is None or item["macro"]!="Template":
        return

    m = quarkpy.qmenu.item
    m.editor = editor
    m.item = item
    refreshTemplateItem = quarkpy.qmenu.item("Refresh &Template", refreshTemplateClick, "|If a template is changed, clicking this function will update those changes to your current map where that template is used.\n\nIt may also update other templates in this same map if they have been changed also.\n\nPress F1 once more to see more details about updating templates in the Infobase.|intro.mapeditor.misctools.html#refreshtemplate")
    return refreshTemplateItem

def template_ent_menu(o, editor, oldmenu=quarkpy.mapentities.EntityType.menu.im_func):
  "point entity menu"
  menu = oldmenu(o, editor)
  templatemenu = RefreshTemplate(o, editor)
  if templatemenu is None:
    return menu
  menu[:0] = [templatemenu,
              quarkpy.qmenu.sep]
  return menu

quarkpy.mapentities.EntityType.menu = template_ent_menu
