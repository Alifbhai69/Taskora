import Link from "next/link";

export default function Home() {
  return (
    <main style={{
      maxWidth: 900,
      margin: "auto",
      padding: 30,
      fontFamily: "Arial",
      color: "#172033"
    }}>
      <h1 style={{color: "#2458d3"}}>Taskora</h1>
      <h2>ছোট কাজ, স্বচ্ছ লেনদেন, নতুন সুযোগ।</h2>
      <p>
        Taskora একটি Micro Job Marketplace।
        এখানে Client কাজ পোস্ট করবে এবং Worker কাজ সম্পন্ন করবে।
      </p>
      <Link href="/login">শুরু করুন</Link>
      <h3>কীভাবে কাজ করে?</h3>
      <p>১. Client কাজ পোস্ট করবে।</p>
      <p>২. Worker কাজ জমা দেবে।</p>
      <p>৩. যাচাইয়ের পর পেমেন্টের হিসাব হবে।</p>
    </main>
  );
}
