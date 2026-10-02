import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Keep Razorpay secrets server-side. Configure RAZORPAY_WEBHOOK_SECRET,
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in Supabase Edge Function secrets.
Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });
  const raw = await req.text();
  const signature = req.headers.get("x-razorpay-signature");
  if (!signature) return new Response("Missing signature", { status: 400 });
  // TODO: verify the Razorpay webhook HMAC with RAZORPAY_WEBHOOK_SECRET,
  // then map the provider subscription id to public.subscriptions and update
  // the business plan only after a verified subscription event.
  console.log("Verified webhook implementation required before production use", raw.length, !!signature);
  return new Response("Webhook scaffold", { status: 200 });
});
