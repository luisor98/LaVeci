$(document).on("click", ".admin-members-ban-toggle", function(){
    var banned = this.checked;
    if(banned) {
        url = $(this).data("ban-url");
        msg = $(this).data('ban-msg');
    } else {
        url = $(this).data("unban-url");
        msg = $(this).data('unban-msg');
    }
    if(confirm(msg)) {
        $.ajax({
            type: "POST",
            url: url,
            dataType: "script",
            data: {_method: 'PATCH'}
        });
    } else {
        this.checked = !banned;
    }
});


$(document).on("click", ".admin-members-is-admin", function(){
    var admin = this.checked,
        url = $(this).data('url'),
        msg = $(this).data('msg'),
        id = $(this).val(),
        data, confirmation;

    if(!admin) {
      data = { remove_admin: id };
      confirmation = true;
    } else {
      data = { add_admin: id };
      confirmation = confirm(msg);
    }

    if(confirmation) {
        $.ajax({
            type: "POST",
            url: url,
            dataType: "script",
            data: data
        });
    } else {
        this.checked = !admin;
    }

});
