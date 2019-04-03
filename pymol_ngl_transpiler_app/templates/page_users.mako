<div id="page_users">
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
    % endif
%endfor
    </ul>
</div>
