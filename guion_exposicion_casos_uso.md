# 🎤 Guión de Exposición — Casos de Uso Óolale

> **Tip clave:** No empiecen hablando del sistema. Empiecen hablando del **problema humano**.
> Los maestros quieren ver que identificaron una necesidad real antes de diseñar cualquier funcionalidad.

---

## 🟥 APERTURA — El Dolor (2-3 minutos)

**[Quien expone habla de frente, sin leer, con seguridad:]**

> *"Imagínense que son músicos. Llevan años practicando, tienen talento, tienen un portafolio, pero…*
> *¿cómo consiguen trabajo?*
> *¿Cómo les avisa alguien que hay una Jam Session el sábado y necesitan un bajista?*
> *Por WhatsApp. Por un grupo de Facebook. Por un conocido del conocido.*"

**[Pausa. Dejan que caiga.] **

> *"El músico de hoy vive en una red de contactos improvisada, informal e ineficiente.*
> *Si eres nuevo en una ciudad, no conoces a nadie. No existes.*
> *Si eres bueno, pero nadie sabe que eres bueno, da igual.*
> *Y si alguien te contrató y fue una mala experiencia... no hay forma de advertirle a los demás."*

---

## 🟧 EL CONTEXTO — ¿A quién le pasa esto? (1 minuto)

> *"Y le pasa a un único perfil de usuario: el músico.*
>
> El mismo músico que hoy busca un evento para tocar, mañana puede organizar una Jam Session y necesitar encontrar un bajista.
>
> No hay un tipo de usuario "organizador" separado. En Óolale, **cualquier músico puede asumir cualquiera de los dos roles en cualquier momento**. Eso hace que el sistema tenga que servir a las dos caras de la misma moneda."*

---

## 🟨 LA PROPUESTA — Qué hace el sistema (1 minuto, sin tecnicismos)

> *"Diseñamos Óolale como la respuesta a ese problema.*
> *Una plataforma donde el músico tiene una identidad digital: su portafolio, su reputación, su disponibilidad.*
> *Y donde la búsqueda de talento deja de ser informal para volverse estructurada, trazable y confiable."*

---

## 🟩 TRANSICIÓN A LOS CASOS DE USO (clave para el maestro)

> *"Para modelar esa solución, identificamos **71 casos de uso** agrupados en **15 módulos funcionales**.*
> *Cada módulo responde a una necesidad concreta del usuario.*
> *Si me permiten, los voy a presentar por área de valor, no como una lista, sino como el recorrido que hace un músico desde el momento en que descarga la app."*

---

## 🗺️ EL RECORRIDO DEL USUARIO (cómo presentar los CU sin aburrirlos)

Presenten los módulos como una **historia en pasos**, no como una tabla:

### Paso 1 — "Entrar al sistema"
> *"Primero el usuario necesita existir en la plataforma. Ahí están los CU del módulo de Autenticación: registrarse, iniciar sesión, recuperar contraseña, cambiar sus datos de acceso. Son 7 casos de uso."*

### Paso 2 — "Construir su identidad"
> *"Una vez dentro, el músico construye quién es. Tiene su perfil, su foto, su bio, sus instrumentos, sus géneros, sus redes sociales, sus tarifas. Son los CU del módulo de Perfil — 6 casos de uso."*

### Paso 3 — "Mostrar su talento"
> *"Su identidad se complementa con lo que sabe hacer. El Portafolio le permite subir videos, audios, imágenes y setlists. Con privacidad configurable por elemento. Son 6 casos de uso."*

### Paso 4 — "Ser encontrado o encontrar"
> *"El músico necesita aparecer. Y cuando ese mismo músico quiere armar un proyecto, necesita buscar a otros. Ahí entra el módulo de Discovery: búsqueda por instrumento, por ubicación, por nombre, por género. 4 casos de uso."*

### Paso 5 — "Conectar"
> *"Encontrar a alguien es solo el primer paso. El músico puede enviar solicitudes de conexión, aceptarlas, rechazarlas o eliminarlas. Eso es el Networking. 4 casos de uso."*

### Paso 6 — "El corazón de la app: los Eventos"
> *"Aquí es donde ocurre la magia. Un músico crea un evento, lo publica con todos sus detalles, y otros músicos se postulan. Quien organizó lo aprueba, confirma asistencias, puede invitar directamente a quien conoció en el Discovery, y hay hasta un chat grupal para coordinar antes del evento. Por eso este módulo tiene 13 casos de uso — el más rico de todos."*

### Paso 7 — "El trabajo directo"
> *"No todo es un evento abierto. A veces un músico encuentra el perfil perfecto en el Discovery y le quiere hacer una oferta directa: un toque, una sesión de estudio, una composición. Eso es el módulo de Contrataciones: enviar una oferta, aceptarla, darle seguimiento. 3 casos de uso."*

### Paso 8 — "La comunicación"
> *"Toda esa red necesita un canal. Mensajería en tiempo real, formatos múltiples, estados de lectura. 4 casos de uso."*

### Paso 9 — "La reputación"
> *"Este es el módulo más estratégico. Porque en Óolale, tu historial te define. Calificaciones de 1 a 5 estrellas, reseñas escritas, fórmula de puntuación, y la posibilidad de reportar evaluaciones injustas. 4 casos de uso."*

### Paso 10 — "La seguridad y Finanzas"
> *"Para cerrar: el sistema tiene módulos de Notificaciones, Rankings, Moderación y Seguridad, un sistema de monetización con planes TOP, y una Wallet para gestionar los ingresos por contratación. En total, otros 20 casos de uso que sostienen todo lo anterior."*

---

## 💬 CIERRE PERFECTO PARA MAESTROS

> *"En resumen: diseñamos el sistema partiendo del dolor del músico — invisible, sin red, sin reputación formal.*
> *Los 71 casos de uso que modelamos no son una lista de funciones. Son el viaje completo de un músico que pasa de no existir… a ser contratado, calificado y reconocido.*
> *Eso es Óolale."*

---

## ⚡ TIPS PARA LA EXPO

| Situación | Qué hacer |
|---|---|
| El maestro pregunta "¿por qué ese caso de uso?" | Siempre responde con **el dolor que resuelve**, no con la función técnica. |
| El maestro pregunta "¿y si hay dos actores?" | Explica que el mismo usuario puede ser organizador o músico según el contexto. |
| El maestro pide un CU específico | Tienes el documento con los 71. Cítalo por número (ej. CU32, CU49). |
| Te preguntan algo que no está implementado | "Está contemplado en la segunda fase. La arquitectura ya lo soporta." |
| Silencio incómodo | Vuelven al recorrido del usuario. Nunca a la lista. |
