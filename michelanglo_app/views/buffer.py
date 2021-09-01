from collections.abc import MutableMapping
from datetime import datetime, timedelta
from typing import Union


class SysStorage(MutableMapping):
    """An ultra simple thread independent container (dictionary) that has a timestamp."""

    def __init__(self):
        self.mapping = {}
        self.timestamps = {}

    def __setitem__(self, key, value):
        self.mapping[key] = value
        self.timestamps[key] = datetime.now()

    def __getitem__(self, key):
        if key not in self.mapping:
            raise ValueError(f'This key {key} does not exists in the buffer (likely expired)!')
        return self.mapping[key]

    def __delitem__(self, key):
        del self.mapping[key]
        del self.timestamps[key]

    def __iter__(self):
        return iter(self.mapping)

    def __contains__(self, value):
        return value in self.mapping

    def __len__(self):
        return len(self.mapping)

    def delete_before(self, cutoff: Union[datetime, timedelta, int] = 1) -> int:
        if isinstance(cutoff, datetime):
            cutoff_time = cutoff
        elif isinstance(cutoff, timedelta):
            cutoff_time = datetime.now() - cutoff
        elif isinstance(cutoff, int):
            cutoff_time = datetime.now() - timedelta(hours=cutoff)
        else:
            raise ValueError
        i = 0
        for key in list(self):
            if self.timestamps[key] < cutoff_time:
                del self[key]
                i += 1
        return i


system_storage = SysStorage()