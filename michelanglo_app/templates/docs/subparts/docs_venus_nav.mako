<%page args="topic"/>

<div class="btn-group ml-5 mb-3" role="group" aria-label="VENUS docs nav">
    <div class="input-group-prepend">
      <div class="input-group-text">VENUS</div>
    </div>
  <a href="/docs/venus" class="btn btn-outline-primary ${'disabled' if topic=='main' else ''}">Main</a>
  <a href="/docs/venus_hypothesis" class="btn btn-outline-info ${'disabled' if topic=='hypothesis' else ''}">Hypothesis generation</a>
  <a href="/docs/venus_model" class="btn btn-outline-info ${'disabled' if topic=='model' else ''}">model choice</a>
  <a href="/docs/venus_energetics" class="btn btn-outline-info ${'disabled' if topic=='energy' else ''}">Free energy</a>
  <a href="/docs/venus_urls" class="btn btn-outline-info ${'disabled' if topic=='url' else ''}">URLs</a>
</div>