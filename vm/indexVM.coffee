define ["ural/vm/itemVM", "ural/modules/pubSub"], (itemVM, pubSub) ->

  class ViewModel

    constructor: (@resource) ->
      @list = ko.observableArray()
      pubSub.sub "crud", "complete_create", (item) => @completeCreate item
      pubSub.sub "crud", "complete_delete", (item) => @completeDelete item
      @initHotKeys()

    completeDelete: (item) ->
      if item.resource == @resource
        @list.remove item.src.item

    completeCreate: (item) ->
      if item.resource == @resource
        item.setSrc null, null
        @list.push item

    add: (data, idx) ->
      item = @createItem data
      item.startEdit()
      idx = @list().length - 1 if idx is not undefined
      @list.splice idx, 0, item
      #Newly created item is not modifyed when key begins with _ since src_data, won't contain this property
      @updateIsModifyed()
      @listenItemIsModifyed(item)

    map: (data) ->
      underlyingArray = @list()
      underlyingArray.splice 0, underlyingArray.length
      underlyingArray.push(@createItem(d)) for d in data
      @list.valueHasMutated()

    load: (filter, done) ->
      @onLoad filter, (err, data) =>
        if !err
          @map data
        done err, @

    onLoad: (filter, done) ->
      done null, []

    save: ->
      @update ->

    update: (done) ->
      res = []
      #check isAdded the same time isRemoved, then remove ones from list
      @list.remove (item) -> item._isAdded() and item._isRemoved()
      list = if @_isModifyedActivated then @getModifyedItems() else @list()
      if !list.length
        done()
        return
      for item in list
        if item.toData
          res.push item.toData()
        else
          res.push item
      @onUpdate res, (err, r) =>
        if !err
          for i in [0..r.length-1]
            item = list[i]
            if r[i].err.length == 0
              if item._isRemoved()
                @list.remove item
              else
                #update key field
                if itemVM.KeyFieldName
                  item[itemVM.KeyFieldName](r[i][itemVM.KeyFieldName])
                item.startEdit()
            else
              item.setErrors(err)
          @updateIsModifyed()
        done err

    onUpdate: (data, done) ->
      done null

    createItem: (data, status) ->
      vm = @onCreateItem()
      if data
        vm.map data
      if status
        vm.setSrc null, status
      vm

    onCreateItem: ->
      new itemVM @resource, @

    startCreate: (some, event) ->
      if event then event.preventDefault()
      pubSub.pub "crud", "start",
        resource: @resource
        item: @createItem(@resource, "create")
        type: "create"

    activateIsModifyed: ->
      @_isModifyed false
      for item in @list()
        item.activateIsModifyed()
        @listenItemIsModifyed(item)

    listenItemIsModifyed: (item) ->
      if @_isModifyedActivated
        item._isModifyed.subscribe (val) =>
          @updateIsModifyed val

    updateIsModifyed: (val) ->
      if @_isModifyedActivated
        f = val || @getIsModifyed()
        @_isModifyed(f)

    getIsModifyed: ->
      for item in @list()
        if item._isModifyed()
          return true
      return false

    getModifyedItems: ->
      res = []
      for item in @list()
        if item._isModifyed()
          res.push item
      res

    startEdit: ->
      if ko.isObservable(@_isModifyed)
        if !@_isModifyedActivated
          @_isModifyedActivated = true
          @activateIsModifyed()

    initHotKeys: ->
      Mousetrap.bindGlobal '+', =>
        @startCreate()
        false

