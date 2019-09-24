/*
<%namespace file="../layout_components/labels.mako" name="info"/>
<%doc>
 This file is a mako template to make JS. The extension is backwards to avoid tinkering with the default PyCharm editor.
 This file contains the main page's tour.
</%doc>
*/

%if not remote:
window.tour = new Tour({
    framework: "bootstrap4",
    debug: false,
    showProgressBar: false,
    showProgressText: false,
    backdrop: true,
    storage: window.sessionStorage,
    template: `<div class="popover" role="tooltip"> 
                <div class="arrow"></div>
                <h3 class="popover-header"></h3>
                <div class="popover-body"></div>
                <div class="popover-navigation">
                    <div class="btn-group">
                        <button class="btn btn-sm btn-outline-primary" data-role="prev">&laquo; Prev</button>
                        <button class="btn btn-sm btn-outline-primary" data-role="next">Next &raquo;</button> 
                        <button class="btn btn-sm btn-outline-warning" data-role="pause-resume" data-pause-text="Pause" data-resume-text="Resume">Pause</button>
                    </div>
                    <button class="btn btn-sm btn-outline-warning" data-role="end">End tour</button>
                </div> </div>`,
    steps: [{
        element: "#viewport",
        title: "Viewport",
        content: 'This is what NGL calls the viewport. The web element containing your protein. This tutorial will guide you in making links that control the view ("prolinks")',
        placement: "top"
      },
      {
          element: "#viewport_menu_popover i",
          title: "Viewport controls",
          content: 'This button shows a menu with various controls, including the list of keys to better move the view around. Of note is the control key which pans.',
          placement: "left",
          onNext: tour => $("#controlguide_modal").modal('show')
      },{
          element: "#viewport_menu_popover i",
          title: "Viewport keys",
          content: 'Of note is the control key which pans.',
          placement: "right",
          onNext: tour => $("#controlguide_modal").modal('hide')
      },
        {
        element: "#getimplement",
        title: "Implement",
        content: 'Here you can find copy-pastable code that allows you to implement this view on your own site.',
        placement: "top"
        },
        {
        element: "#edit_btn",
        title: "Edit",
        content: 'To change the title and description, including creating prolinks, you click here.',
        placement: "left",
        onNext: tour => $("#edit_modal").modal('show')
        },
        {
        element: "#edit_btn",
        title: "Hidden",
        content: '...',
        placement: "left",
        onShown: tour => tour.next()
        },{
        element: "#edit_title",
        title: "Title",
        content: 'This is the title at the top of the page. It does not accept HTML or markdown. To add a title to the description add <code>## title</code> as the first element.',
        placement: "bottom"
        },
        {
        element: "#edit_description",
        title: "Description",
        content: 'This is the editor for the text on the side. Where you can add text with prolinks to control what the visitor sees.',
        placement: "top"
        },
        {
        element: "#formatting_help",
        title: "Description",
        content: 'The editor is in markdown format. For more click here.',
        placement: "left"
        },
        {
        element: "#edit_modal .prolink:eq(0)",
        title: "Prolink",
        content: 'A prolink is a protein view controlling link. When outside of the editor they will be styles green (you can change that) and when you click on it it will alter the protein. In the editor it will look like this.',
        placement: "top"
        },
        {
        element: "#collapse_prolinks",
        title: "Prolinks",
        content: 'When this is checked prolinks are shown as <code>@prolink#n[text]</code>, which is handy for compactness, uncheck to edit of the values.',
        placement: "top"
        },
        {
        element: "#markup_modal_btn",
        title: "Prolink builder",
        content: 'You can manually write a prolink (following the guidelines in the <a href="/docs/markup">documentation</a>) or you can click here. If before clicking this, you select a span of text the prolink will appear there.',
        placement: "bottom",
        onNext: tour => $("#markup_modal").modal('show')
        },
        {
        element: "#edit_btn",
        title: "Hidden",
        content: '...',
        placement: "left",
        onShown: tour => tour.next()
        },
        {
        element: "#domain",
        title: "Focus on domain",
        content: 'There are different types of focusing styles for a selection. If you want to show a domain choose this...',
        placement: "bottom"
        },
        {
        element: "#residue",
        title: "Focus on residue",
        content: '...or if you want to show a few residues choose this.',
        placement: "bottom"
        },
        {
        element: "#markup_selection",
        title: "Selection",
        content: 'Here you specify what you want to select. <code>*</code> will select everything, while <code>23</code> will select all residues numbered 23.',
        placement: "bottom"
        },
        {
        element: "#markup_selection",
        title: "Selection (cont'd)",
        content: `The selection is in the <a href="http://nglviewer.org/ngl/api/manual/selection-language.html" target="_blank">NGL selection format</a>.
                    For example, <code>23:A</code> will select chain A residue 23. For ranges use a hyphen <code>23-26:A</code>.
                    For multiple selections use "or" <code>23:A or 25:A</code>.
                    To find out what is the chain ID of a chain simply hover over the viewport.`,
        placement: "bottom"
        },
        {
        element: "#markup_color",
        title: "Color",
        content: 'Teal is so last year. I hear mustard is the in color this year...',
        placement: "bottom"
        },
        {
        element: "#markup_model",
        title: "Model",
        content: 'This select element allows you specify which "model" to choose. We will go into this at a later step of the tour.',
        placement: "bottom"
        },
        {
        element: "#markup_current",
        title: "Get current orientation",
        content: 'Move the protein around. A warning will appear telling you that the orientation differs from that stored, click here to use the current orientation.',
        placement: "bottom"
        },
        {
        element: "#usespan",
        title: "Use this or cancel",
        content: 'Once you are pleased you can use the prolink created.',
        placement: "top",
        onNext: tour => $("#markup_modal").modal('hide')
        },
        {
        element: "body",
        title: "Hidden",
        content: '...',
        placement: "left",
        delay: 1000,
        orphan: true,
        onShown: tour => tour.next()
        },
        {
        element: "#edit_description",
        title: "New prolink",
        content: 'If you clicked on use, the new prolink will appear around the text you selected before clicking on the link, or if no selection was done it will appear at the top (best practice to move a prolink is to uncollapse the links otherwise you risk loosing bits).',
        placement: "top"
        },
        {
        element: "#columns_viewport",
        title: "Proportions",
        content: 'The size of the viewport (the divider with the canvas with the protein) can be altered with this.',
        placement: "top"
        },
        {
        element: "#image",
        title: "Image",
        content: 'If you have a nice picture online somewhere of your protein you can add that here and image will load instead of the viewport and the protein will load when the image is clicked to dismiss it.',
        placement: "right"
        },
        {
        element: "#page_users",
        title: "Users",
        content: 'Control who can edit this page. Remember that only people you share the link with can see this page. So freely editable mode is as safe as the people you share the link with.',
        placement: "top",
        onNext: tour => $('#security').click()
        },
        {
        element: "#security",
        title: "Security",
        content: 'The security of the page can be furthered customised.',
        placement: "top"
        },
        {
        element: "#mutate_modal_btn",
        title: "Mutate",
        content: 'If you want to create a bunch of point mutations, click here. These will be different models, that can be toggled using the <code>data-load</code> attribute in the prolinks or via the select element in the prolink builder modal',
        placement: "bottom"
        },
        {
        element: "#combine_modal_btn",
        title: "Advanced. Combine",
        content: 'If you want to show two different protein structures or two different complicated views (i.e. PyMOL generated) this is the modal for you.',
        placement: "bottom"
        },
        {
        element: "#chat_modal_btn",
        title: "Questions?",
        content: 'If you still have questions feel free to contact the admin. Also, if can code and would like to do something that is not covered by the GUI, why not check out the <a href="/docs/api">API documentation</a>',
        placement: "left"
        }
]});
$('#tour').click(function () {
    if (tour.ended()) {tour.restart();} else {tour.start()}
});
%endif
