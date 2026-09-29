import { createContext, useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { DemoStore } from "@/lib/demo-store";
import { useAuth } from "@/hooks/useAuth";
import { supabase } from "@/integrations/supabase/client";

export type WorkspaceStatus = "idle" | "loading" | "ready" | "saving" | "error";

export interface DemoContextValue {
  /** True only in the sample-data demo */
  isDemo: boolean;
  /** True when a signed-in user's real workspace is loaded */
  isWorkspace: boolean;
  workspaceStatus: WorkspaceStatus;
  workspaceError: string | null;
  /** Active data store (demo or real workspace) */
  demoStore: DemoStore | null;
  enterDemoMode: () => void;
  exitDemoMode: () => void;
  resetDemoData: () => void;
  bumpVersion: () => void;
  version: number;
}

export const DemoContext = createContext<DemoContextValue | null>(null);

export function DemoProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [demo, setDemo] = useState<DemoStore | null>(null);
  const [workspace, setWorkspace] = useState<DemoStore | null>(null);
  const [status, setStatus] = useState<WorkspaceStatus>("idle");
  const [error, setError] = useState<string | null>(null);
  const [version, setVersion] = useState(0);
  const loadedVersion = useRef(0);

  // Load (or create) the signed-in user's workspace
  useEffect(() => {
    if (!user) { setWorkspace(null); setStatus("idle"); return; }
    let cancelled = false;
    setStatus("loading");
    (async () => {
      const { data, error: err } = await supabase
        .from("workspaces").select("data").eq("owner_id", user.id).maybeSingle();
      if (cancelled) return;
      if (err) {
        setError(err.message.includes("workspaces")
          ? "Your database isn't set up yet. Run the setup script in Supabase."
          : err.message);
        setStatus("error");
        return;
      }
      const store = new DemoStore(false);
      const meta = user.user_metadata ?? {};
      if (data?.data) {
        store.load(data.data);
      } else {
        store.addUser({
          id: user.id,
          name: meta.full_name || user.email?.split("@")[0] || "Owner",
          email: user.email ?? "",
          role: "admin",
          status: "active",
          joinedAt: new Date().toISOString(),
        });
        const { error: insErr } = await supabase.from("workspaces").insert({
          owner_id: user.id,
          name: meta.company || "My workspace",
          plan: meta.plan || "growth",
          data: store.toJSON(),
        });
        if (insErr) { setError(insErr.message); setStatus("error"); return; }
      }
      if (cancelled) return;
      setWorkspace(store);
      setVersion((v) => { loadedVersion.current = v; return v; });
      setError(null);
      setStatus("ready");
    })();
    return () => { cancelled = true; };
  }, [user]);

  // Persist workspace changes (debounced)
  useEffect(() => {
    if (!workspace || demo || !user || version === loadedVersion.current) return;
    const t = setTimeout(async () => {
      setStatus("saving");
      const { error: err } = await supabase
        .from("workspaces")
        .update({ data: workspace.toJSON(), updated_at: new Date().toISOString() })
        .eq("owner_id", user.id);
      if (err) { setError(err.message); setStatus("error"); }
      else { setError(null); setStatus("ready"); }
    }, 600);
    return () => clearTimeout(t);
  }, [version, workspace, demo, user]);

  const enterDemoMode = useCallback(() => { setDemo(new DemoStore()); setVersion((v) => v + 1); }, []);
  const exitDemoMode = useCallback(() => { setDemo(null); setVersion((v) => v + 1); }, []);
  const resetDemoData = useCallback(() => {
    if (demo) { demo.reset(); setVersion((v) => v + 1); }
  }, [demo]);
  const bumpVersion = useCallback(() => setVersion((v) => v + 1), []);

  const value = useMemo<DemoContextValue>(() => ({
    isDemo: demo !== null,
    isWorkspace: demo === null && workspace !== null,
    workspaceStatus: status,
    workspaceError: error,
    demoStore: demo ?? workspace,
    enterDemoMode, exitDemoMode, resetDemoData, bumpVersion, version,
  }), [demo, workspace, status, error, enterDemoMode, exitDemoMode, resetDemoData, bumpVersion, version]);

  return <DemoContext.Provider value={value}>{children}</DemoContext.Provider>;
}
