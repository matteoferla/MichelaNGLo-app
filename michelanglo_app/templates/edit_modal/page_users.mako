<div id="page_users">
    <div class="custom-control custom-switch">
          <input type="checkbox" class="custom-control-input user-editable-state" id="freelyeditable"
                %if freelyeditable:
                    checked
                %endif
                    >
          <label class="custom-control-label" for="freelyeditable">Any registered user with the link can edit it.</label>
        </div>
    <div class="invalid-feedback" id="freelyeditable_error">Public pages cannot be freely edited.</div>

    <div id="authorlist"
    %if freelyeditable:
        style="display: none;"
    %endif
    >
    <p>This is the list of users that have edited, could edit or cannot edit the page.</p>
<ul class="fa-ul">
%for author in authors:
    <li><span class="fa-li" data-toggle="tooltip"  title="can and has edited page"><i class="far fa-user-edit"></i></span> ${author}</li>
%endfor
%for author in editors:
    % if author not in authors:
        <li><span class="fa-li"  data-toggle="tooltip" title="can but hasn't edited page"><i class="far fa-user-tag"></i></span> ${author}</li>
    % endif
%endfor
%for author in visitors:
    % if author not in authors and author not in editors:
        <li  title="can't edit page" data-toggle="tooltip"><span class="fa-li" ><i class="far fa-user-times"></i></span> ${author} &nbsp;
            <div class="custom-control custom-switch" style="display: inline;">
              <input type="checkbox" class="custom-control-input user-editable-state" id="switch${author}" data-user="${author}">
              <label class="custom-control-label" for="switch${author}">can edit</label>
            </div>
        </li>
    % endif
%endfor
    <li><span class="fa-li"  data-toggle="tooltip" title="Write user name. Beware of capitalisation."><i class="far fa-user-plus"></i></span> <div class="input-group-sm"><input type="text" id="input_author" class="form-control" placeholder="username"></div></li>
    </ul>
    </div>
</div>
