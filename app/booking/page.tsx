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
