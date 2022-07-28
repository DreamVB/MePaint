unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, StdCtrls,
  ExtCtrls, Tools;

type

  { TfrmNew }

  TfrmNew = class(TForm)
    Bevel1: TBevel;
    cmdOK: TButton;
    cmdCancel: TButton;
    cmdBackground: TColorButton;
    lblBackground: TLabel;
    lblWidth: TLabel;
    lblHeight: TLabel;
    SpWidth: TSpinEdit;
    SpHeight: TSpinEdit;
    procedure cmdCancelClick(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmNew: TfrmNew;

implementation

{$R *.lfm}

{ TfrmNew }

procedure TfrmNew.FormCreate(Sender: TObject);
begin

end;

procedure TfrmNew.cmdOKClick(Sender: TObject);
begin
  Tools.ButtonPress := 1;
  Tools.ImgBkColor := cmdBackground.ButtonColor;
  Tools.ImgWidth := SpWidth.Value;
  Tools.ImgHeight := SpHeight.Value;
  Close;
end;

procedure TfrmNew.cmdCancelClick(Sender: TObject);
begin
  Tools.ButtonPress := 0;
  Close;
end;

end.
