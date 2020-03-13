function showReview(data) {
    $('#reviewReadLabel').html(data.reviewReadLabel);
    $('#customer_title').html(data.customer_title);
    $('#customer_status').html(data.customer_status);
    $('#customer_text').html(data.customer_text);
    $('#provider_title').html(data.provider_title);
    $('#provider_status').html(data.provider_status);
    $('#provider_text').html(data.provider_text);
    $('#reviewRead').modal('show');
}

$(function() {

});
