$(document).ready(function () {
    var hayEstudiantes = document.getElementById('hayEstudiantes')?.value === 'true';

    if (!hayEstudiantes) {
        return;
    }

    var cursoDocenteId = parseInt(document.getElementById('cursoDocenteId')?.value || '0');
    var fechaSeleccionada = document.getElementById('fechaSeleccionada')?.value || '';

    if (cursoDocenteId > 0 && fechaSeleccionada) {
        CargarHistorialAsistencias(cursoDocenteId, fechaSeleccionada);
    }

    function renderBadgeEstado(estado) {
        if (estado === 'Presente') {
            return '<span class="inline-flex items-center gap-1 rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-700"><i data-lucide="check-circle-2" class="h-3.5 w-3.5"></i>Presente</span>';
        }

        if (estado === 'Ausente') {
            return '<span class="inline-flex items-center gap-1 rounded-full bg-red-50 px-3 py-1 text-xs font-bold text-red-700"><i data-lucide="x-circle" class="h-3.5 w-3.5"></i>Ausente</span>';
        }

        if (estado === 'Justificado') {
            return '<span class="inline-flex items-center gap-1 rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700"><i data-lucide="file-check-2" class="h-3.5 w-3.5"></i>Justificado</span>';
        }

        return '<span class="inline-flex items-center gap-1 rounded-full bg-amber-50 px-3 py-1 text-xs font-bold text-amber-700"><i data-lucide="clock" class="h-3.5 w-3.5"></i>Tardanza</span>';
    }

    function formatearHora(ts) {
        if (!ts) return '00:00:00';

        if (typeof ts === 'object') {
            var hours = ts.Hours || 0;
            var minutes = ts.Minutes || 0;
            var seconds = ts.Seconds || 0;

            return String(hours).padStart(2, '0') + ':' +
                String(minutes).padStart(2, '0') + ':' +
                String(seconds).padStart(2, '0');
        }

        if (typeof ts === 'string') {
            return ts.substring(0, 8);
        }

        return '00:00:00';
    }

    function CargarHistorialAsistencias(cursoDocenteId, fecha) {
        $('#tablaHistorial').html(
            '<div class="rounded-2xl bg-slate-50 p-5 text-center text-sm font-semibold text-slate-600">Cargando historial...</div>'
        );

        $.ajax({
            url: '@Url.Action("ObtenerHistorialAsistencias", "Docente")',
            type: 'GET',
            data: { cursoDocenteId: cursoDocenteId, fecha: fecha },
            success: function (data) {
                if (data.length > 0) {
                    var html = `
                                        <div class="overflow-x-auto">
                                            <table class="w-full min-w-[900px] text-left text-sm">
                                                <thead>
                                                    <tr class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                                                        <th class="px-6 py-4 font-bold">Estudiante</th>
                                                        <th class="px-6 py-4 font-bold">Estado</th>
                                                        <th class="px-6 py-4 font-bold">Observación</th>
                                                        <th class="px-6 py-4 font-bold">Registrado</th>
                                                    </tr>
                                                </thead>
                                                <tbody class="divide-y divide-slate-100">
                                    `;

                    $.each(data, function (i, item) {
                        html += `
                                                    <tr class="transition hover:bg-slate-50">
                                                        <td class="px-6 py-5">
                                                            <p class="font-bold text-slate-950">${item.nombreCompleto || item.NombreCompleto || 'Sin nombre'}</p>
                                                            <p class="text-xs text-slate-500">${item.codigoEstudiante || item.CodigoEstudiante || ''}</p>
                                                        </td>
                                                        <td class="px-6 py-5">${renderBadgeEstado(item.estadoAsistencia || item.EstadoAsistencia)}</td>
                                                        <td class="px-6 py-5 text-slate-600">${item.observacion || item.Observacion || 'Ninguna'}</td>
                                                        <td class="px-6 py-5 text-slate-600 font-mono">${formatearHora(item.horaRegistro || item.HoraRegistro)}</td>
                                                    </tr>
                                                `;
                    });

                    html += `</tbody></table></div>`;
                    $('#tablaHistorial').html(html);
                    lucide.createIcons();
                } else {
                    $('#tablaHistorial').html(
                        '<div class="rounded-2xl border border-blue-200 bg-blue-50 p-5 text-blue-800"><div class="flex items-start gap-3"><i data-lucide="info" class="mt-0.5 h-5 w-5"></i><div><h4 class="font-bold">No hay asistencias registradas</h4><p class="mt-1 text-sm">No hay asistencias registradas para esta fecha.</p></div></div></div>'
                    );
                    lucide.createIcons();
                }
            },
            error: function () {
                $('#tablaHistorial').html(
                    '<div class="rounded-2xl border border-red-200 bg-red-50 p-5 text-red-800"><div class="flex items-start gap-3"><i data-lucide="triangle-alert" class="mt-0.5 h-5 w-5"></i><div><h4 class="font-bold">Error al cargar historial</h4><p class="mt-1 text-sm">No se pudo obtener la información de asistencias.</p></div></div></div>'
                );
                lucide.createIcons();
            }
        });
    }

    $('#btnGuardarAsistencias').click(function () {
        var asistencias = [];

        $('.estado-asistencia').each(function () {
            var matriculaId = $(this).data('matricula-id');
            var estado = $(this).val();
            var observacion = $('.observacion-asistencia[data-matricula-id="' + matriculaId + '"]').val() || '';
            asistencias.push({ matriculaId, estado, observacion });
        });

        if (asistencias.length === 0) {
            alert('No hay asistencias para guardar');
            return;
        }

        var guardados = 0;
        $(asistencias).each(function (index, item) {
            $.ajax({
                url: '@Url.Action("RegistrarAsistencias", "Docente")',
                type: 'POST',
                data: item,
                success: function (response) {
                    if (response.success) guardados++;
                }
            });
        });

        mostrarModalCargando();

        setTimeout(function () {
            mostrarModalResultado(guardados);
            $btn.prop('disabled', false).html(htmlOriginal);
            CargarHistorialAsistencias(cursoDocenteId, fechaSeleccionada);
        }, 3000);
    });

    let historialVisible = false;
    $('#headerHistorial').click(function () {
        historialVisible = !historialVisible;
        if (historialVisible) {
            $('#contenidoHistorial').removeClass('hidden').slideDown(300);
            $('#iconoToggle').css('transform', 'rotate(180deg)');
        } else {
            $('#contenidoHistorial').slideUp(300, function () {
                $(this).addClass('hidden');
            });
            $('#iconoToggle').css('transform', 'rotate(0deg)');
        }
    });

    function mostrarModalCargando() {
        var html = `
                            <div id="modalAsistenciaCargando" class="fixed inset-0 z-[999] flex items-center justify-center bg-slate-950/70">
                                <div class="w-full max-w-md rounded-3xl bg-white p-8 shadow-2xl text-center">
                                    <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-amber-100 text-amber-600">
                                        <i data-lucide="loader-2" class="h-8 w-8 animate-spin"></i>
                                    </div>
                                    <h3 class="mt-4 text-xl font-semibold">Registrando asistencias...</h3>
                                    <p class="mt-2 text-slate-500">Por favor espera un momento</p>
                                </div>
                            </div>
                        `;
        $('#modalAsistenciaCargando').remove();
        $('body').append(html);
    }

    function mostrarModalResultado(guardados) {
        $('#modalAsistenciaCargando').remove();

        var html = `
                            <div id="modalResultadoAsistencia" class="fixed inset-0 z-[999] flex items-center justify-center bg-slate-950/70">
                                <div class="w-full max-w-md rounded-3xl bg-white p-8 shadow-2xl text-center">
                                    <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 text-emerald-600">
                                        <i data-lucide="check-circle-2" class="h-8 w-8"></i>
                                    </div>
                                    <h3 class="mt-4 text-2xl font-extrabold">¡Registro Exitoso!</h3>
                                    <p class="mt-2 text-slate-600">Se registraron <strong>${guardados}</strong> asistencias correctamente.</p>
                                </div>
                            </div>
                        `;

        $('#modalResultadoAsistencia').remove();
        $('body').append(html);
        lucide.createIcons();

        setTimeout(function () {
            $('#modalResultadoAsistencia').fadeOut(400, function () {
                $(this).remove();
                location.reload();
            });
        }, 3000);
    }
});