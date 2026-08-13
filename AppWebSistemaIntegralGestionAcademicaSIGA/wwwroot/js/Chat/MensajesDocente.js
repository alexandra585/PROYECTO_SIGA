(function () {
    'use strict';
    const config = window.CHAT_CONFIG || {};
    let connection = null;
    let conversacionActualId = null;
    let apoderadoActualId = null;
    let cargandoConversacion = false;
    let modalCallback = null;

    function iniciarSignalR() {
        connection = new signalR.HubConnectionBuilder()
            .withUrl(config.hubUrl)
            .withAutomaticReconnect()
            .build();
        connection.on('RecibirMensaje', onRecibirMensaje);
        connection.on('UsuarioEnLinea', onUsuarioEnLinea);
        connection.on('UsuarioDesconectado', onUsuarioDesconectado);
        connection.on('MensajesLeidos', onMensajesLeidos);
        connection.on('ChatEliminado', onChatEliminado);
        connection.on('ChatVaciado', onChatVaciado);
        connection.on('ActualizarUltimoMensaje', onActualizarUltimoMensaje);
        connection.start()
            .then(async function () {
                console.log('SignalR conectado');
                try {
                    var resp = await fetch('/Chat/UsuariosEnLinea');
                    if (resp.ok) {
                        var data = await resp.json();
                        (data.usuarios || []).forEach(function (id) {
                            document.querySelectorAll('.estado-online[data-apoderado-id="' + id + '"]').forEach(function (p) {
                                p.classList.remove('bg-slate-300');
                                p.classList.add('bg-emerald-500');
                            });
                            if (apoderadoActualId === id) {
                                var el = document.getElementById('chatEstadoOnline');
                                if (el) {
                                    el.classList.remove('bg-slate-300');
                                    el.classList.add('bg-emerald-500');
                                }
                            }
                        });
                    }
                } catch (_) { }
            })
            .catch(function (err) { console.error('Error SignalR:', err); });
    }

    function onUsuarioEnLinea(usuarioId) {
        document.querySelectorAll('.estado-online[data-apoderado-id="' + usuarioId + '"]').forEach(function (p) {
            p.classList.remove('bg-slate-300');
            p.classList.add('bg-emerald-500');
        });
        if (apoderadoActualId === usuarioId) {
            var el = document.getElementById('chatEstadoOnline');
            if (el) {
                el.classList.remove('bg-slate-300');
                el.classList.add('bg-emerald-500');
            }
        }
    }

    function onUsuarioDesconectado(usuarioId) {
        document.querySelectorAll('.estado-online[data-apoderado-id="' + usuarioId + '"]').forEach(function (p) {
            p.classList.remove('bg-emerald-500');
            p.classList.add('bg-slate-300');
        });
        if (apoderadoActualId === usuarioId) {
            var el = document.getElementById('chatEstadoOnline');
            if (el) {
                el.classList.remove('bg-emerald-500');
                el.classList.add('bg-slate-300');
            }
        }
    }

    function onRecibirMensaje(mensaje) {
        var convId = mensaje.conversacionId || mensaje.ConversacionId;
        if (convId === conversacionActualId) {
            quitarEstadoVacio();
            agregarBurbuja(mensaje);
            scrollAlFinal();
        }
        var item = document.querySelector('.apoderado-item[data-conversacion-id="' + convId + '"]');
        if (item) {
            var ultimo = item.querySelector('.ultimo-mensaje');
            if (ultimo) ultimo.textContent = mensaje.contenido || mensaje.Contenido || '';
        }
    }

    function onActualizarUltimoMensaje(conversacionId, texto) {
        var item = document.querySelector('.apoderado-item[data-conversacion-id="' + conversacionId + '"]');
        if (item) {
            var ultimo = item.querySelector('.ultimo-mensaje');
            if (ultimo) ultimo.textContent = texto;
        }
    }

    function onMensajesLeidos() { }

    function onChatEliminado(conversacionId) {
        var item = document.querySelector('.apoderado-item[data-conversacion-id="' + conversacionId + '"]');
        if (item) item.remove();
        cerrarChat();
    }

    function onChatVaciado(conversacionId) {
        if (conversacionId === conversacionActualId) {
            mostrarEstadoVacio();
        }
    }

    function mostrarCargando() {
        var cont = document.getElementById('contenedorMensajes');
        cont.innerHTML =
            '<div class="flex h-full min-h-[12rem] flex-col items-center justify-center text-center">' +
            '<div class="mb-3 h-8 w-8 animate-spin rounded-full border-2 border-blue-200 border-t-blue-600"></div>' +
            '<p class="text-sm font-medium text-slate-500">Cargando mensajes...</p>' +
            '</div>';
    }

    function mostrarEstadoVacio() {
        var cont = document.getElementById('contenedorMensajes');
        cont.innerHTML =
            '<div class="flex h-full min-h-[12rem] flex-col items-center justify-center px-6 text-center">' +
            '<div class="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-600 shadow-md">' +
            '<svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.8">' +
            '<path stroke-linecap="round" stroke-linejoin="round" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />' +
            '</svg></div>' +
            '<p class="text-base font-bold text-slate-800">Aún no hay mensajes</p>' +
            '<p class="mt-2 max-w-sm text-sm leading-relaxed text-slate-500">Redacta tu primer mensaje para iniciar la conversación con este apoderado.</p>' +
            '</div>';
    }

    function quitarEstadoVacio() {
        var cont = document.getElementById('contenedorMensajes');
        if (cont.querySelector('.animate-spin') || cont.textContent.indexOf('Aún no hay mensajes') !== -1) {
            cont.innerHTML = '';
        }
    }

    function esperar(ms) {
        return new Promise(function (resolve) { setTimeout(resolve, ms); });
    }

    async function abrirConversacion(apoderadoId, nombre, hijos) {
        if (cargandoConversacion) return;
        cargandoConversacion = true;
        apoderadoActualId = apoderadoId;
        document.getElementById('chatVacio').classList.add('hidden');
        document.getElementById('chatActivo').classList.remove('hidden');
        document.getElementById('chatNombreApoderado').textContent = nombre;

        var hijosTexto = hijos && hijos.trim() !== '' ? 'Hijos a cargo: ' + hijos : 'Sin hijos a cargo';
        document.getElementById('chatHijos').textContent = hijosTexto;

        var estadoItem = document.querySelector('.estado-online[data-apoderado-id="' + apoderadoId + '"]');
        var chatEstado = document.getElementById('chatEstadoOnline');
        if (estadoItem && estadoItem.classList.contains('bg-emerald-500')) {
            chatEstado.classList.remove('bg-slate-300');
            chatEstado.classList.add('bg-emerald-500');
        } else {
            chatEstado.classList.remove('bg-emerald-500');
            chatEstado.classList.add('bg-slate-300');
        }

        mostrarCargando();

        var inicio = Date.now();
        var data = null;
        var errorMsg = null;

        try {
            var itemLista = document.querySelector('.apoderado-item[data-apoderado-id="' + apoderadoId + '"]');
            var convExistente = itemLista ? itemLista.getAttribute('data-conversacion-id') : '';
            var url = '/Chat/ObtenerConversacionDocente?apoderadoId=' + apoderadoId;
            if (convExistente && convExistente !== '' && convExistente !== '0') {
                url += '&conversacionId=' + convExistente;
            }
            var resp = await fetch(url);
            if (!resp.ok) {
                var detalle = 'Error al cargar conversación (HTTP ' + resp.status + ')';
                try {
                    var errBody = await resp.json();
                    if (errBody && errBody.detalle) detalle = errBody.detalle;
                    else if (errBody && errBody.mensaje) detalle = errBody.mensaje;
                } catch (_) { }
                throw new Error(detalle);
            }
            data = await resp.json();
        } catch (err) {
            console.error(err);
            errorMsg = (err && err.message) ? err.message : 'No se pudo cargar la conversación.';
        }
        var restante = 3000 - (Date.now() - inicio);
        if (restante > 0) await esperar(restante);
        var cont = document.getElementById('contenedorMensajes');
        if (errorMsg) {
            cont.innerHTML =
                '<div class="flex h-full min-h-[12rem] flex-col items-center justify-center px-4 text-center">' +
                '<p class="text-sm text-red-500">' + errorMsg + '</p></div>';
            cargandoConversacion = false;
            return;
        }
        conversacionActualId = data.conversacionId || data.ConversacionId;
        var item = document.querySelector('.apoderado-item[data-apoderado-id="' + apoderadoId + '"]');
        if (item) item.setAttribute('data-conversacion-id', conversacionActualId);
        cont.innerHTML = '';
        var mensajes = data.mensajes || data.Mensajes || [];
        if (!mensajes.length) {
            mostrarEstadoVacio();
        } else {
            mensajes.forEach(function (m) { agregarBurbuja(m); });
            scrollAlFinal();
        }
        if (connection && connection.state === signalR.HubConnectionState.Connected && conversacionActualId) {
            connection.invoke('UnirseConversacion', conversacionActualId).catch(function () { });
            connection.invoke('MarcarComoLeido', conversacionActualId).catch(function () { });
        }
        if (item) {
            var badge = item.querySelector('.badge-no-leidos');
            if (badge) badge.remove();
        }
        cargandoConversacion = false;
    }

    async function cerrarChat() {
        if (connection && connection.state === signalR.HubConnectionState.Connected && conversacionActualId) {
            try { await connection.invoke('SalirConversacion', conversacionActualId); } catch (_) { }
        }
        document.getElementById('chatActivo').classList.add('hidden');
        document.getElementById('chatVacio').classList.remove('hidden');
        document.getElementById('contenedorMensajes').innerHTML = '';
        conversacionActualId = null;
        apoderadoActualId = null;
        cargandoConversacion = false;
        document.querySelectorAll('.apoderado-item').forEach(function (b) {
            b.classList.remove('bg-white', 'ring-1', 'ring-blue-200');
        });
    }

    function agregarBurbuja(m) {
        var cont = document.getElementById('contenedorMensajes');
        var esMio = m.esMio === true || m.EsMio === true;
        var contenido = m.contenido || m.Contenido || '';
        var fecha = m.fechaEnvio || m.FechaEnvio;
        var hora = fecha
            ? new Date(fecha).toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit' })
            : '';
        var div = document.createElement('div');
        div.className = 'mb-2 flex ' + (esMio ? 'justify-end' : 'justify-start');
        div.innerHTML =
            '<div class="max-w-[75%] rounded-2xl px-3.5 py-2 shadow-sm ' +
            (esMio
                ? 'rounded-br-md bg-blue-600 text-white'
                : 'rounded-bl-md bg-white text-slate-800') +
            '"><p class="whitespace-pre-wrap break-words text-sm">' + escapeHtml(contenido) +
            '</p><p class="mt-1 text-right text-[10px] ' +
            (esMio ? 'text-blue-100' : 'text-slate-400') + '">' + hora + '</p></div>';
        cont.appendChild(div);
    }

    function escapeHtml(text) {
        var map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
        return String(text).replace(/[&<>"']/g, function (c) { return map[c]; });
    }

    function scrollAlFinal() {
        var cont = document.getElementById('contenedorMensajes');
        setTimeout(function () {
            cont.scrollTop = cont.scrollHeight;
        }, 0);
    }

    async function enviarMensaje(e) {
        e.preventDefault();
        var input = document.getElementById('inputMensaje');
        var texto = (input.value || '').trim();
        if (!texto || !conversacionActualId) return;
        if (!connection || connection.state !== signalR.HubConnectionState.Connected) {
            alert('No hay conexión en tiempo real. Recarga la página.');
            return;
        }
        try {
            await connection.invoke('EnviarMensaje', conversacionActualId, texto);
            input.value = '';
            input.style.height = 'auto';
        } catch (err) {
            console.error(err);
            alert('No se pudo enviar el mensaje.');
        }
    }

    function abrirModal(titulo, texto, esPeligro, callback) {
        document.getElementById('modalTitulo').textContent = titulo;
        document.getElementById('modalTexto').textContent = texto;
        document.getElementById('modalSubtitulo').textContent = esPeligro
            ? 'Esta acción no se puede deshacer fácilmente'
            : 'Puedes seguir chateando después';
        var header = document.getElementById('modalHeader');
        var btn = document.getElementById('modalAceptar');
        var icono = document.getElementById('modalIcono');
        if (esPeligro) {
            header.className = 'bg-gradient-to-r from-red-600 to-rose-600 px-6 py-5';
            btn.className = 'flex-1 rounded-xl bg-red-600 px-4 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-red-700';
            btn.textContent = 'Eliminar';
            icono.setAttribute('data-lucide', 'trash-2');
        } else {
            header.className = 'bg-gradient-to-r from-slate-800 to-slate-700 px-6 py-5';
            btn.className = 'flex-1 rounded-xl bg-blue-600 px-4 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700';
            btn.textContent = 'Vaciar';
            icono.setAttribute('data-lucide', 'eraser');
        }
        modalCallback = callback;
        document.getElementById('modalConfirmar').classList.remove('hidden');
        if (window.lucide) lucide.createIcons();
    }

    function cerrarModal() {
        document.getElementById('modalConfirmar').classList.add('hidden');
        modalCallback = null;
    }

    function eliminarChat() {
        if (!conversacionActualId) return;
        document.getElementById('menuChat').classList.add('hidden');
        abrirModal(
            'Eliminar chat',
            '¿Eliminar este chat? Desaparecerá de tu lista. El apoderado seguirá viendo la conversación.',
            true,
            async function () {
                try {
                    await connection.invoke('EliminarChat', conversacionActualId);
                } catch (err) {
                    console.error(err);
                }
            }
        );
    }

    function vaciarChat() {
        if (!conversacionActualId) return;
        document.getElementById('menuChat').classList.add('hidden');
        abrirModal(
            'Vaciar chat',
            '¿Vaciar el chat? Solo se borrarán los mensajes para ti. El apoderado no se verá afectado.',
            false,
            async function () {
                try {
                    await connection.invoke('VaciarChat', conversacionActualId);
                } catch (err) {
                    console.error(err);
                }
            }
        );
    }

    function filtrarApoderados() {
        var q = (document.getElementById('buscarApoderado').value || '').toLowerCase();
        document.querySelectorAll('.apoderado-item').forEach(function (item) {
            var nombre = (item.getAttribute('data-nombre') || '').toLowerCase();
            var hijos = (item.getAttribute('data-hijos') || '').toLowerCase();
            item.style.display = (nombre.indexOf(q) !== -1 || hijos.indexOf(q) !== -1) ? '' : 'none';
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        iniciarSignalR();
        document.querySelectorAll('.apoderado-item').forEach(function (btn) {
            btn.addEventListener('click', function () {
                document.querySelectorAll('.apoderado-item').forEach(function (b) {
                    b.classList.remove('bg-white', 'ring-1', 'ring-blue-200');
                });
                btn.classList.add('bg-white', 'ring-1', 'ring-blue-200');
                abrirConversacion(
                    parseInt(btn.getAttribute('data-apoderado-id'), 10),
                    btn.getAttribute('data-nombre'),
                    btn.getAttribute('data-hijos')
                );
            });
        });
        document.getElementById('formEnviarMensaje').addEventListener('submit', enviarMensaje);
        var input = document.getElementById('inputMensaje');
        input.addEventListener('input', function () {
            input.style.height = 'auto';
            input.style.height = Math.min(input.scrollHeight, 70) + 'px';
        });
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                document.getElementById('formEnviarMensaje').requestSubmit();
            }
        });
        var buscar = document.getElementById('buscarApoderado');
        buscar.addEventListener('input', filtrarApoderados);
        buscar.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                if (buscar.value) {
                    buscar.value = '';
                    filtrarApoderados();
                } else {
                    buscar.blur();
                }
            }
        });
        document.getElementById('btnMenuChat').addEventListener('click', function (e) {
            e.stopPropagation();
            document.getElementById('menuChat').classList.toggle('hidden');
        });
        document.addEventListener('click', function () {
            document.getElementById('menuChat').classList.add('hidden');
        });
        document.getElementById('btnEliminarChat').addEventListener('click', eliminarChat);
        document.getElementById('btnVaciarChat').addEventListener('click', vaciarChat);
        document.getElementById('btnCerrarChat').addEventListener('click', cerrarChat);
        document.getElementById('modalCancelar').addEventListener('click', cerrarModal);
        document.getElementById('modalAceptar').addEventListener('click', async function () {
            var cb = modalCallback;
            cerrarModal();
            if (cb) await cb();
        });
        document.getElementById('modalConfirmar').addEventListener('click', function (e) {
            if (e.target === this) cerrarModal();
        });
        if (window.lucide) lucide.createIcons();
    });
})();