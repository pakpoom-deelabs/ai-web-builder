import Link from "next/link";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Pricing",
  description: "เลือกแพ็กเกจที่เหมาะกับคุณ",
};

type Plan = {
  name: string;
  price: string;
  priceSuffix?: string;
  description: string;
  features: string[];
  cta: { label: string; href: string };
  highlighted?: boolean;
};

const plans: Plan[] = [
  {
    name: "Basic",
    price: "ฟรี",
    description: "เริ่มต้นใช้งานโดยไม่มีค่าใช้จ่าย เหมาะสำหรับการทดลอง",
    features: [
      "1 โปรเจกต์",
      "พื้นที่จัดเก็บ 1 GB",
      "Community support",
    ],
    cta: { label: "เริ่มต้นใช้งาน", href: "#" },
  },
  {
    name: "Pro",
    price: "฿500",
    priceSuffix: "/เดือน",
    description: "ฟีเจอร์ครบสำหรับฟรีแลนซ์และทีมขนาดเล็ก",
    features: [
      "โปรเจกต์ไม่จำกัด",
      "พื้นที่จัดเก็บ 100 GB",
      "Custom domain",
      "Priority support",
    ],
    cta: { label: "สมัคร Pro", href: "#" },
    highlighted: true,
  },
  {
    name: "Enterprise",
    price: "ติดต่อเรา",
    description: "โซลูชันแบบเฉพาะสำหรับองค์กรขนาดใหญ่",
    features: [
      "ทุกฟีเจอร์ใน Pro",
      "SLA และความปลอดภัยระดับองค์กร",
      "Dedicated account manager",
      "การติดตั้งและฝึกอบรม",
    ],
    cta: { label: "ติดต่อฝ่ายขาย", href: "#" },
  },
];

export default function PricingPage() {
  return (
    <div className="flex flex-1 flex-col items-center bg-zinc-50 px-6 py-20 font-sans sm:py-28 dark:bg-black">
      <header className="w-full max-w-3xl text-center">
        <h1 className="text-4xl font-semibold tracking-tight text-zinc-950 sm:text-5xl dark:text-zinc-50">
          แพ็กเกจราคา
        </h1>
        <p className="mt-4 text-lg leading-8 text-zinc-600 dark:text-zinc-400">
          เลือกแพ็กเกจที่เหมาะกับคุณ ไม่มีข้อผูกมัด ยกเลิกได้ทุกเมื่อ
        </p>
      </header>

      <section className="mt-16 grid w-full max-w-5xl grid-cols-1 gap-6 md:grid-cols-3">
        {plans.map((plan) => (
          <article
            key={plan.name}
            className={`flex flex-col rounded-2xl border p-8 ${
              plan.highlighted
                ? "border-zinc-950 bg-white shadow-sm dark:border-zinc-50 dark:bg-zinc-950"
                : "border-black/[.08] bg-white dark:border-white/[.145] dark:bg-zinc-950"
            }`}
          >
            <div className="flex items-baseline justify-between">
              <h2 className="text-lg font-medium text-zinc-950 dark:text-zinc-50">
                {plan.name}
              </h2>
              {plan.highlighted && (
                <span className="rounded-full bg-zinc-950 px-2.5 py-1 text-xs font-medium text-zinc-50 dark:bg-zinc-50 dark:text-zinc-950">
                  แนะนำ
                </span>
              )}
            </div>

            <div className="mt-6 flex items-baseline gap-1">
              <span className="text-4xl font-semibold tracking-tight text-zinc-950 dark:text-zinc-50">
                {plan.price}
              </span>
              {plan.priceSuffix && (
                <span className="text-sm text-zinc-500 dark:text-zinc-400">
                  {plan.priceSuffix}
                </span>
              )}
            </div>

            <p className="mt-3 text-sm leading-6 text-zinc-600 dark:text-zinc-400">
              {plan.description}
            </p>

            <ul className="mt-8 flex-1 space-y-3 text-sm text-zinc-700 dark:text-zinc-300">
              {plan.features.map((feature) => (
                <li key={feature} className="flex items-start gap-2">
                  <svg
                    aria-hidden="true"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    className="mt-0.5 h-4 w-4 flex-none text-zinc-950 dark:text-zinc-50"
                  >
                    <path
                      fillRule="evenodd"
                      d="M16.704 5.29a1 1 0 0 1 .006 1.414l-7.5 7.6a1 1 0 0 1-1.42.006l-3.5-3.5a1 1 0 1 1 1.414-1.414l2.79 2.79 6.795-6.89a1 1 0 0 1 1.415-.006Z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span>{feature}</span>
                </li>
              ))}
            </ul>

            <Link
              href={plan.cta.href}
              className={`mt-8 flex h-11 items-center justify-center rounded-full px-5 text-sm font-medium transition-colors ${
                plan.highlighted
                  ? "bg-zinc-950 text-zinc-50 hover:bg-[#383838] dark:bg-zinc-50 dark:text-zinc-950 dark:hover:bg-[#ccc]"
                  : "border border-black/[.08] text-zinc-950 hover:bg-black/[.04] dark:border-white/[.145] dark:text-zinc-50 dark:hover:bg-[#1a1a1a]"
              }`}
            >
              {plan.cta.label}
            </Link>
          </article>
        ))}
      </section>
    </div>
  );
}
