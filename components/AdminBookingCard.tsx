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
