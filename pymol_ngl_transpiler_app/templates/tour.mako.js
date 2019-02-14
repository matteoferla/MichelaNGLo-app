/*
<%namespace file="labels.mako" name="info"/>
<%doc>
 This file is a mako template to make JS. The extension is backwards to avoid tinkering with the default PyCharm editor.
 This file contains the main page's tour.
</%doc>
*/


window.tour = new Tour({
      backdrop: true,
      steps: [
      {
        element: "h1",
        title: "Aim",
        content: `${info.attr.aim|n}`,
        placement: "bottom"
      },
      {
        element: "h1",
        title: "Where to use",
        content: `${info.attr.usable|n}`,
        placement: "bottom"
      },{
        element: "h1 .fa-github",
        title: "GitHub Repository",
        content: `${info.attr.github|n}`,
        placement: "right"
      },

      {
        element: "#input_mode_file",
        title: "Input mode",
        content: `${info.attr.mode|n}`,
        placement: "bottom"
      },
      {
        element: "#upload",
        title: "Upload your PSE file",
        content: `${info.attr.upload|n}`,
        placement: "bottom"
      },
      {
        element: "#demo_mod_btn",
        title: "Demo PSE",
        content: `${info.attr.demo_pse|n}`,
        placement: "bottom"
      },
      {
        element: "#pdb_string",
        title: "Include PDB text?",
        content: `${info.attr.pdb_string|n}`,
        placement: "top"
      },
      {
        element: "#pdb",
        title: "PDB address",
        content: `${info.attr.pdb|n}`,
        placement: "top"
      },
      {
        element: "#uniform_non_carbon",
        title: "Correct color error for non-carbons",
        content: `${info.attr.uniform_non_carbon|n}`,
        placement: "top"
      },
      {
        element: "#image",
        title: "Static image on load",
        content: `${info.attr.image|n}`,
        placement: "top"
      },
      {
        element: "#sticks_sym_licorice",
        title: "Stick conversion",
        content: `${info.attr.sticks|n}`,
        placement: "top"
      },
      {
        element: "#technical_div",
        title: "Technicalities",
        content: 'These options are best left alone at first.',
        placement: "top"
      },
      {
        element: "#submit",
        title: "Results",
        content: 'This completes the tour of the inputs. For a tour of the results, choose a demo PSE and submit the job and click the question mark.',
        placement: "top"
      }
]});

tour.init();
$('.card-title .fa-question').click(function () {
    // Initialize the tour

    // Start the tour
    if (tour.ended()) {tour.goTo(0);}
    tour.start(true);
});
