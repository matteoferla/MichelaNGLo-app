class MutantLocation {
  /*
  This is not perfect. But the constructor function of FeatureViewer is too messy to work with.
  There is an inexplicable initial offset.
  When zoomed in and the first block is lost, the line is lost too even when it is inplace.
   */
  constructor(x) {
    this.x = x;
    this.class = 'myVar';
    this.addLine();
    const s = $('#fv svg');
    s.mouseup(event => setTimeout(() => this.addLine.call(this), 1000));
    //s.mousedown(this.make);
  }

  addLine() {
    d3.select('.'+this.class).remove();
    const svgContainer = d3.select("#fv svg g");
    let dOri = d3.select('.domainGroup').data()[0].y - d3.select('.domainGroup').data()[0].x;
    let prime = parseFloat(d3.select('.domainGroup').attr("transform").match(/[-\d.]+/)[0]);
    let dPrime = parseFloat(d3.select('.domainGroup rect').attr("width"));
    this.scaleFactor = dPrime/dOri;
    this.offset = prime - this.scaleFactor * d3.select('.domainGroup').data()[0].x;
    this.h = d3.select(".background").attr("height");
    this.w = this.scaleFactor + 2;
    this.xPrime = this.scaleFactor * this.x - 1;

    svgContainer.append("rect")
            .attr("width", this.w)
            .attr("height", this.h)
            .attr("transform", `translate(${this.xPrime},0)`)
            .attr("class",this.class)
            .style("fill","rgba(200, 0, 0, 0.2)")
            .style("z-index", -1)
            .style("cursor","pointer");
    $('.'+this.class).click(event => this.onClick.call(this));
    return this;
  }

  onClick() {
      if (window.myData !== undefined) NGL.specialOps.showResidue('viewport', this.x+':A');
  }
}