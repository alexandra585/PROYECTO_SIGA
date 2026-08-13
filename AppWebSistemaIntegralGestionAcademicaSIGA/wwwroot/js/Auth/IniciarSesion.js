function mostrarModal(tipo, mensaje) {
    let modal = document.getElementById('customModal');

    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'customModal';
        modal.className = 'modal-overlay';
        modal.innerHTML = `
            <div class="modal-container" id="modalContainer">
                <!-- Icono SVG -->
                <svg class="modal-icon" id="modalIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"/>
                    <path d="M8 14s1.5 2 4 2 4-2 4-2"/>
                    <path d="M9 9h.01"/>
                    <path d="M15 9h.01"/>
                </svg>
                
                <div class="modal-badge" id="modalBadge">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                        <polyline points="22 4 12 14.01 9 11.01"/>
                    </svg>
                    Éxito
                </div>
                
                <h2 class="modal-title" id="modalTitle">¡Operación Exitosa!</h2>
                <p class="modal-message" id="modalMessage">Mensaje de prueba</p>
                
                <div class="modal-progress-container">
                    <div class="modal-progress-bar" id="modalProgress"></div>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    const container = document.getElementById('modalContainer');
    const icon = document.getElementById('modalIcon');
    const badge = document.getElementById('modalBadge');
    const title = document.getElementById('modalTitle');
    const message = document.getElementById('modalMessage');
    const progress = document.getElementById('modalProgress');
    const overlay = document.getElementById('customModal');

    bloquearCampos(true);

    if (tipo === 'success') {
        icon.innerHTML = `
            <circle cx="12" cy="12" r="10"/>
            <path d="M8 14s1.5 2 4 2 4-2 4-2"/>
            <circle cx="9" cy="9" r="0.5" fill="currentColor"/>
            <circle cx="15" cy="9" r="0.5" fill="currentColor"/>
        `;
        icon.style.color = '#34d399';

        badge.innerHTML = `
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
            Éxito
        `;

        title.textContent = '¡Operación Exitosa!';
        container.className = 'modal-container success';

    } else {
        icon.innerHTML = `
            <circle cx="12" cy="12" r="10"/>
            <path d="M16 16s-1.5-2-4-2-4 2-4 2"/>
            <circle cx="9" cy="9" r="0.5" fill="currentColor"/>
            <circle cx="15" cy="9" r="0.5" fill="currentColor"/>
        `;
        icon.style.color = '#f87171';

        badge.innerHTML = `
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <line x1="15" y1="9" x2="9" y2="15"/>
                <line x1="9" y1="9" x2="15" y2="15"/>
            </svg>
            Error
        `;

        title.textContent = '¡Oops! Algo salió mal';
        container.className = 'modal-container error';
    }

    message.textContent = mensaje;

    overlay.classList.add('active');
    document.body.style.overflow = 'hidden';

    progress.style.width = '0%';

    let startTime = Date.now();
    const duration = 3000;

    function updateProgress() {
        const elapsed = Date.now() - startTime;
        const progressPercent = Math.min((elapsed / duration) * 100, 100);

        progress.style.width = progressPercent + '%';

        if (elapsed < duration) {
            requestAnimationFrame(updateProgress);
        } else {
            setTimeout(function () {
                cerrarModal();
            }, 200);
        }
    }

    setTimeout(updateProgress, 50);
}

function cerrarModal() {
    const modal = document.getElementById('customModal');
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';

        const progress = document.getElementById('modalProgress');
        if (progress) {
            progress.style.width = '0%';
        }
    }

    bloquearCampos(false);
}

function bloquearCampos(bloquear) {
    const emailInput = document.querySelector('input[name="email"]') || document.getElementById('email');
    const passwordInput = document.getElementById('passwordInput');

    if (emailInput) {
        emailInput.readOnly = bloquear;
        emailInput.style.opacity = bloquear ? '0.65' : '1';
        emailInput.style.cursor = bloquear ? 'not-allowed' : '';
    }

    if (passwordInput) {
        passwordInput.readOnly = bloquear;
        passwordInput.style.opacity = bloquear ? '0.65' : '1';
        passwordInput.style.cursor = bloquear ? 'not-allowed' : '';
    }

    const togglePassword = document.getElementById('togglePassword');
    if (togglePassword) {
        togglePassword.disabled = bloquear;
        togglePassword.style.opacity = bloquear ? '0.5' : '1';
        togglePassword.style.pointerEvents = bloquear ? 'none' : '';
    }
}

(function () {
    var alert = document.getElementById('errorAlert');
    if (alert) {
        setTimeout(function () {
            if (alert) {
                alert.style.opacity = '0';
                alert.style.transition = 'opacity 0.3s ease';
                setTimeout(function () {
                    if (alert) alert.style.display = 'none';
                }, 300);
            }
        }, 1500);
    }
})();

(function () {
    var form = document.getElementById('loginForm');
    var submitBtn = document.getElementById('submitBtn');
    var isSubmitting = false;

    if (form && submitBtn) {
        form.addEventListener('submit', function (e) {
            if (isSubmitting) {
                e.preventDefault();
                return false;
            }

            var isValid = true;
            if (typeof $ !== 'undefined' && $.validator && $(form).valid) {
                isValid = $(form).valid();
            } else if (form.checkValidity) {
                isValid = form.checkValidity();
            }

            if (!isValid) {
                e.preventDefault();
                return false;
            }

            e.preventDefault();

            isSubmitting = true;
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;

            bloquearCampos(true);

            submitBtn.innerHTML = `
                <span style="
                    display: inline-block;
                    width: 20px;
                    height: 20px;
                    margin-right: 8px;
                    border: 2px solid rgba(255,255,255,0.3);
                    border-radius: 50%;
                    border-top-color: #ffffff;
                    animation: spin 0.8s linear infinite;
                "></span>
                Ingresando
            `;

            if (!document.getElementById('loginSpinStyle')) {
                var style = document.createElement('style');
                style.id = 'loginSpinStyle';
                style.textContent = `
                    @keyframes spin {
                        from { transform: rotate(0deg); }
                        to { transform: rotate(360deg); }
                    }
                `;
                document.head.appendChild(style);
            }

            setTimeout(function () {
                form.submit();
            }, 1500);
        });
    }
})();

(function () {
    var selects = document.querySelectorAll('.input-field select');
    selects.forEach(function (select) {
        if (select.value !== '') {
            select.setAttribute('data-selected', 'true');
        }
        select.addEventListener('change', function () {
            if (this.value !== '') {
                this.setAttribute('data-selected', 'true');
            } else {
                this.removeAttribute('data-selected');
            }
        });
    });
})();

(function () {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function () {
            verificarMensajes();
        });
    } else {
        verificarMensajes();
    }

    function verificarMensajes() {
        var errorAlert = document.getElementById('errorAlert');
        if (errorAlert && errorAlert.textContent.trim() !== '') {
            mostrarModal('error', errorAlert.textContent.trim());
            errorAlert.style.display = 'none';
        }

        var successAlert = document.getElementById('successAlert');
        if (successAlert && successAlert.textContent.trim() !== '') {
            mostrarModal('success', successAlert.textContent.trim());
            successAlert.style.display = 'none';
        }
    }
})();