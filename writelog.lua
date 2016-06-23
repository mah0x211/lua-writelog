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
local concat = table.concat;
-- constants
local WARNING = 1;
local NOTICE = 2;
local VERBOSE = 3;
local DEBUG = 4;
local ISO8601_FMT = '%FT%T%z';
local LOCATION_FMT = '%s:%d';
local LOG_LEVEL_NAME = {
    [WARNING]   = 'warn',
    [NOTICE]    = 'notice',
    [VERBOSE]   = 'verbose',
    [DEBUG]     = 'debug'
};
local LOG_LEVEL_FMT = {
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
local NOOP = function()end


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


local function lwarn( writer, udata )
    return function( ... )
        writer( udata, WARNING, EMPTY_INFO, ... );
    end
end

local function lnotice( writer, udata )
    return function( ... )
        writer( udata, NOTICE, EMPTY_INFO, ...  );
    end
end

local function lverbose( writer, udata )
    return function( ... )
        writer( udata, VERBOSE, EMPTY_INFO, ... );
    end
end

local function ldebug( writer, udata )
    return function( ... )
        writer( udata, DEBUG, getinfo( 2, 'Sl' ), ... );
    end
end


--- defaultwriter
-- @param _
-- @param lv
-- @param info
-- @param ...
local function defaultwriter( _, lv, info, ... )
    local prefix = LOG_LEVEL_FMT[lv]:format(
        date( ISO8601_FMT ), info.short_src, info.currentline
    );

    write( prefix, concat( tostrv( ... ), ' ' ), '\n' );
end


--- new
-- @param lv
-- @param writer
-- @param udata
-- @return logger
local function new( lv, writer, udata )
    if not lv then
        lv = WARNING;
    elseif type( lv ) ~= 'number' then
        error( 'lv must be number', 2 );
    end

    -- use the defaultwriter
    if writer == nil then
        writer = defaultwriter;
    elseif type( writer ) ~= 'function' then
        error( 'writer must be function' );
    end

    return setmetatable({},{
        __index = {
            warn = lwarn( writer, udata ),
            notice = lv > WARNING and lnotice( writer, udata ) or NOOP,
            verbose = lv > NOTICE and lverbose( writer, udata ) or NOOP,
            debug = lv > VERBOSE and ldebug( writer, udata ) or NOOP
        }
    });
end


-- exports
return {
    new = new,
    tostrv = tostrv,
    tolvstr = tolvstr,
    WARNING = WARNING,
    NOTICE = NOTICE,
    VERBOSE = VERBOSE,
    DEBUG = DEBUG
};

