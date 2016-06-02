//= require tag-it
//= require icheck

$(document).on('ready pjax:success', function() {
  $('input').iCheck({
    checkboxClass: 'icheckbox_flat-grey selectable',
    radioClass: 'iradio_flat-grey'
  });

  var checkBox = $('.table-striped > tbody > tr > td:first-child input[type="checkbox"]');
  var togglerCheck = $('th.shrink input[type="checkbox"]');

  checkBox.on('ifChecked', function(e) {
    $(this).parent().parent().parent().addClass('row-highlight');
  });
  checkBox.on('ifUnchecked', function(e) {
    $(this).parent().parent().parent().removeClass('row-highlight');
  });

  togglerCheck.on('ifChecked', function(e) {
    checkBox.iCheck('check');
    handleHighlight();
  });
  togglerCheck.on('ifUnchecked', function(e) {
    checkBox.iCheck('uncheck');
    $('.table-striped tbody tr').removeClass('row-highlight');
  });
  function handleHighlight() {
    $('.table-striped tbody td').has('div.checked').each(function(index, item) {
      $(item).parent().addClass('row-highlight');
    });
  }

  handleActiveBase();
  function handleActiveBase() {
    $('.sub-menu').each(function () {
      if ($(this).hasClass('active')) {
        $(this).parent().prev().addClass('active');
        $(this).parent().prev().addClass('open');
        $(this).parent().slideDown();
      }
    });
  }
});

$(function () {
  var width = $('.nav-stacked').width();
  $('.navbar-header').width(width);

  var array_menu = [];
  var lvl_1 = null;
  var count = 0;

  $('.sidebar-nav li').each(function (index, item) {
    if ($(item).hasClass('dropdown-header')) {
      lvl_1 = count++;
      array_menu[lvl_1] = []
    } else {
      $(item).addClass('sub-menu sub-menu-' + lvl_1);
    }
  });

  for (var i = 0; i <= array_menu.length; i++) {
    $('.sub-menu-' + i).wrapAll("<div class='sub-menu-container' />");
  }

  $('.sub-menu-container').hide();

  handleActiveBase();
  function handleActiveBase() {
    $('.sub-menu').each(function () {
      if ($(this).hasClass('active')) {
        $(this).parent().prev().addClass('active');
        $(this).parent().slideDown();
      }
    });
  }


  $('.dropdown-header').bind('click', function () {
    $('.dropdown-header').removeClass('open');
    $(this).addClass('open');

    $('.dropdown-header').removeClass('active');
    $('.sub-menu-container').stop().slideUp();
    $(this).toggleClass('active');
    $(this).next('.sub-menu-container').stop().slideDown();
  });
});



var ready;
ready = function() {
	$("#show_tags_field").tagit({
		allowSpaces: true,
		singleField: true
	});
};


$(document).ready(ready);
$(document).on('pjax:end', ready);