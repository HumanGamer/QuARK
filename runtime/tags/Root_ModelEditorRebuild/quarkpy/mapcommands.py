"""   QuArK  -  Quake Army Knife

The map editor's "Commands" menu (to be extended by plug-ins)
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$



import quarkx
import qmenu
from qutils import MapHotKeyList

def newitem1click(m):
    quarkx.opentoolbox("New map items...")


NewItem1 = qmenu.item("&Insert map item...", newitem1click, "|Opens the 'New Map items' window:\n\nThis window contains all objects thats possible to use in the map-views and dataform-display. |intro.mapeditor.misctools.html#newmapitem")


#
# Global variables to update from plug-ins.
#

items = [NewItem1]
shortcuts = {}

def onclick(menu):
    pass


def CommandsMenu():
    "The Commands menu, with its shortcuts."
    MapHotKeyList("Insert", NewItem1, shortcuts)
    return qmenu.popup("&Commands", items, onclick), shortcuts

# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.5  2003/03/24 08:58:07  cdunde
#To update info and link to infobase
#
#Revision 1.4  2001/04/28 02:22:08  tiglari
#add 'insert' shortcut loader
#
#Revision 1.3  2001/03/20 07:59:40  tiglari
#customizable hot key support
#
#Revision 1.2  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#