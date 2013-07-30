define ->

  gOpts =
    baseUrl: null
    data:
      term: "Trem"
    fields:
      label: (d) -> if d.FullName then d.FullName else d.Name
      value: "Name"
      key: "Id"

  _filterFields = (viewModel, fields) ->
    data = {}
    for own field of fields
      data[field] = viewModel[fields[field]]()
    data

  _filterParams = (filterParams) ->
    data = {}
    for own field of filterParams
      data[field] = filterParams[field]()
    data

  ko.bindingHandlers.tagedit =

    init: (element, valueAccessor, allBindingsAccessor, viewModel) ->

      gopts = gOpts
      opts = allBindingsAccessor().tageditOpts
      gopts = $.extend(gopts, opts)

      _data = []
      $(element).tagit
        tagSource: (req, res) ->
          data = {}
          data[gopts.data.term] = req.term
          if opts.filterFields
            data = $.extend false, data, _filterFields(viewModel, opts.filterFields)
          if opts.filterParams
            data = $.extend false, data, _filterParams(opts.filterParams)
          $.ajax
            url: gopts.baseUrl + opts.url
            data: data
            dataType: "json"
            success: (data) ->
              m = data.map (d) ->
                data: d
                label: if $.isFunction(gopts.fields.label) then gopts.fields.label(d) else ko.utils.unwrapObservable(d[gopts.fields.label])
                value: if $.isFunction(gopts.fields.value) then gopts.fields.value(d) else ko.utils.unwrapObservable(d[gopts.fields.value])
                key: if $.isFunction(gopts.fields.key) then gopts.fields.key(d) else ko.utils.unwrapObservable(d[gopts.fields.key])
              _data = m
              res m
            minLength: 2
        afterTagAdded: (event, ui) ->
          if ui.duringInitialization then return
          console.log "tag added " + ui.duringInitialization
          d = _data.filter((f) ->f.value == ui.tagLabel)[0]
          if !d
            if gopts.getDefault
              d = gopts.getDefault(ui.tagLabel)
            else
              d = ui.tagLabel
          if gopts.toData
            d = gopts.toData(d)
          $(element).data("tag-it.frozen", true)
          valueAccessor().push d
          $(element).data("tag-it.frozen", false)
          console.log d
        afterTagRemoved: (event, ui) ->
          if gopts.labelField
            d = ko.utils.arrayFirst(valueAccessor()(), (item) -> item[gopts.labelField]() == ui.tagLabel)
            $(element).data("tag-it.frozen", true)
            valueAccessor().remove d
            $(element).data("tag-it.frozen", false)
          console.log ui

      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        console.log "destroy"
        $(element).tagit("destroy")

    update: (element, valueAccessor, allBindingsAccessor) ->
      if $(element).data("tag-it.frozen") then return
      gopts = gOpts
      opts = allBindingsAccessor().tageditOpts
      gopts = $.extend(gopts, opts)
      value = ko.utils.unwrapObservable valueAccessor()
      #console.log value
      if value.length
        valLabels = value.map (m) ->
          if $.isFunction(gopts.fields.label) then gopts.fields.label(m) else m[gopts.fields.label]()
        #remove unused
        assignedTags = $(element).tagit("assignedTags")
        for label in assignedTags
          if valLabels.indexOf(label) == -1
            $(element).tagit("removeTag", label, null, true)
        #append new
        assignedTags = $(element).tagit("assignedTags")
        for label in valLabels
          #label = if $.isFunction(gopts.fields.label) then gopts.fields.label(tag) else tag[gopts.fields.label]()
          if assignedTags.indexOf(label) == -1
            $(element).tagit("createTag", label, null, true)
      else
        $(element).tagit("removeAll")

  gOpts