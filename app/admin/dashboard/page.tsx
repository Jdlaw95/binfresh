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
