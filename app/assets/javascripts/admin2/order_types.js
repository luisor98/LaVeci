$(function() {

    $('#template_order_type').on('change', function(){
        var url = $(this).data('url'),
            id = $(this).val();
        $.get(url, {type_id: id}, null, 'script');
    });

});
