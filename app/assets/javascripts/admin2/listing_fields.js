$(function() {

    $(document).on('change', '#field_type', function() {
        var url = $(this).data('url'),
            value = $(this).val();
        $.get(url, {field_type: value}, null, 'script');
    });

    $('#listingFieldsAddModal').on('show.bs.modal', function (e) {
        $('#body_type').html('');
        $('#field_type').val('');
    });

    if ($('#customList').length) {
        Sortable.create(customList, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
                $('.top_bar_link_position').each(function( index ) {
                    $(this).find('.sort_priority_class').val(index);
                });
            },
        });
    }

});
