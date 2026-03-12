# 🎯 Preguntas Clave sobre los Casos de Uso (Para Exposición)

Estas son las preguntas frecuentes que los maestros, profesores o jurados suelen hacer para poner a prueba tu conocimiento de la plataforma, medir la robustez lógica y verificar que los Casos de Uso tengan sentido con el modelo de negocio.

Además, he incluido cómo deberías responder y defenderlas.

---

## 👥 Sobre los Actores del Sistema
### 1. ¿Cuáles son los actores principales del sistema y cómo se diferencian?
*   **Respuesta esperada:** En Óolale existe un único gran actor general: "El usuario Musico/Artista". Sin embargo, dependiendo de sus acciones, toma el rol de **Contratador / Organizador** (cuando publica un evento, envía propuestas o contrata para un toque) o el rol de **Músico Postulante** (cuando busca en el *Discovery*, sube su portafolio y aplica a los eventos o acepta ofertas directas).

### 2. ¿Puede alguien buscar su portafolio o ver a los músicos sin haberse registrado primero?
*   **Respuesta esperada:** No. Para garantizar una red de profesionalismo, privacidad y prevenir spam hacia los músicos de la plataforma, todo usuario, ya sea que quiera buscar talento o buscar trabajo, debe obligatoriamente cruzar el Caso de Uso de "Registrarse" o "Iniciar Sesión" (y por lo tanto tener un perfil y estar verificado).

---

## 🗃️ Sobre Gestión y Portafolio
### 3. Tienen un caso de uso para subir "Setlists", ¿por qué lo separaron de simplemente subir el portafolio (fotos/videos)?
*   **Respuesta esperada:** Porque aporta un valor y funcionalidad fundamental que los vídeos o audios no tienen solos. No es meramente multimedia. Un Setlist revela el repertorio exacto y las dinámicas puntuales a otro usuario. Para un reemplazo de último minuto en un ensamble (o para aplicar a ciertos *Jam Sessions*), el Setlist actúa como filtro de selección esencial sobre el dominio de las canciones requeridas.

### 4. ¿Qué ocurre si un músico sube un video falso o robado al crear su perfil (CU08/CU09)?
*   **Respuesta esperada:** Es ahí donde el Sistema de **Calificaciones y Reputación (CU29 / CU30)** cumple su función y protege al ecosistema. Si contratan a un músico basándose en el portafolio falso, y luego éste no domina las canciones al presenciarse, los miembros que lo contrataron le pondrán 1 estrella en la app. A la larga, es autogestionable que queden bloqueados del *Discovery* con bajas valoraciones. Además, hay casos de uso de "Reporte" para la intervención de soporte adminstrativo.

---

## 🌍 Sobre el Discovery y la Búsqueda
### 5. ¿Si un músico no quiere ser contratado temporalmente (porque se va de gira o de vacaciones), seguirá saliendo a los organizadores en las búsquedas?
*   **Respuesta esperada:** No, justamente por eso hemos diseñado el Caso de Uso de "Actualizar disponibilidad (Open to Work)". Si el músico desactiva este *toggle* en su perfil, ya no recibirá notificaciones falsas de trabajo y los algoritmos del Discovery lo esconderán u obviarán de los filtros de "Contratación Directa".

### 6. ¿Qué pasa si busco "Baterista de Jazz en CABA", qué Casos de Uso están involucrados?
*   **Respuesta esperada:** Todos operan en conjunto: Se desencadenan los filtros del Caso de Uso "Buscar por Instrumento", cruzados con datos del "Buscar por Ubicación", y combinados con la lista de etiquetas rellenada dentro del CU "Gestionar géneros musicales" por parte de cada usuario baterista en la zona.

---

## 🗓️ Sobre Contrataciones y Eventos
### 7. En términos de flujo, ¿cuál es la diferencia exacta entre el Caso de Uso de "Postularse al Lineup de un Evento" y el de "Recibir y Aceptar Oferta de Trabajo"?
*   **Respuesta esperada:** La diferencia radica en la direccionalidad (**1-a-Muchos** vs **1-a-1**).
    *   **En el evento:** El Organizador crea la situación vacante abierta y espera pasivamente. *Muchos* músicos descubren esa vacante y se postulan (*1 vacante, a Muchos músicos*).
    *   **En la Oferta de Trabajo:** Un Organizador va proactivamente al Discovery, lee el Setlist de un perfil exacto y le envía una propuesta concreta por X dinero / X fecha solo a él (*1 Contratador, a 1 músico*).

### 8. ¿Qué sucede si el músico acepta la Oferta Laboral de un Contratador luego de leerla?
*   **Respuesta esperada:** El estado de la oferta enviada se actualiza en el panel del Contratador (de 'Pendiente' a 'Aceptada'). Además esto gatilla las Notificaciones del sistema para avisar al organizador, y habilita de inmediato el chat de mensajería directa e intercambio formal si no lo tenían antes asíncronamente para poder pactar horas y ubicación sin problemas.

---

## ⭐ Sobre la Reputación (Crucial para Maestros)
### 9. ¿Cómo aseguran que dos amigos músicos no abusen del sistema de calificaciones dejándose estrellas repetidamente y alterando su puntuación positiva de la app?
*   **Respuesta esperada:** Porque el sistema está cerrado a interacciones validadas. Un músico **sólo** puede reseñar o calificar a otro músico *inmediatamente después de que compartieron un "Evento Oficial" o una "Oferta oficial concretada en estado finalizado"*. Evitamos que sea una 'Red Social' libre, si no hay trabajo u evento en común verificado por la plataforma, no hay espacio para el botón de calificar.

### 10. Si un cliente/usuario vengativo califica a otro de forma maliciosa con 1 estrella (Ej. "no se quiso casar conmigo"), ¿qué se hace?
*   **Respuesta esperada:** Para estos extremos contamos con el mecanismo (CU31) de "Reportar calificación injusta". Al activarse, la plataforma congela esa calificación individual del promedio temporalmente y manda un *ticket al equipo de revisión (Administradores/Soporte).* Se audita, y si se comprueba que el texto es fuera de lo profesional y viola los términos, se la borra y posiblemente se sancione al usuario acosador.

---

### 💡 Tip para la Exposición Final:
Si un maestro pregunta por qué no añadieron una función en particular (Ejemplo: *"¿Por qué no hay pasarelas de pago dentro de la app o contratos laborales pdf para este caso de uso?"*), **siempre responde:**
> *"Consideramos la idea durante el análisis inicial; sin embargo, para el alcance de este sprint / entrega inicial decidimos priorizar que el usuario se comunique y que el 'matching' fluya. Formará parte de la Fase 2 del Roadmap, pero nuestra base de datos actual ya lo soporta."*
