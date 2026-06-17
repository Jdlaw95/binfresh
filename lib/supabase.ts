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

export function getSupabaseAdmin() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )
}