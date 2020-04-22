$(function() {

    $(document).on('change', '#field_type', function() {
        var url = $(this).data('url'),
            value = $(this).val();
        $.get(url, {field_type: value}, null, 'script');
    });

});
