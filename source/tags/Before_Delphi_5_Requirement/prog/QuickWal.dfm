ÿ
 TQUICKWALPARSER 0@  TPF0TQuickWalParserQuickWalParserLeftê Top BorderStylebsDialogCaptionTexture File Finder...ClientHeightuClientWidth Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Heightõ	Font.Name
MS Sans Serif
Font.Style OldCreateOrder	PositionpoScreenCenter
OnActivateFormActivateOnCreate
FormCreate
PixelsPerInch`
TextHeight
 TBevelBevel1LeftTopè WidthHeighta  TLabelLabel1LeftTopWidthHeight9AutoSizeCaptionÂThis wizard lets you use your collection of texture files (.wad, .wal, .m8, etc.) with QuArK. Use it if you have a large amount of such texture files in a subdirectory under your game directory.WordWrap	  TLabelLabel2LeftTopHWidthHeight!AutoSizeCaption_You should first create and select a new "main folder" in the texture browser ("Folders" menu).WordWrap	  TLabelLabel3LeftToppWidthù Height
Caption7Please select the directory that contains the textures:  TToolbarButton97OkBtnLeft TopTWidthDHeightCaptionOkEnabled
Glyph.Data
Ò  Î  BMÎ      6   (   $              Î  Ä                                                                                                                                                                                              ÿÿÿ                                                                                                    ÿÿÿ                                                                                                  ÿÿÿ                                                                                                ÿÿÿ                                                                                              ÿÿÿ                                 ÿ                                   ÿÿÿ      ÿÿÿ         ÿÿÿ                            ÿ     ÿ                                 ÿÿÿ      ÿÿÿ      ÿÿÿ                      ÿ    ÿ           ÿ                              ÿÿÿ         ÿÿÿ      ÿÿÿ                      ÿ                 ÿ                                             ÿÿÿ      ÿÿÿ                                        ÿ                                                ÿÿÿ      ÿÿÿ                                        ÿ                                                ÿÿÿ      ÿÿÿ                                        ÿ                                                ÿÿÿ      ÿÿÿ                                        ÿ                                                ÿÿÿ      ÿÿÿ                                        ÿ                                                 ÿÿÿ   ÿÿÿ                                           ÿ                                                  ÿÿÿ                                                 ÿ                                                                                                                                                                      	NumGlyphsOnClick
OkBtnClick  TToolbarButton97	CancelBtnLeftÕ TopTWidthDHeightCaptionCancel
Glyph.Data
Ò  Î  BMÎ      6   (   $              Î  Ä                                                                                                                                                                                     ÿÿÿ                                               ÿ                     ÿ                        ÿÿÿ                  ÿÿÿ                       ÿ                 ÿ                      ÿÿÿ   ÿÿÿ         ÿÿÿÿÿÿ                    ÿ             ÿ                       ÿÿÿ      ÿÿÿ   ÿÿÿ      ÿÿÿ                    ÿ                                 ÿÿÿ         ÿÿÿ            ÿÿÿ                    ÿ                                     ÿÿÿ                     ÿÿÿ                          ÿ                                       ÿÿÿ                  ÿÿÿ                                                                         ÿÿÿ                                                  ÿ                                            ÿÿÿ                                            ÿ                                                          ÿÿÿ                             ÿ                                                         ÿÿÿ                          ÿ           ÿ                                       ÿÿÿ      ÿÿÿ                       ÿ               ÿ                        ÿÿÿ         ÿÿÿ      ÿÿÿ                       ÿ                   ÿ                        ÿÿÿÿÿÿ         ÿÿÿ      ÿÿÿ                                            ÿ    ÿ                                    ÿÿÿÿÿÿÿÿÿ                                                                                                                                                                                                                  	NumGlyphsOnClickCancelBtnClick  TLabelLabel4LeftTopð WidthHeight
CaptionFilter:  TLabelLabel5LeftTopWidth Height4CaptionzFilter is a .pak/.pk3/.shader file name or texture subfolder. E.g. 'mypak.pk3', 'myshad.shader', 'mypix' or 'mypix/house'.WordWrap	  TListBoxListBox1LeftTop WidthHeighta
ItemHeight
TabOrder OnClick
ListBox1Click  	TCheckBoxDynamicCheckBoxLeft¸ Topð WidthQHeightHintÖA dynamic texture-list will show whatever textures that
exists in the choosen folder, when QuArK starts.
A non-dynamic texture-list takes a persistent 'snapshot'
of the textures that can be found in the folder now.CaptionDynamicChecked	State	cbCheckedTabOrder  	TCheckBox
MergeCheckBoxLeft¸ TopWidthQHeightHint}Merged combines all textures (and shaders) into one texture-list
hierarchy. Non-merged separates contents of different pak's.CaptionMergedChecked	State	cbCheckedTabOrder  	TCheckBoxShaderListCheckBoxLeft¸ Top WidthQHeightHintfIf shaderlist.txt exists in folder, only shaders
are shown in merged mode.
(Quake-3 game-engines only)CaptionShaderlist.txtChecked	State	cbCheckedTabOrder  TEdit
FilterEditLeft0Topð WidthyHeightTabOrder   