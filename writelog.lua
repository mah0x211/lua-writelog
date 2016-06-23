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
local unpack = unpack or table.unpack;
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
local LOG_LEVEL_FMT = {
    [WARNING]   = '%s [warn] ',
    [NOTICE]    = '%s [notice] ',
    [VERBOSE]   = '%s [verbose] ',
    [DEBUG]     = '%s [debug:' .. LOCATION_FMT .. '] '
};
local INSPECT_OPT = {
    depth = 0,
    padding = 0
};
local EMPTY_INFO = {};
local NOOP = function()end


--- tostrv - returns a string-vector
-- @param lv
-- @param ...
local function output( lv, info, ... )
    local prefix = LOG_LEVEL_FMT[lv]:format(
        date( ISO8601_FMT ), info.short_src, info.currentline
    );
    local idx = 2;
    local argv = {...};
    local narg = select( '#', ... );
    local strv = { prefix };
    local t, v;

    -- convert to string
    for i = 1, narg do
        v = argv[i];
        t = type( v );
        if t == 'string' then
            strv[idx] = v;
        elseif t == 'table' then
            strv[idx] = inspect( v, INSPECT_OPT );
        else
            strv[idx] = tostring( v );
        end
        -- append space
        strv[idx + 1] = i ~= narg and ' ' or '\n';
        idx = idx + 2;
    end

    write( unpack( strv ) );
end


local function lwarn( ... )
    output( WARNING, EMPTY_INFO, ... );
end

local function lnotice( ... )
    output( NOTICE, EMPTY_INFO, ... );
end

local function lverbose( ... )
    output( VERBOSE, EMPTY_INFO, ... );
end

local function ldebug( ... )
    output( DEBUG, getinfo( 2, 'Sl' ), ... );
end


--- new
-- @param lv
-- @return logger
local function new( lv )
    if not lv then
        lv = WARNING;
    elseif type( lv ) ~= 'number' then
        error( 'lv must be number', 2 );
    end

    return setmetatable({},{
        __index = {
            warn = lwarn,
            notice = lv > WARNING and lnotice or NOOP,
            verbose = lv > NOTICE and lverbose or NOOP,
            debug = lv > VERBOSE and ldebug or NOOP
        }
    });
end


-- exports
return {
    new = new,
    WARNING = WARNING,
    NOTICE = NOTICE,
    VERBOSE = VERBOSE,
    DEBUG = DEBUG
};

