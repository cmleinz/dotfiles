
#!/usr/bin/env python3

#Uses libraries python-rofi and pulsectl

from rofi import Rofi
import pulsectl, sys

SINK_ALIASES = {
  'GM200 High Definition Audio Digital Stereo (HDMI 3)': "Creative Pebble Speakers",
  'Starship/Matisse HD Audio Controller Analog Stereo': "Sony WH-1000X M3",
}

def main():
  pulse = pulsectl.Pulse()
  rofi = Rofi()

  sinks = pulse.sink_list()
  current_default_name = pulse.server_info().default_sink_name
  for i, s in enumerate(sinks):
    if s.name == current_default_name:
      current_default = i

  if current_default == None:
    print("Couldn't find the default sink?")
    return

  sink_index, _ = rofi.select("Select default output", [s.description if s.description not in SINK_ALIASES else SINK_ALIASES[s.description] for s in sinks], select=current_default)
  if sink_index == -1:
    return

  pulse.default_set(sinks[sink_index])


if __name__ == '__main__':
  main()
