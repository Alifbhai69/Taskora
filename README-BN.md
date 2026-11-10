# Taskora Public Starter (Mobile-friendly)

এটি Next.js + Supabase ভিত্তিক পাবলিক ওয়েবসাইটের **শুরুর প্যাকেজ**। এটি এক ক্লিকে সম্পূর্ণ production marketplace নয়। আগে test project-এ চালান; real money/payment চালু করবেন না।

## মোবাইল থেকে সেটআপ
1. ZIP Extract করুন।
2. GitHub-এ নতুন private repository তৈরি করে ফাইল আপলোড করুন।
3. Supabase-এ নতুন project তৈরি করুন।
4. Supabase SQL Editor-এ `supabase/schema.sql` খুলে সম্পূর্ণ SQL চালান।
5. Supabase Project Settings → API থেকে Project URL ও anon/publishable key নিন। **service_role key কখনো frontend/GitHub/chat-এ দেবেন না।**
6. `.env.example` কপি করে `.env.local` বানান; URL ও anon key বসান। GitHub-এ `.env.local` আপলোড করবেন না।
7. Vercel-এ GitHub repository Import করুন; Environment Variables-এ একই দুইটি value বসিয়ে Deploy দিন।
8. Supabase Auth → URL Configuration-এ Vercel-এর live URL এবং redirect URL যোগ করুন।

## Payment flow (manual)
- Client bKash/Nagad-এ নির্ধারিত merchant/business payment destination-এ টাকা পাঠাবে।
- ওয়েব অ্যাপে payment request-এ amount, method, transaction reference জমা হবে।
- Admin আলাদা নিরাপদ admin role দিয়ে provider dashboard/statement-এ মিলিয়ে দেখে approve/reject করবে।
- শুধু client-side form submit করলেই wallet credit হবে না। Approval-এর পরে database transaction/secure server function দিয়ে ledger entry তৈরি করতে হবে।
- এই starter schema payment request ও ledger কাঠামো দেয়; **সম্পূর্ণ admin UI, server-side approve/reject endpoint, task escrow release এবং withdrawal disbursement integration এখনও implement ও security review করতে হবে।**

## Safety / production checklist
- Supabase Auth email verification এবং MFA for admins চালু করুন।
- Admin role কখনো public signup থেকে set করা যাবে না; trusted owner-only SQL/admin process দিয়ে assign করতে হবে।
- `service_role` key শুধু server-side secret store-এ; client bundle-এ নয়।
- Admin approval endpoint-এ role check, idempotency, audit log, amount/reference validation ও database transaction বাধ্যতামূলক।
- Manual withdrawal মানে admin provider app-এ আলাদাভাবে payout করে reference সংরক্ষণ করবে; শুধু status update করলেই টাকা পাঠানো হয় না।
- bKash/Nagad merchant/business account, terms, fees, KYC, বয়স/অভিভাবক এবং স্থানীয় আইনগত শর্ত যাচাই করুন।
- Production চালুর আগে independent security review ও ছোট অঙ্কের sandbox/test run করুন।
- Taskora আয় নিশ্চিত করে না; fake tasks, deposit-to-earn বা referral pyramid চালাবেন না।

## Commission
Worker reward ৳100 হলে platform fee ৳20 এবং client budget ৳120। Fee policy UI-তে স্পষ্টভাবে দেখাতে হবে। Refund/cancellation rules লিখিতভাবে প্রকাশ করুন.
