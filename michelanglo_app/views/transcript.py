import csv, re, os
from typing import Dict, Union
from Bio import SeqIO, pairwise2
from michelanglo_protein import global_settings, ProteinCore
from .common_methods import is_malformed
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound


@view_config(route_name='venus_transcript', renderer='json')
def venus_transcript(request):
    """
    This route is available for humans only.
    """
    malformed = is_malformed(request, 'enst', 'mutation')
    if malformed:
        return {'status': malformed}
    data = get_transcript(request)
    if 'redirect' in request.params:
        return HTTPFound(location=f'/venus?gene={data["uniprot"]}&species=9606&mutation={data["mutation"]}')
    else:
        return data


def get_transcript(request):
    enst = request.params['enst']
    mutation = request.params['mutation']
    mapper = ENSTMapper(enst)
    if mapper.is_full_match():
        return {'uniprot': mapper.uniprot,
                'mutation': mutation}
    else:
        p = ProteinCore(uniprot=mapper.uniprot, taxid=9606).load()
        return {'uniprot': mapper.uniprot,
                'mutation': mapper.convert(p.sequence, mutation)}


class ENSTMapper:
    """
    Map an Ensembl ENST transcript id and position to a uniprot one.
    Requires the files:

    - ftp://ftp.ensembl.org/pub/release-99/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz
    - ftp://ftp.ensembl.org/pub/release-99/tsv/homo_sapiens/Homo_sapiens.GRCh38.99.uniprot.tsv.gz

    >>> ENSTMapper('ENST00000454575.6').convert('MAAAA....AAAAA', 1932)
    """
    def __init__(self, enst: str):
        self.enst = re.sub(r'\.\d+', '', enst)  # version does not matter.
        # create self.info:Dict
        self.ENST2info()
        self.ensp = self.info['protein_stable_id']
        self.uniprot = self.info['xref']

    def ENST2info(self) -> Dict:
        for entry in csv.DictReader(global_settings.open('ensembl-uniprot'), delimiter='\t'):
            if entry['transcript_stable_id'] == self.enst:
                self.info = entry
                return entry

    def is_full_match(self) -> bool:
        """
        Is the self.uniprot the same as self.ent?
        """
        return all([self.info['db_name'] == 'Uniprot/SWISSPROT',
                    self.info['xref_identity'] == '100',  # alt value can be '-' so no int!
                    self.info['source_identity'] == '100'])

    @property
    def sequence(self) -> str:
        fasta = os.path.join(global_settings.reference_folder, 'Homo_sapiens.GRCh38.pep.all.fa')
        for record in SeqIO.parse(fasta, "fasta"):
            if re.sub(r'\.\d+', '', record.id) == self.ensp:
                return record.seq

    @staticmethod
    def clean_sequence(sequence: str) -> str:
        """Gets rid of non-letters."""
        return re.sub(r'[^\w]', '', str(sequence).replace('\n', ''))

    @staticmethod
    def clean_position(position: Union[str, int]) -> int:
        """Makes sure its a number"""
        return position if isinstance(position, int) else int(re.search(r'(\d+)', position).group(1))

    def convert_position(self, sequence: str, position: int):
        """
        Sequence is the query one. reference is the ENSP sequence.
        """
        ref = self.clean_sequence(self.sequence)
        seq = self.clean_sequence(sequence)
        print(self.ensp, len(ref), self.uniprot, len(seq))
        alignement = pairwise2.align.globalxx(ref, seq)[0]
        a_ref = alignement[0]
        a_query = alignement[1]
        mapping_ref = [i+1 for i, r in enumerate(a_ref) if r != '-']
        mapping_query = [i+1 for i, r in enumerate(a_query) if r != '-']
        mp = mapping_ref[position]  # this is the position in the aligned sequence.
        ar = a_ref[mp]  # residue at mp
        aq = a_query[mp]  # residue at mp
        assert ar == aq, f'The positions do not match {aq}!={ar}'
        return mapping_query.index(mp)

    def convert(self, sequence: str, mutation: str) -> str:
        """
        Convert the mutation to the numbering of the seuwnece provided.
        See ``self.convert_position(sequence, position)`` for more.
        """
        position = self.clean_position(mutation)
        xpos = self.convert_position(sequence, position)
        return re.sub(str(position), str(xpos), mutation)


def test():
    # ENST00000635253.2 is Q96N67
    assert ENSTMapper('ENST00000635253.2').is_full_match(), 'Error: ENST00000635253.2 is Q96N67 in full'
    # ENST00000454575.6 is not
    assert not ENSTMapper('ENST00000635253.2').is_full_match(), 'Error: ENST00000635253.2 is not Q96N67 in full'
    u = '''MAERRAFAQKISRTVAAEVRKQISGQYSGSPQLLKNLNIVGNISHHTTVPLTEAVDPVDL
    EDYLITHPLAVDSGPLRDLIEFPPDDIEVVYSPRDCRTLVSAVPEESEMDPHVRDCIRSY
    TEDWAIVIRKYHKLGTGFNPNTLDKQKERQKGLPKQVFESDEAPDGNSYQDDQDDLKRRS
    MSIDDTPRGSWACSIFDLKNSLPDALLPNLLDRTPNEEIDRQNDDQRKSNRHKELFALHP
    SPDEEEPIERLSVPDIPKEHFGQRLLVKCLSLKFEIEIEPIFASLALYDVKEKKKISENF
    YFDLNSEQMKGLLRPHVPPAAITTLARSAIFSITYPSQDVFLVIKLEKVLQQGDIGECAE
    PYMIFKEADATKNKEKLEKLKSQADQFCQRLGKYRMPFAWTAIHLMNIVSSAGSLERDST
    EVEISTGERKGSWSERRNSSIVGRRSLERTTSGDDACNLTSFRPATLTVTNFFKQEGDRL
    SDEDLYKFLADMRRPSSVLRRLRPITAQLKIDISPAPENPHYCLTPELLQVKLYPDSRVR
    PTREILEFPARDVYVPNTTYRNLLYIYPQSLNFANRQGSARNITVKVQFMYGEDPSNAMP
    VIFGKSSCSEFSKEAYTAVVYHNRSPDFHEEIKVKLPATLTDHHHLLFTFYHVSCQQKQN
    TPLETPVGYTWIPMLQNGRLKTGQFCLPVSLEKPPQAYSVLSPEVPLPGMKWVDNHKGVF
    NVEVVAVSSIHTQDPYLDKFFALVNALDEHLFPVRIGDMRIMENNLENELKSSISALNSS
    QLEPVVRFLHLLLDKLILLVIRPPVIAGQIVNLGQASFEAMASIINRLHKNLEGNHDQHG
    RNSLLASYIHYVFRLPNTYPNSSSPGPGGLGGSVHYATMARSAVRPASLNLNRSRSLSNS
    NPDISGTPTSPDDEVRSIIGSKGLDRSNSWVNTGGPKAAPWGSNPSPSAESTQAMDRSCN
    RMSSHTETSSFLQTLTGRLPTKKLFHEELALQWVVCSGSVRESALQQAWFFFELMVKSMV
    HHLYFNDKLEAPRKSRFPERFMDDIAALVSTIASDIVSRFQKDTEMVERLNTSLAFFLND
    LLSVMDRGFVFSLIKSCYKQVSSKLYSLPNPSVLVSLRLDFLRIICSHEHYVTLNLPCSL
    LTPPASPSPSVSSATSQSSGFSTNVQDQKIANMFELSVPFRQQHYLAGLVLTELAVILDP
    DAEGLFGLHKKVINMVHNLLSSHDSDPRYSDPQIKARVAMLYLPLIGIIMETVPQLYDFT
    ETHNQRGRPICIATDDYESESGSMISQTVAMAIAGTSVPQLTRPGSFLLTSTSGRQHTTF
    SAESSRSLLICLLWVLKNADETVLQKWFTDLSVLQLNRLLDLLYLCVSCFEYKGKKVFER
    MNSLTFKKSKDMRAKLEEAILGSIGARQEMVRRSRGQLGTYTIASPPERSPSGSAFGSQE
    NLRWRKDMTHWRQNTEKLDKSRAEIEHEALIDGNLATEANLIILDTLEIVVQTVSVTESK
    ESILGGVLKVLLHSMACNQSAVYLQHCFATQRALVSKFPELLFEEETEQCADLCLRLLRH
    CSSSIGTIRSHASASLYLLMRQNFEIGNNFARVKMQVTMSLSSLVGTSQNFNEEFLRRSL
    KTILTYAEEDLELRETTFPDQVQDLVFNLHMILSDTVKMKEHQEDPEMLIDLMYRIAKGY
    QTSPDLRLTWLQNMAGKHSERSNHAEAAQCLVHSAALVAEYLSMLEDRKYLPVGCVTFQN
    ISSNVLEESAVSDDVVSPDEEGICSGKYFTESGLVGLLEQAAASFSMAGMYEAVNEVYKV
    LIPIHEANRDAKKLSTIHGKLQEAFSKIVHQSTGWERMFGTYFRVGFYGTKFGDLDEQEF
    VYKEPAITKLAEISHRLEGFYGERFGEDVVEVIKDSNPVDKCKLDPNKAYIQITYVEPYF
    DTYEMKDRITYFDKNYNLRRFMYCTPFTLDGRAHGELHEQFKRKTILTTSHAFPYIKTRV
    NVTHKEEIILTPIEVAIEDMQKKTQELAFATHQDPADPKMLQMVLQGSVGTTVNQGPLEV
    AQVFLSEIPSDPKLFRHHNKLRLCFKDFTKRCEDALRKNKSLIGPDQKEYQRELERNYHR
    LKEALQPLINRKIPQLYKAVLPVTCHRDSFSRMSLRKMDL
    '''
    assert ENSTMapper('ENST00000454575.6').convert(u, 1932) == 1943, 'Error: ENST00000635253.2 @ 1932 is Q96N67 @ 1943'

    if __name__ == '__main__':
        test()