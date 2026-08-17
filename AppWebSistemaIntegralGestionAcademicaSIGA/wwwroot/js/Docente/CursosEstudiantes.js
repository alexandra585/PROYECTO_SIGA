const ModuloNotas = (function () {
    let urlObtenerNotas = '';
    let modal = null;
    let modalTitulo = null;
    let modalBody = null;
    let cerrarModal = null;

    function mostrarCargando() {
        modalBody.innerHTML = `
            <div class="flex flex-col items-center justify-center h-full py-12">
                <div class="animate-spin h-10 w-10 border-4 border-blue-200 border-t-blue-600 rounded-full"></div>
                <p class="mt-4 text-sm text-slate-500">Cargando notas del estudiante</p>
            </div>
        `;
    }

    function abrirModal() {
        modal.classList.remove("hidden");
        modal.classList.add("flex");
        document.body.style.overflow = 'hidden';
    }

    function cerrar() {
        modal.classList.add("hidden");
        modal.classList.remove("flex");
        document.body.style.overflow = '';
    }

    function cargarNotas(matriculaId, nombre) {
        modalTitulo.textContent = "Estudiante: " + nombre;
        mostrarCargando();
        abrirModal();

        setTimeout(function () {
            $.ajax({
                url: urlObtenerNotas,
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
                            const notaValor = parseFloat(nota.nota !== undefined ? nota.nota : nota.Nota) || 0;
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

                    if (typeof lucide !== 'undefined' && lucide.createIcons) {
                        lucide.createIcons();
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error al cargar notas:', error);
                    modalBody.innerHTML = `
                        <div class="rounded-2xl border border-red-200 bg-red-50 p-5 text-red-800">
                            <div class="flex items-start gap-3">
                                <i data-lucide="triangle-alert" class="mt-0.5 h-5 w-5"></i>
                                <div>
                                    <h4 class="font-bold">Error al cargar notas</h4>
                                    <p class="mt-1 text-sm">No se pudo obtener la información del estudiante. Por favor, intenta nuevamente.</p>
                                </div>
                            </div>
                        </div>
                    `;

                    if (typeof lucide !== 'undefined' && lucide.createIcons) {
                        lucide.createIcons();
                    }
                }
            });
        }, 3000);
    }

    function inicializar(url) {
        urlObtenerNotas = url;

        modal = document.getElementById("modalNotas");
        modalTitulo = document.getElementById("modalNotasTitulo");
        modalBody = document.getElementById("modalNotasBody");
        cerrarModal = document.getElementById("cerrarModalNotas");

        if (!modal || !modalTitulo || !modalBody || !cerrarModal) {
            console.error('No se encontraron los elementos del modal');
            return;
        }

        cerrarModal.addEventListener("click", cerrar);

        modal.addEventListener("click", function (e) {
            if (e.target === modal) {
                cerrar();
            }
        });

        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape" && !modal.classList.contains("hidden")) {
                cerrar();
            }
        });

        configurarBotones();
    }

    function configurarBotones() {
        document.querySelectorAll(".btn-ver-notas").forEach(function (btn) {
            btn.removeEventListener("click", manejarClickBoton);
            btn.addEventListener("click", manejarClickBoton);
        });
    }

    function manejarClickBoton(e) {
        const btn = e.currentTarget;
        const matriculaId = btn.dataset.matriculaId;
        const nombre = btn.dataset.nombre;

        if (!matriculaId) {
            console.error('No se encontró el ID de matrícula');
            return;
        }

        cargarNotas(matriculaId, nombre);
    }

    return {
        inicializar: inicializar,
        configurarBotones: configurarBotones,
        cerrarModal: cerrar
    };
})();

document.addEventListener("DOMContentLoaded", function () {
    if (typeof window.Urls !== 'undefined' && window.Urls.obtenerNotas) {
        ModuloNotas.inicializar(window.Urls.obtenerNotas);
    } else {
        console.warn('No se encontró la URL para obtener notas');
    }
});