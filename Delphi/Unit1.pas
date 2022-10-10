// Convert a BMP file into data
// to be used in an Apple assembly language program
// written by J.B. Langston
// https://gist.github.com/jblang/5b9e9ba7e6bbfdc64ad2a55759e401d5
//
// This Apple II program displays this image in text mode.
// Text mode on Apple II : 24 lines of 40 chars, bottom line is used to title the image.
// So resolution is 40 x 23

// Each pixel of the valid BMP file is run length encoded,
// accordingly to algorithm used in Apple II program :
// 1st nibble is length, 2nd nibble is value.


// Bruno Z.
// august 2022

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ShellApi, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { Déclarations privées }
    procedure WMDropFiles(var msg : TMessage); message WM_DROPFILES;
  public
    { Déclarations publiques }
  end;

  bytefile = file of Byte;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure doread(var f: bytefile; n : integer);
var
  i : integer;
  c : byte;
begin
  for i := 1 to n do read(f,c);
end;

function readint4(var f: bytefile) : integer;
var
  a,b,c,d : byte;
begin
  read(f,a);
  read(f,b);
  read(f,c);
  read(f,d);
  readint4 := a+b*256+c*256*256+d*256*256*256;
end;

function readint2(var f: bytefile) : integer;
var
  a,b : byte;
begin
  read(f,a);
  read(f,b);
  readint2 := a+b*256;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  filin : bytefile;
  filout : textfile;
  temp,i,j : integer;
  b, bhi,blo,l,val : byte;
  line : array [0..39] of byte;
  written : integer;
  bw : integer;
  sa : array [1..23] of string;
  errors : integer;


  procedure Header;
  begin
    try
      if readint2(filin) = 19778 then
      memo1.Lines.Add('==> Signature OK' )
      else
      begin
        memo1.Lines.Add('==> Bad signature!' ) ;
        errors := errors + 1;
      end;

      temp := readint4(filin);
      memo1.Lines.Add('Total size : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');

      Doread(filin,4); // reserved

      temp := readint4(filin);
      memo1.Lines.Add('Image offset  : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');

      Doread(filin,4); // entete

      temp := readint4(filin);

      if temp = 40 then
      memo1.Lines.Add('==> Width OK : ' + IntToStr(temp)+ ' pixels ($' + IntToHex(temp,1)+')') else
      begin
        memo1.Lines.Add('==> Bad width !  ' + IntToStr(temp)+ ' pixels ($' + IntToHex(temp,1)+'');
        errors := errors + 1;
      end;

      temp := readint4(filin);
      If temp = 23 then memo1.Lines.Add('==> Heigth OK : ' + IntToStr(temp)+ ' pixels  ($' + IntToHex(temp,1)+')')
      else
      begin
        memo1.Lines.Add('==> Bad heigth ! ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
        errors := errors + 1;
      end;

      Doread(filin,2); // layers (always 1)

      temp := readint2(filin);
      if temp = 4 then memo1.Lines.Add('==> Bits/pixel OK : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')')
      else
      begin
        memo1.Lines.Add('==> Bad bits/pixel ! : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
        errors := errors + 1;
      end;

      temp := readint4(filin);
      memo1.Lines.Add('Compression : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
      temp := readint4(filin);
      memo1.Lines.Add('Image size : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
      temp := readint4(filin);
      memo1.Lines.Add('H res. : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
      temp := readint4(filin);
      memo1.Lines.Add('V res. : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
      temp := readint4(filin);
      memo1.Lines.Add('Palette colors : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
      temp := readint4(filin);
      memo1.Lines.Add('Imp. colors : ' + IntToStr(temp)+ ' ($' + IntToHex(temp,1)+')');
      doread(filin,64);    // palette
      except
    end;   // try
  end;

 function Init : boolean;
 var
  j:integer;
 begin
  memo1.Clear;
  Init := true;
  try
    assignfile(filin,Edit1.text);
    reset(filin);

    assignfile(filout,Edit2.text);
    rewrite(filout);
  except
  on Exception do
    begin
    Init := false;
    memo1.Clear;
    memo1.Lines.Add('Error !') ;
    Exit;
    end;
  end;

  bw := 0;
  for j:=1 to 23 do
    sa[j] := '';

  // Header
  memo1.Lines.Add('BMP Header :');
  Header;

 end;


procedure DoWriteByte;
begin
  sa[j]:= sa[j] + IntToHex(b,2);
  written :=  written +l;
end;

  // START HERE
begin
  //--------- init. ---------
  errors := 0;
  if not(Init) then exit;
  if errors > 0 then
  begin
    memo1.Lines.Add('');
    memo1.Lines.Add(' >>> Errors in file, must be a valid 40 by 23 pixels, 4 bits/pixel BMP file <<<') ;
    closefile(filout);
    DeleteFile(Edit2.Text) ;
    closefile(filin);
    Exit;
  end
  else
  begin
    memo1.Lines.Add('');
    memo1.Lines.Add('BMP file seems OK');
    memo1.Lines.Add('Writting data...');
  end;

  // Data
  memo1.Lines.Add('');
  memo1.Lines.Add('Data :');
    //--------- starts here ---------
  try

  for j := 1 to 23  do  // 23 lines
  begin
    for i := 0 to 19  do    // 20 bytes = 40 pixels
    begin
      read(filin,b);
      bhi := b shr 4;  // 1st pixel  (= hi nibble)
      blo := b and 15 ;  // 2nd pixel ((= low nibble)
      // populate line array
      line[2*i] := bhi;
      line[2*i+1] := blo;
    end;

    l := 0;
    val := 0;
    written := 0;

    for i := 0 to 39  do
    begin

      // Length = 0
      //
      if l = 0 then
      begin
        l := 1;
        val := line[i];
      end

      else

      // Length > 0
      //
      begin
        if l =15 then  // max length = 15 (one nibble)
        begin
          // write previous data
          b := l*16 + val;
          DoWriteByte;
          // init. new data
          l:=1;
          val := line[i];
        end

        else

        if (val = line [i]) then    // same value as previous data
        begin
          // update length
          l := l +1;
        end

        else

        begin    // new value
          // write previous data
          b := l*16 + val;
          DoWriteByte;
          // init. new data
          l := 1;
          val := line[i];
        end;
      end;

    end;   // inner loop

    // write not written remaining data
      b := l*16 + val;
      DoWriteByte;
      memo1.Lines.Add('Line #'+IntToStr(j)+' : '+IntToStr(written)+' pixels');
  end;  // outter loop

  closefile(filin);

  // output data to file
  j := 23  ;   // 23 downto 1 : BMP files start with bottom line and up
  bw := 0;
  repeat
    i := 1;
    repeat
      if bw mod 4 = 0 then    //  new line every 4 hex number
      begin
        writeln(filout);
        write(filout,' db $');
        write(filout, sa[j][i]);
        inc(i);
        write(filout, sa[j][i]);
        inc(i);

      end
      else
      begin
        write(filout,',$');   // add a hex number on the same line
        write(filout, sa[j][i]);
        inc(i);
        write(filout, sa[j][i]);
        inc(i);
      end;
      inc (bw);
    until (i>length(sa[j]));
    dec(j);  // next line of pixels
  until (j = 0);

  closefile(filout);
  memo1.Lines.Add('');
  memo1.Lines.Add('End.');

  except
    begin
     closefile(filout);
     closefile(filin);
     memo1.Clear;
     memo1.Lines.Add('Error !');
    end;

  end; // try
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, true);
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

// drag n drop file
procedure TForm1.WMDropFiles(var msg : TMessage);
var
  hand: THandle;
  nbFich, i : integer;
  buf:array[0..254] of Char;
  begin
    hand:=msg.wParam;
    nbFich:= DragQueryFile(hand, 4294967295, buf, 254);
    for i:= 0 to nbFich - 1 do
    begin
      DragQueryFile(hand, i, buf, 254);
      Edit1.Text := buf;
      Edit2.Text := buf+'.txt';
      Memo1.Clear;
    end;
    DragFinish(hand);
end;

end.
