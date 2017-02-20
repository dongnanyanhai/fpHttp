library fpHttp;

{$mode objfpc}{$H+}

{$TYPEINFO ON}
// Lua version
{$Define LUA51}
// Lazarus version > 1
{$Define LAZ1}
// FPC version > 2
{$Define FPC3}

uses
  Classes,
  {$IFDEF LUA53}
     Lua in 'lua53/Lua.pas',
     LuaPas in 'lua53/LuaPas.pas',
  {$ELSE}
     {$IFDEF LUA52}
       Lua in 'lua52/Lua.pas',
       LuaPas in 'lua52/LuaPas.pas',
     {$ELSE}
       Lua in 'lua51/Lua.pas',
       LuaPas in 'lua51/LuaPas.pas',
     {$ENDIF}
  {$ENDIF}
  //LuaTable in 'LuaTable.pas',
  LuafpHttp in 'LuafpHttp.pas';
  const
    LUA_LIBNAME = 'fpHttp';
    LIB_COUNT = 3;

  var
    fpHttp_lib : array[0..LIB_COUNT] of lual_reg = (
        (name:'get'; func:@get),
        (name:'post'; func:@post),
        (name:'test'; func:@test),
        (name:nil;func:nil)
    )

  { you can add units after this };

function luaopen_fpHttp(L: Plua_State): Integer; cdecl;
begin

  // luaL_openlib is deprecated
  {$IFDEF LUA53}
     luaL_newlibtable(l, @fpHttp_lib);
     luaL_setfuncs(l, @fpHttp_lib, 0);
  {$ELSE}
     luaL_openlib(L, LUA_LIBNAME, @fpHttp_lib, 0);
  {$ENDIF}

  lua_pushliteral (L, '_COPYRIGHT');
  lua_pushliteral (L, 'Copyright (C) 2017, H5power.cn');
  lua_settable (L, -3);
  lua_pushliteral (L, '_DESCRIPTION');
  {$IFDEF LUA53}
     lua_pushliteral (L, 'fphttpclient for LUA (5.3)');
  {$ELSE}
     {$IFDEF LUA52}
       lua_pushliteral (L, 'fphttpclient for LUA (5.2)');
     {$ELSE}
       lua_pushliteral (L, 'fphttpclient for LUA (5.1)');
     {$ENDIF}
  {$ENDIF}
  lua_settable (L, -3);
  lua_pushliteral (L, '_NAME');
  lua_pushliteral (L, 'fpHttp');
  lua_settable (L, -3);
  lua_pushliteral (L, '_VERSION');
  lua_pushliteral (L, '0.0.1');
  lua_settable (L, -3);

  //InitTotableFunc(L);
  InitLuafpHttpFunc(L);
  result := 1;
end;
exports luaopen_fpHttp;

end.

