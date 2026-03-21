unit vstHelper;

interface

uses
  System.SysUtils,
  System.Classes,
  VirtualTrees,
  Generics.Collections;

type
  TBase = class
  private
    FNode: PVirtualNode;
  public
    constructor Create; virtual;
    property Node: PVirtualNode read FNode;
  end;

  TBaseClass = class of TBase;

  TBaseRecord = class(TBase)
    class function CreateAsBase(ConcreateClass: TBaseClass): TBase;
    class function CreateClass<T: TBase>: T;
  end;

  TVSTHelper = class helper for TBaseVirtualTree
    function Add<T: TBaseRecord>(ANode: PVirtualNode = nil): T;
    function Obj<T: TBaseRecord>(ANode: PVirtualNode): T;
    function CurrentObj<T: TBaseRecord>: T;
  end;

implementation

{ TBase }

constructor TBase.Create;
begin
  FNode := nil;
end;

{ TBaseRecord }

class function TBaseRecord.CreateAsBase(ConcreateClass: TBaseClass): TBase;
begin
  Result := ConcreateClass.Create;
end;

class function TBaseRecord.CreateClass<T>: T;
begin
  Result := CreateAsBase(T) as T;
end;

{ TVSTHelper }

function TVSTHelper.Add<T>(ANode: PVirtualNode): T;
var
  V: PVirtualNode;
  obj: TObject;
begin
  Result := nil;
  V := nil;
  if ANode = nil then
  begin
    V := Self.AddChild(self.RootNode);
    T(GetNodeData(V)^) := TBaseRecord.CreateClass<T>;
  end
    else
  begin
    obj := TObject(GetNodeData(ANode)^);
    if not (obj is T) then
    begin
      if Assigned(obj) then
        FreeAndNil(obj);
      V := ANode;
      T(GetNodeData(V)^) := TBaseRecord.CreateClass<T>;
    end;
  end;
  if Assigned(V) then
  begin
    Result := T(GetNodeData(V)^);
    Result.FNode := V;
  end;
end;

function TVSTHelper.Obj<T>(ANode: PVirtualNode): T;
var
  obj: TObject;
begin
  Result := nil;
  if ANode <> nil then
  begin
    obj := TObject(GetNodeData(ANode)^);
    if Assigned(obj) and (obj is T) then
      Result := T(obj);
  end;
end;

function TVSTHelper.CurrentObj<T>: T;
begin
  Result := obj<T>(FocusedNode);
end;

end.
