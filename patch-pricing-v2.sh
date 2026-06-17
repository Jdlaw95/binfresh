#!/bin/bash

echo "💰 Applying BinFresh pricing update..."

# ── components/BookingForm.tsx ────────────────────────────────────────────────
cat > components/BookingForm.tsx << 'EOF'
'use client'

import { useState, useMemo } from 'react'
import { useRouter } from 'next/navigation'

const SUBURBS: { name: string; surcharge: number }[] = [
  { name: 'Grassy Park',     surcharge: 0 },
  { name: 'Lotus River',     surcharge: 0 },
  { name: 'Retreat',         surcharge: 20 },
  { name: 'Steenberg',       surcharge: 20 },
  { name: 'Capricorn',       surcharge: 20 },
  { name: 'Strandfontein',   surcharge: 20 },
  { name: 'Mitchells Plain', surcharge: 20 },
  { name: 'Ottery',          surcharge: 20 },
  { name: 'Pelikan Park',    surcharge: 20 },
  { name: 'Cafda',           surcharge: 20 },
  { name: 'Other',           surcharge: 20 },
]

const PRICE_PER_BIN_ONCE   = 49.99
const PRICE_PER_BIN_WEEKLY = 49.99
const MONTHLY_BASE         = 150    // includes 1 bin, 3 cleans
const MONTHLY_EXTRA_BIN    = 30     // per additional bin/month

const TIME_SLOTS = [
  '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
  '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
  '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
  '16:00', '16:30', '17:00', '17:30',
]

export default function BookingForm() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const [form, setForm] = useState({
    name: '',
    phone: '',
    email: '',
    address: '',
    suburb: '',
    date: '',
    time_slot: '',
    bin_count: 1,
    frequency: 'once-off',
    notes: '',
  })

  const today = new Date().toISOString().split('T')[0]

  const estimate = useMemo(() => {
    const suburbData = SUBURBS.find(s => s.name === form.suburb)
    const surcharge = suburbData ? suburbData.surcharge : 0
    const bins = Number(form.bin_count)

    if (form.frequency === 'monthly') {
      const extraBins = Math.max(0, bins - 1)
      const base = MONTHLY_BASE + extraBins * MONTHLY_EXTRA_BIN
      return {
        lines: [
          { label: 'Monthly plan (1 bin, 3 cleans)', amount: MONTHLY_BASE },
          ...(extraBins > 0 ? [{ label: `${extraBins} extra bin${extraBins > 1 ? 's' : ''} × R${MONTHLY_EXTRA_BIN}/mo`, amount: extraBins * MONTHLY_EXTRA_BIN }] : []),
          ...(surcharge > 0 ? [{ label: `${form.suburb} surcharge`, amount: surcharge }] : []),
        ],
        total: base + surcharge,
        period: '/month',
      }
    }

    if (form.frequency === 'weekly') {
      const perVisit = bins * PRICE_PER_BIN_WEEKLY
      return {
        lines: [
          { label: `${bins} bin${bins > 1 ? 's' : ''} × R${PRICE_PER_BIN_WEEKLY.toFixed(2)} per visit`, amount: perVisit },
          ...(surcharge > 0 ? [{ label: `${form.suburb} surcharge`, amount: surcharge }] : []),
        ],
        total: perVisit + surcharge,
        period: '/visit',
      }
    }

    // once-off
    const binTotal = bins * PRICE_PER_BIN_ONCE
    return {
      lines: [
        { label: `${bins} bin${bins > 1 ? 's' : ''} × R${PRICE_PER_BIN_ONCE.toFixed(2)}`, amount: binTotal },
        ...(surcharge > 0 ? [{ label: `${form.suburb} surcharge`, amount: surcharge }] : []),
      ],
      total: binTotal + surcharge,
      period: '',
    }
  }, [form.suburb, form.bin_count, form.frequency])

  function handleChange(e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) {
    const value = e.target.name === 'bin_count' ? Number(e.target.value) : e.target.value
    setForm(prev => ({ ...prev, [e.target.name]: value }))
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const res = await fetch('/api/bookings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })

      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Submission failed')
      router.push('/booking/success')
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Something went wrong. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const showEstimate = form.suburb && form.bin_count > 0

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Full name</label>
          <input name="name" value={form.name} onChange={handleChange} required placeholder="e.g. Sarah Adams"
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Phone number</label>
          <input name="phone" value={form.phone} onChange={handleChange} required placeholder="e.g. 082 123 4567"
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
        </div>
      </div>

      <div>
        <label className="block text-sm font-semibold text-gray-700 mb-1">Email address</label>
        <input name="email" type="email" value={form.email} onChange={handleChange} required placeholder="e.g. sarah@email.com"
          className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Street address</label>
          <input name="address" value={form.address} onChange={handleChange} required placeholder="e.g. 12 Rose Street"
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Suburb</label>
          <select name="suburb" value={form.suburb} onChange={handleChange} required
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600 bg-white">
            <option value="">Select suburb</option>
            {SUBURBS.map(s => <option key={s.name} value={s.name}>{s.name}</option>)}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Preferred date</label>
          <input name="date" type="date" value={form.date} onChange={handleChange} min={today} required
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Preferred time</label>
          <select name="time_slot" value={form.time_slot} onChange={handleChange} required
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600 bg-white">
            <option value="">Select time</option>
            {TIME_SLOTS.map(t => <option key={t} value={t}>{t}</option>)}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Number of bins</label>
          <input name="bin_count" type="number" min={1} max={20} value={form.bin_count} onChange={handleChange} required
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-1">Service type</label>
          <select name="frequency" value={form.frequency} onChange={handleChange}
            className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600 bg-white">
            <option value="once-off">Once-off clean</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly (3 cleans/month)</option>
          </select>
        </div>
      </div>

      {/* Live cost estimate */}
      {showEstimate && (
        <div className="bg-teal-50 border border-teal-100 rounded-xl px-5 py-4 space-y-2">
          <p className="text-xs font-semibold text-teal-700 uppercase tracking-wide mb-3">Estimated cost</p>
          {estimate.lines.map((line, i) => (
            <div key={i} className="flex justify-between text-sm text-gray-600">
              <span>{line.label}</span>
              <span>R{line.amount.toFixed(2)}</span>
            </div>
          ))}
          <div className="border-t border-teal-100 pt-2 flex justify-between text-sm font-bold text-teal-800">
            <span>Estimated total</span>
            <span>R{estimate.total.toFixed(2)}{estimate.period}</span>
          </div>
          <p className="text-xs text-teal-600">Payment is due after the service is completed.</p>
        </div>
      )}

      <div>
        <label className="block text-sm font-semibold text-gray-700 mb-1">
          Additional notes <span className="font-normal text-gray-400">(optional)</span>
        </label>
        <textarea name="notes" value={form.notes} onChange={handleChange} rows={3}
          placeholder="Gate code, access instructions, anything Jenaid should know..."
          className="w-full border border-gray-200 rounded-lg px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-600 resize-none" />
      </div>

      {error && (
        <p className="text-red-600 text-sm bg-red-50 border border-red-100 rounded-lg px-4 py-3">{error}</p>
      )}

      <button type="submit" disabled={loading}
        className="w-full bg-teal-700 hover:bg-teal-800 disabled:opacity-60 text-white font-semibold py-4 rounded-lg transition-colors text-sm tracking-wide">
        {loading ? 'Sending booking...' : 'Request booking'}
      </button>

      <p className="text-xs text-center text-gray-400">
        Jenaid will confirm your booking via email. Payment is due after the service.
      </p>
    </form>
  )
}
EOF

# ── app/page.tsx ──────────────────────────────────────────────────────────────
cat > app/page.tsx << 'EOF'
import Link from 'next/link'

const NO_SURCHARGE   = ['Grassy Park', 'Lotus River']
const WITH_SURCHARGE = ['Retreat', 'Steenberg', 'Capricorn', 'Strandfontein', 'Mitchells Plain', 'Ottery', 'Pelikan Park', 'Cafda']

export default function Home() {
  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-5 max-w-5xl mx-auto">
        <span className="font-bold text-xl text-teal-700 tracking-tight">BinFresh</span>
        <a href="https://wa.me/27745432768" target="_blank" rel="noopener noreferrer"
          className="text-sm font-semibold text-teal-700 hover:underline">
          WhatsApp us
        </a>
      </nav>

      {/* Hero */}
      <section className="max-w-5xl mx-auto px-6 pt-16 pb-24 text-center">
        <div className="inline-flex items-center gap-2 bg-teal-50 border border-teal-100 rounded-full px-4 py-1.5 text-xs font-semibold text-teal-700 mb-8 uppercase tracking-widest">
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
          {/* Once-off */}
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

          {/* Weekly */}
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

          {/* Monthly — highlighted */}
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

        {/* Surcharge note */}
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
      <footer className="bg-gray-900 text-gray-400 text-sm text-center py-8">
        <p>BinFresh · Grassy Park & Surrounds ·{' '}
          <a href="https://wa.me/27745432768" className="text-teal-400 hover:underline">074 543 2768</a>
        </p>
      </footer>
    </main>
  )
}
EOF

echo ""
echo "✅ Pricing update applied!"
echo ""
echo "Changes:"
echo "  - Landing page: 3-column pricing cards (once-off / weekly / monthly)"
echo "  - Booking form: live estimate adapts to service type selection"
echo ""
echo "Restart: npm run dev"
