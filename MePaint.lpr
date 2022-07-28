program MePaint;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
          {$ENDIF} {$IFDEF HASAMIGA}
  athreads,
          {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  Unit2,
  Tools { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(Tfrmmain, frmmain);
  Application.CreateForm(TfrmNew, frmNew);
  Application.Run;
end.
