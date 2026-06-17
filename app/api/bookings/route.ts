import { NextRequest, NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase'
import { resend, ADMIN_EMAIL, FROM_EMAIL } from '@/lib/resend'

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()

    const { name, phone, email, address, suburb, date, time_slot, bin_count, frequency, notes } = body

    if (!name || !phone || !email || !address || !suburb || !date || !time_slot || !bin_count) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
    }

    const { data, error } = await getSupabaseAdmin()
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
