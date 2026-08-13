function toggleOtroDetalle() {
    const select = document.getElementById('parentescoSelect');
    const container = document.getElementById('otroDetalleContainer');
    const input = document.getElementById('parentescoDetalle');

    if (select.value === 'Otro') {
        container.classList.remove('hidden');
        input.required = true;
    } else {
        container.classList.add('hidden');
        input.required = false;
        input.value = '';
    }
}

document.addEventListener('DOMContentLoaded', function () {
    const select = document.getElementById('parentescoSelect');
    if (select && select.value === 'Otro') {
        toggleOtroDetalle();
    }
});