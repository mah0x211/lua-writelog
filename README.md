# lua-writelog

simple logging module.

## Dependencies

- util: https://github.com/mah0x211/lua-util

## Installation

```
luarocks install writelog --from=http://mah0x211.github.io/rocks/
```

## Using a logger

### logger, err = writelog.new( [loglevel, [pathname, [...]]] )

returns a logger

**Parameters**

- `loglevel:number`: log level constants (default: `WARNING`)
- `pathname:string`: pathname of output destination (use the `stdout` if `nil`);
- `...`: options for logger constructor


**Returns**

1. `logger:table`: table that contain the following methods;
  - `err:function`: write a error log
  - `warn:function`: write a warning log
  - `notice:function`: write a notice log
  - `verbose:function`: write a verbose log
  - `debug:function`: write a debug log
  - `close:function`: default destructor for context data
2. `err:string` error message


### Pathname format specification

`pathname` format is like the URL format as follows;

- `<scheme>://<path>`
  - a first letter of `<path>` string must be `.` or `/` in this case
- `<scheme>://<user>:<password>@<host>:<port>/<path>`


`scheme` will be considered a submodule name of writelog (i.e. `'writelog.<scheme>'`).

that submodule will be loaded automatically and call a 'new' function with the parsed arguments.


### Usage

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

logger:warn( unpack( args ) )
logger:notice( unpack( args ) )
logger:verbose( unpack( args ) )
logger:debug( unpack( args ) )
```


## Creating a custom logger

### logger = writelog.create( [ctx], [loglevel [, writer [, formatter]]] )

returns a logger function table

**Parameters**

- `ctx:table`: context data for the custom logger (default: empty-table)
- `loglevel:number`: log level constants (default: `WARNING`)
- `writer:callable`: your custom log writer
- `formatter:callable`: your custom log formatter

**NOTE:** the `callable` type must be a `function` or has a `__call` metamethod.

**Returns**

1. `logger:table`: table that contain the following function in __index table;
  - `err:function`: write a error log
  - `warn:function`: write a warning log
  - `notice:function`: write a notice log
  - `verbose:function`: write a verbose log
  - `debug:function`: write a debug log
  - `flush:function`: set a default flush method if a `flush` function not contained in ctx
  - `close:function`: set a default destructor method if a `close` function not contained in ctx
2. `err:string`: error message

### Log Level Constants

- `writelog.ERROR`
- `writelog.WARNING`
- `writelog.NOTICE`
- `writelog.VERBOSE`
- `writelog.DEBUG`


## Log Writer Specification

### writer( ctx, ... )

**Params**

- `ctx`: context data
- `...`: formatted logging data


the default log writer is implemented as follows;

```lua
function defaultwriter( _, ... )
    io.write( ... );
end
```


## Log Formatter Specification

### ... = formatter( loglevel, debuginfo, ... )

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

