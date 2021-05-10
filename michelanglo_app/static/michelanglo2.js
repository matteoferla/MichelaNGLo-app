// OO version of michelanglo.js idea.
// this is way way long overdue
// not live.
// change $.prototype.protein to call Prolink();
// NGL.specialOps.prolink(element) => Prolink(element)
// remember special case of viewport

class Prolink {

    constructor(element) { // click = former prolink
        this.element = element;
        this.selection = this.getData('selection', null); // compulsory
        // todo. Why is this a case?
        if (typeof selection === 'number') {
            this.selection = this.selection.toString();
        }
    }

    showDomain() {} //etc.

    getData(key, blank) { //data attribute
        // blank => value (return that) or null (raise error) or undefined (tolerate)
        const value = this.element.dataset[key];
        if (value !== undefined) {return value}  // present
        else if (blank === null) {throw `Expected value for data-${key}`;} // raise
        else {return blank} // tolerate
    }

    get target () {
        let target = getData('target');
        if (target !== undefined) {return target}
        else if (this.element.hasAttribute('href')) {
            target = this.element.getAttribute('href').replace('#', '');
            if (target === '') {return 'viewport'}
            else {return target}
        }
        else {return 'viewport'}
    }

    get numberAlts() {
        let i = 1;
        while (this.getData('selection-alt' + i) !== undefined) {
            i++;
        }
        return i - 1;
    }

    getMultiselection() {
        // range(1, this.numberAlts() )
        const range = [...Array(this.numberAlts()).keys()].map(i => i + 1);
        return range.map(i => {
                    let f = this.getData('focus-alt' + i, 'residue');
                    //residue is the only focus mode that will work as intended...
                    let c = this.getData('color-alt' + i, NGL.specialOps.colorDefaults[f]);
                    return [f, this.getData('selection-alt' + i, null), c]
                });
    }


    static enableDOMProlinks() {
        // still requires $.prototype.protein function. protein is listener. prolink is on click
        //activate prolinks
        $('[data-toggle="protein"]:not([role="NGL"])').protein();
        //activate viewport
        $('[role="NGL"],[role="proteinViewport"],[role="proteinviewport"],[role="protein_viewport"]').viewport();
    }
}