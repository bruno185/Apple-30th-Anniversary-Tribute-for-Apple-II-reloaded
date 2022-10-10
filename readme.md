# Delphi program to convert an image to data to be used in an Apple II program

The Apple II program written by J.B. Langston, is here :
https://gist.github.com/jblang/5b9e9ba7e6bbfdc64ad2a55759e401d5
and in this guthub

## Credits

- J.B. Langston
- Apple 30th Anniversary Tribute for Apple II by Dave Schmenk
- Original at https://www.applefritter.com/node/24600#comment-60100

## Usage

This archive contains a disk image to be used it with Applewin or your favourite Apple II emulator.

- Boot a230th.po image disk
- type brun a230TH

But you can also use your own image :

1/ Delphi program :
Prepare a BMP image file, 40 x 23 pixels, 4 bit / pixel.
Run the Delphi program in \Delphi\Win32\Release\
Drag and drop the BMP file over the window.
Clic Convert button.
A text file is created.

2/ Apple II program (assembly language) :
Copy data of the text file at the end of program source a230th.s, in "IMAGE" section.
You can replace the existing data.
Add a "00" byte
Add a title :

- first, a byte for the length of the title + 1
- then, bytes of the title
  Add a "00" byte

See a230th.s for an example.

Compile le program with Merlin32
Copy produced code to an image disk with Applecommander
Boot image disk with Applewin
Start program with "brun" command

## Requirements to compile and run

Here is my configuration:

- Visual Studio Code with 2 extensions :

-> [Merlin32 : 6502 code hightliting](marketplace.visualstudio.com/items?itemName=olivier-guinart.merlin32)

-> [Code-runner : running batch file with right-clic in VS Code.](marketplace.visualstudio.com/items?itemName=formulahendry.code-runner)

- [Merlin32 cross compiler](brutaldeluxe.fr/products/crossdevtools/merlin)

- [Applewin : Apple IIe emulator](github.com/AppleWin/AppleWin)

- [Applecommander ; disk image utility](applecommander.sourceforge.net)

- [Ciderpress ; disk image utility](a2ciderpress.com)

Note :
DoMerlin.bat puts all things together. It needs a path to Merlin32 directory, to Applewin, and to Applecommander.
DoMerlin.bat is to be placed in project directory.
It compile source (\*.s) with Merlin32, copy 6502 binary to a disk image (containg ProDOS), and launch Applewin with this disk in S1,D1.

## Todo

- import any format image
