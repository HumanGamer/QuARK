(**************************************************************************
QuArK -- Quake Army Knife -- 3D game editor
Copyright (C) 1996-99 Armin Rigo

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

Contact the author Armin Rigo by e-mail: arigo@planetquake.com
or by mail: Armin Rigo, La Cure, 1854 Leysin, Switzerland.
See also http://www.planetquake.com/quark
**************************************************************************)

unit QkPcx;

interface

uses SysUtils, Classes, QkObjects, QkFileObjects, QkImages;

type
 QPcx = class(QImages)
        protected
          procedure Enregistrer(Info: TInfoEnreg1); override;
          procedure Charger(F: TStream; Taille: Integer); override;
        public
          class function TypeInfo: String; override;
          class procedure FileObjectClassInfo(var Info: TFileObjectClassInfo); override;
        end;

 {------------------------}

implementation

uses Windows, Travail, Quarkx;

const
 pcxSignature   = $0801050A;
 pcxColorPlanes = 1;
 pcxPalette256  = 12;
 pcxPositionPalette = 769;
 pcxTaillePalette = pcxPositionPalette-1;

type
 TPcxHeader = record
               {Manufacturer, Version, Encoding, BitsPerPixel: Byte;}
               Signature: LongInt;
               xmin, ymin, xmax, ymax: Word;
               hres, vres: Word;
               Palette: array[0..47] of Byte;
               Reserved: Byte;
               ColorPlanes: Byte;
               BytesPerLine: Word;
               PaletteType: Word;
               Reserved2: array[0..57] of Byte;
               Data: record end;
              end;

 {------------------------}

class function QPcx.TypeInfo: String;
begin
 TypeInfo:='.pcx';
end;

class procedure QPcx.FileObjectClassInfo(var Info: TFileObjectClassInfo);
begin
 inherited;
 Info.NomClasseEnClair:=LoadStr1(5137);
 Info.FileExt:=781;
 Info.WndInfo:=[wiWindow];
end;

procedure QPcx.Charger(F: TStream; Taille: Integer);
const
 Spec1 = 'Image1=';
 Spec2 = 'Pal=';
var
 Header: TPcxHeader;
 XSize, YSize, ScanW, I, J, K, L: Integer;
 V: array[1..2] of Single;
 Data: String;
 ScanLine: PChar;
 Byte1, Byte2: Byte;
 InBuffer: String;
 BufStart, BufEnd, BufMin: Integer;
 Origine: LongInt;
begin
 case ReadFormat of
  1: begin  { as stand-alone file }
      if Taille<SizeOf(Header) then
       Raise EError(5519);
      F.ReadBuffer(Header, SizeOf(Header));
      Origine:=F.Position;
      Dec(Taille, SizeOf(Header));
      if (Header.Signature<>pcxSignature)
      or (Header.ColorPlanes<>pcxColorPlanes) then
       Raise EErrorFmt(5532, [LoadName,
        Header.Signature, Header.ColorPlanes,
        pcxSignature,     pcxColorPlanes]);
      if Taille<pcxPositionPalette then
       Raise EErrorFmt(5533, [LoadName]);
      Dec(Taille, pcxPositionPalette);

      F.Position:=Origine+Taille;
      F.ReadBuffer(Byte1, 1);
      if Byte1<>pcxPalette256 then
       Raise EErrorFmt(5533, [LoadName]);
      F.Position:=Origine;

      XSize:=Header.Xmax - Header.Xmin + 1;
      YSize:=Header.Ymax - Header.Ymin + 1;
      DebutTravail(5448, YSize); try
      V[1]:=XSize;
      V[2]:=YSize;
      SetFloatsSpec('Size', V);
      ScanW:=(XSize+3) and not 3;
      if Header.BytesPerLine > ScanW then
       Raise EErrorFmt(5509, [34]);
      Data:=Spec1;
      I:=ScanW*YSize;   { 'Image1' byte count }
      SetLength(Data, Length(Spec1)+I);
      ScanLine:=PChar(Data)+Length(Data);
      BufMin:=Header.BytesPerLine*2;  { one input line may need up to this count of bytes }
      SetLength(InBuffer, BufMin*8);
      BufStart:=1;
      BufEnd:=1;
      for J:=1 to YSize do
       begin
        Dec(ScanLine, ScanW);  { stores as bottom-up, 4-bytes aligned data }

         { fills in the input buffer as needed }
        if BufEnd-BufStart <= BufMin then
         begin
           { moves any remaining data back to the beginning }
          Move(InBuffer[BufStart], InBuffer[1], BufEnd-BufStart);
          BufEnd:=BufEnd+1-BufStart;
          BufStart:=1;
           { loads data }
          I:=Length(InBuffer)+1-BufEnd;
          if I>Taille then I:=Taille;
          F.ReadBuffer(InBuffer[BufEnd], I);
          Inc(BufEnd, I);
          Dec(Taille, I);
         end;

         { decodes the line }
        I:=0;
        while I<Header.BytesPerLine do
         begin
          if BufStart=BufEnd then
           Raise EErrorFmt(5509, [31]);
          Byte1:=Ord(InBuffer[BufStart]);
          Inc(BufStart);
          if Byte1<$C0 then
           begin
            ScanLine[I]:=Chr(Byte1);
            Inc(I);
           end
          else
           begin
            K:=Byte1 and not $C0;   { repeat count }
            if I+K>Header.BytesPerLine then
             Raise EErrorFmt(5509, [32]);
            if BufStart=BufEnd then
             Raise EErrorFmt(5509, [31]);
            Byte2:=Ord(InBuffer[BufStart]);
            Inc(BufStart);
            for L:=I to I+K-1 do
             ScanLine[L]:=Chr(Byte2);
            Inc(I,K);
           end;
         end;
        while I<ScanW do
         begin
          ScanLine[I]:=#0;  { fills with zeroes }
          Inc(I);
         end;
        ProgresTravail;
       end;
      Specifics.Add(Data);  { "Data=xxxxx" }

       { reads the palette }
      F.Seek(Taille+1, 1);  { skips remaining data if any (should not) }
      Data:=Spec2;
      SetLength(Data, Length(Spec2)+pcxTaillePalette);
      F.ReadBuffer(Data[Length(Spec2)+1], pcxTaillePalette);
      SpecificsAdd(Data);  { "Pal=xxxxx" }
      finally FinTravail; end;
     end;
 else inherited;
 end;
end;

procedure QPcx.Enregistrer(Info: TInfoEnreg1);
var
 Header: TPcxHeader;
 Size: TPoint;
 Data: String;
 ScanW, J, K: Integer;
 ScanLine, P, EndOfLine: PChar;
 Byte1: Byte;
 OutBuffer: String;
begin
 with Info do case Format of
  1: begin  { as stand-alone file }
      NotTrueColor;  { FIXME }
      FillChar(Header, SizeOf(Header), 0);
      Header.Signature:=pcxSignature;
      Size:=GetSize;
      DebutTravail(5449, Size.Y); try
      Header.Xmax:=Size.X-1;
      Header.Ymax:=Size.Y-1;
      Header.hres:=Size.X;   { why not, it's how Quake 2 .pcx are made }
      Header.vres:=Size.Y;   { idem }
      Header.ColorPlanes:=pcxColorPlanes;
      Header.BytesPerLine:=(Size.X+1) and not 1;
      Header.PaletteType:=2;  { idem }
      F.WriteBuffer(Header, SizeOf(Header));

       { writes the image data }
      Data:=GetSpecArg('Image1');
      ScanW:=(Size.X+3) and not 3;
      if Length(Data)-Length('Image1=') <> ScanW*Size.Y then
       Raise EErrorFmt(5534, ['Image1']);
      ScanLine:=PChar(Data)+Length(Data);
      for J:=1 to Size.Y do
       begin
        Dec(ScanLine, ScanW);   { image is bottom-up }
        OutBuffer:='';
        P:=ScanLine;
        EndOfLine:=P+Header.BytesPerLine;
        while P<EndOfLine do
         begin
          Byte1:=Ord(P^);
          Inc(P);
          K:=1;
          while (P<EndOfLine) and (Byte1=Ord(P^)) do
           begin
            Inc(P);
            Inc(K);
           end;
          if (K>1) or (Byte1>=$C0) then
           begin  { uses the run-length format }
            while K>$3F do  { too many bytes }
             begin
              OutBuffer:=OutBuffer+#$FF+Chr(Byte1);
              Dec(K,$3F);
             end;
            OutBuffer:=OutBuffer+Chr($C0 or K)+Chr(Byte1);
           end
          else  { direct encoding }
           OutBuffer:=OutBuffer+Chr(Byte1);
         end;
        F.WriteBuffer(OutBuffer[1], Length(OutBuffer));
        ProgresTravail;
       end;

       { writes the palette }
      Byte1:=pcxPalette256;
      F.WriteBuffer(Byte1, 1);
      Data:=GetSpecArg('Pal');
      if Length(Data)-Length('Pal=') < pcxTaillePalette then
       Raise EErrorFmt(5534, ['Pal']);
      F.WriteBuffer(Data[Length('Pal=')+1], pcxTaillePalette);
      finally FinTravail; end;
     end;
 else inherited;
 end;
end;

 {------------------------}

initialization
  RegisterQObject(QPcx, 'l');
end.
