# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

#require i18n/translations

# scope for global functions
app = window.App ||={}

class app.ApiUserUpdate
  constructor: () ->
    bind.call()

  ENTER_KEYCODE = 13

  updateApiUserValidFor = (user_id, valid_for) ->
    data = { attributes: { valid_for: valid_for } }
    updateApiUser(user_id, data)

  updateApiUserDescription = (user_id, description) ->
    data = { attributes: { description: description } }
    updateApiUser(user_id, data)

  updateApiUser = (id, data) ->
    $.ajax({
      type: "PATCH",
      url: '/api/api_users/' +id,
      data: { data }
    })

  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')

  hasDescription = (elem) ->
    $(elem).text().trim()!= I18n.t 'profile.api_users.enter_description'

  replace = (toReplace, replaceWith) ->
    toReplace.hide()
    toReplace.after replaceWith
    replaceWith.focus()

  saveDescription = (input, textfield) ->
    textfield = $(textfield)
    newDescription = $(input).val().trim()
    oldDescription = textfield.text().trim()
    if(newDescription != '' and newDescription != oldDescription)
      updateApiUserDescription(id(input), newDescription)
      textfield.text(newDescription)
    input.remove()
    textfield.show()

  bind = ->
    $(document).on 'click', '#dropdown_valid_for', (e) ->
      e.preventDefault()
      valid_for = $(this).closest('li').attr('val')
      updateApiUserValidFor(id(this), valid_for)
      $(this).parents('.dropdown').find('.dropdown-toggle span:first').text($(this).text())

    $(document).on 'click', '.api-user-description', ->
      elem = this
      user_id = id(elem)
      replaceWith = $('<input class="hiddenFied" id="descriptionInput" type="text" />')
      if(hasDescription(elem))
        replaceWith.val($(elem).text().trim())

      replace($(this), replaceWith)
      replaceWith.keypress (e) ->
        if(e.which == ENTER_KEYCODE)
          this.blur()
      replaceWith.blur ->
        saveDescription(this, elem)

  new ApiUserUpdate
