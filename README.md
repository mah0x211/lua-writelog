lua-writelog
=======

simple logging module.

## Dependencies

- util: https://github.com/mah0x211/lua-util

## Installation

```
luarocks install writelog --from=http://mah0x211.github.io/rocks/
```

## Creating a logger

### logger = writelog.new( [loglevel [, writer [, udata]]] )

returns a logger function table

**Parameters**

- `loglevel:number`: log level constants (default: `WARNING`)
- `writer:function`: your custom log writer
- `udata`: any data for the first argument of your custom log writer

**Returns**

1. `logger:table`: table that contained following function;
    - `warn:function`: write a warning log
    - `notice:function`: write a notice log
    - `verbose:function`: write a verbose log
    - `debug:function`: write a debug log


### Log Level Constants

- `writelog.WARNING`
- `writelog.NOTICE`
- `writelog.VERBOSE`
- `writelog.DEBUG`


## Custom Log Writer Specification

### function writer( udata, loglevel, debuginfo, ... )

**Params**

- `udata`: any data
- `loglevel:number`: log level constants
- `debuginfo:table`: table of debug.getinfo() with `'Sl'` option
- `...`: passed logging data


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
