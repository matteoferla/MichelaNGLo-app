<%page args="structure, toggle_fx=True, viewport='viewport', variants=[], save=False, backgroundColor='white', lipid=False, image=False, tag_wrapped=False, **other" />

% if tag_wrapped: ###will always be false. But it is here to make the IDE behave.
    <script type="text/javascript">
% endif

var id = ${viewport};
var proteins = [];
var backgroundColor = ${backgroundColor};

NGL.specialOps.multiLoader(id, proteins, backgroundColor, 0);






% if tag_wrapped: ###will always be false. But it is here to make the IDE behave.
    </script>
% endif
