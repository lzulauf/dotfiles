from __future__ import print_function

def print_build_time():
  import os
  import sys
  import time
  time_struct = time.localtime(os.path.getmtime(sys.executable))
  print("%s" % sys.executable)
  print("Build time: %s" % time.strftime("%A, %B %d, %Y @ %I:%m:%S %p", time_struct))
#  print_build_time()
del print_build_time


def add_tab_complete():
  import readline
  readline.parse_and_bind("tab: complete")
add_tab_complete()
del add_tab_complete


def add_history():
  import os
  import readline
  import atexit
  histfile = os.path.join(os.path.expanduser('~/.pyhistory'))
  try:
    readline.read_history_file(histfile)
  except IOError:
    pass

  atexit.register(readline.write_history_file, histfile)
add_history()
del add_history


try:
  from IPython.core.magic import (
    Magics,
    magics_class,
    line_cell_magic,
  )
  @magics_class
  class DebugPrintMagics(Magics):
    @line_cell_magic
    def debug_print(self, line, cell=None):
      raw_lines = [line]
      if cell:
        raw_lines.extend(cell.split('\n'))
      lines = [line.strip() for line in raw_lines]
      for line in lines:
        if not line:
          continue
        print(">>> %s" % line)
        self.shell.run_cell(line)


  try:
    get_ipython().register_magics(DebugPrintMagics)
  except:
    print('not running in ipython')
  del DebugPrintMagics
except:
  pass
