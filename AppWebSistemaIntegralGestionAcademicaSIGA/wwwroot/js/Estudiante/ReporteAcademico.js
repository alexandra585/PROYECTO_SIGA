function abrirModalDrive() {
    document.getElementById('modalDrive').classList.remove('hidden');
    document.getElementById('modalDrive').classList.add('flex');
    lucide.createIcons();
}

function cerrarModalDrive() {
    document.getElementById('modalDrive').classList.add('hidden');
    document.getElementById('modalDrive').classList.remove('flex');
}

function irADrive() {
    cerrarModalDrive();
    window.open('https://drive.google.com/drive/u/0/my-drive', '_blank');
}

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        cerrarModalDrive();
    }
});

document.getElementById('modalDrive').addEventListener('click', function (e) {
    if (e.target === this) {
        cerrarModalDrive();
    }
});