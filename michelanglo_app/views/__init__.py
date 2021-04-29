### custom messages are visible to all users everytime they request a page.
# they are toasts.
# This is different from the new user cookie warning.
# each list element is a dict(title= 'title', descr= 'body text', bg= 'bootstrap bg- class for background'}
# to set go to admin console.

from .custom_message import custom_messages

from collections import defaultdict
votes = defaultdict(lambda: {'up': 0, 'down': 0})

valid_extensions = ['pdb', 'cif', 'mmtf', 'pqr', 'sdf', 'mol', 'mol2']