define ["ural/viewRender"], (viewRender) ->

  _layoutModelsData = []

  #** render(path, done) **
  #
  #see viewRender.render
  render = (path, done) ->
    viewRender.render path, done

  #** render(path, done) **
  #
  #Apply data binding to generated html, append generated html to layot (static .html)
  #
  #This is default view engine
  #+ All viewbag data will be bound to `bodyHtml` jsrender template values
  #+ Rendered `layoutHtml` html will be appended to the container element with `id=_layout`
  #+ `layoutModelData :
  #     [{layot : "name of the layout to apply data binding to"},
  #     {data : data to apply as data-binding for corresponding layout}]`
  #
  #This abstraction level needed because binding is depended on view engine used,
  #also you could choose diffrent procedures to bind data, for example - bind model to jsrender templates values instead
  #of knockout ones, or before applying values to html template merge model and viewBag data.
  applyData = (bodyHtml, layoutModelsData, viewBag, isApply) ->

    $.templates pvt : bodyHtml
    layoutHtml = $.render.pvt viewBag

    for lmd in _layoutModelsData
      lt = $("#" + lmd.layout)[0]
      ko.cleanNode lt
      $("[data-view-engine-clean]", lt).empty()
    _layoutModelsData = []

    $("#_layout").empty()
    $("#_layout").append layoutHtml

    if isApply
      ###
      for lmd in layoutModelsData
        lt = $("#" + lmd.layout)[0]
        if !lt then throw "Layout [#{lmd.layout}] to apply bindings not found"
        ko.applyBindings lmd.data, lt
      ###
      applyBinding(layoutModelsData)
      _layoutModelsData = layoutModelsData

      if $("#layout_loading").is(":visible")
        $("#layout_loading").hide()
        $("#layout_content").show()

  applyBinding = (layoutModelsData) ->
    for lmd in layoutModelsData
      lt = $("#" + lmd.layout)[0]
      if !lt then throw "Layout [#{lmd.layout}] to apply bindings not found"
      ko.applyBindings lmd.data, lt

  render : render
  applyData : applyData
  applyBinding : applyBinding