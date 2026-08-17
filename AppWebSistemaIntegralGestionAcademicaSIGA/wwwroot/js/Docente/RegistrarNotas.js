var cambiosPendientes = [];

$(document).ready(function () {
    var hayEstudiantes = document.getElementById('hayEstudiantes')?.value === 'true';

    if (!hayEstudiantes) {
        return;
    }

    $('.nota-input').focus(function () {
        $(this).closest('td').find('.obs-input').removeClass('hidden');
    });

    $('.nota-input').on('input', function () {
        var $td = $(this).closest('td');
        var notaInput = $(this);
        var nota = parseFloat(notaInput.val());
        var isValid = !isNaN(nota) && nota >= 0 && nota <= 20;
        var isEmpty = notaInput.val() === '';

        if (!isEmpty && !isValid) {
            notaInput
                .removeClass('border-slate-300 border-emerald-500 border-amber-500')
                .addClass('border-red-500');
        } else if (!isEmpty && isValid) {
            notaInput
                .removeClass('border-red-500 border-slate-300 border-amber-500')
                .addClass('border-emerald-500');
        } else {
            notaInput
                .removeClass('border-red-500 border-emerald-500 border-amber-500')
                .addClass('border-slate-300');
        }

        verificarNotasInvalidas();
    });

    function verificarNotasInvalidas() {
        var hayError = false;

        $('.nota-input').each(function () {
            var val = $(this).val();
            if (val !== '') {
                var nota = parseFloat(val);
                if (isNaN(nota) || nota < 0 || nota > 20) {
                    hayError = true;
                    return false;
                }
            }
        });

        if (hayError) {
            $('#btnGuardarTodo').prop('disabled', true)
                .addClass('opacity-50 cursor-not-allowed')
                .html('<i data-lucide="alert-circle" class="h-4 w-4"></i> Corrige notas inválidas');
        } else {
            $('#btnGuardarTodo').prop('disabled', false)
                .removeClass('opacity-50 cursor-not-allowed')
                .html('<i data-lucide="save" class="h-4 w-4"></i> Registrar notas');
        }
        lucide.createIcons();
    }

    $('.nota-input, .obs-input').on('change', function () {
        var $td = $(this).closest('td');
        var notaInput = $td.find('.nota-input');
        var obsInput = $td.find('.obs-input');

        var matriculaId = notaInput.data('matricula-id');
        var evaluacionId = notaInput.data('evaluacion-id');
        var nota = notaInput.val();
        var observacion = obsInput.val().trim();

        if (!observacion) {
            observacion = "Ninguna";
        }

        if (nota && !isNaN(nota) && nota >= 0 && nota <= 20) {
            cambiosPendientes = cambiosPendientes.filter(function (item) {
                return !(item.matriculaId == matriculaId && item.evaluacionId == evaluacionId);
            });

            cambiosPendientes.push({
                matriculaId: matriculaId,
                evaluacionId: evaluacionId,
                nota: parseFloat(nota),
                observacion: observacion,
                estudiante: notaInput.data('estudiante-nombre'),
                evaluacion: notaInput.data('evaluacion-nombre')
            });

            notaInput
                .removeClass('border-slate-300 border-emerald-500 border-red-500')
                .addClass('border-amber-500');
        }
    });

    function mostrarModal(titulo, mensaje, tipo, callback) {
        var iconos = {
            success: 'check-circle-2',
            error: 'x-circle',
            warning: 'alert-triangle',
            info: 'info'
        };

        var colores = {
            success: 'emerald',
            error: 'red',
            warning: 'amber',
            info: 'blue'
        };

        var color = colores[tipo] || 'blue';
        var icono = iconos[tipo] || 'info';

        var modalHtml = `
                            <div id="modalNotificacion" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 px-4">
                                <div class="w-full max-w-md rounded-3xl bg-white p-8 shadow-2xl">
                                    <div class="flex flex-col items-center text-center">
                                        <div class="flex h-16 w-16 items-center justify-center rounded-full bg-${color}-100 text-${color}-600">
                                            <i data-lucide="${icono}" class="h-8 w-8"></i>
                                        </div>
                                        <h3 class="mt-4 text-2xl font-extrabold text-slate-950">${titulo}</h3>
                                        <p class="mt-2 text-sm text-slate-600">${mensaje}</p>
                                    </div>
                                </div>
                            </div>
                        `;

        $('#modalNotificacion').remove();
        $('body').append(modalHtml);
        lucide.createIcons();

        setTimeout(function () {
            $('#modalNotificacion').fadeOut(300, function () {
                $(this).remove();
                if (callback) callback();
            });
        }, 3000);

        $('#modalNotificacion').on('click', function (e) {
            if (e.target === this) {
                $(this).fadeOut(300, function () {
                    $(this).remove();
                    if (callback) callback();
                });
            }
        });
    }

    $('#btnGuardarTodo').click(function () {
        var hayError = false;
        $('.nota-input').each(function () {
            var val = $(this).val();
            if (val !== '') {
                var nota = parseFloat(val);
                if (isNaN(nota) || nota < 0 || nota > 20) {
                    hayError = true;
                    return false;
                }
            }
        });

        if (hayError) {
            mostrarModal(
                'Notas inválidas',
                'Existen notas fuera del rango permitido (0 - 20).',
                'error',
                function () {
                    location.reload();
                }
            );
            return;
        }

        if (cambiosPendientes.length === 0) {
            mostrarModal(
                'Sin cambios',
                'No hay notas nuevas o modificadas para guardar.',
                'info',
                function () {
                    location.reload();
                }
            );
            return;
        }

        var $btn = $(this);
        $btn.prop('disabled', true)
            .html('<i data-lucide="loader-2" class="h-4 w-4 animate-spin"></i> Guardando...');
        lucide.createIcons();

        var guardados = 0;
        var errores = 0;
        var total = cambiosPendientes.length;
        var procesados = 0;

        $(cambiosPendientes).each(function (index, item) {
            $.ajax({
                url: (window.Urls && window.Urls.registrarNota) ? window.Urls.registrarNota : '/Docente/RegistrarNota',
                type: 'POST',
                data: {
                    matriculaId: item.matriculaId,
                    evaluacionId: item.evaluacionId,
                    nota: item.nota,
                    observacion: item.observacion
                },
                success: function (response) {
                    var selector = '.nota-input[data-matricula-id="' + item.matriculaId + '"][data-evaluacion-id="' + item.evaluacionId + '"]';

                    if (response.success) {
                        guardados++;
                        $(selector)
                            .removeClass('border-amber-500 border-red-500')
                            .addClass('border-emerald-500');
                    } else {
                        errores++;
                        $(selector)
                            .removeClass('border-amber-500 border-emerald-500')
                            .addClass('border-red-500');
                    }
                    procesados++;
                    if (procesados === total) {
                        mostrarResultado(guardados, errores);
                    }
                },
                error: function () {
                    errores++;
                    var selector = '.nota-input[data-matricula-id="' + item.matriculaId + '"][data-evaluacion-id="' + item.evaluacionId + '"]';
                    $(selector)
                        .removeClass('border-amber-500 border-emerald-500')
                        .addClass('border-red-500');
                    procesados++;
                    if (procesados === total) {
                        mostrarResultado(guardados, errores);
                    }
                }
            });
        });

        function mostrarResultado(guardados, errores) {
            $btn.prop('disabled', false)
                .html('<i data-lucide="save" class="h-4 w-4"></i> Registrar notas');
            lucide.createIcons();

            if (errores === 0) {
                mostrarModal(
                    '¡Éxito!',
                    `Se registraron ${guardados} nota(s) correctamente.`,
                    'success',
                    function () {
                        location.reload();
                    }
                );
            } else {
                mostrarModal(
                    'Errores al guardar',
                    `Guardados: ${guardados} | Errores: ${errores}`,
                    'error',
                    function () {
                        location.reload();
                    }
                );
            }

            cambiosPendientes = [];
        }
    });

    $('.obs-input').each(function () {
        if ($(this).val().trim() !== '' && $(this).val() !== 'Ninguna') {
            $(this).removeClass('hidden');
        }
    });

    $('.nota-input').focus(function () {
        $(this).closest('td').find('.obs-input').removeClass('hidden');
    });

    setTimeout(function () {
        verificarNotasInvalidas();
    }, 500);
});