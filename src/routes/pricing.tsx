import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { Check, ArrowLeft, Package } from "lucide-react";
import { useDemo } from "@/hooks/useDemo";

export const Route = createFileRoute("/pricing")({
  component: PricingPage,
  head: () => ({
    meta: [
      { title: "Pricing — Stackwise Inventory Plans" },
      {
        name: "description",
        content:
          "Simple Stackwise pricing. Start free with the demo, then upgrade to a real workspace with your own data, team roles, and unlimited stock movements.",
      },
      { property: "og:title", content: "Pricing — Stackwise Inventory Plans" },
      {
        property: "og:description",
        content:
          "Simple Stackwise pricing. Start free with the demo, then upgrade to a real workspace with your own data, team roles, and unlimited stock movements.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
});

interface Plan {
  id: string;
  name: string;
  price: string;
  period: string;
  tagline: string;
  features: string[];
  cta: string;
  highlighted?: boolean;
}

const plans: Plan[] = [
  {
    id: "starter",
    name: "Starter",
    price: "$0",
    period: "forever",
    tagline: "For a single operator getting organised.",
    features: [
      "Up to 100 items",
      "1 location",
      "Stock movements & history",
      "CSV import / export",
      "1 user",
    ],
    cta: "Create free account",
  },
  {
    id: "growth",
    name: "Growth",
    price: "$29",
    period: "per month",
    tagline: "For teams running real inventory day to day.",
    features: [
      "Unlimited items & locations",
      "Suppliers & purchase orders",
      "Inventory requests + approvals",
      "Role-based access (admin/manager/requestor)",
      "Analytics & reporting",
      "Up to 10 users",
    ],
    cta: "Start with Growth",
    highlighted: true,
  },
  {
    id: "scale",
    name: "Scale",
    price: "$79",
    period: "per month",
    tagline: "For multi-site operations that need forecasting.",
    features: [
      "Everything in Growth",
      "AI reorder & demand forecasting",
      "Anomaly detection",
      "Custom fields & barcode labels",
      "Priority support",
      "Unlimited users",
    ],
    cta: "Start with Scale",
  },
];

function PricingPage() {
  const navigate = useNavigate();
  const { isDemo, enterDemoMode } = useDemo();

  const handleTryDemo = () => {
    if (!isDemo) enterDemoMode();
    navigate({ to: "/app/dashboard" });
  };

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b border-border px-4 py-4">
        <div className="mx-auto flex max-w-6xl items-center justify-between">
          <Link to="/" className="flex items-center gap-2 text-sm font-semibold">
            <Package className="h-4 w-4 text-primary" />
            Stackwise
          </Link>
          <Link
            to="/"
            className="inline-flex items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Back home
          </Link>
        </div>
      </header>

      <main className="px-4 py-16 sm:py-24">
        <div className="mx-auto max-w-2xl text-center">
          <span className="inline-block rounded-md bg-primary/10 px-3 py-1 text-xs font-semibold text-primary">
            Pricing
          </span>
          <h1 className="mt-4 text-3xl font-semibold tracking-tight sm:text-4xl">
            Move from demo to your own workspace
          </h1>
          <p className="mx-auto mt-4 max-w-xl text-base text-muted-foreground">
            The demo runs on sample data that resets each session. Create an
            account to keep your own catalog, suppliers, and history.
          </p>
        </div>

        <div className="mx-auto mt-14 grid max-w-6xl grid-cols-1 gap-6 lg:grid-cols-3">
          {plans.map((plan) => (
            <div
              key={plan.id}
              className={`relative flex flex-col rounded-2xl border bg-card p-7 transition-all ${
                plan.highlighted
                  ? "border-primary shadow-xl shadow-primary/10 lg:-translate-y-2"
                  : "border-border shadow-xs hover:shadow-md"
              }`}
            >
              {plan.highlighted && (
                <span className="absolute -top-3 left-7 rounded-full bg-primary px-3 py-1 text-[11px] font-semibold text-primary-foreground">
                  Most popular
                </span>
              )}

              <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">
                {plan.name}
              </h2>
              <div className="mt-3 flex items-baseline gap-1.5">
                <span className="text-4xl font-semibold tracking-tight">{plan.price}</span>
                <span className="text-sm text-muted-foreground">/ {plan.period}</span>
              </div>
              <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
                {plan.tagline}
              </p>

              <ul className="mt-6 flex-1 space-y-3">
                {plan.features.map((f) => (
                  <li key={f} className="flex items-start gap-2.5 text-sm">
                    <Check className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
                    <span className="text-foreground/80">{f}</span>
                  </li>
                ))}
              </ul>

              <Link
                to="/signup"
                search={{ plan: plan.id }}
                className={`mt-7 inline-flex w-full items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold transition-all ${
                  plan.highlighted
                    ? "bg-primary text-primary-foreground shadow-lg hover:brightness-110"
                    : "border border-border bg-background text-foreground hover:bg-muted"
                }`}
              >
                {plan.cta}
              </Link>
            </div>
          ))}
        </div>

        <div className="mx-auto mt-16 max-w-2xl rounded-xl border border-border bg-muted/40 p-6 text-center">
          <p className="text-sm text-muted-foreground">
            Not ready yet? Explore the full product with sample data first.
          </p>
          <button
            type="button"
            onClick={handleTryDemo}
            className="mt-4 inline-flex items-center gap-2 rounded-lg border border-border bg-background px-4 py-2 text-sm font-semibold transition-colors hover:bg-muted"
          >
            Continue in demo
          </button>
        </div>
      </main>

      <footer className="border-t border-border px-4 py-10 text-center">
        <div className="flex items-center justify-center gap-2 text-sm text-muted-foreground">
          <Package className="h-4 w-4 text-primary" />
          <span>Built with Stackwise · {new Date().getFullYear()}</span>
        </div>
      </footer>
    </div>
  );
}
