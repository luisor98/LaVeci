function showError(text) {
    if ($('.ajax-update-notification').length) {
        $('.ajax-update-notification').remove();
    }
    $('.topnav').after('<div class="alert alert-danger ajax-update-notification" role="alert"><button class="close" data-dismiss="alert">x</button>'+ text +'</div>');
}

function showSuccess(text) {
    if ($('.ajax-update-notification').length) {
        $('.ajax-update-notification').remove();
    }
    $('.topnav').after('<div class="alert alert-info ajax-update-notification" role="alert"><button class="close" data-dismiss="alert">x</button>'+ text +'</div>');
}

function banMembership(id) {
    var row = $('.row-member-' + id);
    row.addClass('opacity_04');
    row.find('.admin-members-is-admin').prop('disabled', true);
    row.find('.admin-members-can-post-listings').prop('disabled', true);
    row.find('.edit-membership').addClass('is-disabled');
    var can_post = row.find('.admin-members-can-post-listings');
    if (can_post.length === 0) {
        row.find('.post-membership').addClass('is-disabled');
    } else if (!can_post.prop('checked')) {
        row.find('.post-membership').addClass('is-disabled');
    }
}

function unbanMembership(id) {
    var row = $('.row-member-' + id);
    row.removeClass('opacity_04');
    row.find('.admin-members-is-admin').prop('disabled', false);
    row.find('.admin-members-can-post-listings').prop('disabled', false);
    row.find('.edit-membership').removeClass('is-disabled');
    var can_post = row.find('.admin-members-can-post-listings');
    if (can_post.length === 0) {
        row.find('.post-membership').removeClass('is-disabled');
    } else if (can_post.prop('checked')) {
        row.find('.post-membership').removeClass('is-disabled');
    } else {
        row.find('.post-membership').addClass('is-disabled');
    }
}

function allowPost(id) {
    var row = $('.row-member-' + id);
    row.find('.post-membership').removeClass('is-disabled');
}

function disallowPost(id) {
    var row = $('.row-member-' + id);
    row.find('.post-membership').addClass('is-disabled');
}

$(function() {
    $(document).on("click", ".admin-members-ban-toggle", function () {
        var banned = this.checked, url, msg;
        if (banned) {
            url = $(this).data("ban-url");
            msg = $(this).data('ban-msg');
        } else {
            url = $(this).data("unban-url");
            msg = $(this).data('unban-msg');
        }
        if (confirm(msg)) {
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

    $('.change-status-filter').on('change', function () {
        $(this).parents('form').submit();
    });

    $(document).on("click", ".admin-members-is-admin", function () {
        var admin = this.checked,
            url = $(this).data('url'),
            msg = $(this).data('msg'),
            id = $(this).val(),
            data, confirmation;

        if (!admin) {
            data = {remove_admin: id};
            confirmation = true;
        } else {
            data = {add_admin: id};
            confirmation = confirm(msg);
        }

        if (confirmation) {
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

    $(document).on("click", ".admin-members-can-post-listings", function () {
        var can_post = this.checked,
            url = $(this).data('url'),
            id = $(this).val(), data;
        if (!can_post) {
            data = {disallowed_to_post: id};
        } else {
            data = {allowed_to_post: id};
        }
        $.ajax({
            type: 'patch',
            url: url,
            dataType: "script",
            data: data
        });
    });
});
