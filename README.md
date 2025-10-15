# Terminus
An Open-Source Terminal Rendering library for Lua.

# Classes
## Screen
Used to easily store and render a large chunk of pixels at once. By default, there are 2 pixels stacked vertically per character. This can be changed using the char parameter in `Terminus.Screen:setPixel(x,y,  r,g,b,  char)`.

# Windows Weirdness
If the screen looks weird / each group of pixels is replaced by a bunch of random characters, try running `chcp 65001` in your terminal. Also, be aware that (at least from my experience) the windows terminal does not like getting resized.