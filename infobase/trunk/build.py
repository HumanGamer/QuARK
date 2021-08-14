#! /usr/bin/env python

import html.entities, datetime, time, os, sys
from format import *

OutputPath = "output"
copyrightyear = datetime.date.today().year


#
# Text-to-HTML character conversion
#
TEXT_TO_HTML = { }
for c in range(256):
    TEXT_TO_HTML[chr(c)] = chr(c)
for entity, character in html.entities.entitydefs.items():
    TEXT_TO_HTML[character] = "&" + entity + ";"
TEXT_TO_HTML_NBSP = TEXT_TO_HTML.copy()
TEXT_TO_HTML_NBSP[" "] = "&nbsp;"

#
# ------------------------------------------------------------
#

def text2html(text):
    newtext = "".join(map(TEXT_TO_HTML.get, text))
    # Fix a problem with "&lt;" "&gt;" becoming "&amp;lt;" "&amp;gt;"
    newtext = newtext.replace("&amp;lt;",   "&lt;")
    newtext = newtext.replace("&amp;gt;",   "&gt;")
    # Hmmm? Lets fix "&nbsp;" too
    newtext = newtext.replace("&amp;nbsp;", "&nbsp;")
    return newtext

def text2html_nbsp(text, maxlen=999):
    if (len(text) > maxlen):
        text = text[:maxlen] + "..."
    return "".join(map(TEXT_TO_HTML_NBSP.get, text))

def path2html(path):
    return ".".join(list(filter(None, path.split(os.sep)))+["html"])

def climbpath(curpath, relpath):
    if relpath[:3] == ".."+os.sep:
        return climbpath(curpath[:-1], relpath[3:])
    else:
        if verboseMode:
            print('CURPATH ' + curpath)
        if curpath != []:
            newpath = os.sep.join(curpath + [relpath])
        else:
            newpath = relpath
        if verboseMode:
            print('NEWPATH ' + newpath)
        return newpath


def relpath(curpath, relpath):
    if relpath.startswith('.'+os.sep):
       return curpath + relpath[len('.'+os.sep):]
    elif relpath.startswith('..'+os.sep):
       track = curpath.split(os.sep)
       return climbpath(track[:-1], relpath)
    return relpath

def findref(root, path, name, fkw, extraargs):
    if verboseMode:
        print('FKW: ' + fkw["path"])

#    def ref(refnormal, refwithname, kw, name=name, extraargs):
    def ref(refnormal, refwithname, kw, name=name):
        if name == "":
            return refnormal % kw
        else:
            kw['refname'] = name
            return refwithname % kw

    path = relpath(fkw["path"], path)
    if verboseMode:
        print('PATH: ' + path)
        print('name: ' + name)
    parts = path.split(os.sep)
    pathsofar = ""
    while parts:
        pathsofar = pathsofar + parts[0] + os.sep
        for folder in root.folders:
            if folder.path == pathsofar:
                # Found matching folder
                root = folder
                del parts[0]
                break
        else:
            if len(parts) == 1:
                for subfiles in root.files:
                    if subfiles.kw["hrefaname"] == parts[0]:
                        return ref(REFFILE, REFFILE_NAME, subfiles.kw)
            raise RuntimeError("Reference not found to " + path + " in " + fkw["htmlfile"])
    return ref(REFDIR, REFDIR_NAME, root.kw)

def proc_g(kw, words):
    # '<g>...</g>' for Glossary-link
    # Ugly hack! This needs proper fixing, and not this semi-hardcoded bullshit.
    if words.startswith('.'):
        namelink = "fileext"
    elif words[:1] >= '0' and words[:1] <= '9':
        namelink = "numbers"
    else:
        namelink = words[:1].lower()
    return "<a href=\"glossary.html#%s\">%s</a>" % (namelink, words)

def proclink(kw, targetname, extraargs):
    # I know <link> exists in HTML, but we're not using it here, and it just seemed the best name of this!
    from links import linksdict
    link = linksdict[extraargs]
    return "<a target=\"_blank\" href=\"%s\">%s</a>" % (link, targetname)

def procpic(kw, path, extraargs):
    if (os.sep.find(path) > -1) or (os.sep.find(path) > -1) or path.startswith("."):
        raise RuntimeError("Illegal picture filename: [%s]" % path)
    picrl = PICLOC + ".".join(list(filter(None, kw["path"].split(os.sep)))+[path])
    if extraargs == '':
        img = '<img src="%s">' % (picrl)
    else:
        img = '<img %s src="%s">' % (extraargs, picrl)
    data = open(kw["path"]+path, "rb").read()
    with open(os.path.join(OutputPath, picrl), "wb") as f:
        f.write(data)
#    self.forgotten.remove(path)
    return img

def procrsc(kw, path):
    rscrl = ".".join(list(filter(None, kw["path"].split(os.sep)))+[path])
    data = open(kw["path"]+path, "rb").read()
    with open(os.path.join(OutputPath, rscrl), "wb") as f:
        f.write(data)
#    self.forgotten.remove(path)
    return '"%s"' % rscrl

def proczip(kw, path):
#    self.forgotten.remove(path)
    if localMode:
        data = open(os.path.join(ZIPLOC, path), "rb").read()
        if not os.path.exists(os.path.join(OutputPath, ZIPLOC)):
            os.mkdir(os.path.join(OutputPath, ZIPLOC))
        with open(os.path.join(OutputPath, ZIPLOC, path), "wb") as f:
            f.write(data)
        return '<a href="%s%s">%s</a>' % (ZIPLOC, path, path)
    else:
        return '<a href="%s%s%s">%s</a>' % (REMOTELOC, ZIPLOC, path, path)

def procact(kw, actionstring):
    # An 'action' is usually composed of a series of menu-actions the user
    # has to drill into. An example: "<act> RMB | Curves|Arch </act>"
    actionstring = actionstring.replace(" | ", " -&gt; ")
    actionstring = actionstring.replace("|",   " -&gt; ")
    return ACT_HTML % actionstring


def processtext(root, self, data):

    def perform_tag_action(tag, line, flags, root, kw):

        def perform_ref_action(extraargs, datastring, root, kw):
            datastring = datastring.strip()
            try:
                # figure out, if there is an alternative text for the link-reference
                idx = datastring.index('\\')
                pathname = datastring[:idx].strip().replace("/", os.sep)
                refname = datastring[idx+len('\\'):].strip()
            except (ValueError):
                pathname = datastring.replace("/", os.sep)
                refname = ""
            return findref(root, pathname, refname, kw, extraargs.strip())

        def perform_link_action(extraargs, datastring, root, kw):
            return proclink(kw, datastring.strip(), extraargs.strip())

        def perform_pic_action(extraargs, datastring, root, kw):
            return procpic(kw, datastring.strip().replace("/", os.sep), extraargs.strip())

        def perform_zip_action(datastring, root, kw):
            return proczip(kw, datastring.strip())

        def perform_rsc_action(datastring, root, kw):
            return procrsc(kw, datastring.strip())

        def perform_act_action(datastring, root, kw):
            return procact(kw, datastring.strip())

        def perform_g_action(datastring, root, kw):
            return proc_g(kw, datastring.strip())


        if tag.startswith("<code"):
            replacewith = "<div class=\"doccode\"><pre>"
            flags["preformatmode"] = flags["preformatmode"] + 1
        elif tag.startswith("</code"):
            replacewith = "</pre></div>"
            if (flags["preformatmode"] > 0):
                flags["preformatmode"] = flags["preformatmode"] - 1
        elif tag.startswith("<tt>"):
            replacewith = "&nbsp;<tt>"
        elif tag.startswith("</tt>"):
            replacewith = "</tt>&nbsp;"
        elif tag.startswith("<ref"):
            end_tag = line.find("</ref>")
            if end_tag == -1:
                # A <ref>-tag must have a </ref>-tag on the same line, else this code won't work.
                raise RuntimeError("<ref>-tag without any </ref>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_ref_action(tag[len("<ref"):-1], line[:end_tag], root, kw)
            line = line[end_tag+len("</ref>"):]
        elif tag.startswith("<link"):
            end_tag = line.find("</link>")
            if end_tag == -1:
                # A <link>-tag must have a </link>-tag on the same line, else this code won't work.
                raise RuntimeError("<link>-tag without any </link>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_link_action(tag[len("<link"):-1], line[:end_tag], root, kw)
            line = line[end_tag+len("</link>"):]
        elif tag.startswith("<img"):
            end_tag = line.find("</img>")
            if end_tag == -1:
                # A <img>-tag must have a </img>-tag on the same line, else this code won't work.
                raise RuntimeError("<img>-tag without any </img>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_pic_action(tag[len("<img"):-1], line[:end_tag], root, kw)
            line = line[end_tag+len("</img>"):]
        elif tag.startswith("<pic"):
            end_tag = line.find("</pic>")
            if end_tag == -1:
                # A <pic>-tag must have a </pic>-tag on the same line, else this code won't work.
                raise RuntimeError("<pic>-tag without any </pic>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_pic_action(tag[len("<pic"):-1], line[:end_tag], root, kw)
            line = line[end_tag+len("</pic>"):]
        elif tag.startswith("<zip"):
            end_tag = line.find("</zip>")
            if end_tag == -1:
                # A <zip>-tag must have a </zip>-tag on the same line, else this code won't work.
                raise RuntimeError("<zip>-tag without any </zip>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_zip_action(line[:end_tag], root, kw)
            line = line[end_tag+len("</zip>"):]
        elif tag.startswith("<rsc"):
            end_tag = line.find("</rsc>")
            if end_tag == -1:
                # A <rsc>-tag must have a </rsc>-tag on the same line, else this code won't work.
                raise RuntimeError("<rsc>-tag without any </rsc>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_rsc_action(line[:end_tag], root, kw)
            line = line[end_tag+len("</rsc>"):]
        elif tag.startswith("<act"):
            end_tag = line.find("</act>")
            if end_tag == -1:
                # A <act>-tag must have a </act>-tag on the same line, else this code won't work.
                raise RuntimeError("<act>-tag without any </act>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_act_action(line[:end_tag], root, kw)
            line = line[end_tag+len("</act>"):]
        elif tag.startswith("<g"):
            end_tag = line.find("</g>")
            if end_tag == -1:
                # A <g>-tag must have a </g>-tag on the same line, else this code won't work.
                raise RuntimeError("<g>-tag without any </g>-tag on same line! <File>.TXT title: \"%s\"" % kw["title"])
            replacewith = perform_g_action(line[:end_tag], root, kw)
            line = line[end_tag+len("</g>"):]
        elif tag.startswith("</i>"):
            replacewith = tag
            if (line[:6] != "&nbsp;"):
                # Force in a non-breakable-space after end-of-italic.
                replacewith = replacewith + "&nbsp;"
        elif tag.startswith("< "):
            raise RuntimeError("Illegal use of '<'-char. Use '&lt;' if a single '<' is needed! <File>.TXT title: \"%s\"" % kw["title"])
        else:
            replacewith = tag
            if tag.startswith("<pre"):
                flags["preformatmode"] = flags["preformatmode"] + 1
            elif tag.startswith("</pre"):
                if (flags["preformatmode"] > 0):
                    flags["preformatmode"] = flags["preformatmode"] - 1
        return replacewith, line, flags

    paragraph_tags_added = 0
    listing_tags_added = 0
    table_tags_added = 0
    table_td_nesting = 0
    lastnonemptyline = -1
    flags = { }
    flags["prevlineempty"] = 1
    flags["preformatmode"] = 0
    flags["inhtmlcomment"] = 0

    for line in self.text:
        correctedline = ""
        trimmedline = line.strip()
        if not trimmedline:
            correctedline = "\n"
            flags["prevlineempty"] = 1
            if (flags["preformatmode"] == 0) and (flags["inhtmlcomment"] == 0):
                if (paragraph_tags_added > 0) and (listing_tags_added == 0) and (table_tags_added == 0):
                    if len(data):
                        data[-1] = data[-1].rstrip("\r\n") + "</p>\n"
                    else:
                        data.append("</p>\n")
                    paragraph_tags_added = paragraph_tags_added - 1
                    lastnonemptyline = -1
                if (lastnonemptyline > -1) and (table_td_nesting != 0):
                    data[lastnonemptyline] = data[lastnonemptyline].rstrip("\r\n") + "<br>\n"
        else:
            # Scan through the 'line' in search for "<tag's" to replace/perform actions on
            while len(line) > 0:
                if (flags["inhtmlcomment"] == 1):
                    endofcomment_found = line.find("-->")
                    if endofcomment_found == -1:
                        # We're still in HTML-comment
                        correctedline = correctedline + line
                        line = ""
                    else:
                        # Exiting HTML-comment mode
                        correctedline = correctedline + line[:endofcomment_found+len("-->")]
                        line = line[endofcomment_found+len("-->"):]
                        flags["inhtmlcomment"] = 0
                else:
                    if len(line.strip()) != 0:
                        lastnonemptyline = len(data)
                    startchar_tag_found = line.find("<")
                    if startchar_tag_found == -1:
                        # No "<tag" were found, so just copy the entire line
                        correctedline = correctedline + text2html(line)
                        line = ""
                    else:
                        # Found a "<tag". Take anything before that, and append to 'correctedline'
                        correctedline = correctedline + text2html(line[:startchar_tag_found])
                        line = line[startchar_tag_found:]
                        if line.startswith("<!--"):
                            flags["inhtmlcomment"] = 1
                            correctedappend = line[:len("<!--")]
                            line = line[len("<!--"):]
                        else:
                            endchar_tag_found = line.find(">")
                            if endchar_tag_found == -1:
                                # there must exist an endchar_tag on the same line!
                                raise RuntimeError("'%s' without ending '>' problem! <File>.TXT title: \"%s\"" % (line[:5], self.kw["title"]))
                            endchar_tag_found += len(">")
                            tag = (line[:endchar_tag_found]).lower()
                            if (tag == "<p>") or (tag == "</p>") or tag.startswith("<html") or tag.startswith("</html"):
                                # do not allow these tags!
                                raise RuntimeError("The %s tag is not allowed! <File>.TXT title: \"%s\"" % (tag, self.kw["title"]))
                            if tag.startswith("<ul") or tag.startswith("<ol") or tag.startswith("<dl"):
                                listing_tags_added += 1
                            elif tag.startswith("</ul") or tag.startswith("</ol") or tag.startswith("</dl"):
                                listing_tags_added -= 1
                                lastnonemptyline = -1 #Don't add breaks outside due to content inside
                                flags["prevlineempty"] = 0 #Don't paragraph this line, even if the previous line was empty
                            elif tag.startswith("<table"):
                                table_tags_added += 1
                            elif tag.startswith("</table"):
                                table_tags_added -= 1
                                lastnonemptyline = -1 #Don't add breaks outside due to content inside
                                flags["prevlineempty"] = 0 #Don't paragraph this line, even if the previous line was empty
                            elif tag.startswith("</code"):
                                lastnonemptyline = -1 #Don't add breaks outside due to content inside
                                flags["prevlineempty"] = 0 #Don't paragraph this line, even if the previous line was empty
                            elif tag.startswith("<td"):
                                table_td_nesting += 1
                            elif tag.startswith("</td"):
                                table_td_nesting -= 1
                            tag = (line[:endchar_tag_found]) #Don't lowercase, as this can break URLs
                            try:
                                correctedappend, line, line_flags = perform_tag_action(tag, line[endchar_tag_found:], flags, root, self.kw)
                            except:
                                print("ERROR: Encountered a problem processing the tag in file %s:" % (self.filename))
                                raise
                        correctedline = correctedline + correctedappend

            if flags["prevlineempty"] == 1:
                if (listing_tags_added == 0) and (table_tags_added == 0) and (flags["preformatmode"] == 0) and (flags["inhtmlcomment"] == 0):
                    # prepend with paragraph-tag
                    correctedline = "<p>" + correctedline
                    paragraph_tags_added = paragraph_tags_added + 1

            flags["prevlineempty"] = 0

        data.append(correctedline)

    for ptags in range(paragraph_tags_added):
        if len(data):
            data[-1] = data[-1].rstrip("\r\n") + "</p>\n"
        else:
            data.append("</p>\n")

    if len(data) and not data[-1].endswith("\n"):
        data[-1] = data[-1] + "\n"

    if listing_tags_added != 0:
        raise RuntimeError("File ends with an open ul/ol/dl-tag! <File>.TXT title: \"%s\"" % (self.kw["title"], ))

def parse(file):
    try:
        f = open(file, "r")
    except:
        raise RuntimeError("File missing: %s" % file)
    try:
        kw = { }
        # Read the beginning non-empty lines, which should contain "key: value"'s
        while 1:
            line = f.readline().strip()
            if not line: # empty line found, stop reading for "key: value"'s
                break
            keysplit = line.find(":")
            if keysplit == -1: # not a valid keypair; we're probably done
                break
            key = line[:keysplit].strip()
            value = line[keysplit+len(":"):].strip()
            try:
                data = kw[key]
            except (KeyError):
                kw[key] = value
            else:
                kw[key] = data+"\n"+value
        restdata = f.readlines()
    finally:
        f.close()
    return kw, restdata, os.stat(file).st_mtime

class File:
    def __init__(self, filename):
        self.filename = filename
        self.kw, self.text, self.lastmodifydate = parse(filename)

class Folder:
    def __init__(self, path, classif, parents, prev=None):
        self.prev = prev
        self.parents = parents
        self.path = path
        if verboseMode:
            print('Path: '+self.path)
        self.classif = classif
        if classif: # Decker
            shortname = "".join(map(lambda s: s+".", classif)) + "&nbsp;"
        else: # Decker
            shortname = "" # Decker - Make the 'index.html' title _not_ prefixed with a single space
        if verboseMode:
            print(shortname,)
        self.kw, self.text, lastmodifydate = parse(self.path + "index" + EXTENSION)
        s = self.kw["title"]
        if verboseMode:
            print(s)
        self.kw["htmltitle"] = text2html_nbsp(s)
        self.kw["htmltitleshort"] = text2html_nbsp(s, 25) # Decker - Try to prevent text-wrapping, so make it max 25 characters long
        self.kw["classif"] = shortname
        self.kw["path"] = path
        if not classif:
            shortname = "index.html"
        else:
            shortname = path2html(path)
        self.kw["htmlfile"] = shortname
        self.kw["copyrightyear"] = copyrightyear
        self.kw["navprev"] = NAVNOPREV
        self.kw["navup"]   = NAVNOUP
        self.kw["navnext"] = NAVNONEXT
        if parents:
            self.kw["parenthtmlfile"] = parents[-1].kw["htmlfile"]
            self.kw["navup"] = NAVUP % parents[-1].kw
        # Recusivee into sub-folders
        self.folders = []
        self.forgotten = list(map(str.lower, os.listdir(os.path.join(".", self.path))))
        self.forgotten.remove("index" + EXTENSION)
        self.kw["next"] = ""
        self.kw["nextfooter"] = ""
        htmlpath = path2html(path)
        previous = None
        for foldername in self.kw.get("subdir", "").split():
            folder = Folder(path + foldername + os.sep, classif + (str(len(self.folders) + 1),), parents + (self,), previous)
            if folder.lastmodifydate > lastmodifydate:
                lastmodifydate = folder.lastmodifydate
            self.folders.append(folder)
            self.forgotten.remove(foldername)
            previous = folder
        self.files = []
        for filename in self.kw.get("desc", "").split():
            file = File(self.path + filename + EXTENSION)
            if file.lastmodifydate > lastmodifydate:
                lastmodifydate = file.lastmodifydate
            file.kw["htmlfile"] = shortname
            file.kw["hrefaname"] = filename
            file.kw["updateday"] = time.strftime("%d %b %Y", time.localtime(file.lastmodifydate))
            file.kw["path"] = path  # tiglari         @: Gotta go away!
            self.files.append(file)  #@(kw, text)
            self.forgotten.remove(filename + EXTENSION)
        self.lastmodifydate = lastmodifydate
        self.kw["updateday"] = time.strftime("%d %b %Y", time.localtime(lastmodifydate))
        # Setup backwards navigation links
        if not parents:
            lvl = MAINHEADERLVL
        else:
            lvl = SUBHEADERLVL
            for folder in parents:
                lvl = lvl + HEADERLVL % folder.kw
        self.kw["headerlvl"] = lvl

    def navigation(self):
        # Setup navigation links (Prev-Up-Next) # Decker
        try:
            prev = self.parents[-1]
            i = len(prev.folders) - 1
            while (i >= 0 and prev.folders[i] != self):
                i = i - 1
            if (i > 0):
                prev = prev.folders[i - 1]
                while (len(prev.folders) > 0):
                    prev = prev.folders[-1]
            prev.kw["navnext"] = NAVNEXT % self.kw
            self.kw["navprev"] = NAVPREV % prev.kw
        except:
            pass
        for folder in self.folders:
            folder.navigation()

    def writefiles(self, root, filewriter):
        if verboseMode:
            print('writing file: ' + self.kw["htmlfile"], "  [%s]" % self.kw["title"])
        filewriter(self.kw["htmlfile"], self.makefile(root))
        for folder in self.folders:
            folder.writefiles(root, filewriter)

    def makefile(self, root):
        data = [ HEADER_BEGIN % self.kw ]
        processtext(root, self, data)
        data.append(HEADER_END % { })
        if self.folders:
            data.append(SUBDIR_BEGIN % self.kw)
            for folder in self.folders:
                data.append(SUBDIR_ITEM_BEGIN % folder.kw)
                DoneMore = False
                if folder.folders:
                    if not DoneMore:
                        data.append(SUBDIR_ITEM_MORE % { })
                        DoneMore = True
                    data.append(SUBSUBDIR_BEGIN % folder.kw)
                    for subfolder in folder.folders:
                        data.append(SUBSUBDIR_ITEM % subfolder.kw)
                    data.append(SUBSUBDIR_END % folder.kw)
                if folder.files:
                    if not DoneMore:
                        data.append(SUBDIR_ITEM_MORE % { })
                        DoneMore = True
                    if len(folder.files) < 11:
                        data.append(SUBFILES_BEGIN % folder.kw)
                        for subfiles in folder.files:
                            data.append(SUBFILES_ITEM % subfiles.kw)
                        data.append(SUBFILES_END % folder.kw)
                    else:
                        # If more than 10 files, put into two columns
                        data.append(SUBFILES_TABLEBEGIN % { });
                        data.append(SUBFILES_BEGIN % folder.kw)
                        cnt = 0
                        for subfiles in folder.files:
                            if cnt == int((len(folder.files)+1) / 2):
                                data.append(SUBFILES_END % folder.kw)
                                data.append(SUBFILES_TABLEMIDDLE % { });
                                data.append(SUBFILES_BEGIN % folder.kw)
                            data.append(SUBFILES_ITEM % subfiles.kw)
                            cnt = cnt + 1
                        data.append(SUBFILES_END % folder.kw)
                        data.append(SUBFILES_TABLEEND % { });
                data.append(SUBDIR_ITEM_END % { })
            data.append(SUBDIR_END % self.kw)
        if self.files:
            data.append(FILES_BEGIN % self.kw)
            if len(self.files) < 11:
                data.append(FILES_ITEMBEGIN % self.kw)
                for subfiles in self.files:
                    data.append(FILES_ITEM % subfiles.kw)
                data.append(FILES_ITEMEND % self.kw)
            else:
                # If more than 10 files, put into two columns
                data.append(SUBFILES_TABLEBEGIN % { });
                data.append(FILES_ITEMBEGIN % self.kw)
                cnt = 0
                for subfiles in self.files:
                    if cnt == int((len(self.files)+1) / 2):
                        data.append(FILES_ITEMEND % self.kw)
                        data.append(SUBFILES_TABLEMIDDLE % { });
                        data.append(FILES_ITEMBEGIN % self.kw)
                    data.append(FILES_ITEM % subfiles.kw)
                    cnt = cnt + 1
                data.append(FILES_ITEMEND % self.kw)
                data.append(SUBFILES_TABLEEND % { });
            data.append(FILES_MIDDLE % self.kw)
            for subfiles in self.files:
                data.append(FILE_BEGIN % subfiles.kw)
                processtext(root, subfiles, data)
                data.append(FILE_END % subfiles.kw)
            data.append(FILES_END % self.kw)
        data.append(FOOTER % self.kw)
        return data

    def viewforgotten(self):
        for s in self.forgotten:
            #if s[-1:]!="~" and s!="cvs" and s.find('.png')==-1 and s.find('.jpg')==-1 and s.find('.gif')==-1:
            if s[-1:]!="~" and s.find('.png')==-1 and s.find('.jpg')==-1 and s.find('.gif')==-1:
                print("NOTE: file '%s' not found in index" % (self.path+s))
        for folder in self.folders:
            folder.viewforgotten()


def defaultwriter(filename, data, writemode="w"):
    # write the target file
    with open(os.path.join(OutputPath, filename), writemode) as f:
        f.writelines(data)

def run(filewriter):
    def printline(text):
        if len(text)>77-3-1:
            print(text)
        else:
            print("---" + text + "-"*(80-len(text)-3-1))
    # load format file
    # create additional output directories, if needed
    if PICLOC != '':
        if not os.path.exists(os.path.join(OutputPath, PICLOC)):
            os.mkdir(os.path.join(OutputPath, PICLOC))
    # recursively load everything in memory
    printline("FINDING ALL FILES")
    root = Folder("", (), ())
    # recursively set navigation links
    printline("SETTING UP NAVIGATION")
    root.navigation() # Decker
    
    # recursively write everything to disk
    printline("WRITING FILES TO DISK")
    root.writefiles(root, filewriter)
    for filename in root.kw.get("extrafiles_text", "").split():
        filewriter(filename, [open(filename, "r").read()])
    for filename in root.kw.get("extrafiles_binary", "").split():
        filewriter(filename, [open(filename, "rb").read()], "wb")
    printline("PRINTING FORGOTTEN FILES")
    root.forgotten = []
    root.viewforgotten()

localMode=0
verboseMode=0
for flag in sys.argv:
    if flag=='-local':
        localMode=1
    if flag=='-verbose':
        verboseMode=1
if not os.path.exists(OutputPath):
    os.mkdir(OutputPath)
else:
    print("WARNING: Output directory already exists!")

run(defaultwriter)
