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
                var array = [],
                    url = $('#customList').data('url');
                $('#customList > .nested').each(function( index ) {
                    array.push($(this).data('id'));
                });
                $.post(url, {order: array});
            },
        });
    }

});
