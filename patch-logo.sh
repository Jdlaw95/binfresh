#!/bin/bash

echo "🖼️ Applying BinFresh logo update..."

# ── app/page.tsx ──────────────────────────────────────────────────────────────
cat > app/page.tsx << 'EOF'
import Link from 'next/link'
import Image from 'next/image'

const NO_SURCHARGE   = ['Grassy Park', 'Lotus River']
const WITH_SURCHARGE = ['Retreat', 'Steenberg', 'Capricorn', 'Strandfontein', 'Mitchells Plain', 'Ottery', 'Pelikan Park', 'Cafda']

export default function Home() {
  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4 max-w-5xl mx-auto">
        <Image src="/binfreshlogo.png" alt="BinFresh" width={140} height={60} className="object-contain" />
        <a href="https://wa.me/27745432768" target="_blank" rel="noopener noreferrer"
          className="text-sm font-semibold text-teal-700 hover:underline">
          WhatsApp us
        </a>
      </nav>

      {/* Hero */}
      <section className="max-w-5xl mx-auto px-6 pt-8 pb-24 text-center">
        <div className="flex justify-center mb-6">
          <Image src="/binfreshlogo.png" alt="BinFresh" width={280} height={200} className="object-contain" />
        </div>
        <div className="inline-flex items-center gap-2 bg-teal-50 border border-teal-100 rounded-full px-4 py-1.5 text-xs font-semibold text-teal-700 mb-6 uppercase tracking-widest">
          Grassy Park & Surrounds
        </div>
        <h1 className="text-5xl md:text-7xl font-bold text-gray-900 leading-[1.05] tracking-tight mb-6">
          Clean bins.<br />
          <span className="text-teal-700">Happy street.</span>
        </h1>
        <p className="text-lg text-gray-500 max-w-xl mx-auto mb-10">
          Professional bin cleaning by Jenaid — quick, thorough, and priced fairly.
          Book online in under two minutes.
        </p>
        <Link href="/booking"
          className="inline-block bg-teal-700 hover:bg-teal-800 text-white font-semibold px-8 py-4 rounded-xl text-sm tracking-wide transition-colors shadow-lg shadow-teal-900/10">
          Book a clean
        </Link>
      </section>

      {/* How it works */}
      <section className="bg-white border-t border-gray-100 py-20">
        <div className="max-w-5xl mx-auto px-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-12 text-center">How it works</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { step: '1', title: 'Submit a booking', desc: 'Fill in your address, preferred date and time, and number of bins.' },
              { step: '2', title: 'Jenaid confirms', desc: "You'll get an email confirmation once your slot is approved — usually within the hour." },
              { step: '3', title: 'Pay after the job', desc: 'No upfront payment. Settle with Jenaid directly once your bins are sparkling.' },
            ].map(item => (
              <div key={item.step} className="text-center">
                <div className="w-12 h-12 rounded-full bg-teal-700 text-white font-bold text-lg flex items-center justify-center mx-auto mb-4">
                  {item.step}
                </div>
                <h3 className="font-semibold text-gray-900 mb-2">{item.title}</h3>
                <p className="text-sm text-gray-500 leading-relaxed">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section className="py-20 max-w-5xl mx-auto px-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4 text-center">Simple pricing</h2>
        <p className="text-gray-500 text-sm text-center mb-12">No hidden fees. Pay after the job is done.</p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl mx-auto">
          <div className="bg-white border border-gray-100 rounded-2xl p-7 shadow-sm flex flex-col">
            <p className="text-xs font-semibold text-teal-700 uppercase tracking-widest mb-4">Once-off</p>
            <p className="text-4xl font-bold text-gray-900 mb-1">R49<span className="text-xl">.99</span></p>
            <p className="text-sm text-gray-400 mb-6">per bin</p>
            <ul className="text-sm text-gray-500 space-y-2 mt-auto">
              <li className="flex items-center gap-2"><span className="text-teal-600">✓</span> Single visit</li>
              <li className="flex items-center gap-2"><span className="text-teal-600">✓</span> Full clean & sanitise</li>
              <li className="flex items-center gap-2"><span className="text-teal-600">✓</span> No commitment</li>
            </ul>
          </div>

          <div className="bg-white border border-gray-100 rounded-2xl p-7 shadow-sm flex flex-col">
            <p className="text-xs font-semibold text-teal-700 uppercase tracking-widest mb-4">Weekly</p>
            <p className="text-4xl font-bold text-gray-900 mb-1">R49<span className="text-xl">.99</span></p>
            <p className="text-sm text-gray-400 mb-6">per bin, per visit</p>
            <ul className="text-sm text-gray-500 space-y-2 mt-auto">
              <li className="flex items-center gap-2"><span className="text-teal-600">✓</span> Every week</li>
              <li className="flex items-center gap-2"><span className="text-teal-600">✓</span> Full clean & sanitise</li>
              <li className="flex items-center gap-2"><span className="text-teal-600">✓</span> Cancel anytime</li>
            </ul>
          </div>

          <div className="bg-teal-700 rounded-2xl p-7 shadow-sm flex flex-col relative overflow-hidden">
            <div className="absolute top-4 right-4 bg-white text-teal-700 text-xs font-bold px-2.5 py-1 rounded-full">
              Best value
            </div>
            <p className="text-xs font-semibold text-teal-200 uppercase tracking-widest mb-4">Monthly</p>
            <p className="text-4xl font-bold text-white mb-1">R150</p>
            <p className="text-sm text-teal-300 mb-6">per month · 1 bin</p>
            <ul className="text-sm text-teal-100 space-y-2 mt-auto">
              <li className="flex items-center gap-2"><span className="text-teal-300">✓</span> 3 cleans per month</li>
              <li className="flex items-center gap-2"><span className="text-teal-300">✓</span> +R30/month per extra bin</li>
              <li className="flex items-center gap-2"><span className="text-teal-300">✓</span> Full clean & sanitise</li>
            </ul>
          </div>
        </div>

        <div className="mt-8 max-w-4xl mx-auto bg-white border border-gray-100 rounded-xl px-6 py-4 flex flex-col md:flex-row md:items-center gap-4 text-sm shadow-sm">
          <p className="font-semibold text-gray-700 shrink-0">Area surcharge</p>
          <div className="flex flex-wrap gap-x-6 gap-y-1 text-gray-500">
            <span><strong className="text-gray-700">No surcharge:</strong> {NO_SURCHARGE.join(', ')}</span>
            <span><strong className="text-gray-700">+R20:</strong> {WITH_SURCHARGE.join(', ')}</span>
          </div>
        </div>

        <p className="text-center text-sm text-gray-400 mt-6">
          The booking form calculates your exact estimate automatically.
        </p>
      </section>

      {/* Areas */}
      <section className="bg-white border-t border-gray-100 py-20">
        <div className="max-w-5xl mx-auto px-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-8 text-center">Areas covered</h2>
          <div className="flex flex-wrap gap-3 justify-center">
            {[...NO_SURCHARGE, ...WITH_SURCHARGE].map(area => (
              <span key={area} className="bg-[#F5F0E8] border border-gray-200 text-gray-700 text-sm px-4 py-2 rounded-full font-medium">
                {area}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="bg-teal-700 py-20 text-center">
        <h2 className="text-3xl font-bold text-white mb-4">Ready for fresh bins?</h2>
        <p className="text-teal-100 mb-8 text-sm">Available 7 days a week, 7am – 6pm</p>
        <Link href="/booking"
          className="inline-block bg-white text-teal-700 font-semibold px-8 py-4 rounded-xl text-sm tracking-wide hover:bg-teal-50 transition-colors">
          Book a clean
        </Link>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 py-8 text-center">
        <Image src="/binfreshlogo.png" alt="BinFresh" width={120} height={50} className="object-contain mx-auto mb-4 opacity-80" />
        <p className="text-gray-400 text-sm">Grassy Park & Surrounds ·{' '}
          <a href="https://wa.me/27745432768" className="text-teal-400 hover:underline">074 543 2768</a>
        </p>
      </footer>
    </main>
  )
}
EOF

# ── app/booking/page.tsx ──────────────────────────────────────────────────────
cat > app/booking/page.tsx << 'EOF'
import BookingForm from '@/components/BookingForm'
import Link from 'next/link'
import Image from 'next/image'

export default function BookingPage() {
  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      <nav className="flex items-center justify-between px-6 py-4 max-w-2xl mx-auto">
        <Link href="/">
          <Image src="/binfreshlogo.png" alt="BinFresh" width={120} height={50} className="object-contain" />
        </Link>
        <a href="https://wa.me/27745432768" target="_blank" rel="noopener noreferrer"
          className="text-sm font-semibold text-teal-700 hover:underline">
          WhatsApp us
        </a>
      </nav>
      <div className="max-w-2xl mx-auto px-6 py-12">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Book a bin clean</h1>
          <p className="text-gray-500 text-sm">Fill in your details and Jenaid will confirm your slot via email.</p>
        </div>
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 md:p-8">
          <BookingForm />
        </div>
      </div>
    </main>
  )
}
EOF

# ── app/admin/login/page.tsx ──────────────────────────────────────────────────
cat > app/admin/login/page.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase'
import Image from 'next/image'

export default function AdminLogin() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { data, error } = await supabase.auth.signInWithPassword({ email, password })

    if (error || !data.session) {
      setError('Incorrect email or password.')
      setLoading(false)
      return
    }

    document.cookie = `sb-access-token=${data.session.access_token}; path=/; max-age=3600; SameSite=Strict`
    document.cookie = `sb-refresh-token=${data.session.refresh_token}; path=/; max-age=86400; SameSite=Strict`

    router.push('/admin/dashboard')
  }

  return (
    <main className="min-h-screen bg-[#F5F0E8] flex items-center justify-center px-6">
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8 w-full max-w-sm">
        <div className="flex justify-center mb-6">
          <Image src="/binfreshlogo.png" alt="BinFresh" width={140} height={60} className="object-contain" />
        </div>
        <p className="text-sm text-gray-400 mb-8 text-center">Admin — sign in to manage bookings</p>
        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1">Email</label>
            <input type="email" value={email} onChange={e => setEmail(e.target.value)} required
              className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1">Password</label>
            <input type="password" value={password} onChange={e => setPassword(e.target.value)} required
              className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
          </div>
          {error && (
            <p className="text-red-600 text-sm bg-red-50 border border-red-100 rounded-lg px-4 py-3">{error}</p>
          )}
          <button type="submit" disabled={loading}
            className="w-full bg-teal-700 hover:bg-teal-800 disabled:opacity-60 text-white font-semibold py-3 rounded-lg transition-colors text-sm">
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </form>
      </div>
    </main>
  )
}
EOF

echo ""
echo "✅ Logo update applied!"
echo ""
echo "IMPORTANT: Copy binfreshlogo.png into your public/ folder first."
echo "Then restart: npm run dev"
