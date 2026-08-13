document.addEventListener("DOMContentLoaded", function () {
    const modal = document.getElementById("modalNotas");
    const modalTitulo = document.getElementById("modalNotasTitulo");
    const modalBody = document.getElementById("modalNotasBody");
    const cerrarModal = document.getElementById("cerrarModalNotas");

    function mostrarCargando() {
        modalBody.innerHTML = `
                    <div class="flex flex-col items-center justify-center h-full py-12">
                        <div class="animate-spin h-10 w-10 border-4 border-blue-200 border-t-blue-600 rounded-full"></div>
                        <p class="mt-4 text-sm text-slate-500">Cargando notas del estudiante...</p>
                    </div>
                `;
    }

    function abrirModal() {
        modal.classList.remove("hidden");
        modal.classList.add("flex");
    }

    function cerrar() {
        modal.classList.add("hidden");
        modal.classList.remove("flex");
    }

    cerrarModal.addEventListener("click", cerrar);

    modal.addEventListener("click", function (e) {
        if (e.target === modal) {
            cerrar();
        }
    });

    document.querySelectorAll(".btn-ver-notas").forEach(function (btn) {
        btn.addEventListener("click", function () {
            const matriculaId = this.dataset.matriculaId;
            const nombre = this.dataset.nombre;

            modalTitulo.textContent = "Estudiante: " + nombre;
            mostrarCargando();
            abrirModal();

            setTimeout(function () {
                $.ajax({
                    url: '@Url.Action("ObtenerNotasEstudiante", "Docente")',
                    type: 'GET',
                    data: { matriculaId: matriculaId },
                    success: function (data) {
                        if (data && data.length > 0) {
                            let html = `
                                    <div class="overflow-x-auto rounded-2xl border border-slate-200">
                                        <table class="w-full text-left text-sm">
                                            <thead>
                                                <tr class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                                                    <th class="px-5 py-4 font-bold">Evaluación</th>
                                                    <th class="px-5 py-4 font-bold">Nota</th>
                                                    <th class="px-5 py-4 font-bold">Observación</th>
                                                </tr>
                                            </thead>
                                            <tbody class="divide-y divide-slate-100">
                                `;

                            $.each(data, function (i, nota) {
                                const nombreEval = nota.nombreEvaluacion || nota.NombreEvaluacion || "Evaluación";
                                const notaValor = (nota.nota !== undefined ? nota.nota : nota.Nota) || 0;
                                const observacion = nota.observacion || nota.Observacion || "Ninguna";
                                const notaClase = notaValor >= 11 ? 'text-emerald-600' : 'text-red-600';

                                html += `
                                        <tr>
                                            <td class="px-5 py-4 font-semibold text-slate-900">${nombreEval}</td>
                                            <td class="px-5 py-4">
                                                <span class="text-lg font-extrabold ${notaClase}">${notaValor.toFixed(2)}</span>
                                            </td>
                                            <td class="px-5 py-4 text-slate-600">${observacion}</td>
                                        </tr>
                                    `;
                            });

                            html += `</tbody></table></div>`;
                            modalBody.innerHTML = html;
                        } else {
                            modalBody.innerHTML = `
                                    <div class="rounded-2xl border border-blue-200 bg-blue-50 p-5 text-blue-800">
                                        <div class="flex items-start gap-3">
                                            <i data-lucide="info" class="mt-0.5 h-5 w-5"></i>
                                            <div>
                                                <h4 class="font-bold">No hay notas registradas</h4>
                                                <p class="mt-1 text-sm">Este estudiante aún no tiene calificaciones registradas.</p>
                                            </div>
                                        </div>
                                    </div>
                                `;
                        }
                        lucide.createIcons();
                    },
                    error: function () {
                        modalBody.innerHTML = `
                                        <div class="rounded-2xl border border-red-200 bg-red-50 p-5 text-red-800">
                                            <div class="flex items-start gap-3">
                                                <i data-lucide="triangle-alert" class="mt-0.5 h-5 w-5"></i>
                                                <div>
                                                    <h4 class="font-bold">Error al cargar notas</h4>
                                                    <p class="mt-1 text-sm">No se pudo obtener la información del estudiante.</p>
                                                </div>
                                            </div>
                                        </div>
                                    `;
                        lucide.createIcons();
                    }
                });
            }, 3000);
        });
    });
});