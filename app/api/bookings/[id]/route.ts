import { NextRequest, NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase'
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
