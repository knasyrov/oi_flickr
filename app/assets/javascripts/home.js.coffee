# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $("a.fancybox").fancybox()

  $(document).on 'ajax:beforeSend', 'form.form-search', ()->
    $('.images').fadeOut ()->
      $('#ajax_loader').show()
      $(@).empty()

  $(document).on 'ajax:success', 'form.form-search', (event, data, status, xhr)->
    if !data || data.length == 0
      $('.images').append("<p class='text-info'>По вашему запросу ничего не найдено</p>")
    else
      $.each data, (index, item) ->
        $('.images').append("<div class='image-pane'><a href='#{item.link}' title='#{item.title}' class='fancybox' rel='images'><img src='#{item.thumb}' class='img-thumbnail' alt='#{item.title}'/></a></div>")
    $('#ajax_loader').hide()
    $('.images').fadeIn()

  $(document).on 'ajax:error', 'form.form-search', (event, xhr, status)->
    $('#ajax_loader').hide()
    $('.images').fadeIn()    
    alert xhr.responseText