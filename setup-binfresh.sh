#!/bin/bash

echo "🚀 Setting up BinFresh files..."

# Create directories
mkdir -p lib
mkdir -p app/api/bookings/\[id\]
mkdir -p app/booking/success
mkdir -p app/admin/login
mkdir -p app/admin/dashboard
mkdir -p components

# ── lib/supabase.ts ──────────────────────────────────────────────────────────
cat > lib/supabase.ts << 'EOF'
import { createClient } from '@supabase/supabase-js'

export type Booking = {
  id: string
  name: string
  phone: string
  email: string
  address: string
  suburb: string
  date: string
  time_slot: string
  bin_count: number
  frequency: 'once-off' | 'weekly' | 'monthly'
  notes?: string
  status: 'pending' | 'approved' | 'rejected'
  created_at: string
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export const supabaseAdmin = createClient(
  supabaseUrl,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
EOF

# ── lib/resend.ts ────────────────────────────────────────────────────────────
cat > lib/resend.ts << 'EOF'
import { Resend } from 'resend'

export const resend = new Resend(process.env.RESEND_API_KEY)

export const ADMIN_EMAIL = process.env.ADMIN_EMAIL!
export const FROM_EMAIL = 'BinFresh <onboarding@resend.dev>'
EOF

# ── app/api/bookings/route.ts ─────────────────────────────────────────────────
cat > app/api/bookings/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { resend, ADMIN_EMAIL, FROM_EMAIL } from '@/lib/resend'

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()

    const { name, phone, email, address, suburb, date, time_slot, bin_count, frequency, notes } = body

    if (!name || !phone || !email || !address || !suburb || !date || !time_slot || !bin_count) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
    }

    const { data, error } = await supabaseAdmin
      .from('bookings')
      .insert([{ name, phone, email, address, suburb, date, time_slot, bin_count, frequency, notes }])
      .select()
      .single()

    if (error) throw error

    await resend.emails.send({
      from: FROM_EMAIL,
      to: ADMIN_EMAIL,
      subject: `New BinFresh Booking — ${name}`,
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #0D5C63;">New Booking Request</h2>
          <table style="width: 100%; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; color: #666;">Name</td><td style="padding: 8px 0; font-weight: 600;">${name}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Phone</td><td style="padding: 8px 0; font-weight: 600;">${phone}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Email</td><td style="padding: 8px 0; font-weight: 600;">${email}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Address</td><td style="padding: 8px 0; font-weight: 600;">${address}, ${suburb}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Date</td><td style="padding: 8px 0; font-weight: 600;">${date}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Time</td><td style="padding: 8px 0; font-weight: 600;">${time_slot}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Bins</td><td style="padding: 8px 0; font-weight: 600;">${bin_count}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Frequency</td><td style="padding: 8px 0; font-weight: 600;">${frequency}</td></tr>
            ${notes ? `<tr><td style="padding: 8px 0; color: #666;">Notes</td><td style="padding: 8px 0;">${notes}</td></tr>` : ''}
          </table>
          <p style="margin-top: 24px;">
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/admin/dashboard"
               style="background: #0D5C63; color: white; padding: 12px 24px; border-radius: 6px; text-decoration: none; font-weight: 600;">
              Review in Dashboard
            </a>
          </p>
        </div>
      `,
    })

    await resend.emails.send({
      from: FROM_EMAIL,
      to: email,
      subject: 'BinFresh — Booking Received',
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #0D5C63;">We've got your booking, ${name.split(' ')[0]}!</h2>
          <p style="color: #444;">Jenaid will review your request and confirm shortly.</p>
          <table style="width: 100%; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; color: #666;">Address</td><td style="padding: 8px 0; font-weight: 600;">${address}, ${suburb}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Date</td><td style="padding: 8px 0; font-weight: 600;">${date}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Time</td><td style="padding: 8px 0; font-weight: 600;">${time_slot}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Bins</td><td style="padding: 8px 0; font-weight: 600;">${bin_count}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Frequency</td><td style="padding: 8px 0; font-weight: 600;">${frequency}</td></tr>
          </table>
          <p style="color: #444; margin-top: 24px;">Payment is due after the service. Questions? WhatsApp Jenaid on <strong>074 543 2768</strong>.</p>
          <p style="color: #888; font-size: 13px; margin-top: 32px;">BinFresh · Grassy Park & Surrounds · Clean bins, happy street.</p>
        </div>
      `,
    })

    return NextResponse.json({ success: true, id: data.id })
  } catch (err) {
    console.error('Booking error:', err)
    return NextResponse.json({ error: 'Something went wrong' }, { status: 500 })
  }
}
EOF

# ── app/api/bookings/[id]/route.ts ────────────────────────────────────────────
cat > "app/api/bookings/[id]/route.ts" << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { resend, FROM_EMAIL } from '@/lib/resend'
import { createClient } from '@supabase/supabase-js'
import { cookies } from 'next/headers'

export async function PATCH(req: NextRequest, { params }: { params: { id: string } }) {
  try {
    const cookieStore = await cookies()
    const accessToken = cookieStore.get('sb-access-token')?.value
    const refreshToken = cookieStore.get('sb-refresh-token')?.value

    if (!accessToken || !refreshToken) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const authClient = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )

    const { data: { user }, error: authError } = await authClient.auth.setSession({
      access_token: accessToken,
      refresh_token: refreshToken,
    })

    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { status } = await req.json()

    if (!['approved', 'rejected'].includes(status)) {
      return NextResponse.json({ error: 'Invalid status' }, { status: 400 })
    }

    const { data: booking, error } = await supabaseAdmin
      .from('bookings')
      .update({ status })
      .eq('id', params.id)
      .select()
      .single()

    if (error) throw error

    const isApproved = status === 'approved'

    await resend.emails.send({
      from: FROM_EMAIL,
      to: booking.email,
      subject: isApproved ? 'BinFresh — Booking Confirmed!' : 'BinFresh — Booking Update',
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #0D5C63;">
            ${isApproved ? `You're booked in, ${booking.name.split(' ')[0]}!` : `Booking update, ${booking.name.split(' ')[0]}`}
          </h2>
          ${isApproved
            ? `<p style="color: #444;">Your bin clean is confirmed. Jenaid will be at your address on the details below.</p>`
            : `<p style="color: #444;">Unfortunately Jenaid can't make this slot. Please book again or WhatsApp him on <strong>074 543 2768</strong>.</p>`
          }
          ${isApproved ? `
          <table style="width: 100%; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; color: #666;">Address</td><td style="padding: 8px 0; font-weight: 600;">${booking.address}, ${booking.suburb}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Date</td><td style="padding: 8px 0; font-weight: 600;">${booking.date}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Time</td><td style="padding: 8px 0; font-weight: 600;">${booking.time_slot}</td></tr>
            <tr><td style="padding: 8px 0; color: #666;">Bins</td><td style="padding: 8px 0; font-weight: 600;">${booking.bin_count}</td></tr>
          </table>
          <p style="color: #444; margin-top: 16px;">Payment is due after the service. Questions? WhatsApp Jenaid on <strong>074 543 2768</strong>.</p>
          ` : ''}
          <p style="color: #888; font-size: 13px; margin-top: 32px;">BinFresh · Grassy Park & Surrounds · Clean bins, happy street.</p>
        </div>
      `,
    })

    return NextResponse.json({ success: true })
  } catch (err) {
    console.error('Update error:', err)
    return NextResponse.json({ error: 'Something went wrong' }, { status: 500 })
  }
}
EOF

# ── middleware.ts ─────────────────────────────────────────────────────────────
cat > middleware.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl

  if (pathname.startsWith('/admin/dashboard')) {
    const token = req.cookies.get('sb-access-token')
    if (!token) {
      return NextResponse.redirect(new URL('/admin/login', req.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/admin/dashboard/:path*'],
}
EOF

# ── components/BookingForm.tsx ────────────────────────────────────────────────
cat > components/BookingForm.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

const SUBURBS = [
  'Grassy Park', 'Retreat', 'Steenberg', 'Lavender Hill', 'Vrygrond',
  'Capricorn', 'Seawinds', 'Strandfontein', 'Mitchells Plain', 'Ottery',
  'Lotus River', 'Pelikan Park', 'Cafda', 'Other'
]

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

  function handleChange(e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))
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
            {SUBURBS.map(s => <option key={s} value={s}>{s}</option>)}
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
            <option value="monthly">Monthly</option>
          </select>
        </div>
      </div>

      <div>
        <label className="block text-sm font-semibold text-gray-700 mb-1">Additional notes <span className="font-normal text-gray-400">(optional)</span></label>
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

# ── components/AdminBookingCard.tsx ───────────────────────────────────────────
cat > components/AdminBookingCard.tsx << 'EOF'
'use client'

import { useState } from 'react'
import { Booking } from '@/lib/supabase'

type Props = {
  booking: Booking
  onUpdate: (id: string, status: 'approved' | 'rejected') => void
}

export default function AdminBookingCard({ booking, onUpdate }: Props) {
  const [loading, setLoading] = useState<'approved' | 'rejected' | null>(null)

  async function handleAction(status: 'approved' | 'rejected') {
    setLoading(status)
    try {
      const res = await fetch(`/api/bookings/${booking.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      })
      if (!res.ok) throw new Error('Failed')
      onUpdate(booking.id, status)
    } catch {
      alert('Something went wrong. Try again.')
    } finally {
      setLoading(null)
    }
  }

  const statusColors = {
    pending: 'bg-amber-50 text-amber-700 border-amber-200',
    approved: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    rejected: 'bg-red-50 text-red-600 border-red-200',
  }

  return (
    <div className="bg-white border border-gray-100 rounded-xl p-5 shadow-sm">
      <div className="flex items-start justify-between gap-4 mb-4">
        <div>
          <h3 className="font-semibold text-gray-900">{booking.name}</h3>
          <p className="text-sm text-gray-500">{booking.phone} · {booking.email}</p>
        </div>
        <span className={`text-xs font-semibold px-2.5 py-1 rounded-full border capitalize ${statusColors[booking.status]}`}>
          {booking.status}
        </span>
      </div>

      <div className="grid grid-cols-2 gap-x-4 gap-y-2 text-sm mb-4">
        <div>
          <span className="text-gray-400 text-xs uppercase tracking-wide">Address</span>
          <p className="text-gray-800 font-medium">{booking.address}</p>
          <p className="text-gray-600">{booking.suburb}</p>
        </div>
        <div>
          <span className="text-gray-400 text-xs uppercase tracking-wide">Date & Time</span>
          <p className="text-gray-800 font-medium">{booking.date}</p>
          <p className="text-gray-600">{booking.time_slot}</p>
        </div>
        <div>
          <span className="text-gray-400 text-xs uppercase tracking-wide">Bins</span>
          <p className="text-gray-800 font-medium">{booking.bin_count}</p>
        </div>
        <div>
          <span className="text-gray-400 text-xs uppercase tracking-wide">Frequency</span>
          <p className="text-gray-800 font-medium capitalize">{booking.frequency}</p>
        </div>
      </div>

      {booking.notes && (
        <p className="text-sm text-gray-500 bg-gray-50 rounded-lg px-3 py-2 mb-4 italic">"{booking.notes}"</p>
      )}

      {booking.status === 'pending' && (
        <div className="flex gap-3">
          <button onClick={() => handleAction('approved')} disabled={!!loading}
            className="flex-1 bg-teal-700 hover:bg-teal-800 disabled:opacity-60 text-white text-sm font-semibold py-2.5 rounded-lg transition-colors">
            {loading === 'approved' ? 'Confirming...' : 'Approve'}
          </button>
          <button onClick={() => handleAction('rejected')} disabled={!!loading}
            className="flex-1 border border-red-200 text-red-600 hover:bg-red-50 disabled:opacity-60 text-sm font-semibold py-2.5 rounded-lg transition-colors">
            {loading === 'rejected' ? 'Rejecting...' : 'Reject'}
          </button>
        </div>
      )}
    </div>
  )
}
EOF

# ── app/layout.tsx ────────────────────────────────────────────────────────────
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Plus_Jakarta_Sans, Inter } from 'next/font/google'
import './globals.css'

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ['latin'],
  variable: '--font-jakarta',
  weight: ['400', '500', '600', '700', '800'],
})

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

export const metadata: Metadata = {
  title: 'BinFresh — Clean bins, happy street.',
  description: 'Professional bin cleaning in Grassy Park and surrounding areas. Book online, pay after the job.',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${plusJakarta.variable} ${inter.variable} font-sans antialiased`}>
        {children}
      </body>
    </html>
  )
}
EOF

# ── app/globals.css ───────────────────────────────────────────────────────────
cat > app/globals.css << 'EOF'
@import "tailwindcss";

:root {
  --font-jakarta: 'Plus Jakarta Sans', sans-serif;
  --font-inter: 'Inter', sans-serif;
}

body {
  font-family: var(--font-inter);
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-jakarta);
}
EOF

# ── app/page.tsx ──────────────────────────────────────────────────────────────
cat > app/page.tsx << 'EOF'
import Link from 'next/link'

export default function Home() {
  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      <nav className="flex items-center justify-between px-6 py-5 max-w-5xl mx-auto">
        <span className="font-bold text-xl text-teal-700 tracking-tight">BinFresh</span>
        <a href="https://wa.me/27745432768" target="_blank" rel="noopener noreferrer"
          className="text-sm font-semibold text-teal-700 hover:underline">
          WhatsApp us
        </a>
      </nav>

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

      <section className="py-20 max-w-5xl mx-auto px-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-8 text-center">Areas covered</h2>
        <div className="flex flex-wrap gap-3 justify-center">
          {['Grassy Park', 'Retreat', 'Steenberg', 'Lavender Hill', 'Vrygrond', 'Capricorn', 'Seawinds', 'Strandfontein', 'Mitchells Plain', 'Ottery', 'Lotus River', 'Pelikan Park'].map(area => (
            <span key={area} className="bg-white border border-gray-200 text-gray-700 text-sm px-4 py-2 rounded-full font-medium">
              {area}
            </span>
          ))}
        </div>
      </section>

      <section className="bg-teal-700 py-20 text-center">
        <h2 className="text-3xl font-bold text-white mb-4">Ready for fresh bins?</h2>
        <p className="text-teal-100 mb-8 text-sm">Available 7 days a week, 7am – 6pm</p>
        <Link href="/booking"
          className="inline-block bg-white text-teal-700 font-semibold px-8 py-4 rounded-xl text-sm tracking-wide hover:bg-teal-50 transition-colors">
          Book a clean
        </Link>
      </section>

      <footer className="bg-gray-900 text-gray-400 text-sm text-center py-8">
        <p>BinFresh · Grassy Park & Surrounds ·{' '}
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

export default function BookingPage() {
  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      <nav className="flex items-center justify-between px-6 py-5 max-w-2xl mx-auto">
        <Link href="/" className="font-bold text-xl text-teal-700 tracking-tight">BinFresh</Link>
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

# ── app/booking/success/page.tsx ──────────────────────────────────────────────
cat > app/booking/success/page.tsx << 'EOF'
import Link from 'next/link'

export default function SuccessPage() {
  return (
    <main className="min-h-screen bg-[#F5F0E8] flex flex-col items-center justify-center px-6 text-center">
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-10 max-w-md w-full">
        <div className="w-16 h-16 bg-teal-50 rounded-full flex items-center justify-center mx-auto mb-6">
          <svg className="w-8 h-8 text-teal-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-3">Booking received!</h1>
        <p className="text-gray-500 text-sm mb-6 leading-relaxed">
          Jenaid will review your request and send a confirmation email shortly. Keep an eye on your inbox.
        </p>
        <p className="text-gray-400 text-xs mb-8">
          Need to reach Jenaid directly?{' '}
          <a href="https://wa.me/27745432768" className="text-teal-700 font-semibold hover:underline">WhatsApp him here</a>
        </p>
        <Link href="/" className="inline-block text-sm font-semibold text-teal-700 hover:underline">← Back to home</Link>
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
        <h1 className="text-xl font-bold text-gray-900 mb-1">BinFresh Admin</h1>
        <p className="text-sm text-gray-400 mb-8">Sign in to manage bookings</p>
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

# ── app/admin/dashboard/page.tsx ──────────────────────────────────────────────
cat > app/admin/dashboard/page.tsx << 'EOF'
'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase, Booking } from '@/lib/supabase'
import AdminBookingCard from '@/components/AdminBookingCard'

type Filter = 'all' | 'pending' | 'approved' | 'rejected'

export default function AdminDashboard() {
  const router = useRouter()
  const [bookings, setBookings] = useState<Booking[]>([])
  const [filter, setFilter] = useState<Filter>('pending')
  const [loading, setLoading] = useState(true)

  useEffect(() => { fetchBookings() }, [])

  async function fetchBookings() {
    const { data, error } = await supabase
      .from('bookings')
      .select('*')
      .order('date', { ascending: true })
      .order('time_slot', { ascending: true })

    if (error) console.error(error)
    else setBookings(data || [])
    setLoading(false)
  }

  function handleUpdate(id: string, status: 'approved' | 'rejected') {
    setBookings(prev => prev.map(b => b.id === id ? { ...b, status } : b))
  }

  async function handleLogout() {
    await supabase.auth.signOut()
    document.cookie = 'sb-access-token=; path=/; max-age=0'
    document.cookie = 'sb-refresh-token=; path=/; max-age=0'
    router.push('/admin/login')
  }

  const filtered = filter === 'all' ? bookings : bookings.filter(b => b.status === filter)
  const counts = {
    all: bookings.length,
    pending: bookings.filter(b => b.status === 'pending').length,
    approved: bookings.filter(b => b.status === 'approved').length,
    rejected: bookings.filter(b => b.status === 'rejected').length,
  }

  const tabs: { key: Filter; label: string }[] = [
    { key: 'pending', label: `Pending (${counts.pending})` },
    { key: 'approved', label: `Approved (${counts.approved})` },
    { key: 'rejected', label: `Rejected (${counts.rejected})` },
    { key: 'all', label: `All (${counts.all})` },
  ]

  return (
    <main className="min-h-screen bg-[#F5F0E8]">
      <nav className="bg-white border-b border-gray-100 px-6 py-4 flex items-center justify-between">
        <span className="font-bold text-teal-700 text-lg">BinFresh Admin</span>
        <button onClick={handleLogout} className="text-sm text-gray-500 hover:text-gray-700 font-medium">Sign out</button>
      </nav>
      <div className="max-w-3xl mx-auto px-6 py-10">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
          <p className="text-sm text-gray-400 mt-1">Approve or reject incoming requests. Customer is notified by email.</p>
        </div>
        <div className="flex gap-2 mb-6 flex-wrap">
          {tabs.map(tab => (
            <button key={tab.key} onClick={() => setFilter(tab.key)}
              className={`px-4 py-2 rounded-lg text-sm font-semibold transition-colors ${
                filter === tab.key ? 'bg-teal-700 text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
              }`}>
              {tab.label}
            </button>
          ))}
        </div>
        {loading ? (
          <p className="text-gray-400 text-sm text-center py-12">Loading bookings...</p>
        ) : filtered.length === 0 ? (
          <div className="text-center py-16 bg-white rounded-2xl border border-gray-100">
            <p className="text-gray-400 text-sm">No {filter === 'all' ? '' : filter} bookings yet.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {filtered.map(booking => (
              <AdminBookingCard key={booking.id} booking={booking} onUpdate={handleUpdate} />
            ))}
          </div>
        )}
      </div>
    </main>
  )
}
EOF

echo ""
echo "✅ All files created successfully!"
echo ""
echo "Next steps:"
echo "  1. Add your .env.local variables"
echo "  2. Run: npm run dev"
echo "  3. Visit: http://localhost:3000"
