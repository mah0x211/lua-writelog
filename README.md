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

### logger = writelog.new( [loglevel, [writer]] )

returns a logger function table

**Parameters**

- `loglevel:number`: log level constants (default: `WARNING`)
- `writer:function`: your custom log writer

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

### function writer( loglevel, debuginfo, ... )

**Params**

- `loglevel:number`: log level constants
- `debuginfo:table`: table of debug.getinfo() with `'Sl'` option
- `...`: passed logging data


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
