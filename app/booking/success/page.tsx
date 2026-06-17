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
          We'll review your request and send a confirmation email shortly. Keep an eye on your inbox.
        </p>
        <p className="text-gray-400 text-xs mb-8">
          Need to reach us directly?{' '}
          <a href="https://wa.me/27745432768" className="text-teal-700 font-semibold hover:underline">WhatsApp him here</a>
        </p>
        <Link href="/" className="inline-block text-sm font-semibold text-teal-700 hover:underline">← Back to home</Link>
      </div>
    </main>
  )
}
