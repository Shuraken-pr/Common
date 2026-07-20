unit uSkinHelper;

interface

uses
  Vcl.Forms, System.Classes,
  cxLookAndFeels,
  dxSkinsForm, dxLayoutLookAndFeels;

/// <summary>Применить скин к RootLookAndFeel формы (и её Ribbon при наличии).</summary>
procedure ApplySkinToForm(AForm: TForm; const ASkinName: string;
  ANativeStyle: Boolean; ARibbon: TObject = nil);

/// <summary>
/// Синхронизировать центральный TdxSkinController и TdxLayoutSkinLookAndFeel
/// в DataModule. Используется для скининга TdxLayoutControl.
/// </summary>
procedure ApplySkinToDataModule(ADM: TDataModule;
  ASkinController: TdxSkinController;
  ALayoutSkinLookAndFeel: TdxLayoutSkinLookAndFeel;
  const ASkinName: string; ANativeStyle: Boolean);

implementation

uses
  dxRibbon;  // для приведения ARibbon к TdxRibbon

procedure ApplySkinToForm(AForm: TForm; const ASkinName: string;
  ANativeStyle: Boolean; ARibbon: TObject = nil);
var
  Ribbon: TdxRibbon;
begin
  if ASkinName = '' then Exit;
  RootLookAndFeel.BeginUpdate;
  try
    RootLookAndFeel.SkinName := ASkinName;
    RootLookAndFeel.NativeStyle := ANativeStyle;
  finally
    RootLookAndFeel.EndUpdate;
  end;
  if Assigned(ARibbon) and (ARibbon is TdxRibbon) then
  begin
    Ribbon := TdxRibbon(ARibbon);
    Ribbon.ColorSchemeName := ASkinName;
  end;
end;

procedure ApplySkinToDataModule(ADM: TDataModule;
  ASkinController: TdxSkinController;
  ALayoutSkinLookAndFeel: TdxLayoutSkinLookAndFeel;
  const ASkinName: string; ANativeStyle: Boolean);
begin
  if ASkinName = '' then Exit;
  if Assigned(ASkinController) then
  begin
    ASkinController.SkinName := ASkinName;
    ASkinController.NativeStyle := ANativeStyle;
  end;
  if Assigned(ALayoutSkinLookAndFeel) then
  begin
    ALayoutSkinLookAndFeel.LookAndFeel.NativeStyle := ANativeStyle;
    ALayoutSkinLookAndFeel.LookAndFeel.SkinName := ASkinName;
  end;
end;

end.
