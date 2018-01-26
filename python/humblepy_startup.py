import datetime
import os

from google.appengine.ext import db

from libraries import chrono
try:
  from libraries.environ import get_app_dir
except:
  get_app_dir = lambda: os.getenv('CLIENT_DIR')
from libraries.datastore import iter_fetch, fetch_all

ipython_config.TerminalInteractiveShell.editing_mode = 'vi'
ipython_config.InteractiveShellApp.extensions = [
  'autoreload',
]
ipython_config.InteractiveShellApp.exec_lines = [
  '%autoreload 2',
]

def load_all_models():
  import importlib
  from google.appengine.api.datastore_errors import BadArgumentError
  model_modules = [
    os.path.splitext(module_name)[0]
    for module_name in os.listdir(os.path.join(get_app_dir(), 'models'))
    if module_name.endswith('.py') and not module_name.startswith('_')
  ]
  for module_name in model_modules:
    try:
      module = importlib.import_module('models.%s' % module_name)
    except BadArgumentError as e:
      # Importing ExportJob ends up trying to run a query inside DisplayItem
      # that tries to find all Genres
      if e.message == 'app must not be empty.':
        continue
      raise

    try:
      model = getattr(module, module_name)
    except AttributeError:
      continue
    except Exception as e:
      raise

    globals()[module_name] = model
load_all_models()
del load_all_models


@db.transactional
def put_thing(thing):
  thing.put()


