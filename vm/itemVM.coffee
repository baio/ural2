define ["ural/modules/pubSub"], (pubSub) ->

  class ViewModel

    constructor: (@resource, @_index) ->
      @init()

    @KeyFieldName: null

    _isAdded: ->
      if ViewModel.KeyFieldName then (@[ViewModel.KeyFieldName]() is null) else false

    init: ->
      # `ko.mapping.toJS` - works only after `ko.mapping.fromJS` was executed
      data = {}
      for own prop of @
        if ko.isObservable(@[prop]) and !ko.isComputed(@[prop])
          if @[prop]() is undefined
            if @[prop].destroyAll
              data[prop] = []
            else
              data[prop] = null
          else
            data[prop] = @[prop]()

      ko.mapping.fromJS data, {}, @

    completeUpdate: (data) ->
      if @src
        #item was in edit mode
        data = if !data then @toData() else data
        @src.item.map data
      else
        #direct update
        @map data

    completeCreate: (data) ->
      data = if !data then @toData() else data
      if @_index then @_index.add data, 0
      #@setSrc null, null
      @map data

    completeRemove: ->
      if @src.item._index
        @src.item._index.list.remove @src.item
      @setSrc null, null

    map: (data) ->

      data = data[0] if $.isArray()
      dataIndexVM = {}

      #exclude index view models from mapping
      for own prop of @
        #TO DO: change property check to instanceof ItemVM (Circular Dependencies problem)
        if @[prop] and data[prop] and @[prop].list
          dataIndexVM[prop] = data[prop]
          delete data[prop]

      #convert fields to js dates
      for own prop of data
        d = @tryDate data[prop]
        data[prop] = d if d

      ko.mapping.fromJS data, {}, @

      #map index view models now
      for own prop of dataIndexVM
        @[prop].map dataIndexVM[prop]

      if ko.validation
        @_validationGroup = ko.validation.group @
        @setIsModified(false)

    setIsModified: (val) ->
      for own prop of @
        if ko.isObservable(@[prop])
          @[prop].isModified?(val)

    tryDate: (str) ->
      if str and typeof str == "string"
        match = /\/Date\((\d+)\)\//.exec str
        if match
          moment(str).toDate()

    clone: (status) ->
      vm = @onCreateItem()
      vm.map @toData()
      vm.setSrc @, status
      vm

    onCreateItem: ->
      new ViewModel @resource, @_index

    setSrc: (item, status) ->
      @src =
        item : item
        status : status

    cancel: (item, event) ->
      event.preventDefault()
      pubSub.pub "crud", "end",
        resource : @resource
        type: @src.status

    confirmEvent: (event, eventName) ->
      if !event then return true
      attr = $(event.target).attr "data-bind-event"
      !attr or attr == eventName

    startUpdate: (item, event) ->
      if @confirmEvent event, "startUpdate"
        event.preventDefault()
        pubSub.pub "crud", "start",
          resource: @resource
          item: @clone "update"
          type: "update"

    startRemove: (item, event) ->
      if @confirmEvent event, "startRemove"
        event.preventDefault()
        pubSub.pub "crud", "start",
          resource: @resource
          item: @clone "delete"
          type: "delete"

    remove: ->
      if ko.isObservable(@_isRemoved)
        @_isRemoved true
      else
        @onRemove (err) =>
          @completeRemove()
          pubSub.pub "crud", "end",
            err: err
            type: @onGetRemoveType()
            msg: "Success"
            resource: @resource

    onRemove: (done)->
      #done()
      throw "not implemented"

    onGetRemoveType: -> "delete"

    details: (item, event) ->
      if @confirmEvent event, "details"
        event.preventDefault()
        pubSub.pub "crud", "details", item : @clone "details"

    startEdit: (data, event) ->
      f = @confirmEvent event, "start-edit"
      if f
        console.log "REAL start edit - store src"
        @stored_data = @toData()
        if @_isModifyedActivated
          @updateIsModifyed false
        if ko.isObservable(@_isModifyed)
          if !@_isModifyedActivated
            @activateIsModifyed()
            @_isModifyedActivated = true
      f

    updateIsModifyed: (val) ->
      if @_isModifyed() != val
        @onIsModifyedChanged val

    onIsModifyedChanged: (val) ->
      @_isModifyed val

    cancelEdit: (data, event) ->
      f = @confirmEvent event, "cancel-edit"
      if f and @stored_data
        console.log "REAL cancel edit - map from src"
        @map @stored_data, true
      f

    setErrors: (errs) ->
      for err in errs
        flag = false
        #check if not exists
        rule = @[err.field].rules().filter((f) -> f.params == "custom")[0]
        if rule then @[err.field].rules.remove rule
        @[err.field].extend
          validation:
            params: "custom"
            validator: (val, otherVal) ->
              _flag = flag
              flag = true
              _flag
            message:
              err.message

    _isIgnoreProp: (prop) ->
      #if property name starts with _, this is private property, don't map and don't listen for onModify
      #TO DO - use $ for ignore properties
      prop == "errors" or (prop.indexOf("_") == 0 and prop != "_isRemoved" and prop != ViewModel.KeyFieldName)

    toData: ->
      data = ko.mapping.toJS @
      #map children list properties
      for own prop of @
        #TO DO: change property check to instanceof ItemVM (Circular Dependencies problem)
        if @_isIgnoreProp prop
          delete data[prop]
        else if @[prop] and @[prop].list
          data[prop] = @[prop].list().map (m) -> m.toData()
      data

    activateIsModifyed: ->
      @_isModifyed false
      @updateIsModifyed @getIsModifyed()
      for own prop of @
        if !@_isIgnoreProp(prop) and ko.isObservable @[prop]
          @[prop].subscribe =>
            @updateIsModifyed @_isRemoved() or (@isValid() and @getIsModifyed())

    getIsChanged: ->
      if !@src then return false
      if @src.status == "create" then return true
      src_data = @src.item.toData()
      data = @toData()
      for own prop of src_data
        if src_data[prop] != data[prop]
          return true
      return false

    getIsModifyed: ->
      if !@stored_data then return false
      for own prop of @stored_data
        val = ko.utils.unwrapObservable(@[prop])
        if @_isAdded() or @_isRemoved()
            return not (@_isAdded() and @_isRemoved())
        if  val != @stored_data[prop] then return true
      return false

    save: (data, event) ->
      if event then event.preventDefault()
      status = @src.status
      _done = (err) =>
        @onSaved err, status
      if !@getIsChanged()
        _done()
      else if !@isValid()
        @_validationGroup?.showAllMessages(true)
        _done "Not valid"
      else if status == "create"
        @onSaving()
        @create _done
      else if status == "update"
        @onSaving()
        @update _done
      else
        throw new Error("Item not in edit state")

    onSaving: ->
      pubSub.pub "crud", "before",
        resource: @resource
        type: status

    onSaved: (err, status) ->
      pubSub.pub "crud", "end",
        resource: @resource
        type: status
        err: err
        msg: "Success"

    create: (done) ->
      @onCreate (err, data) =>
        if !err
          @completeCreate data
        done err

    onCreate: (done) ->
      throw "not implemented"
      #done()

    update: (done) ->
      @onUpdate (err, data) =>
        if !err
          @completeUpdate data
        done err

    onUpdate: (done) ->
      throw "not implemented"
      #done()

    load: (filter, done) ->
      @onLoad filter, (err, data) =>
        if !err and data
          @map data
        done err, @

    onLoad: (filter, done) ->
      done null, []

