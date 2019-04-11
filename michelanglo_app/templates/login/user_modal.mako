<div class="modal fade" tabindex="-1" role="dialog" id="login">
  <div class="modal-dialog" role="document">
      %if user:
          #### user mode... logout and pages
            <%include file="logout_modalcont.mako"/>
      %else:
          <%include file="login_modalcont.mako"/>
      %endif
  #### login mode...





  </div>
</div>
