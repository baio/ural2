define ->

  setup : (local, done) ->

    require ["ural/localization/#{local}/controller.text"], (controllerText) ->
      window.localization =
        controller :
          text : controllerText
      if done then done()


