//<%text>
// same as venus route!

const vbtn = $('#venus_calc');
mutation.keyup(e => {
    if ($(e.target).val().search(/\d+/) !== -1 && uniprotValue !== 'ERROR') {
        vbtn.show();
        $('#error_mutation').hide();
        $(e.target).removeClass('is-invalid');
        if (event.keyCode === 13) vbtn.click();
    } else {
        vbtn.hide();
    }
});

// different
// not... class MultiVenus extends Venus {....

class MultiVenus {
    constructor() {
        this.uniprot = window.uniprotValue;
        this.taxid = window.taxidValue;
        this.mutations = window.mutation.value.split(/[^\w*]/);
    }

    analyse() {
        return $.post({
            url: "venus_multianalyse", data: {
                uniprot: this.uniprot,
                species: this.taxid,
                mutations: this.mutations.join(' ')
            }
        }).fail(ops.addErrorToast)
    }
}


vbtn.click(e => {
    if (taxidValue === 'ERROR') {
        $('#error_species').show();
        return 0;
    }
    if (uniprotValue === 'ERROR') {
        $('#error_gene').show();
        return 0;
    }
    if (mutation.val().search(/\d+/) === -1) {
        $('#error_mutation').show();
        return 0;
    }
    $(e.target).attr('disabled', 'disabled');
    window.multivenus = new MultiVenus();
    window.multivenus.analyse();
});
//</%text>