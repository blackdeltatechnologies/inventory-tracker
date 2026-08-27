import { createClient } from "@supabase/supabase-js";

// Publishable (anon) credentials — safe to ship in client code.
const SUPABASE_URL =
  import.meta.env['VITE_SUPABASE_URL'] ?? "https://sizgzfuoksxzqizylzzw.supabase.co";
const SUPABASE_PUBLISHABLE_KEY =
  import.meta.env['VITE_SUPABASE_PUBLISHABLE_KEY'] ??
  "sb_publishable_weKQ8C2nx1bGAxHfmIyJDg_TIB6EJ3g";

export const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
    storage: typeof window === "undefined" ? undefined : window.localStorage,
  },
});
