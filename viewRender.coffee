#Default render engine, use `jsrender` templates to generate partial views
define ->

  #**render (path, done)**#
  #
  #Render html, by the template defined in file with path `path`
  #
  #+ Partial views could be included
  #+ Any element with `data-partial-view='path-to-partial-view'` will be considered as container for partial view
  #+ Partial view containers also could define parameters via `data-partial-view-bag='{json-stingifyed}'`
  #these parameters will be used while generating elements values/attributes via `jsrender` engine
  #+ Partial views are loaded asyncronously from server via `requirejs`.
  #+ After all partial views loaded and genrated (each partial view is appended as nested element to its container)
  # `done` method is invoked such as `done (err, html)`, where html is generated html.
  render = (bodyPath, done) ->
    async.waterfall [
      (ck) ->
        require ["ural/libs/text!#{bodyPath}"], (bodyHtml) ->
          ck null, bodyHtml
      , (bodyHtml, ck) ->
        _renderPartialViews bodyHtml, ck
    ], done

  _renderPartialViews = (html, callback) ->
    html = "<div>#{html}</div>"
    __renderPartialViews html, (err, renderedHtml) ->
      if renderedHtml then renderedHtml = $(renderedHtml).html()
      callback err, renderedHtml

  __renderPartialViews = (html, callback) ->
    partialViews = $("[data-partial-view]", html)
    rawPaths = $.makeArray(partialViews.map (i, p) -> $(p).attr "data-partial-view")
    paths = rawPaths.map (p) -> "ural/libs/text!#{p}"
    if paths.length
      require paths, ->
        partialHtmls = _argsToArray arguments
        viewsHash = []
        for partialHtml, i in partialHtmls
          $h = $(html)
          idx = viewsHash[rawPaths[i]]
          idx ?= 0
          $pratialViewTag = $h.find "[data-partial-view='#{rawPaths[i]}']:eq(#{idx})"
          viewsHash[rawPaths[i]] = idx+1
          viewBag = $pratialViewTag.attr "data-partial-view-bag"
          $pratialViewTag.removeAttr "data-partial-view"
          $pratialViewTag.removeAttr "data-partial-view-bag"
          jViewBag = if viewBag then eval "(#{viewBag})" else {}
          $.templates pvt : partialHtml
          partialHtml = $.render.pvt jViewBag
          $pratialViewTag.html partialHtml
          html = "<div>#{html}</div>"
        async.forEachSeries partialHtmls
        ,(ph, ck) ->
          __renderPartialViews $h[0], (err, renderedHtml) ->
            html = renderedHtml
            ck err
        ,(err) -> callback err, html
    else
      callback null, html

  _argsToArray = (args) ->
    for i in [0..args.length-1]
      args[i]

  render : render