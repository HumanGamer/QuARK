"""   QuArK  -  Quake Army Knife

For registering python 'plugins' files for model importers
and exporters to QuArK's Main Files - Import menu.
"""

#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

# $Header$

# Text = title displayed on the menu.
# Ext = text of the file type, ex: ".md2 file"
# Desc = type of file (displayed at bottom) that can be selected in the file selection window, ex: "*.md2"
# Proc = the function that is to be called (and file passed back to) in the importer plugin once a file is selected.
# ImporterFile and ExporterFile = imports the plugin file itself (without the .py) so it can be used in mdlmgr.py later.
def RegisterMdlImporter(Text, Ext, Desc, Proc, ImporterFile=None):
    import qmacro
    import quarkx
    if ImporterFile is not None:
        import mdlmgr
        from mdlmgr import SFTexts, mdltypes, IEfile
        mdlmgr.SFTexts = mdlmgr.SFTexts + [Desc.strip("*")]
        mdlmgr.mdltypes = mdlmgr.mdltypes + [len(mdltypes)]
        mdlmgr.IEfile = mdlmgr.IEfile + [ImporterFile]
    qmacro.mdlimport.update( { Text: ([Ext, Desc],  Proc) } )
    quarkx.mdlimportmenu(Text)

def RegisterMdlExporter(Text, Ext, Desc, Proc, ExporterFile=None):
    import qmacro
    if ExporterFile is not None:
        import mdlmgr
        from mdlmgr import SFTexts, mdltypes, IEfile
        mdlmgr.SFTexts = mdlmgr.SFTexts + [Desc.strip("*")]
        mdlmgr.mdltypes = mdlmgr.mdltypes + [len(mdltypes)]
        mdlmgr.IEfile = mdlmgr.IEfile + [ExporterFile]
    qmacro.mdlexport.update( { Text: ([Ext, Desc],  Proc) } )
    
# ----------- REVISION HISTORY ------------
# $Log$
# Revision 1.3  2008/07/10 23:43:44  cdunde
# Added detail info to the file comments.
#
# Revision 1.2  2008/06/29 16:38:31  cdunde
# Minor correction.
#
# Revision 1.1  2008/06/04 03:56:39  cdunde
# Setup new QuArK Model Editor Python model import export system.
#
#