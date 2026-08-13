(function () {
    var successAlert = document.getElementById('successAlert');

    var redirectUrl = document.querySelector('meta[name="redirect-url"]').getAttribute('content');

    if (successAlert) {
        setTimeout(function () {
            if (successAlert) {
                successAlert.style.opacity = '0';
                successAlert.style.transition = 'opacity 0.3s ease';
                setTimeout(function () {
                    if (successAlert) successAlert.style.display = 'none';
                    window.location.href = redirectUrl;
                }, 300);
            }
        }, 3000);
    }
})();