print("iterate name CA, print resi+','+ss+','+resn")
ss_list='''PASTE HERE'''.split()

ss_last='L'
resi_start='0'
resn_start='XXX'
resi_last='0'
resn_last='XXX'
ss_count={'H':1,'S':1,'L':0}

# http://www.wwpdb.org/documentation/file-format-content/format23/sect5.html
for line in ss_list:
    (resi_this,ss_this,resn_this)=line.split(',')
    if ss_last != ss_this:
        # deal with previous first
        if ss_last == 'H':  # previous was the other type
            print('{typos}    {ss_count: >3}HA {resn_start} A  {resi_start: >3}  {resn_end} A  {resi_end: >3} {h_class: >2}                                  {length: >2}'.format(
                typos='HELIX',
                ss_count=ss_count[ss_last],
                resn_start=resn_start,
                resi_start=resi_start,
                resn_end=resn_last,
                resi_end=resi_last,
                h_class=1,
                length=int(resi_last)-int(resi_start)
            ))
            ss_count[ss_last]+=1
        elif ss_last == 'S':  # previous was the other type
            print('{typos}  {ss_count: >3} {ss_count: >2}S 1 {resn_start} A {resi_start: >3}  {resn_end} A {resi_end: >3}  0'.format(
                typos='SHEET',
                ss_count=ss_count[ss_last],
                resn_start=resn_start,
                resi_start=resi_start,
                resn_end=resn_last,
                resi_end=resi_last,
                h_class=0,
                length=int(resi_last)-int(resi_start)
            ))
            ss_count[ss_last]+=1
        # deal with current
        if ss_this in ('S', 'H'): # start of a new
            resi_start = resi_this
            resn_start = resn_this
            ss_last = ss_this
    #move on
    resi_last = resi_this
    resn_last = resn_this
    ss_last = ss_this





