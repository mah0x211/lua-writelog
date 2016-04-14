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

### logger = writelog.new( [loglevel] )

returns a logger function table

**Parameters**

- `loglevel:number`: log level constants (default: `WARNING`)

**Returns**

1. `logger:table`: logger function table


### Log Level Constants

- `writelog.WARNING`
- `writelog.NOTICE`
- `writelog.VERBOSE`
- `writelog.DEBUG`


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
