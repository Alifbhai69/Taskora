"use client";

import { useState } from "react";
import { createClient } from "@supabase/supabase-js";

export default function Login() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");

  async function sendLoginLink() {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (!url || !key) {
      setMessage("Supabase এখনো সংযুক্ত হয়নি।");
      return;
    }

    const supabase = createClient(url, key);

    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: window.location.origin
      }
    });

    setMessage(
      error ? error.message : "আপনার ইমেইলে লগইন লিংক পাঠানো হয়েছে।"
    );
  }

  return (
    <main className="login">
      <a href="/" className="brand">Taskora</a>
      <h1>অ্যাকাউন্টে প্রবেশ</h1>
      <p>ইমেইল দিয়ে নিরাপদ লগইন লিংক নিন।</p>

      <input
        type="email"
        placeholder="আপনার ইমেইল"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />

      <button onClick={sendLoginLink}>
        লগইন লিংক পাঠান
      </button>

      <p>{message}</p>
    </main>
  );
} 
