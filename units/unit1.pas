unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, LCLIntf, LCLType, Unit2, Tools, Clipbrd, Menus;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    Bevel1: TBevel;
    cmdToolAirBrush: TSpeedButton;
    cmdToolLines: TSpeedButton;
    cmdUndo: TSpeedButton;
    cmdPaste: TSpeedButton;
    cmdCopy: TSpeedButton;
    cmdSwapColors: TButton;
    cmdOpen: TSpeedButton;
    cmdSave: TSpeedButton;
    cmdToolLine: TSpeedButton;
    cmdToolRect: TSpeedButton;
    cmdToolCircle: TSpeedButton;
    cmdToolRound: TSpeedButton;
    cmdToolTriangle: TSpeedButton;
    cboLineStyle: TComboBox;
    cboPenSize: TComboBox;
    cmdToolFill: TSpeedButton;
    cboBrushStyle: TComboBox;
    cmdToolPicker: TSpeedButton;
    cmdToolErase: TSpeedButton;
    FirstColor: TColorButton;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    ImgDrawArea: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    mnuFlipBoth: TMenuItem;
    mnuFlipH: TMenuItem;
    mnuFlipV: TMenuItem;
    mnuRotate: TMenuItem;
    mnuImage: TMenuItem;
    mnuInvertImage: TMenuItem;
    mnuFile: TMenuItem;
    mnuFilters: TMenuItem;
    mnuNew: TMenuItem;
    mnuOpen: TMenuItem;
    mnuSave: TMenuItem;
    mnuExit: TMenuItem;
    mnuLighten: TMenuItem;
    mnuDarken: TMenuItem;
    Separator2: TMenuItem;
    Separator1: TMenuItem;
    SecondColor: TColorButton;
    GroupBox1: TGroupBox;
    ImgColor: TImage;
    ScrollBox1: TScrollBox;
    cmdToolPencil: TSpeedButton;
    cmdNew: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure cboBrushStyleSelect(Sender: TObject);
    procedure cboLineStyleSelect(Sender: TObject);
    procedure cboPenSizeSelect(Sender: TObject);
    procedure cmdCopyClick(Sender: TObject);
    procedure cmdNewClick(Sender: TObject);
    procedure cmdOpenClick(Sender: TObject);
    procedure cmdPasteClick(Sender: TObject);
    procedure cmdSaveClick(Sender: TObject);
    procedure cmdSwapColorsClick(Sender: TObject);
    procedure cmdToolAirBrushClick(Sender: TObject);
    procedure cmdToolEraseClick(Sender: TObject);
    procedure cmdToolRoundClick(Sender: TObject);
    procedure cmdUndoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ImgColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ImgColorMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure ImgColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ImgDrawAreaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ImgDrawAreaMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure ImgDrawAreaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ImgDrawAreaPaint(Sender: TObject);
    procedure mnuDarkenClick(Sender: TObject);
    procedure mnuFlipBothClick(Sender: TObject);
    procedure mnuFlipHClick(Sender: TObject);
    procedure mnuFlipVClick(Sender: TObject);
    procedure mnuInvertImageClick(Sender: TObject);
    procedure mnuLightenClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuRotateClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
  private
    procedure NewDrawing(Sender: TObject; W, H: integer; Background: TColor);
    procedure OpenDrawing(Sender: TObject; TheBimap: TBitmap);
    procedure AirBrush(X, Y: integer);
    procedure SetPenStyle(ps: TPenStyle);
    function GetPixelColor: TColor;
    procedure ImageLightenDarken(Sender: TObject; Value: integer);
    procedure ImageInvert(Sender: TObject);
    procedure UpdateUndo;
    procedure Rotate90(Sender: TObject; Bitmap: TBitmap);
    procedure FlipImage(Sender: TObject; TheBitmap: TBitmap; FlipDir: integer);
  public

  end;

var
  frmmain: Tfrmmain;
  ThePaintCanvas: TBitmap;
  IsDrawing: boolean;
  IsPickingColor: boolean;
  PicColorButton: TMouseButton;
  DrawingButton: TMouseButton;
  pDrawStyle: TBrushStyle;
  pOldPenSize: integer;
  RoundRadius: integer;
  pEraseSize: integer;
  OldX, OldY: integer;
  UndoObj: TBitmap;

implementation

{$R *.lfm}

{ Tfrmmain }

procedure Tfrmmain.FlipImage(Sender: TObject; TheBitmap: TBitmap; FlipDir: integer);
var
  src, dest: TRect;
  bmp: TBitmap;
  w, h: integer;
begin
  w := TheBitmap.Width;
  h := TheBitmap.Height;
  dest := bounds(0, 0, w, h);

  case FlipDir of
    0:
    begin
      src := rect(0, h - 1, w - 1, 0); // Vertical flip
    end;
    1:
    begin
      src := rect(w - 1, 0, 0, h - 1); // Horizontal flip
    end;
    2:
    begin
      src := rect(w - 1, h - 1, 0, 0); // Both flip
    end;
  end;

  bmp := TBitmap.Create;
  bmp.PixelFormat := pf24bit;
  bmp.SetSize(w, h);
  bmp.Canvas.Draw(0, 0, TheBitmap);
  TheBitmap.Canvas.CopyRect(dest, bmp.Canvas, src);
  bmp.Free;

  ImgDrawAreaPaint(Sender);
end;

procedure Tfrmmain.Rotate90(Sender: TObject; Bitmap: TBitmap);
type
  TRGBArray = array[0..0] of TRGBTriple;
  pRGBArray = ^TRGBArray;
var
  oldRows, oldColumns: integer;
  rowIn, rowOut: pRGBArray;
  bmp: TBitmap;
begin
  // Create tmp bitmap
  bmp := TBitmap.Create;

  // Adjust tmp bitmap size and pixelformat (rotate 90 = W-> and H->W)
  with bmp do
  begin
    Width := Bitmap.Height;
    Height := Bitmap.Width;
    PixelFormat := Bitmap.PixelFormat;
  end;

  for oldColumns := 0 to Bitmap.Width - 1 do
  begin
    rowOut := bmp.ScanLine[oldColumns];

    // Fastest way is reading bit, so we work on one line in the new bitmap ata time
    for oldRows := 0 to Bitmap.Height - 1 do
    begin
      rowIn := Bitmap.ScanLine[oldRows];
      rowOut[oldRows] := rowIn[Bitmap.Width - oldColumns - 1];
    end;
  end;

  // Copy bitmap to source and free tmp bitmap
  bitmap.Assign(bmp);
  bmp.Free;

  ImgDrawAreaPaint(Sender);
end;

function FixRgb(Value: integer): integer;
var
  v: integer;
begin
  v := Value;
  if v < 0 then v := 0;
  if v > 255 then v := 255;
  Result := v;
end;

procedure Tfrmmain.UpdateUndo;
begin
  UndoObj.Assign(ThePaintCanvas);
  cmdUndo.Enabled := True;
end;

procedure Tfrmmain.ImageInvert(Sender: TObject);
var
  X, Y: integer;
  C: longint;
  R, G, B: integer;
begin

  R := 0;
  G := 0;
  B := 0;

  for X := 0 to ThePaintCanvas.Width - 1 do
  begin
    for Y := 0 to ThePaintCanvas.Height - 1 do
    begin
      //Get color
      C := ColorToRGB(ThePaintCanvas.Canvas.Pixels[X, Y]);
      //Get rgb vals
      R := 255 - GetRValue(C);
      G := 255 - GetGValue(C);
      B := 255 - GetBValue(C);
      //Update pixels
      ThePaintCanvas.Canvas.Pixels[X, Y] := RGB(R, G, B);
    end;
  end;

  //Update
  ImgDrawAreaPaint(Sender);

end;

procedure Tfrmmain.ImageLightenDarken(Sender: TObject; Value: integer);
var
  X, Y: integer;
  C: longint;
  R, G, B: integer;
begin

  R := 0;
  G := 0;
  B := 0;

  for X := 0 to ThePaintCanvas.Width - 1 do
  begin
    for Y := 0 to ThePaintCanvas.Height - 1 do
    begin
      //Get color
      C := ColorToRGB(ThePaintCanvas.Canvas.Pixels[X, Y]);
      //Get rgb vals
      R := FixRgb(GetRValue(C) + Value);
      G := FixRgb(GetGValue(C) + Value);
      B := FixRgb(GetBValue(C) + Value);
      //Update pixels
      ThePaintCanvas.Canvas.Pixels[X, Y] := RGB(R, G, B);
    end;
  end;

  //Update
  ImgDrawAreaPaint(Sender);
end;

procedure Tfrmmain.AirBrush(X, Y: integer);
var
  pColor: TColor;
  R1, R2, R3: integer;
begin
  Randomize;
  //Make some random values
  R1 := Random(2);
  R2 := Random(6);
  R3 := Random(8);

  //get color to use.
  pColor := GetPixelColor;

  ImgDrawArea.Canvas.Pixels[x + r1, y + r2] := pColor;
  ImgDrawArea.Canvas.Pixels[x + r2, y + r1] := pColor;
  ImgDrawArea.Canvas.Pixels[x - r3, y + r2] := pColor;
  ImgDrawArea.Canvas.Pixels[x - r2, y - r3] := pColor;
  ImgDrawArea.Canvas.Pixels[X - r2, y - r1] := pColor;
  ImgDrawArea.Canvas.Pixels[x + r3, y - r2] := pColor;

  ThePaintCanvas.Canvas.Pixels[x + r1, y + r2] := pColor;
  ThePaintCanvas.Canvas.Pixels[x + r2, y + r1] := pColor;
  ThePaintCanvas.Canvas.Pixels[x - r3, y + r2] := pColor;
  ThePaintCanvas.Canvas.Pixels[x - r2, y - r3] := pColor;
  ThePaintCanvas.Canvas.Pixels[X - r2, y - r1] := pColor;
  ThePaintCanvas.Canvas.Pixels[x + r3, y - r2] := pColor;
end;

function Tfrmmain.GetPixelColor: TColor;
begin
  if DrawingButton = mbLeft then
  begin
    Result := FirstColor.ButtonColor;
  end;

  if DrawingButton = mbRight then
  begin
    Result := SecondColor.ButtonColor;
  end;
end;

procedure Tfrmmain.SetPenStyle(ps: TPenStyle);
begin
  ImgDrawArea.Canvas.Pen.Style := ps;
  ThePaintCanvas.Canvas.Pen.Style := ps;
end;

procedure Tfrmmain.OpenDrawing(Sender: TObject; TheBimap: TBitmap);
begin
  // then start fresh
  if ThePaintCanvas <> nil then
    ThePaintCanvas.Destroy;

  ThePaintCanvas := TBitmap.Create;
  ThePaintCanvas.SetSize(TheBimap.Width, TheBimap.Height);
  ThePaintCanvas.Canvas.Draw(0, 0, TheBimap);

  ImgDrawAreaPaint(Sender);
end;

procedure Tfrmmain.NewDrawing(Sender: TObject; W, H: integer; Background: TColor);
begin

  // then start fresh
  if ThePaintCanvas <> nil then
    ThePaintCanvas.Destroy;

  ThePaintCanvas := TBitmap.Create;

  ThePaintCanvas.PixelFormat := pf24bit;
  ThePaintCanvas.SetSize(W, H);
  ThePaintCanvas.Canvas.Brush.Color := Background;
  ThePaintCanvas.Canvas.FillRect(0, 0, W, H);

  ThePaintCanvas.Canvas.Brush.Style := bsClear;
  ImgDrawArea.Canvas.Brush.Style := bsClear;

  ThePaintCanvas.Canvas.Pen.Color := FirstColor.ButtonColor;
  ThePaintCanvas.Canvas.Pen.Width := 1;

  ImgDrawAreaPaint(Sender);
end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  UndoObj := TBitmap.Create;
  pDrawStyle := bsClear;
  NewDrawing(Sender, 320, 300, clWhite);
end;

procedure Tfrmmain.cboLineStyleSelect(Sender: TObject);
begin
  case cboLineStyle.ItemIndex of
    0:
    begin
      SetPenStyle(psSolid);
    end;
    1:
    begin
      SetPenStyle(psDot);
    end;
    2:
    begin
      SetPenStyle(psDash);
    end;
    3:
    begin
      SetPenStyle(psDashDot);
    end;
    4:
    begin
      SetPenStyle(psDashDotDot);
    end;
  end;
end;

procedure Tfrmmain.cboBrushStyleSelect(Sender: TObject);
begin
  case cboBrushStyle.ItemIndex of
    0:
    begin
      pDrawStyle := bsHorizontal;
    end;
    1:
    begin
      pDrawStyle := bsVertical;
    end;
    2:
    begin
      pDrawStyle := bsFDiagonal;
    end;
    3:
    begin
      pDrawStyle := bsBDiagonal;
    end;
    4:
    begin
      pDrawStyle := bsCross;
    end;
    5:
    begin
      pDrawStyle := bsDiagCross;
    end;
    6:
    begin
      pDrawStyle := bsSolid;
    end;
    7:
    begin
      pDrawStyle := bsClear;
    end;
  end;
end;

procedure Tfrmmain.cboPenSizeSelect(Sender: TObject);
var
  sSize: string;
begin
  sSize := cboPenSize.Items[cboPenSize.ItemIndex];
  ImgDrawArea.Canvas.Pen.Width := StrToInt(sSize);
  ThePaintCanvas.Canvas.Pen.Width := StrToInt(sSize);
end;

procedure Tfrmmain.cmdCopyClick(Sender: TObject);
begin
  Clipboard.Assign(ThePaintCanvas);
end;

procedure Tfrmmain.cmdNewClick(Sender: TObject);
var
  frm: TfrmNew;
begin
  frm := TfrmNew.Create(self);
  Tools.ButtonPress := 0;
  frm.ShowModal;
  if Tools.ButtonPress = 1 then
  begin
    NewDrawing(Sender, Tools.ImgWidth, Tools.ImgHeight, Tools.ImgBkColor);
  end;

  cmdundo.Enabled := False;
end;

procedure Tfrmmain.cmdOpenClick(Sender: TObject);
var
  od: TOpenDialog;
  jpg: TJPEGImage;
  bmp: TBitmap;
begin

  od := TOpenDialog.Create(self);
  od.Title := 'Open Picture';
  od.Filter := 'Bitmap Files(*.bmp)|*.bmp|JPEG Files(*.jpg)|*.jpg';
  //Create bitmap object to hold the source image.
  bmp := TBitmap.Create;

  if od.Execute then
  begin
    if od.FilterIndex = 2 then
    begin
      bmp := TBitmap.Create;
      jpg := TJPEGImage.Create;
      jpg.LoadFromFile(od.FileName);
      bmp.PixelFormat := pf24bit;
      bmp.SetSize(jpg.Width, jpg.Height);
      bmp.Assign(jpg);
      jpg.Free;
    end
    else
    begin
      bmp.LoadFromFile(od.FileName);
    end;
    //Open drawing
    OpenDrawing(Sender, bmp);
    bmp.Free;
  end;
  od.Free;
  cmdundo.Enabled := False;
end;

procedure Tfrmmain.cmdPasteClick(Sender: TObject);
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  if ClipBoard.HasFormat(CF_Bitmap) then
  begin
    //Load bitmap from clipbard.
    bmp.LoadFromClipboardFormat(CF_Bitmap);
    //Assign the bitmap obj to the ThePaintCanvas
    ThePaintCanvas.Assign(bmp);
    //Refresh
    ImgDrawAreaPaint(Sender);

    bmp.Free;
  end;
end;

procedure Tfrmmain.cmdSaveClick(Sender: TObject);
var
  sd: TSaveDialog;
  jpg: TJPEGImage;
begin
  sd := TSaveDialog.Create(self);
  sd.Title := 'Save Picture';
  sd.Filter := 'Bitmap Files(*.bmp)|*.bmp|JPEG Files(*.jpg)|*.jpg';
  sd.DefaultExt := 'bmp';

  if sd.Execute then
  begin

    if sd.FilterIndex = 2 then
    begin
      jpg := TJPEGImage.Create;
      jpg.CompressionQuality := 99;
      jpg.Assign(ThePaintCanvas);
      jpg.SaveToFile(sd.FileName);
      jpg.Free;
    end
    else
    begin
      ThePaintCanvas.SaveToFile(sd.FileName);
    end;
  end;
  sd.Free;

end;

procedure Tfrmmain.cmdSwapColorsClick(Sender: TObject);
var
  tmp: TColor;
begin
  tmp := SecondColor.ButtonColor;
  SecondColor.ButtonColor := FirstColor.ButtonColor;
  FirstColor.ButtonColor := tmp;
end;

procedure Tfrmmain.cmdToolAirBrushClick(Sender: TObject);
begin

end;

procedure Tfrmmain.cmdToolEraseClick(Sender: TObject);
var
  sPenSize: string;
  code: integer;
begin
  sPenSize := trim(InputBox('Eraser', 'Size', '16'));

  if sPenSize <> '' then
  begin
    Val(sPenSize, pEraseSize, code);
  end;

  if code = 0 then
  begin
    if pEraseSize = 0 then pEraseSize := 16;
  end;

end;

procedure Tfrmmain.cmdToolRoundClick(Sender: TObject);
var
  sRoundRect: string;
  code: integer;
begin
  sRoundRect := trim(InputBox('Round Rectangle', 'Radius', '12'));

  if sRoundRect <> '' then
  begin
    Val(sRoundRect, RoundRadius, code);
  end;

  if code = 0 then
  begin
    if RoundRadius = 0 then RoundRadius := 12;
  end;
end;

procedure Tfrmmain.cmdUndoClick(Sender: TObject);
begin
  ThePaintCanvas.Assign(UndoObj);
  ImgDrawAreaPaint(Sender);
  cmdUndo.Enabled := False;
end;

procedure Tfrmmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ThePaintCanvas.Free;
end;

procedure Tfrmmain.ImgColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  IsPickingColor := True;
  PicColorButton := Button;
  ImgColorMouseMove(Sender, shift, x, y);
end;

procedure Tfrmmain.ImgColorMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  if IsPickingColor then
  begin
    if PicColorButton = mbLeft then
    begin
      FirstColor.ButtonColor := ImgColor.Canvas.Pixels[X, Y];
    end;
    if PicColorButton = mbRight then
    begin
      SecondColor.ButtonColor := ImgColor.Canvas.Pixels[X, Y];
    end;
  end;
end;

procedure Tfrmmain.ImgColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  IsPickingColor := False;
end;

procedure Tfrmmain.ImgDrawAreaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  IsDrawing := True;
  DrawingButton := Button;
  //Copy the old picture to UndoObj
  UpdateUndo;

  if DrawingButton = mbLeft then
  begin
    ImgDrawArea.Canvas.Pen.Color := FirstColor.ButtonColor;
    ThePaintCanvas.Canvas.Pen.Color := FirstColor.ButtonColor;
  end;
  if DrawingButton = mbRight then
  begin
    ImgDrawArea.Canvas.Pen.Color := SecondColor.ButtonColor;
    ThePaintCanvas.Canvas.Pen.Color := SecondColor.ButtonColor;
  end;

  OldX := X;
  OldY := Y;
end;

procedure Tfrmmain.ImgDrawAreaMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
var
  pixColor: TColor;
  sRgb: string;
begin
  if x < 0 then x := 0;
  if y < 0 then y := 0;

  pixColor := ImgDrawArea.Canvas.Pixels[X, Y];

  sRgb := ' | RGB (' + IntToStr(GetRValue(pixColor)) + ',' +
    IntToStr(GetGValue(pixColor)) + ',' + IntToStr(GetBValue(pixColor)) + ')';

  StatusBar1.Panels[0].Text := ' X:Y ' + IntToStr(X) + ':' + IntToStr(Y) + sRgb;

  if IsDrawing then
  begin
    if pDrawStyle <> bsClear then
    begin
      ImgDrawArea.Canvas.Brush.Style := pDrawStyle;
      ThePaintCanvas.Canvas.Brush.Style := pDrawStyle;
      ImgDrawArea.Canvas.Brush.Color := GetPixelColor;
    end
    else
    begin
      ImgDrawArea.Canvas.Brush.Style := bsClear;
      ThePaintCanvas.Canvas.Brush.Style := bsClear;
    end;

    //Check what tools are pressed.
    if cmdToolPencil.Down then
    begin
      ImgDrawArea.Canvas.Line(OldX, OldY, X, Y);
      ThePaintCanvas.Canvas.Line(OldX, OldY, X, Y);
      OldY := Y;
      OldX := X;
    end
    else if cmdToolLine.Down then
    begin
      ImgDrawAreaPaint(Sender);
      // we draw a preview line
      ImgDrawArea.Canvas.Line(OldX, OldY, X, Y);
    end
    else if cmdToolRect.Down then
    begin
      ImgDrawAreaPaint(Sender);
      ImgDrawArea.Canvas.Rectangle(OldX, OldY, X, Y);
    end
    else if cmdToolCircle.Down then
    begin
      ImgDrawAreaPaint(Sender);
      ImgDrawArea.Canvas.Ellipse(OldX, OldY, X, Y);
    end
    else if cmdToolRound.Down then
    begin
      ImgDrawAreaPaint(Sender);
      ImgDrawArea.Canvas.RoundRect(OldX, OldY, X, Y, RoundRadius, RoundRadius);
    end
    else if cmdToolTriangle.Down then
    begin
      ImgDrawAreaPaint(Sender);
      ImgDrawArea.Canvas.Line(OldX, Y, OldX + ((X - OldX) div 2), OldY);
      ImgDrawArea.Canvas.Line(OldX + ((X - OldX) div 2), OldY, X, Y);
      ImgDrawArea.Canvas.Line(OldX, Y, X, Y);
    end
    else if cmdToolErase.Down then
    begin
      pOldPenSize := ThePaintCanvas.Canvas.Pen.Width;

      ImgDrawArea.Canvas.Pen.Width := pEraseSize;
      ThePaintCanvas.Canvas.Pen.Width := pEraseSize;
      ImgDrawArea.Canvas.Pen.Color := clWhite;
      ThePaintCanvas.Canvas.Pen.Color := clWhite;
      ImgDrawArea.Canvas.Line(OldX, OldY, X, Y);
      ThePaintCanvas.Canvas.Line(OldX, OldY, X, Y);
      OldY := Y;
      OldX := X;

      ImgDrawArea.Canvas.Pen.Width := pOldPenSize;
      ThePaintCanvas.Canvas.Pen.Width := pOldPenSize;
    end
    else if cmdToolAirBrush.Down then
    begin
      AirBrush(x, y);
    end
    else if cmdToolLines.Down then
    begin
      ImgDrawArea.Canvas.Line(OldX, OldY, X, Y);
      ThePaintCanvas.Canvas.Line(OldX, OldY, X, Y);
    end;
  end;
end;

procedure Tfrmmain.ImgDrawAreaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  Pixel: TColor;
begin

  if IsDrawing then
  begin
    if pDrawStyle <> bsClear then
    begin
      ThePaintCanvas.Canvas.Brush.Color := GetPixelColor;
    end;

    if cmdToolLine.Down then
    begin
      ThePaintCanvas.Canvas.Line(OldX, OldY, X, Y);
    end
    else if cmdToolRect.Down = True then
    begin
      ThePaintCanvas.Canvas.Rectangle(OldX, OldY, X, Y);
    end
    else if cmdToolCircle.Down then
    begin
      ThePaintCanvas.Canvas.Ellipse(OldX, OldY, X, Y);
    end
    else if cmdToolRound.Down then
    begin
      ThePaintCanvas.Canvas.RoundRect(OldX, OldY, X, Y, RoundRadius, RoundRadius);
    end
    else if cmdToolTriangle.Down then
    begin
      ThePaintCanvas.Canvas.Line(OldX, Y, OldX + ((X - OldX) div 2), OldY);
      ThePaintCanvas.Canvas.Line(OldX + ((X - OldX) div 2), OldY, X, Y);
      ThePaintCanvas.Canvas.Line(OldX, Y, X, Y);
    end
    else if cmdToolFill.Down then
    begin
      Pixel := ThePaintCanvas.Canvas.Pixels[X, Y];
      ThePaintCanvas.Canvas.Brush.Style := pDrawStyle;
      ThePaintCanvas.Canvas.Brush.Color := GetPixelColor;
      ThePaintCanvas.Canvas.FloodFill(X, Y, Pixel, fsSurface);
      ImgDrawAreaPaint(Sender);
    end
    else if cmdToolPicker.Down then
    begin
      if DrawingButton = mbLeft then
      begin
        FirstColor.ButtonColor := ThePaintCanvas.Canvas.Pixels[X, Y];
      end;
      if DrawingButton = mbRight then
      begin
        SecondColor.ButtonColor := ThePaintCanvas.Canvas.Pixels[X, Y];
      end;
    end;
  end;

  IsDrawing := False;
end;

procedure Tfrmmain.ImgDrawAreaPaint(Sender: TObject);
begin
  if ImgDrawArea.Width <> ThePaintCanvas.Width then
  begin
    ImgDrawArea.Width := ThePaintCanvas.Width;
    exit;
  end;
  if ImgDrawArea.Height <> ThePaintCanvas.Height then
  begin
    ImgDrawArea.Height := ThePaintCanvas.Height;
    Exit;
  end;

  ImgDrawArea.Canvas.Draw(0, 0, ThePaintCanvas);

end;

procedure Tfrmmain.mnuDarkenClick(Sender: TObject);
begin
  UpdateUndo;
  ImageLightenDarken(Sender, -25);
end;

procedure Tfrmmain.mnuFlipBothClick(Sender: TObject);
begin
  UpdateUndo;
  FlipImage(Sender, ThePaintCanvas, 2);
end;

procedure Tfrmmain.mnuFlipHClick(Sender: TObject);
begin
  UpdateUndo;
  FlipImage(Sender, ThePaintCanvas, 1);
end;

procedure Tfrmmain.mnuFlipVClick(Sender: TObject);
begin
  UpdateUndo;
  FlipImage(Sender, ThePaintCanvas, 0);
end;

procedure Tfrmmain.mnuInvertImageClick(Sender: TObject);
begin
  UpdateUndo;
  ImageInvert(Sender);
end;

procedure Tfrmmain.mnuLightenClick(Sender: TObject);
begin
  UpdateUndo;
  ImageLightenDarken(Sender, 25);
end;

procedure Tfrmmain.mnuNewClick(Sender: TObject);
begin
  cmdNewClick(Sender);
end;

procedure Tfrmmain.mnuOpenClick(Sender: TObject);
begin
  cmdOpenClick(Sender);
end;

procedure Tfrmmain.mnuRotateClick(Sender: TObject);
begin
  UpdateUndo;
  Rotate90(Sender, ThePaintCanvas);
end;

procedure Tfrmmain.mnuSaveClick(Sender: TObject);
begin
  cmdSaveClick(Sender);
end;

end.
