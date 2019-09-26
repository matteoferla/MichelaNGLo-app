// toggler

let apo = '';

let ligdex = [];

const getHolo = (i) => {
    let lig = ligdex[i];
    let holo = apo.replace(/\nEND\n?/,'\nTER\n') + lig + 'END';
};

