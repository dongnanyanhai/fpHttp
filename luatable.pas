unit LuaTable;

//{$mode delphi}

interface

uses
  Classes, SysUtils, Lua, LuaPas;

procedure InitTotableFunc(L: Plua_State);

implementation

uses TypInfo, FileUtil;

// TStrings
procedure ToStrings(L: Plua_State; lStrings: TStrings);
var i:Integer;
begin
    lua_newtable(L);
    if Assigned(lStrings) then
    for i:= 0 to lStrings.Count-1 do begin
      lua_pushnumber(L,i+1);
      lua_pushstring(L,pchar(lStrings[i]));
      lua_rawset(L,-3);
    end;
end;

function ToLuaTable(L: Plua_State): Integer; cdecl;
var obj: TObject;
begin
     obj := GetLuaObject(L, 1);
     if obj.InheritsFrom(TStrings) then
        ToStrings(L, TStrings(obj))
     else
        lua_pushstring(L,'lua-->totable');
     Result := 1;
end;


// OS functions
(*
  faReadOnly  = $00000001;
  faHidden    = $00000002;
  faSysFile   = $00000004;
  faVolumeId  = $00000008;
  faDirectory = $00000010;
  faArchive   = $00000020;
  faSymLink   = $00000040;
  faAnyFile   = $0000003f;
*)
function DirToLuaTable(L: Plua_State): Integer; cdecl;
Var Info : TSearchRec;
    Count : Longint;
    path: string;
    n: Integer;
Begin
  n := lua_gettop(L);
  Count:=0;
  path := '*';
  if lua_isstring(L,n) then
     path := lua_tostring(L,n);
  If FindFirst (path,faAnyFile and faDirectory,Info)=0 then begin
    lua_newtable(L);
    Repeat
      if (Info.Name='.') or (Info.Name='..') then continue;
      Inc(Count);
      lua_pushnumber(L,Count);
      lua_newtable(L);
      With Info do begin
           lua_pushstring(L,'Name');
           lua_pushstring(L,pchar(Name));
           lua_rawset(L,-3);
           lua_pushstring(L,'Size');
           lua_pushnumber(L,Size);
           lua_rawset(L,-3);
           lua_pushstring(L,'Attr');
           lua_pushnumber(L,Attr);
           lua_rawset(L,-3);
           lua_pushstring(L,'Time');
           lua_pushnumber(L,Time);
           lua_rawset(L,-3);
           {$IFDEF unix}
           lua_pushstring(L,'Mode');
           lua_pushnumber(L,Mode);
           lua_rawset(L,-3);
           {$IFDEF FPC2}
             // deprecated
             lua_pushstring(L,'PathOnly');
             lua_pushstring(L,pchar(PathOnly));
             lua_rawset(L,-3);
           {$ELSE}
           lua_pushstring(L,'PathOnly');
           lua_pushstring(L,'');
           lua_rawset(L,-3);
           {$ENDIF}
           {$ENDIF}
      end;
      lua_rawset(L,-3);
    Until FindNext(info)<>0;
  end else lua_pushnil(L);
  FindClose(Info);
  Result := 1;
end;

function LuaForceDirectory(L: Plua_State): Integer; cdecl;
Var path: string;
    n: Integer;
Begin
  n := lua_gettop(L);
  if lua_isstring(L,n) then begin
     path := lua_tostring(L,n);
     lua_pushboolean(L,ForceDirectory(path));
  end else lua_pushboolean(L,false);
  Result := 1;
end;

function LuaRemoveDirectory(L: Plua_State): Integer; cdecl;
Var path: string;
    n: Integer;
Begin
  n := lua_gettop(L);
  if lua_isstring(L,n) then begin
     path := lua_tostring(L,n);
     lua_pushboolean(L,RemoveDirUTF8(path));
  end else lua_pushboolean(L,false);
  Result := 1;
end;

function LuaGetDirectory(L: Plua_State): Integer; cdecl;
Begin
  lua_pushstring(L,pchar(GetCurrentDirUTF8()));
  Result := 1;
end;

function LuaChangeDirectory(L: Plua_State): Integer; cdecl;
Var path: string;
    n: Integer;
Begin
  n := lua_gettop(L);
  if lua_isstring(L,n) then begin
     path := lua_tostring(L,n);
     lua_pushboolean(L,SetCurrentDirUTF8(path));
  end else lua_pushboolean(L,false);
  Result := 1;
end;

procedure InitTotableFunc(L: Plua_State);
begin
     lua_pushcfunction(L, @ToLuaTable);
     lua_setglobal(L, 'totable');

     // extend os lib with dir
     lua_getglobal(L, 'os');
     lua_pushstring(L,'dir');
     lua_pushcfunction(L, @DirToLuaTable);
     lua_settable (L, -3);
     lua_pushstring(L,'mkdir');
     lua_pushcfunction(L, @LuaForceDirectory);
     lua_settable (L, -3);
     lua_pushstring(L,'rmdir');
     lua_pushcfunction(L, @LuaRemoveDirectory);
     lua_settable (L, -3);
     lua_pushstring(L,'pwd');
     lua_pushcfunction(L, @LuaGetDirectory);
     lua_settable (L, -3);
     lua_pushstring(L,'chdir');
     lua_pushcfunction(L, @LuaChangeDirectory);
     lua_settable (L, -3);
     lua_pop(L,1);
end;

end.

