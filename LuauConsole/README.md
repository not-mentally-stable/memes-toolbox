# LuauConsole
a recreation of the JS console object in Luau! (it ofc doesn't fully support every console function) but almost all of them
it follows this [console api](https://developer.mozilla.org/en-US/docs/Web/API/console)

# Installation
1. open roblox studio
2. execute this script in the **commandbar** (you may get a warning just ignore)
```Luau
-- not done
```
3. then enjoy!

## Features & Supported Methods

### Logging Methods
all logging methods support table previewing and indentation in both studio and in-game.
 * `console.log(...any)` - Standard output/print
 * `console.info(...any)` - Outputs info messages (the blue text).
 * `console.warn(...any)` - Outputs a warning messages.
 * `console.error(...any) / console.exception(...any)` - Spawns a separate thread to log errors without terminating the calling script's execution (like the real console.error).
 * `console.debug(...any)` - Like .info but with a [DEBUG] tag.

### Introspection & Utilities
 * `console.dir(item: any)` - Deeply inspects an item. If it is a Roblox Instance, it queries ReflectionService to report its ClassName, Superclass, properties (and their current values), methods, and signals.
 * `console.table(data: any)` - Formats and displays tabular/dictionary structures elegantly within the output context.
 * `console.assert(condition: any, message: string?)` - Logs an error message if the condition evaluates to false.
 * `console.trace(...any)` - Outputs a stack trace along with an optional message.
 * `console.clear()` - Clears the Studio output console (LogService:ClearOutput()) only works in studio.

### Timers & Counters
 * `console.count(label: string?)` - Logs the number of times this specific count() has been invoked with the given label.
 * `console.countReset(label: string?)` - Resets the counter for the given label.
 * `console.time(label: string?)` - Starts a high-precision performance timer (os.clock()).
 * `console.timeLog(label: string?, ...any)` - Logs the current elapsed time of a timer along with trailing parameters.
 * `console.timeEnd(label: string?)` - Stops the timer and logs the final duration.

### Log Grouping & Profiling
 * `console.group(...any) / console.groupCollapsed(...any)` - Increases the internal indentation level for all subsequent logs, visually grouping related logs together.
 * `console.groupEnd()` - Steps back out of the current log group.
 * `console.profile(label: string?)` - Inline alias for Roblox's MicroProfiler debug.profilebegin().
 * `console.profileEnd()` - Inline alias for Roblox's MicroProfiler debug.profileend().
 
## Quick Usage Example
```Luau
local console = require("./console")

console.group("User Authentication")
console.log("Checking session...")
console.info("Session valid for user:", { ID = 1, Name = "Roblox" })
console.groupEnd()

console.time("Heavy Operation")
for i = 1, 100000 do
    local x = math.sin(i)
end
console.timeEnd("Heavy Operation")
```
