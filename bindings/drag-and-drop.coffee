#http://smellegantcode.wordpress.com/2012/12/26/jquery-ui-drag-and-drop-bindings-for-knockout-js/
#http://www.knockmeout.net/2011/05/dragging-dropping-and-sorting-with.html

#connect items with observableArrays
###
ko.bindingHandlers.sortableList =
  init: (element, valueAccessor, allBindingsAccessor, context) ->
    $(element).data("sortList", valueAccessor()) #attach meta-data
    $(element).sortable
      update: (event, ui) ->
        item = ui.item.data("sortItem")
        if item
          #identify parents
          originalParent = ui.item.data "parentList"
          newParent = ui.item.parent().data "sortList"
          #figure out its new position
          position = ko.utils.arrayIndexOf ui.item.parent().children(), ui.item[0]
          if (position >= 0)
            #originalParent.remove item
            newParent.splice position, 0, item
      connectWith: '.container'

#attach meta-data
ko.bindingHandlers.sortableItem =
  init: (element, valueAccessor) ->
    options = valueAccessor()
    $(element).data("sortItem", options.item)
    $(element).data("parentList", options.parentList)
###

# removeFromList [default=flase] - remove from drag list, when dropped
ko.bindingHandlers.draggable =
  init: (element, valueAccessor, allBindingsAccessor) ->
    options = valueAccessor()
    $(element).draggable
      containment: 'window',
      helper: (evt, ui) ->
        h = $(element).clone().css width: $(element).width(), height: $(element).height()
        h.data("ko.draggable.item", options.item)
        h.data("ko.draggable.parentList", options.parentList)
        h.data("ko.draggable.options", allBindingsAccessor().draggableOpts)
        return h
      appendTo: 'body'

#Options
# compareField - find item in list by this field, skip adding to list if found
# appendToDropList [default=true] - append to drop list, when dropped
ko.bindingHandlers.droppable =
  init: (element, valueAccessor, allBindingsAccessor, context) ->
    $(element).droppable
      #tolerance: 'pointer'
      #hoverClass: 'dragHover'
      #activeClass: 'dragActive'
      drop: (evt, ui) ->
        opts = allBindingsAccessor().droppableOpts
        dropList = valueAccessor()
        item = ui.helper.data("ko.draggable.item")
        dragList = ui.helper.data("ko.draggable.parentList")
        dragOpts = ui.helper.data("ko.draggable.options")
        if opts and opts.compareField
          f = dropList().filter((f) -> f[opts.compareField]() == item[opts.compareField]())[0]
          if f
            return
        if dragOpts and dragOpts.removeFromList
          dragList.remove item
          if dragOpts and dragOpts.afterRemove
            dragOpts.afterRemove dropList, item
        if opts and opts.appendToList == false
          return
        dropList.splice 0, 0, item
        if opts and opts.afterAppend
          opts.afterAppend dropList, item

        console.log item
