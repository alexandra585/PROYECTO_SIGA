function abrirModalDesasignar(id, estudiante, curso) {
    document.getElementById('modalMatriculaId').value = id;
    document.getElementById('modalEstudiante').textContent = estudiante;
    document.getElementById('modalCurso').textContent = curso;

    const modal = document.getElementById('modalDesasignar');
    modal.classList.remove('hidden');
    modal.classList.add('flex');

    if (window.lucide) {
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