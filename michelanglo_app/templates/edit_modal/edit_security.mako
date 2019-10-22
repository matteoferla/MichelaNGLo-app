<div id="security">

    <a href="#" data-toggle="collapse" data-target="#security .collapse">Security <span class="collapse show"><i class="far fa-chevron-double-down"></i></span>
        <span class="collapse">
            <i class="far fa-chevron-double-up"></i></span></a>


    <div class="collapse">
        <p>Currently, the address to your data contains <a href="https://en.wikipedia.org/w/index.php?title=Universally_unique_identifier" target="_blank">a long id, which cannot be guessed (five undecillion combinations) <i class="far fa-external-link"></i></a>.
        However, if the server is compromised or the administrator turns evil the data can be seen &mdash;note that this does not apply your password, which cannot be seen as it is stored hashed.
            If your data is <i>extremely</i> sensitive, the data can be encrypted serverside. This requires the encryption password each time the data is requested to be viewed &mdash;as you may share this page and its password please do not use your log-in password. <b>Note that, if you forget the key, the data is lost, so please proceed with care.</b></p>
        <div class="input-group">
      <div class="input-group-prepend">
          <div class="input-group-text px-2">
                <div class="custom-control custom-switch">
              <input type="checkbox" class="custom-control-input user-editable-state" id="encryption"
                 %if encrypted:
                    checked
                %endif
                    >
              <label class="custom-control-label" for="encryption">use encryption</label>
            </div>
          </div>
      </div>

                <input type="password" class="form-control" aria-label="encryption key" id="encryption_key" autocomplete="new-password"
            %if encrypted:
                value="${encryption_key}"
            %else:
                placeholder="key"
            %endif
                >
    </div>
        <div class="valid-feedback" id="encryption_key_error">No key provided</div>

        <p class="pt-3">Alternatively, If the worry is more collaborators sharing this information, you can enable a nice 'confidential' banner on top:</p>
    <div class="custom-control custom-switch">
          <input type="checkbox" class="custom-control-input user-editable-state" id="confidential"
                %if confidential:
                    checked
                %endif
                    >
          <label class="custom-control-label" for="confidential">Confidential</label>
        </div>
        <br/>
    <p>Lastly, you can make the page publicly listed. Search engines do not and cannot know about your page and cannot parse them otherwise. Enabling this will disable encryption.</p>
        <div class="custom-control custom-switch">
          <input type="checkbox" class="custom-control-input user-editable-state" id="public"
                 %if public:
                    checked
                 %endif
                    >
          <label class="custom-control-label" for="public">Public</label>
        </div>

    </div>
</div>
<hr/>
<p>If you want to use a page in a publication the page must be guaranteed to not change. See <a href="/monitor/${page}" target="_blank">monitoring page</a>.</p>

