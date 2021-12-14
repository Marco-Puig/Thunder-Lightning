#!/usr/bin/ruby
require "zlib"
data = [
  ["BootSequence"],
  ["require PSDK_PATH.gsub(\"\\\\\",'/') + '/scripts/ScriptLoad.rb'"]
]
File.open("PSDK_BOOT.rxdata","w") do |f| Marshal.dump(Zlib::Deflate.deflate(Marshal.dump(data)), f) end
