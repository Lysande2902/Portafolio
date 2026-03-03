// ============================================
// SUPABASE EDGE FUNCTION: send-notification
// Firebase Cloud Messaging API v1
// ============================================

// Este archivo debe colocarse en: supabase/functions/send-notification/index.ts

// @ts-nocheck - Este archivo usa Deno, no Node.js
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { create, getNumericDate } from "https://deno.land/x/djwt@v2.8/mod.ts"

// Configuración de Firebase (desde variables de entorno)
const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID') || 'oolale'
const FIREBASE_CLIENT_EMAIL = Deno.env.get('FIREBASE_CLIENT_EMAIL') || 'firebase-adminsdk-fbsvc@oolale.iam.gserviceaccount.com'
const FIREBASE_PRIVATE_KEY = Deno.env.get('FIREBASE_PRIVATE_KEY') || ''

// Función para generar JWT token
async function generateJWT(): Promise<string> {
  const privateKey = FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
  
  const key = await crypto.subtle.importKey(
    "pkcs8",
    new TextEncoder().encode(privateKey),
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"]
  )

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: FIREBASE_CLIENT_EMAIL,
      sub: FIREBASE_CLIENT_EMAIL,
      aud: "https://oauth2.googleapis.com/token",
      iat: getNumericDate(0),
      exp: getNumericDate(3600),
      scope: "https://www.googleapis.com/auth/firebase.messaging",
    },
    key
  )

  return jwt
}

// Función para obtener Access Token de Google
async function getAccessToken(): Promise<string> {
  const jwt = await generateJWT()

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  })

  const data = await response.json()
  return data.access_token
}

// Función para enviar notificación a Firebase
async function sendNotification(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<boolean> {
  try {
    const accessToken = await getAccessToken()

    const message = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body,
        },
        data: data,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      },
    }

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
      }
    )

    if (!response.ok) {
      const error = await response.text()
      console.error("Error sending notification:", error)
      return false
    }

    console.log("Notification sent successfully")
    return true
  } catch (error) {
    console.error("Error in sendNotification:", error)
    return false
  }
}

// Handler principal
serve(async (req) => {
  // CORS headers
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const requestData = await req.json()
    const { user_id, title, body, type, data } = requestData

    console.log('Received request:', { user_id, title, body, type, hasData: !!data })

    if (!user_id || !title || !body) {
      return new Response(
        JSON.stringify({ error: "Missing required fields", received: { user_id, title, body } }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }

    // El token viene en data.token
    const token = data?.token
    
    if (!token) {
      console.error('No token provided in data:', data)
      return new Response(
        JSON.stringify({ error: "No FCM token provided in data", data }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      )
    }

    console.log('Sending notification to token:', token.substring(0, 20) + '...')

    // Enviar notificación
    const success = await sendNotification(
      token,
      title,
      body,
      {
        type: type || 'general',
        user_id: user_id,
        ...(data || {})
      }
    )

    console.log('Notification sent:', success)

    return new Response(
      JSON.stringify({ success, message: success ? "Notification sent" : "Failed to send" }),
      {
        status: success ? 200 : 500,
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    console.error("Error in handler:", error)
    return new Response(
      JSON.stringify({ error: error.message, stack: error.stack }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})

/* 
INSTRUCCIONES DE DESPLIEGUE:
=============================

1. Instalar Supabase CLI:
   npm install -g supabase

2. Inicializar proyecto:
   supabase init

3. Crear la función:
   supabase functions new send-notification

4. Copiar este código a:
   supabase/functions/send-notification/index.ts

5. Configurar secrets:
   supabase secrets set FIREBASE_PROJECT_ID=oolale
   supabase secrets set FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@oolale.iam.gserviceaccount.com
   supabase secrets set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"

6. Desplegar:
   supabase functions deploy send-notification

7. Obtener URL:
   La URL será algo como:
   https://[tu-proyecto].supabase.co/functions/v1/send-notification
*/
