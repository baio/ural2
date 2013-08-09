define ->

  _getDataPropertyType = (prop) ->

    if ko.isComputed(prop)
      return "data_property_computed_observable"

    val = ko.utils.unwrapObservable(prop)
    if val
      if Array.isArray val
        return "data_property_array"
      else if $.isPlainObject(val)
        return "data_property_object"
      else
        return "data_property"
    else
      if ko.isObservable(prop)
        if prop.destroyAll
          return "data_property_array"
        else
          return "data_property"
      else
        return undefined

  #get property value, uzip observables
  _getPropVal = (prop) ->
    propType = _getDataPropertyType prop
    prop = ko.utils.unwrapObservable prop
    switch propType
      when "data_property"
        return prop
      when "data_property_array"
        res = []
        if prop
          for i in prop
            res.push object2json(i)
        return res
      when "data_property_object"
        return @_getPropVal prop
      else
        return undefined

  #convert object with observable properties to json structure
  object2json = (obj) ->
    data = {}
    for own prop of obj
      if prop[0] != '_'
        val = _getPropVal(obj[prop])
        if val != undefined
          data[prop] = val
    data


  object2json : object2json
