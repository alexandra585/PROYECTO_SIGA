function abrirModalDesasignar(id, estudiante, apoderado, parentesco) {
    document.getElementById('modalAsignacionId').value = id;
    document.getElementById('modalEstudiante').textContent = estudiante;
    document.getElementById('modalApoderado').textContent = apoderado;
    document.getElementById('modalParentesco').textContent = parentesco;

    const modal = document.getElementById('modalDesasignar');
    modal.classList.remove('hidden');
    modal.classList.add('flex');

    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
}

function cerrarModalDesasignar() {
    const modal = document.getElementById('modalDesasignar');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
}

document.addEventListener('DOMContentLoaded', function () {
    const modal = document.getElementById('modalDesasignar');
    modal.addEventListener('click', function (e) {
        if (e.target === this) {
            cerrarModalDesasignar();
        }
    });
});