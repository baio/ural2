define ->

  gOpts =
      baseUrl: null
      data:
        term: "Trem"
      fields:
        label: (d) -> if d.FullName then d.FullName else d.Name
        value: "Name"
        key: "Id"

  _updateAutocompleteFields = (viewModel, fields, item, isResetOnNull) ->
    for own field of fields
      if item and item.data
        viewModel[fields[field]] item.data[field]
      else if isResetOnNull
        viewModel[fields[field]] null

  _filterFields = (viewModel, fields) ->
    data = {}
    for own field of fields
      data[field] = viewModel[fields[field]]()
    data

  _filterParams = (filterParams) ->
    data = {}
    for own field of filterParams
      prm = filterParams[field]
      prm = prm() if $.isFunction(prm)
      data[field] = prm
    data


  ko.bindingHandlers.autocomplete =

    init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
      gopts = gOpts
      opts = allBindingsAccessor().autocompleteOpts
      opts.allowNotInList = true if opts.allowNotInList == undefined
      gopts = $.extend(gopts, opts)
      $(element).autocomplete
        source: ( request, response ) ->
          data = {}
          data[gopts.data.term] = $(element).val()
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
                label: if $.isFunction(gopts.fields.label) then gopts.fields.label(d) else d[gopts.fields.label]
                value: if $.isFunction(gopts.fields.value) then gopts.fields.value(d) else d[gopts.fields.value]
                key: if $.isFunction(gopts.fields.key) then gopts.fields.key(d) else d[gopts.fields.key]
              response m
            minLength: 2
        select: (event, ui) ->
          valueAccessor() ui.item.value
          _updateAutocompleteFields viewModel, opts.fields, ui.item, opts.resetRelatedFieldsOnNull
        change: (event, ui) ->
          observable = valueAccessor()
          observable (if opts.allowNotInList or ui.item  then $(element).val() else null)
          $(element).val observable()
          _updateAutocompleteFields viewModel, opts.fields, ui.item, opts.resetRelatedFieldsOnNull

    update: (element, valueAccessor, allBindingsAccessor) ->
      opts = allBindingsAccessor().autocompleteOpts
      value = ko.utils.unwrapObservable valueAccessor()
      if $(element).val() != value
        $(element).val value

  gOpts