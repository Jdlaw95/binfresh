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
