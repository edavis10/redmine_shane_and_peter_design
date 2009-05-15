jQuery.noConflict();

jQuery(document).ready(function($) {

	// a few constants for animations speeds, etc.
	var animRate = 100;

	// header menu hovers
	$("#account .drop-down").hover(function() {
		$(this).addClass("open").find("ul").slideDown(animRate);
		$("#top-menu").toggleClass("open");
	}, function() {
		$(this).removeClass("open").find("ul").slideUp(animRate);
		$("#top-menu").toggleClass("open");
	});

	// show/hide header search box
	$("#account a.search").click(function() {
		var searchWidth = $("#account-nav").width();

		$(this).toggleClass("open");
		$("#nav-search").width(searchWidth).slideToggle(animRate, function(){
			$("#nav-search-box").select();
		});

		return false;
	});

	// issue table info tooltips
	$(".js-tooltip").wrapInner("<div class='js-tooltip-inner'></div>").append("<span class='arrow'></span>"); // give an extra div for styling

	$("table.issues td.issue").hover(function(event) {
		var $thisTR = $(event.target).parents("tr");
		var trPos = $thisTR.position();
		var tTarget = $thisTR.attr("id");

		$("form#issue-list").toggleClass("tooltip-active");
		$("div[rel="+tTarget+"]").css('top', trPos.top).fadeIn(animRate*2, function(){
			//ie cleartype uglies
			if ($.browser.msie) {this.style.removeAttribute('filter'); };
			});

	}, function(event) {
		var $thisTR = $(event.target).parents("tr");
		var tTarget = $thisTR.attr("id");

		$("form#issue-list").toggleClass("tooltip-active");
		$("div[rel="+tTarget+"]").hide();
	});

	// show/hide the profile box when hover over the gravatar
	$(".profile-wrap").hover(function() {
		/*
		*  this is currently set to deal with profiles that are already in the document
		*  if you wish to move to an ajax call instead, this is where it will occur
		*/
		$(this).find("a").removeAttr("title"); /* tooltips always mess with hovers */
		$(this).find(".profile-box").slideDown(animRate);
	}, function() {
		$(this).find(".profile-box").slideUp(animRate);
	});

	// set up functions for delayed profile views.
	function profileShow(){
		var thisTop = $(this).height() + 5;
		$(this).find("a").removeAttr("title"); /* tooltips always mess with hovers */
		$(this).find(".profile-box").css('top', thisTop).slideDown(animRate);
	};
	function profileHide(){
		$(this).find(".profile-box").hide();
	};

	// call a delayed profile view
	$(".user").hoverIntent({
		sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
		interval: 400, // number = milliseconds for onMouseOver polling interval
		over: profileShow, // function = onMouseOver callback (REQUIRED)
		timeout: 50, // number = milliseconds delay before onMouseOut
		out: profileHide // function = onMouseOut callback (REQUIRED)

	});

	// file table thumbnails
	$("table a.has-thumb").hover(function() {
		$(this).removeAttr("title").toggleClass("active");

		// grab the image dimensions to position it properly
		var thumbImg = $(this).find("img");
		var thumbImgLeft = -(thumbImg.outerWidth() );
		var thumbImgTop = -(thumbImg.height() / 2 );
		thumbImg.css({top: thumbImgTop, left: thumbImgLeft}).show();

	}, function() {
		$(this).toggleClass("active").find("img").hide();
	});

	// show/hide the files table
	$(".attachments h4").click(function() {
		$(this).toggleClass("closed").next().slideToggle(animRate);
	});

	// custom function for sliding the main-menu. IE6 & IE7 don't handle sliding very well
	$.fn.mySlide = function() {
		if (parseInt($.browser.version, 10) < 8 && $.browser.msie) {
			// no animations, just toggle
			this.toggle();
			// this forces IE to redraw the menu area, un-bollocksing things
			$("#main-menu").css({paddingBottom:5}).animate({paddingBottom:0}, 10);
		} else {
			this.slideToggle(animRate);
		}

		return this;
	};

	// open and close the main-menu sub-menus
	$("#main-menu li:has(ul) > a").not("ul ul a")
		.append("<span class='toggler'></span>")
		.click(function() {

			$(this).toggleClass("open").parent().find("ul").not("ul ul ul").mySlide();

			return false;
	});

	// open/close the filters dropdown
	$('.title-bar h2, a#extras-close').click(function() {
		$('.title-bar-extras').slideToggle(animRate);
		return false;
	});


	// submenu flyouts
	$("#main-menu li li:has(ul)").hover(function() {
		$(this).find(".profile-box").show();
		$(this).find("ul").slideDown(animRate);
	}, function() {
		$(this).find("ul").slideUp(animRate);
	});

	// add filter dropdown menu
	$(".button-large:has(ul) > a").click(function(event) {
		var tgt = $(event.target);

		// is this inside the title bar?
		if (tgt.parents().is(".title-bar")) {
			$(".title-bar-extras:hidden").slideDown(animRate);
		}

		$(this).parent().find("ul").slideToggle(animRate);

		return false;
	});

	// suckerfish-esque on those issue dropdown menus for IE6
	if (parseInt($.browser.version, 10) < 7 && $.browser.msie) {
		$(".issue-dropdown li").hover(function() {
			$(this).toggleClass("hover");
		}, function() {
			$(this).toggleClass("hover");
		});
	}


});
