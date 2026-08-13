document.addEventListener('DOMContentLoaded', function () {
    const modoNuevo = document.getElementById('modoNuevo');
    const modoExistente = document.getElementById('modoExistente');
    const seccionNuevo = document.getElementById('seccionNuevo');
    const seccionExistente = document.getElementById('seccionExistente');
    const usuarioId = document.getElementById('usuarioId');
    const inputNombre = document.getElementById('inputNombre');
    const inputEmail = document.getElementById('inputEmail');
    const nombreUsuarioSeleccionado = document.getElementById('nombreUsuarioSeleccionado');
    const emailUsuarioSeleccionado = document.getElementById('emailUsuarioSeleccionado');
    const errorUsuario = document.getElementById('errorUsuario');
    const modal = document.getElementById('modalUsuarios');
    const btnAbrir = document.getElementById('btnAbrirModalUsuarios');
    const btnCerrar = document.getElementById('btnCerrarModal');
    const btnCancelar = document.getElementById('btnCancelarModal');
    const inputBusqueda = document.getElementById('inputBusquedaUsuario');
    const listaUsuarios = document.getElementById('listaUsuarios');
    let timeoutBusqueda = null;

    function cambiarModo() {
        if (modoExistente.checked) {
            seccionNuevo.classList.add('hidden');
            seccionExistente.classList.remove('hidden');
            inputNombre.value = '';
            inputEmail.value = '';
            inputNombre.removeAttribute('required');
            inputEmail.removeAttribute('required');
        } else {
            seccionNuevo.classList.remove('hidden');
            seccionExistente.classList.add('hidden');
            usuarioId.value = '0';
            nombreUsuarioSeleccionado.value = '';
            emailUsuarioSeleccionado.value = '';
            errorUsuario.textContent = '';
            inputNombre.setAttribute('required', 'required');
            inputEmail.setAttribute('required', 'required');
        }
    }

    modoNuevo.addEventListener('change', cambiarModo);
    modoExistente.addEventListener('change', cambiarModo);

    btnAbrir.addEventListener('click', function () {
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        inputBusqueda.value = '';
        inputBusqueda.focus();
        buscarUsuarios('');
    });

    function cerrarModal() {
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }

    btnCerrar.addEventListener('click', cerrarModal);
    btnCancelar.addEventListener('click', cerrarModal);

    modal.addEventListener('click', function (e) {
        if (e.target === modal) cerrarModal();
    });

    inputBusqueda.addEventListener('input', function () {
        clearTimeout(timeoutBusqueda);
        const filtro = this.value.trim();
        timeoutBusqueda = setTimeout(() => buscarUsuarios(filtro), 300);
    });

    function buscarUsuarios(filtro) {
        listaUsuarios.innerHTML = `
            <div class="flex h-full flex-col items-center justify-center px-4 py-8 text-center text-sm text-slate-400">
                <div class="inline-block h-6 w-6 animate-spin rounded-full border-2 border-emerald-500 border-t-transparent"></div>
                <p class="mt-3 font-medium text-slate-500">Buscando usuarios...</p>
            </div>`;

        const inicio = Date.now();
        const MINIMO_MS = 3000;

        fetch(`/CRUDDocente/BuscarUsuarioDisponibleDocente?filtro=${encodeURIComponent(filtro)}`)
            .then(r => {
                if (!r.ok) throw new Error('Error en la respuesta del servidor');
                return r.json();
            })
            .then(data => {
                const transcurrido = Date.now() - inicio;
                const esperaRestante = Math.max(0, MINIMO_MS - transcurrido);
                setTimeout(() => {
                    renderResultados(data);
                }, esperaRestante);
            })
            .catch(err => {
                console.error(err);
                const transcurrido = Date.now() - inicio;
                const esperaRestante = Math.max(0, MINIMO_MS - transcurrido);
                setTimeout(() => {
                    listaUsuarios.innerHTML = `
                        <div class="flex h-full flex-col items-center justify-center px-4 py-8 text-center">
                            <div class="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-red-50 text-red-500">
                                <i data-lucide="alert-circle" class="h-6 w-6"></i>
                            </div>
                            <p class="text-sm font-medium text-slate-700">Error al cargar los usuarios</p>
                            <p class="mt-1 text-sm text-slate-500">Intente nuevamente en unos momentos.</p>
                        </div>`;
                    if (typeof lucide !== 'undefined') lucide.createIcons();
                }, esperaRestante);
            });
    }

    function renderResultados(data) {
        if (!data || data.length === 0) {
            listaUsuarios.innerHTML = `
                <div class="flex h-full flex-col items-center justify-center px-6 py-8 text-center">
                    <div class="mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-slate-100 text-slate-400">
                        <i data-lucide="user-x" class="h-7 w-7"></i>
                    </div>
                    <p class="text-base font-semibold text-slate-800">
                        Aún no hay usuarios disponibles
                    </p>
                    <p class="mt-2 max-w-xs text-sm text-slate-500">
                        Registre primero un usuario con rol <strong class="text-slate-700">Docente</strong> para poder vincularlo y registrarlo en el sistema.
                    </p>
                    <a href="/CRUDUsuario/CreateUsuario"
                       class="mt-5 inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700">
                        <i data-lucide="user-plus" class="h-4 w-4"></i>
                        Registrar usuario - docente
                    </a>
                </div>`;
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
            return;
        }

        let html = '';
        data.forEach(u => {
            html += `
                <div class="flex cursor-pointer items-center justify-between rounded-xl px-4 py-3 hover:bg-emerald-50"
                     data-id="${u.id}" data-nombre="${u.nombreCompleto}" data-email="${u.email}">
                    <div class="flex items-center gap-3">
                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-emerald-50 text-emerald-600">
                            <i data-lucide="user" class="h-5 w-5"></i>
                        </div>
                        <div>
                            <p class="text-sm font-semibold text-slate-900">${u.nombreCompleto}</p>
                            <p class="text-xs text-slate-500">${u.email}</p>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-medium text-emerald-700">${u.rol || 'Docente'}</span>
                        <button type="button" class="btn-seleccionar rounded-lg bg-emerald-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-emerald-700">
                            Seleccionar
                        </button>
                    </div>
                </div>`;
        });

        listaUsuarios.innerHTML = html;

        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }

        document.querySelectorAll('.btn-seleccionar').forEach(btn => {
            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                const fila = this.closest('[data-id]');
                seleccionarUsuario(fila.dataset.id, fila.dataset.nombre, fila.dataset.email);
            });
        });

        document.querySelectorAll('#listaUsuarios > div[data-id]').forEach(fila => {
            fila.addEventListener('click', function () {
                seleccionarUsuario(this.dataset.id, this.dataset.nombre, this.dataset.email);
            });
        });
    }

    function seleccionarUsuario(id, nombre, email) {
        usuarioId.value = id;
        nombreUsuarioSeleccionado.value = nombre;
        emailUsuarioSeleccionado.value = email;
        errorUsuario.textContent = '';
        cerrarModal();
    }

    document.getElementById('formDocente').addEventListener('submit', function (e) {
        if (modoExistente.checked) {
            if (!usuarioId.value || usuarioId.value === '0') {
                e.preventDefault();
                errorUsuario.textContent = 'Debe seleccionar un usuario.';
                return false;
            }
        }
    });
});