(function ($) {
	"use strict";
	
	/*----------------------------
    START - Slider activation
    ------------------------------ */
	$('.screenshot-area-slider').owlCarousel({
		loop:true,
		dots:true,
		autoplay: true,
		autoplayTimeout:4000,
		nav:true,
		navText: ["<i class='icofont icofont-long-arrow-left'></i>", "<i class='icofont icofont-long-arrow-right'></i>"],
		margin:20,
		responsive:{
			0:{
				items: 1,
				margin:0,
			},
			576:{
				items: 2,
			},
			768:{
				items: 3,
			},
			992:{
				items: 4,
			},
			1900:{
				items: 4,
			}
		}
	})
	$('.author-feedback').owlCarousel({
		loop:true,
		autoplay: true,
		autoplayTimeout:8000,
		dots:false,
		nav:true,
		navText: ["<i class='icofont icofont-long-arrow-left'></i>", "<i class='icofont icofont-long-arrow-right'></i>"],
		items:1,
		animateOut: 'fadeOut',
	});
	$(".author-feedback").on('translate.owl.carousel', function() {
		$('.author-single-slide h4').removeClass('slideInDown animated').hide();
		$('.author-single-slide .author-img').removeClass('slideInLeft animated').hide();
		$('.author-single-slide p').removeClass('slideInRight animated').hide();
		$('.author-single-slide .author-rating').removeClass('slideInUp animated').hide();
	});
	$(".author-feedback").on('translated.owl.carousel', function() {
		$('.owl-item.active .author-single-slide h4').addClass('slideInDown animated').show();
		$('.owl-item.active .author-single-slide .author-img').addClass('slideInLeft animated').show();
		$('.owl-item.active .author-single-slide p').addClass('slideInRight animated').show();
		$('.owl-item.active .author-single-slide .author-rating').addClass('slideInUp animated').show();
	});

	/*--------------------------------
	START - PIE CHART
	--------------------------------*/
	$('.activity-box-chart').easyPieChart({
		animate: 2000,
		scaleColor: false,
		lineWidth: 10,
		barColor: '#03a9f4',
		trackColor: '#e0e0e0',
		size: 180
	});

}(jQuery));