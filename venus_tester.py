"""
This class is not a manual test not a unitest as a human needs to assess if the fail rate is decent.

>>> VenusTester.test_randoms(20)

"""

import requests, time


class VenusTester:
    url = 'http://localhost:8088'

    def __init__(self, uniprot: str, mutation: str, taxid: int = 9606, **kwargs):
        self.uniprot = uniprot
        self.mutation = mutation
        self.taxid = int(taxid)
        self.analysis = self.analyse()

    @classmethod
    def from_random(cls):
        r = requests.get(f'{cls.url}/venus_random').json()
        return cls(**r)

    def analyse(self):
        return requests.get(f'{self.url}/venus_analyse', params=dict(uniprot=self.uniprot,
                                                                     species=self.taxid,
                                                                     mutation=self.mutation,
                                                                     step='ddG')).json()

    def is_successful(self):
        return self.analysis['status'] == 'success'

    def assert_successful(self):
        if self.is_successful():
            return None
        raise ValueError(self.get_error())

    def get_full_url(self):
        return f'{self.url}/venus?uniprot={self.uniprot}&species={self.taxid}&mutation={self.mutation}'

    def get_error(self):
        if self.is_successful():
            return 'success'
        else:
            return f"{self.analysis['error']}: {self.analysis['msg']}"

    @property
    def ddG(self):
        if self.is_successful() and 'ddG' in self.analysis:
            return self.analysis['ddG']['ddG']
        else:
            return float('nan')

    @classmethod
    def test_randoms(cls, trials: int = 20):
        success_tally = 0
        for i in range(1, 101):
            tick = time.time()
            trial = cls.from_random()
            tock = time.time()
            print(f'trial #{i} reported {trial.get_error()}. ' +
                  f'({trial.ddG} kcal/mol), in {tock - tick}s {trial.get_full_url()}')
            if trial.is_successful():
                success_tally += 1
        print(success_tally / i)