app = window.App ||= {}

class app.AccountHelper

    @showCopyMessage: (e, name) ->
      parent = $(e.target.closest(name)).parent()
      if $(parent).hasClass('result-password select-click')
          message = '<p class="copied" >Password copied! </p>'
          div = '.result-password'
      else
          message = '<p class="copied" >Username copied! </p>'
          div = '.result-username'
      $(message).appendTo div
      parent.find($('.copied')).fadeIn('fast')
      setTimeout (->
        $(div).find($('.copied')).fadeOut('fast')
        $(div).find($('.copied')).remove()
        return
      ), 2000
