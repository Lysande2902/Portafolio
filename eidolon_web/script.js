// Easter egg for the ARG element: 
// The user has to type "WAKEUP" or "WITNESS" to trigger the true face of Eidolon.

let secretCode = "";
const targetCode = "WITNESS";
const body = document.body;
const logo = document.querySelector('.logo');
const emailDisplay = document.querySelector('.email-display');

document.addEventListener('keydown', (e) => {
    // Collect keystrokes
    if (e.key.length === 1 && /[a-zA-Z]/.test(e.key)) {
        secretCode += e.key.toUpperCase();
    }

    // Keep buffer the size of targetCode
    if (secretCode.length > targetCode.length) {
        secretCode = secretCode.substring(secretCode.length - targetCode.length);
    }

    if (secretCode === targetCode) {
        triggerTrueEidolon();
    }
});

let isNightmareActive = false;
let crashLevel = 0;

function triggerTrueEidolon() {
    if (body.classList.contains('nightmare-mode')) return; // Avoid double triggering

    isNightmareActive = true;

    // Activate Real Nightmare Mode
    body.classList.add('dark-mode');
    body.classList.add('nightmare-mode');

    // Alter text elements heavily matching the game's lore
    logo.innerHTML = `<span style="color:red;">EIDOLON</span><span style="font-weight:300; margin-left:5px; text-decoration: line-through;">LIES</span>`;

    // Navbar
    const navLinks = document.querySelectorAll('.nav-links a');
    if (navLinks[0]) navLinks[0].innerText = "VÍCTIMAS";
    if (navLinks[1]) navLinks[1].innerText = "TORTURA ACTIVA";
    if (navLinks[2]) navLinks[2].innerText = "LA MÁQUINA";
    if (navLinks[3]) navLinks[3].innerText = "NO HAY SALIDA";

    // Hero
    const heroTitle = document.querySelector('.hero-content h1');
    if (heroTitle) heroTitle.innerHTML = `Destruyendo la <span class="highlight" style="font-family: monospace;">CONCIENCIA</span> Humana`;
    const heroDesc = document.querySelector('.hero-content p');
    if (heroDesc) heroDesc.innerText = "Has entrado en la capa 2 del protocolo. Alex se resiste. El bucle se reinicia. 15 llamadas perdidas. Él es el culpable.";
    const heroBtn = document.querySelector('.btn-primary.large');
    if (heroBtn) {
        heroBtn.innerText = "NO PUEDES DESPERTAR";
        heroBtn.style.backgroundColor = "transparent";
        heroBtn.style.border = "1px solid red";
        heroBtn.style.color = "red";
    }

    // About Section
    const titleAbout = document.getElementById('title-about');
    if (titleAbout) {
        titleAbout.innerText = "S0BR3 NU3STR0S P3C4D0S";
        titleAbout.classList.add('glitch-text');
    }
    const descAbout1 = document.getElementById('desc-about-1');
    if (descAbout1) descAbout1.innerText = "En Eidolon, creemos que el sufrimiento debe ser ETERNO. Jugamos a ser dioses con mentes rotas. Alex es nuestro paciente cero, nuestra marioneta favorita.";
    const descAbout2 = document.getElementById('desc-about-2');
    if (descAbout2) descAbout2.innerText = "Nuestra misión es simple: TORTURAR. Extirpar las 7 facetas. Que nunca olvide las 15 llamadas de Víctor que ignoró por grabar un live.";

    // Tech Section
    const titleTech = document.getElementById('title-tech');
    if (titleTech) {
        titleTech.innerText = "LA CÁRCEL NEURAL";
        titleTech.classList.add('glitch-text');
    }
    const descTech1 = document.getElementById('desc-tech-1');
    if (descTech1) descTech1.innerText = "El Protocolo MindHack está fallando a propósito. La faceta de VÍCTOR (La Ira) está colapsando la simulación. El Kernel mantiene vivo a Alex en un bucle de agonía. Él lo mató indirectamente por los likes. Ahora su cerebro pagará con cada ciclo que no logre superar.";

    // Trials Section
    const trialTitles = document.querySelectorAll('.trial-card h3');
    if (trialTitles[0]) trialTitles[0].innerText = "PENA_DE_MUERTE_DIGITAL";
    if (trialTitles[1]) trialTitles[1].innerText = "BORRADO_MASIVO: VÍCTOR";

    const statuses = document.querySelectorAll('.card-status');
    statuses.forEach(s => {
        s.className = 'card-status danger';
        s.innerText = "ERROR FATAL";
    });

    // Contact
    document.querySelector('.section-title#contact h2') && (document.querySelector('.section-title#contact h2').innerText = "VOTACIÓN FINAL");
    emailDisplay.innerHTML = "EL_RELOJ_SIGUE_CORRIENDO@WITNESS.ME";
    emailDisplay.style.backgroundColor = "#220000";
    emailDisplay.style.color = "red";

    // Uncomfortable visual nightmare (Distortion & Flashing)
    setInterval(() => {
        // Harsh invert flash (simulating broken CRT or neural overload)
        if (Math.random() > 0.85) {
            body.style.filter = 'invert(1) contrast(200%) grayscale(100%)';
            body.style.transform = `translate(${Math.random() * 20 - 10}px, ${Math.random() * 20 - 10}px)`;
            setTimeout(() => {
                body.style.filter = 'none';
                body.style.transform = 'none';
            }, 60 + Math.random() * 100);
        }

        // Randomly layout distortion on individual elements
        const elements = document.querySelectorAll('p, h2, h3, .trial-card');
        const target = elements[Math.floor(Math.random() * elements.length)];
        if (target) {
            const origTransform = target.style.transform || 'none';
            target.style.transform = `${origTransform} skew(${Math.random() * 30 - 15}deg)`;
            setTimeout(() => { target.style.transform = origTransform; }, 150); // Snap back quickly
        }
    }, 200);
}

// Interacción normal - Botón Copy Email
emailDisplay.addEventListener('click', () => {
    if (!body.classList.contains('dark-mode')) {
        navigator.clipboard.writeText("witnessme.eidolon@gmail.com");
        let originalText = emailDisplay.innerText;
        emailDisplay.innerText = "¡Copiado al portapapeles!";
        setTimeout(() => {
            emailDisplay.innerText = originalText;
        }, 2000);
    }
});

// --- ARG & FAKE 404 BOOT SEQUENCE ---
const fake404 = document.getElementById('fake-404');
const eidolonSite = document.getElementById('eidolon-site');
const consoleDiv = document.getElementById('creepy-console');

const messages = [
    "Estableciendo enlace seguro...",
    "El error 404 persiste.",
    "Eludiendo firewall neural...",
    "Usuario identificado como: EXTERNO",
    "ADVERTENCIA: Accediendo a subcapa Eidolon prohibida.",
    "Inyectando interfaz...",
    "Bienvenido a la verdad."
];

window.addEventListener('load', () => {
    // Escupir texto como si fuera una terminal después de unos segundos
    setTimeout(() => {
        let delay = 0;
        messages.forEach((msg, index) => {
            setTimeout(() => {
                consoleDiv.innerHTML += `\n[${new Date().toISOString().split('T')[1].slice(0, -1)}] ${msg}`;
            }, delay);
            delay += Math.random() * 800 + 400; // Entre 400ms y 1200ms por línea
        });

        // Al terminar los mensajes, hacer glitch y revelar
        setTimeout(() => {
            fake404.classList.add('glitching-404');

            setTimeout(() => {
                fake404.style.display = 'none';
                eidolonSite.style.opacity = 1;
                eidolonSite.style.pointerEvents = 'all';

                // AUTOMATIC HORROR TRIGGER: Decae después de 10 segundos
                setTimeout(() => {
                    triggerTrueEidolon();
                }, 10000);

            }, 1000); // 1 segundo de glitch grave

        }, delay + 500);

    }, 3000); // Esperar 3 segundos viendo solo el error 404
});

// --- CRASH ON CLICK LAYER (DEEP LORE) ---
document.addEventListener('click', (e) => {
    // Solo permitir que se crashee si la pesadilla ya comenzó
    if (!isNightmareActive) return;

    crashLevel++;
    const crashOverlay = document.getElementById('fatal-crash-overlay');
    crashOverlay.style.display = 'flex';

    if (crashLevel === 1) {
        // Stage 1: Pantalla Azul clásica (Falso error de sistema)
        crashOverlay.innerHTML = `<div class="fatal-text">*** MINDHACK KERNEL PANIC - FATAL EXCEPTION 0E ***</div>`;
        crashOverlay.innerHTML += `<div class="fatal-text">MEMORY LEAK DETECTED AT: 0xDEADBEEF</div>`;
        crashOverlay.innerHTML += `<div class="fatal-text">DUMPING PHYSICAL MEMORY...</div>`;
        crashOverlay.innerHTML += `<br><div class="fatal-text" style="animation: blink 1s infinite;">PULSE CLICK PARA FORZAR REINICIO DEL KERNEL...</div>`;
    } else if (crashLevel === 2) {
        // Stage 2: La pantalla se vuelve roja y el juego te habla
        crashOverlay.style.background = '#aa0000';
        crashOverlay.innerHTML += `<br><div class="fatal-text" style="color: black; background: white; display: inline-block; padding: 5px; font-weight: bold;">ERROR: VÍCTOR TE ESTÁ OBSERVANDO. VÍCTOR SIEMPRE TE ESTUVO OBSERVANDO.</div>`;
        crashOverlay.innerHTML += `<div class="fatal-text" style="font-size: 1.5rem; color: #fff;">¿POR QUÉ NO CONTESTASTE, ALEX?</div>`;
    } else if (crashLevel === 3) {
        // Stage 3: Ruptura visual
        body.style.filter = "invert(1)";
        crashOverlay.innerHTML += `<br><div class="fatal-text" style="color: #ffaaaa;">FACETA: IRA = DESBORDADA.</div>`;
        crashOverlay.innerHTML += `<div class="fatal-text" style="color: #ffaaaa;">MAGNOLIA LLORA EN LA OTRA HABITACIÓN. ERES UNA DECEPCIÓN.</div>`;
    } else if (crashLevel === 4) {
        // Stage 4: Culminación roja parpadeante
        crashOverlay.classList.add('kernel-panic');
        crashOverlay.innerHTML += `<br><div class="fatal-text" style="font-size: 4rem; color: yellow; font-weight: bold; background: black; line-height: 1;">TÚ LO<br>MATASTE.<br>15 LLAMADAS.</div>`;
    } else {
        // Stage 5+: Desbordamiento de basura de memoria (Cuelgue real de simulación)
        let garbage = "";
        const chars = "10!@#$%#$^&*()_+VÍCTORCULPAMORTALESCONDIDOERROR ";
        for (let i = 0; i < 1000; i++) {
            garbage += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        crashOverlay.innerHTML += `<span class="garbage-text">${garbage}</span>`;
        // Scroll to the bottom as new garbage arrives
        crashOverlay.scrollTop = crashOverlay.scrollHeight;

        // Provocar vibración en la cámara cada vez que hacen click ahora
        document.body.style.transform = `translate(${Math.random() * 40 - 20}px, ${Math.random() * 40 - 20}px)`;
        setTimeout(() => document.body.style.transform = 'none', 50);
    }
});
