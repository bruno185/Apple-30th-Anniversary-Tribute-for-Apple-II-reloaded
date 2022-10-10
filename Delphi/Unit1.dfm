object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'BMP to Apple II RLE source'
  ClientHeight = 602
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 192
    Top = 5
    Width = 316
    Height = 13
    Caption = 
      'Drag a BMP file over this window (40 by 23 pixels, 4 bits per pi' +
      'xel)'
  end
  object Label2: TLabel
    Left = 20
    Top = 27
    Width = 54
    Height = 13
    Caption = 'Image file :'
  end
  object Label3: TLabel
    Left = 16
    Top = 54
    Width = 58
    Height = 13
    Caption = 'Output file :'
  end
  object Button1: TButton
    Left = 8
    Top = 132
    Width = 66
    Height = 41
    Caption = 'Convert'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 96
    Top = 78
    Width = 515
    Height = 515
    ScrollBars = ssVertical
    TabOrder = 1
    OnChange = Memo1Change
  end
  object Edit1: TEdit
    Left = 96
    Top = 24
    Width = 515
    Height = 21
    TabOrder = 2
  end
  object Edit2: TEdit
    Left = 96
    Top = 51
    Width = 515
    Height = 21
    TabOrder = 3
  end
end
