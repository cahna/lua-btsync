#!/usr/bin/env luajit

local curses = require 'curses'
local btsync = require 'btsync'()

curses.initscr()
curses.cbreak()
curses.echo(false)
curses.nl(false)

local stdscr = curses.stdscr()
stdscr:clear()

local folder_data = btsync:get_sync_folders()
local folders = folder_data.folders

local x, y = 2, 5

for _,folder in ipairs(folders) do
  stdscr:mvaddstr(y, x, folder.name)
  y = y + 1
end

stdscr:refresh()

local c = stdscr:getch()

if c < 256 then 
  c = string.char(c) 
end

curses.endwin()

if c == 'y' then
  table.sort(folders)
  for i,k in ipairs(folders) do 
    print(k.secret) 
  end
end
