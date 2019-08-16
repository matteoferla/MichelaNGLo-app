<%inherit file="layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Monitor
</%block>
<%block name="subtitle">
            These are the images that are tracked
</%block>

<%block name="main">
    %if status == 'monitoring' or status == 'generating':
    <div class="alert alert-success">
       <h4 class="alert-heading">Protected</h4>
       <p>Your <a href="/data/${page}">page</a> is marked as publication-ready/published, so these conditions are enforced.</p>
       <hr/>
       <p>If you erroneously activated this feature press the following:
           <button type="button" class="btn btn-danger" onclick="alter_protection('deprotection')"><i class="far fa-lock-open"></i> Unprotect page</button></p>
    </div>
    %else:
    <div class="alert alert-warning">
       <h4 class="alert-heading">Unprotected</h4>
       <p>Your <a href="/data/${page}">page</a> is not protected.</p>
       <hr/>
       <p>To activate this feature press the following:
           <button type="button" class="btn btn-success" onclick="alter_protection('protection')"><i class="far fa-lock-open"></i> Unprotect page</button></p>
    </div>
    %endif

   <p>A page marked as publication-ready/published must remain stable for many years, therefore the following are enforced:
   </p>
       <ul>
       <li>It is deletion protected</li>
       <li>A backup has been made</li>
       <li>prolink monitoring</li>
       </ul>
   <p>The system will monitor every month [TODO SET SCHEDULER] that the prolinks generate the same images and that the content is consistent with that stored.
       If something differs, the admin will be notified and action will be taken as follows:</p>
       <ol>
        <li><b>Bug</b>: the issue will be corrected if possible, else you will be contacted (extremely unlikely).</li>
        <li><b>Minor edit</b>*: no action. (&lowast;borrowing the definition from <a href="https://en.wikipedia.org/wiki/Help:Minor_edit">  Wikipedia <i class="far fa-external-link"></i></a>)</li>
        <li><b>Major edit</b>: you will be contacted to verify this was truly you.</li>
       </ol>

   <h2>Prolink monitoring</h2>
   %if status == 'monitoring':
       <p>The following images are monitored:</p>
       <div class="row">
           %for i in range(len(labels)):
               <div class="col-12 col-xl-3">
                   <div class="card mb-2">
                      <img class="card-img-top" src="/monitor/${page}?image=${i}" alt="${i}">
                      <div class="card-body">
                        <h5 class="card-title">Link &#8470; ${i+1}</h5>
                        <p class="card-text">${labels[i]}</p>
                      </div>
                    </div>
               </div>
           %endfor
       </div>
   %elif status == 'generating':
       <p>Generating data... Come back in a minute</p>
   %else:
      <p>This page is not protected.</p>
   %endif

</%block>


<%block name='scripts'>
    <script type="text/javascript">
        window.alter_protection = (mode) => {
            $.ajax({
                type: "POST",
                url: "/set",
                data: {item: mode,
                       page: "${page}"
                       }
            }).done(msg => ops.addToast('requested',mode, msg.status ,'bg-success'))
                .fail(ops.addErrorToast);
        };
    </script>
</%block>
