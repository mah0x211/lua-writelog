--[[

  Copyright (C) 2016 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.


  writelog.lua
  lua-writelog
  Created by Masatoshi Teruya on 16/04/14.

--]]

-- assign to local
local inspect = require('util').inspect;
local write = io.write;
local date = os.date;
local getinfo = debug.getinfo;
local getmetatable = debug.getmetatable;
local concat = table.concat;
-- constants
local ERROR = 0;
local WARNING = 1;
local NOTICE = 2;
local VERBOSE = 3;
local DEBUG = 4;
local ISO8601_FMT = '%FT%T%z';
local LOCATION_FMT = '%s:%d';
local LOG_LEVEL_NAME = {
    [ERROR]     = 'error',
    [WARNING]   = 'warn',
    [NOTICE]    = 'notice',
    [VERBOSE]   = 'verbose',
    [DEBUG]     = 'debug'
};
local LOG_LEVEL_FMT = {
    [ERROR]     = ('%%s [%s] '):format( LOG_LEVEL_NAME[ERROR] ),
    [WARNING]   = ('%%s [%s] '):format( LOG_LEVEL_NAME[WARNING] ),
    [NOTICE]    = ('%%s [%s] '):format( LOG_LEVEL_NAME[NOTICE] ),
    [VERBOSE]   = ('%%s [%s] '):format( LOG_LEVEL_NAME[VERBOSE] ),
    [DEBUG]     = ('%%s [%s: %s] '):format( LOG_LEVEL_NAME[DEBUG], LOCATION_FMT )
};
local INSPECT_OPT = {
    depth = 0,
    padding = 0
};
local EMPTY_INFO = {};
local NOOP = function()end;


--- tolvstr - returns a stringified log level
-- @param lv
-- @return lvstr
local function tolvstr( lv )
    return LOG_LEVEL_NAME[lv] or 'unknown_level';
end


--- tostrv - returns a string-vector
-- @param ...
-- @return strv
local function tostrv( ... )
    local argv = {...};
    local narg = select( '#', ... );
    local strv = {};
    local t, v;

    -- convert to string
    for i = 1, narg do
        v = argv[i];
        t = type( v );
        if t == 'string' then
            strv[i] = v;
        elseif t == 'table' then
            strv[i] = inspect( v, INSPECT_OPT );
        else
            strv[i] = tostring( v );
        end
    end

    return strv;
end


local function lerror( writer, udata, formatter )
    return function( ... )
        writer( udata, formatter( ERROR, EMPTY_INFO, ... ) );
    end
end

local function lwarn( writer, udata, formatter )
    return function( ... )
        writer( udata, formatter( WARNING, EMPTY_INFO, ... ) );
    end
end

local function lnotice( writer, udata, formatter )
    return function( ... )
        writer( udata, formatter( NOTICE, EMPTY_INFO, ... ) );
    end
end

local function lverbose( writer, udata, formatter )
    return function( ... )
        writer( udata, formatter( VERBOSE, EMPTY_INFO, ... ) );
    end
end

local function ldebug( writer, udata, formatter )
    return function( ... )
        writer( udata, formatter( DEBUG, getinfo( 2, 'Sl' ), ... ) );
    end
end


--- defaultwriter
-- @param _
-- @param ...
local function defaultwriter( _, ... )
    write( ... );
end


--- defaultformatter
-- @param lv
-- @param info
-- @param ...
local function defaultformatter( lv, info, ... )
    return LOG_LEVEL_FMT[lv]:format(
        date( ISO8601_FMT ), info.short_src, info.currentline
    ), concat( tostrv( ... ), ' ' ), '\n';
end


--- iscallable
-- @param val
-- @return bool
local function iscallable( val )
    return type( val ) == 'function' or
           type( val ) == 'table' and
           type( getmetatable( val ) ) == 'table' and
           type( getmetatable( val ).__call ) == 'function';
end


--- new
-- @param lv
-- @param writer
-- @param udata
-- @param formatter
-- @return logger
local function new( lv, writer, udata, formatter )
    -- use WARNING level as a default level
    if not lv then
        lv = WARNING;
    elseif type( lv ) ~= 'number' then
        error( 'lv must be number', 2 );
    end

    -- use the defaultwriter
    if writer == nil then
        writer = defaultwriter;
    elseif not iscallable( writer ) then
        error( 'writer must be callable' );
    end

    -- use the defaultformatter
    if formatter == nil then
        formatter = defaultformatter;
    elseif not iscallable( formatter ) then
        error( 'formatter must be callable' );
    end

    return setmetatable({},{
        __index = {
            err = lerror( writer, udata, formatter ),
            warn = lv > ERROR and lwarn( writer, udata, formatter ) or NOOP,
            notice = lv > WARNING and lnotice( writer, udata, formatter ) or NOOP,
            verbose = lv > NOTICE and lverbose( writer, udata, formatter ) or NOOP,
            debug = lv > VERBOSE and ldebug( writer, udata, formatter ) or NOOP
        }
    });
end


-- exports
return {
    new = new,
    tostrv = tostrv,
    tolvstr = tolvstr,
    ERROR = ERROR,
    WARNING = WARNING,
    NOTICE = NOTICE,
    VERBOSE = VERBOSE,
    DEBUG = DEBUG
};

