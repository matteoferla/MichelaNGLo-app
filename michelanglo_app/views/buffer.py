from collections.abc import MutableMapping
from datetime import datetime, timedelta
from typing import Union, Tuple
from typing_extensions import TypedDict   #  >3.8
from collections import defaultdict


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

# ----------------------------------------------------------------------------------------------------------------------

class StatsType(TypedDict):
    running: bool
    start: float
    stop: float
    status: str
    error: str
    step: str

class VenusStats(SysStorage):
    def summarize(self):
        step_counts = defaultdict(int)
        step_errors = defaultdict(int)
        step_times = defaultdict(list)
        step_running = defaultdict(int)
        steps = set()
        stats: StatsType
        for stats in self.mapping.values():
            step = stats['step']
            steps.add(step)
            step_counts[step] += 1
            if stats['error']:
                step_errors[step] += 1
            diff = stats['stop'] - stats['start']
            if str(diff) != 'nan':
                step_times[step].append(diff)
            if stats['running']:
                step_running[step] += 1
        max_times = {step: max(step_times[step]) for step in step_times}
        mean_times = {step: sum(step_times[step]) / len(step_times[step]) for step in step_times}
        return {step: {'count': step_counts.get(step, 0),
                        'N_errors': step_errors.get(step, 0),
                        'max_time': max_times.get(step, float('nan')),
                        'mean_time': mean_times.get(step, float('nan')),
                        'N_running': step_running.get(step, 0)} for step in steps}

venus_stats = VenusStats()
