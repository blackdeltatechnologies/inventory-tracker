import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Package, ArrowLeft, Loader2 } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";

const planLabels: Record<string, string> = {
  starter: "Starter · $0/mo",
  growth: "Growth · $29/mo",
  scale: "Scale · $79/mo",
};

export const Route = createFileRoute("/signup")({
  validateSearch: (search: Record<string, unknown>) => ({
    plan: typeof search['plan'] === "string" ? (search['plan'] as string) : "growth",
  }),
  component: SignUpPage,
  head: () => ({
    meta: [
      { title: "Create your Stackwise account" },
      {
        name: "description",
        content:
          "Create a Stackwise workspace to move from the demo to real inventory: your own catalog, suppliers, purchase orders, and team roles.",
      },
      { property: "og:title", content: "Create your Stackwise account" },
      {
        property: "og:description",
        content:
          "Create a Stackwise workspace to move from the demo to real inventory: your own catalog, suppliers, purchase orders, and team roles.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
});

function SignUpPage() {
  const { plan } = Route.useSearch();
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [company, setCompany] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    // Account creation is wired up once the database connection is in place.
    window.setTimeout(() => {
      setSubmitting(false);
      toast.info("Almost there", {
        description:
          "Account creation goes live as soon as the database is connected. Your details weren't stored.",
      });
    }, 600);
  };

  return (
    <div className="flex min-h-screen flex-col bg-background text-foreground">
      <header className="border-b border-border px-4 py-4">
        <div className="mx-auto flex max-w-6xl items-center justify-between">
          <Link to="/" className="flex items-center gap-2 text-sm font-semibold">
            <Package className="h-4 w-4 text-primary" />
            Stackwise
          </Link>
          <Link
            to="/pricing"
            className="inline-flex items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Back to pricing
          </Link>
        </div>
      </header>

      <main className="flex flex-1 items-center justify-center px-4 py-12">
        <div className="w-full max-w-md rounded-2xl border border-border bg-card p-7 shadow-sm">
          <h1 className="text-xl font-semibold tracking-tight">Create your workspace</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            Selected plan:{" "}
            <span className="font-medium text-foreground">
              {planLabels[plan] ?? planLabels['growth']}
            </span>{" "}
            ·{" "}
            <Link to="/pricing" className="text-primary underline-offset-4 hover:underline">
              change
            </Link>
          </p>

          <form onSubmit={handleSubmit} className="mt-6 space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="name">Full name</Label>
              <Input
                id="name"
                autoComplete="name"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Alex Rivera"
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="company">Company</Label>
              <Input
                id="company"
                autoComplete="organization"
                value={company}
                onChange={(e) => setCompany(e.target.value)}
                placeholder="Acme Supply Co"
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="email">Work email</Label>
              <Input
                id="email"
                type="email"
                autoComplete="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@company.com"
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                autoComplete="new-password"
                required
                minLength={8}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="At least 8 characters"
              />
            </div>

            <button
              type="submit"
              disabled={submitting}
              className="inline-flex w-full items-center justify-center gap-2 rounded-lg bg-primary px-4 py-2.5 text-sm font-semibold text-primary-foreground shadow-lg transition-all hover:brightness-110 disabled:opacity-60"
            >
              {submitting && <Loader2 className="h-4 w-4 animate-spin" />}
              Create account
            </button>
          </form>

          <p className="mt-5 text-center text-xs text-muted-foreground">
            Just looking around?{" "}
            <Link to="/" className="text-primary underline-offset-4 hover:underline">
              Go back to the demo
            </Link>
          </p>
        </div>
      </main>
    </div>
  );
}
