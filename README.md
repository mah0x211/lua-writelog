# lua-writelog

simple logging module.

## Dependencies

- util: https://github.com/mah0x211/lua-util

## Installation

```
luarocks install writelog --from=http://mah0x211.github.io/rocks/
```

## Creating a logger

### logger = writelog.new( [loglevel [, writer [, udata [, formatter]]]] )

returns a logger function table

**Parameters**

- `loglevel:number`: log level constants (default: `WARNING`)
- `writer:callable`: your custom log writer
- `udata`: data for the first argument of your custom log writer
- `formatter:callable`: your custom log formatter

**NOTE:* the `callable` type must be a `function` or has a `__call` metamethod.

**Returns**

1. `logger:table`: table that contained following function;
  - `err:function`: write a error log
  - `warn:function`: write a warning log
  - `notice:function`: write a notice log
  - `verbose:function`: write a verbose log
  - `debug:function`: write a debug log


### Log Level Constants

- `writelog.ERROR`
- `writelog.WARNING`
- `writelog.NOTICE`
- `writelog.VERBOSE`
- `writelog.DEBUG`


## Log Writer Specification

### function writer( udata, ... )

**Params**

- `udata`: any of your data
- `...`: formatted logging data


the default log writer is implemented as follows;

```lua
function defaultwriter( _, ... )
    io.write( ... );
end
```


## Log Formatter Specification

### ... = function formatter( loglevel, debuginfo, ... )

**Params**

- `loglevel:number`: log level constants
- `debuginfo:table`: table of debug.getinfo() with `'Sl'` option
- `...`: passed logging data


the default log formatter is implemented as follows;

```lua
local ISO8601_FMT = '%FT%T%z';
local LOCATION_FMT = '%s:%d';
local LOG_LEVEL_NAME = {
    [ERROR]   = 'error',
    [WARNING] = 'warn',
    [NOTICE]  = 'notice',
    [VERBOSE] = 'verbose',
    [DEBUG]   = 'debug'
};
local LOG_LEVEL_FMT = {
    [ERROR]   = ('%%s [%s] '):format( LOG_LEVEL_NAME[ERROR] ),
    [WARNING] = ('%%s [%s] '):format( LOG_LEVEL_NAME[WARNING] ),
    [NOTICE]  = ('%%s [%s] '):format( LOG_LEVEL_NAME[NOTICE] ),
    [VERBOSE] = ('%%s [%s] '):format( LOG_LEVEL_NAME[VERBOSE] ),
    [DEBUG]   = ('%%s [%s: %s] '):format( LOG_LEVEL_NAME[DEBUG], LOCATION_FMT )
};

--- defaultformatter
-- @return prefix '<ISO8601> [<level <srcfile:line>>] '
-- @return str string
-- @return LF line-feed
local function defaultformatter( lv, info, ... )
    return LOG_LEVEL_FMT[lv]:format(
        os.date( ISO8601_FMT ), info.short_src, info.currentline
    ), table.concat( tostrv( ... ), ' ' ), '\n';
end
```


## Helper Functions

### lvstr = writelog.tolvstr( lv )

returns a stringified log level

**Params**

- `lv:number`: log level constants

**Returns**

1. `lvstr:string`: a stringified log level or `unknown_level`


### strv = writelog.tostrv( ... )

returns a string vector

**Parameters**

- `...`: any arguments

**Returns**

1. `strv:table`: string vector that index started at 1


## Usage

```lua
local unpack = unpack or table.unpack;
local writelog = require('writelog');
local logger = writelog.new( writelog.DEBUG );
local args = {
    'hello',
    0,
    1,
    -1,
    1.2,
    'world',
    {
        foo = 'bar',
        baz = {
            x = {
                y = 'z'
            }
        }
    },
    true,
    function()end,
    coroutine.create(function()end)
};

logger.warn( unpack( args ) )
logger.notice( unpack( args ) )
logger.verbose( unpack( args ) )
logger.debug( unpack( args ) )
```
