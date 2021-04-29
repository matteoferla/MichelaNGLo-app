### contents is fom self.generic_data (VenusBase class) in turn imported from venus_text.py
% for entry in contents:
    <div class="modal" tabindex="-1" role="dialog" id="${entry['id']}">
    %if 'xl' in entry:
      <div class="modal-dialog modal-xl">
    %else:
      <div class="modal-dialog">
    %endif
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
                %if 'icon' in entry:
                <i class="far fa-${entry['icon']}"></i>
                %else:
                <i class="far fa-lightbulb-on"></i>
                %endif
                ${entry['title']}</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
              <p>${entry['description']|n}</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
% endfor