javascript:(function() { var transaction_type = jQuery('#virtual_terminal_channel_id').attr('name').split('_')[0]; jQuery('#amount_dollar').val(100); jQuery('#' + transaction_type + '_transaction_usage').val("Test"); jQuery('#' + transaction_type + '_transaction_card_number').val("4200000000000000"); jQuery('#' + transaction_type + '_transaction_card_holder').val("Emil Petkov"); jQuery('#' + transaction_type + '_transaction_cvv').val("123"); jQuery('#' + transaction_type + '_transaction_expiration_month').val("12"); jQuery('#' + transaction_type + '_transaction_expiration_year').val("2016"); jQuery('#' + transaction_type + '_transaction_customer_email').val("emil@emerchantpay.com"); jQuery('#' + transaction_type + '_transaction_customer_phone').val("3598851248511"); jQuery('#billing_address_first_name').val("Emil"); jQuery('#billing_address_last_name').val("Petkov"); jQuery('#billing_address_address1').val("Nikola Vapcarov 53V"); jQuery('#billing_address_zip_code').val("1407"); jQuery('#billing_address_city').val("Sofia"); jQuery('#billing_address_country').val("BG"); jQuery("#billing_address_country").trigger("liszt:updated") } )()