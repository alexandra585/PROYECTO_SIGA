document.addEventListener("DOMContentLoaded", function () {
    const modal = document.getElementById("modalDetalle");
    const cerrarModal = document.getElementById("cerrarModal");

    document.querySelectorAll(".btn-detalle").forEach(function (btn) {
        btn.addEventListener("click", function () {
            document.getElementById("detalleCurso").textContent = this.dataset.curso;
            document.getElementById("detalleCodigo").textContent = this.dataset.codigo;
            document.getElementById("detallePromedio").textContent = this.dataset.promedio;
            document.getElementById("detalleEstado").textContent = this.dataset.estado;
            document.getElementById("detalleCreditos").textContent = this.dataset.creditos;

            modal.classList.remove("hidden");
            modal.classList.add("flex");
        });
    });

    cerrarModal.addEventListener("click", function () {
        modal.classList.add("hidden");
        modal.classList.remove("flex");
    });

    modal.addEventListener("click", function (e) {
        if (e.target === modal) {
            modal.classList.add("hidden");
            modal.classList.remove("flex");
        }
    });
});