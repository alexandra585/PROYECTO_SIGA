window.onload = function () {
    setTimeout(function () {
        window.print();
    }, 500);
}

window.onafterprint = function () {
    window.close();
}