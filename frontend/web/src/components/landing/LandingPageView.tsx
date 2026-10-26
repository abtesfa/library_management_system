import React, { useState } from 'react';
import {
  BookOpen,
  Search,
  Users,
  User,
  Clock,
  Shield,
  ArrowRight,
  ChevronLeft,
  ChevronRight,
  Phone,
  Mail,
  MapPin,
  Settings,
  Sparkles,
  Layers,
  CheckCircle2,
  Bookmark,
  LogIn
} from 'lucide-react';
import { Book, RoleType } from '../../types';
import { BookCover } from '../common/BookCover';
import { SignInModal } from '../modals/SignInModal';

interface LandingPageViewProps {
  onEnterPortal: (role: RoleType) => void;
  onSelectBook?: (book: Book) => void;
}

export const LandingPageView: React.FC<LandingPageViewProps> = ({
  onEnterPortal,
  onSelectBook
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilterTag, setActiveFilterTag] = useState<'All' | 'Books' | 'Authors' | 'Categories'>('All');
  const [activeNav, setActiveNav] = useState('Home');
  const [selectedBookDetail, setSelectedBookDetail] = useState<any | null>(null);
  const [isSignInOpen, setIsSignInOpen] = useState(false);
  const [signInInitialRole, setSignInInitialRole] = useState<RoleType>('admin');

  // Featured books matching the exact screenshot
  const featuredBooks = [
    {
      id: 'fb-1',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Programming',
      status: 'Available',
      coverImage: '/web/src/assets/images/book_cover_cleancode_1791886211255.jpg',
      isbn: '978-0132350884',
      location: 'Shelf D1'
    },
    {
      id: 'fb-2',
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Self Improvement',
      status: 'Available',
      coverTheme: 'atomic-habits',
      isbn: '978-0735211292',
      location: 'Shelf A1'
    },
    {
      id: 'fb-3',
      title: 'The Martian',
      author: 'Andy Weir',
      category: 'Science Fiction',
      status: 'Borrowed',
      coverTheme: 'the-martian',
      isbn: '978-0553418026',
      location: 'Shelf B1'
    },
    {
      id: 'fb-4',
      title: 'Design Patterns',
      author: 'Erich Gamma',
      category: 'Software Engineering',
      status: 'Available',
      coverTheme: 'design-patterns',
      isbn: '978-0201633610',
      location: 'Shelf C2'
    },
    {
      id: 'fb-5',
      title: 'Think Like a Monk',
      author: 'Jay Shetty',
      category: 'Psychology',
      status: 'Available',
      coverTheme: 'think-like-a-monk',
      isbn: '978-1982134488',
      location: 'Shelf E4'
    }
  ];

  const handleNavClick = (sectionId: string, navName: string) => {
    setActiveNav(navName);
    const elem = document.getElementById(sectionId);
    if (elem) {
      elem.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <div className="min-h-screen bg-[#F4F7FC] text-slate-800 font-['Plus_Jakarta_Sans',sans-serif] flex flex-col">
      {/* 1. TOP NAVIGATION BAR */}
      <header className="h-16 bg-[#0052CC] text-white px-6 md:px-10 flex items-center justify-between shadow-md sticky top-0 z-40">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-lg bg-blue-500/30 border border-white/20 flex items-center justify-center shadow-inner">
            <BookOpen className="w-5 h-5 text-white" />
          </div>
          <span className="text-lg md:text-xl font-bold tracking-tight text-white">
            Library Management System
          </span>
        </div>

        {/* Center Nav Links */}
        <nav className="hidden md:flex items-center gap-7 text-sm font-medium">
          {['Home', 'Browse Books', 'Categories', 'About', 'Contact'].map((item) => {
            const isHome = activeNav === item;
            const targetId =
              item === 'Home'
                ? 'hero'
                : item === 'Browse Books'
                ? 'featured-books'
                : item === 'Categories'
                ? 'featured-books'
                : item === 'About'
                ? 'how-it-works'
                : 'contact';

            return (
              <button
                key={item}
                onClick={() => handleNavClick(targetId, item)}
                className={`transition-colors relative py-1 cursor-pointer ${
                  isHome ? 'text-white font-semibold' : 'text-blue-100/80 hover:text-white'
                }`}
              >
                {item}
                {isHome && (
                  <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-white rounded-full"></span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Right Action Buttons */}
        <div className="flex items-center gap-3">
          <button
            onClick={() => handleNavClick('hero', 'Home')}
            className="w-9 h-9 rounded-full bg-blue-600/40 hover:bg-white/10 flex items-center justify-center text-white transition-colors"
            title="Search catalog"
          >
            <Search className="w-4 h-4" />
          </button>

          <button
            onClick={() => {
              setSignInInitialRole('admin');
              setIsSignInOpen(true);
            }}
            className="px-4 py-1.5 bg-white text-[#0052CC] hover:bg-blue-50 font-bold text-xs rounded-lg shadow-sm transition-all flex items-center gap-1.5 cursor-pointer active:scale-95"
            title="Sign in to Admin, Librarian, or Reader dashboard"
          >
            <LogIn className="w-3.5 h-3.5" />
            <span>Sign In</span>
          </button>
        </div>
      </header>

      {/* 2. HERO SECTION */}
      <section id="hero" className="relative p-6 md:p-10 max-w-[1500px] mx-auto w-full">
        <div className="relative rounded-3xl overflow-hidden border border-slate-200/90 shadow-sm bg-white min-h-[440px] flex items-center">
          {/* Background image & overlay */}
          <div className="absolute inset-0 z-0">
            <img
              src="/web/src/assets/images/landing_hero_library_1792172159535.jpg"
              alt="University Library Study Space"
              className="w-full h-full object-cover object-right"
              referrerPolicy="no-referrer"
            />
            {/* Soft gradient wash across left for reading contrast */}
            <div className="absolute inset-0 bg-gradient-to-r from-white via-white/90 to-transparent md:w-3/4"></div>
          </div>

          {/* Left Content */}
          <div className="relative z-10 max-w-2xl p-8 md:p-14 space-y-6">
            {/* Pill Tag */}
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 border border-blue-200/80 text-blue-700 text-xs font-medium">
              <BookOpen className="w-3.5 h-3.5" />
              <span>Knowledge Builds a Brighter Future</span>
            </div>

            {/* Headline */}
            <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-slate-900 leading-[1.15]">
              Discover. Learn.{' '}
              <span className="text-[#1877F2]">Grow.</span>
            </h1>

            {/* Subtitle */}
            <p className="text-slate-600 text-sm md:text-base leading-relaxed max-w-xl">
              The Library Management System helps you explore thousands of books, manage your reading journey, and access knowledge whenever you need it.
            </p>

            {/* Search Input Bar */}
            <div className="flex flex-col sm:flex-row gap-2 max-w-lg bg-white p-2 rounded-2xl shadow-lg border border-slate-200">
              <div className="relative flex-1 flex items-center pl-3">
                <Search className="w-4 h-4 text-slate-400 mr-2 shrink-0" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search for books, authors, ISBN, or categories..."
                  className="w-full text-xs text-slate-800 placeholder-slate-400 focus:outline-none bg-transparent"
                />
              </div>
              <button
                onClick={() => handleNavClick('featured-books', 'Browse Books')}
                className="px-6 py-2.5 bg-[#1877F2] hover:bg-blue-600 text-white font-semibold text-xs rounded-xl transition-colors shrink-0 flex items-center justify-center gap-1.5 shadow-sm"
              >
                <span>Search</span>
              </button>
            </div>

            {/* Search Filter Tags */}
            <div className="flex items-center gap-2 pt-1 text-xs">
              {(['All', 'Books', 'Authors', 'Categories'] as const).map((tag) => (
                <button
                  key={tag}
                  onClick={() => setActiveFilterTag(tag)}
                  className={`px-3.5 py-1 rounded-full text-xs font-medium transition-colors ${
                    activeFilterTag === tag
                      ? 'bg-[#1877F2] text-white'
                      : 'bg-slate-100 hover:bg-slate-200 text-slate-600'
                  }`}
                >
                  {tag}
                </button>
              ))}
            </div>
          </div>

          {/* Right Floating Handwritten-Style Note */}
          <div className="hidden lg:block absolute right-16 top-12 z-10 rotate-[-4deg] text-center pointer-events-none">
            <span className="font-['Plus_Jakarta_Sans'] font-extrabold text-2xl text-[#0052CC] drop-shadow-sm tracking-tight block">
              A good book<br />builds a better<br />tomorrow
            </span>
            <svg className="w-24 h-4 mx-auto mt-1 text-[#1877F2]" viewBox="0 0 100 20" fill="none">
              <path d="M5 12 Q 50 2, 95 14" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
            </svg>
          </div>
        </div>
      </section>

      {/* 3. METRIC STATS STRIP */}
      <section className="px-6 md:px-10 max-w-[1500px] mx-auto w-full -mt-2">
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-sm p-6 grid grid-cols-2 md:grid-cols-4 gap-6">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <BookOpen className="w-6 h-6" />
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900 tabular-nums">1,200+</div>
              <div className="text-xs text-slate-500 font-medium">Books Available</div>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Users className="w-6 h-6" />
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900 tabular-nums">350+</div>
              <div className="text-xs text-slate-500 font-medium">Registered Members</div>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Clock className="w-6 h-6" />
            </div>
            <div>
              <div className="text-xl font-extrabold text-slate-900 tabular-nums">24/7</div>
              <div className="text-xs text-slate-500 font-medium">Online Access</div>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Shield className="w-6 h-6" />
            </div>
            <div>
              <div className="text-base font-extrabold text-slate-900">Secure</div>
              <div className="text-xs text-slate-500 font-medium">&amp; Reliable</div>
            </div>
          </div>
        </div>
      </section>

      {/* 4. FEATURE CARDS (EXCLUDING "Manage Your Account" and "For Librarians") */}
      <section className="px-6 md:px-10 max-w-[1500px] mx-auto w-full pt-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Card 1: Browse Books */}
          <div className="bg-white p-7 rounded-2xl border border-slate-200/90 shadow-sm hover:border-blue-300 hover:shadow-md transition-all flex items-start gap-5">
            <div className="w-14 h-14 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <BookOpen className="w-7 h-7" />
            </div>
            <div className="space-y-2 flex-1">
              <h3 className="text-base font-bold text-slate-900">Browse Books</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Explore our collection of books and find your next read across diverse genres and subjects.
              </p>
              <button
                onClick={() => handleNavClick('featured-books', 'Browse Books')}
                className="text-xs font-bold text-[#1877F2] hover:underline flex items-center gap-1.5 pt-1"
              >
                <span>View Books</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>

          {/* Card 2: Search & Discover */}
          <div className="bg-white p-7 rounded-2xl border border-slate-200/90 shadow-sm hover:border-blue-300 hover:shadow-md transition-all flex items-start gap-5">
            <div className="w-14 h-14 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Search className="w-7 h-7" />
            </div>
            <div className="space-y-2 flex-1">
              <h3 className="text-base font-bold text-slate-900">Search &amp; Discover</h3>
              <p className="text-xs text-slate-600 leading-relaxed">
                Find books by title, author, ISBN or category with instant real-time lookup and shelf locations.
              </p>
              <button
                onClick={() => handleNavClick('hero', 'Home')}
                className="text-xs font-bold text-[#1877F2] hover:underline flex items-center gap-1.5 pt-1"
              >
                <span>Search Now</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* 5. FEATURED BOOKS SECTION */}
      <section id="featured-books" className="p-6 md:p-10 max-w-[1500px] mx-auto w-full space-y-6">
        <div className="bg-white p-8 rounded-3xl border border-slate-200/90 shadow-sm space-y-6">
          {/* Header */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-100 pb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-blue-100 text-blue-600 flex items-center justify-center">
                <BookOpen className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-xl font-bold text-slate-900">Featured Books</h2>
                <p className="text-xs text-slate-500">
                  Explore some of our most popular and highly rated books.
                </p>
              </div>
            </div>

            <button
              onClick={() => onEnterPortal('reader')}
              className="text-xs font-bold text-[#1877F2] hover:underline flex items-center gap-1 self-start sm:self-auto"
            >
              <span>View All Books</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* Carousel Grid with Left & Right Arrow Buttons */}
          <div className="relative">
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-5">
              {featuredBooks.map((b) => (
                <div
                  key={b.id}
                  className="bg-slate-50/50 rounded-2xl border border-slate-200/80 p-4 flex flex-col justify-between hover:shadow-md hover:border-blue-300 transition-all group"
                >
                  <div className="space-y-3">
                    {/* Book Cover */}
                    <div className="w-full aspect-[3/4] rounded-xl overflow-hidden shadow-sm flex items-center justify-center bg-white">
                      <BookCover
                        title={b.title}
                        author={b.author}
                        coverImage={b.coverImage}
                        coverTheme={b.coverTheme}
                        size="md"
                        className="w-full h-full"
                      />
                    </div>

                    {/* Metadata */}
                    <div>
                      <h4 className="font-bold text-sm text-slate-900 group-hover:text-blue-600 transition-colors line-clamp-1">
                        {b.title}
                      </h4>
                      <p className="text-xs text-slate-500 mt-0.5">{b.author}</p>

                      {/* Category Tag with plus icon */}
                      <div className="mt-2">
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-sky-50 text-sky-700 border border-sky-200">
                          <span>✦</span>
                          <span>{b.category}</span>
                        </span>
                      </div>

                      {/* Availability status dot */}
                      <div className="flex items-center gap-1.5 mt-2 text-xs">
                        <span
                          className={`w-2 h-2 rounded-full ${
                            b.status === 'Available' ? 'bg-emerald-500' : 'bg-amber-500'
                          }`}
                        ></span>
                        <span
                          className={`font-semibold text-[11px] ${
                            b.status === 'Available' ? 'text-emerald-700' : 'text-amber-700'
                          }`}
                        >
                          {b.status}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* View Details Button */}
                  <button
                    onClick={() => setSelectedBookDetail(b)}
                    className="mt-4 w-full py-2 bg-white hover:bg-blue-50 border border-blue-400 text-blue-600 font-semibold text-xs rounded-xl shadow-2xs transition-colors"
                  >
                    View Details
                  </button>
                </div>
              ))}
            </div>

            {/* Left and Right Nav Buttons */}
            <button
              onClick={() => {}}
              className="hidden lg:flex absolute -left-4 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-white border border-slate-200 shadow-md items-center justify-center text-slate-600 hover:bg-slate-50 transition-colors"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={() => {}}
              className="hidden lg:flex absolute -right-4 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-white border border-slate-200 shadow-md items-center justify-center text-slate-600 hover:bg-slate-50 transition-colors"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </section>

      {/* 6. HOW IT WORKS SECTION */}
      <section id="how-it-works" className="px-6 md:px-10 max-w-[1500px] mx-auto w-full pb-8">
        <div className="bg-white rounded-3xl border border-slate-200/90 shadow-sm p-8 md:p-12 flex flex-col lg:flex-row items-center gap-10">
          {/* Left Illustration */}
          <div className="lg:w-1/3 flex justify-center">
            <div className="w-64 h-56 relative flex items-center justify-center bg-gradient-to-tr from-blue-50 to-indigo-50/60 rounded-3xl p-6 border border-blue-100/60">
              <div className="text-center space-y-3">
                <div className="w-16 h-16 rounded-2xl bg-blue-600 text-white flex items-center justify-center mx-auto shadow-md">
                  <BookOpen className="w-9 h-9" />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-bold text-slate-800 block">Seamless Student Access</span>
                  <span className="text-[11px] text-slate-500 block">Explore books, borrow instantly, and read anywhere.</span>
                </div>
              </div>
            </div>
          </div>

          {/* Right Steps */}
          <div className="lg:w-2/3 space-y-8">
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <Settings className="w-5 h-5 text-blue-600" />
                <h3 className="text-xl font-bold text-slate-900">How It Works</h3>
              </div>
              <p className="text-xs text-slate-500">
                Access library services in three simple steps.
              </p>
            </div>

            {/* 3 Step Process with Arrows */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-start relative">
              {/* Step 1 */}
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-[#1877F2] text-white flex items-center justify-center font-bold text-sm shadow-sm">
                    1
                  </div>
                  <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
                    <Users className="w-4 h-4" />
                  </div>
                </div>
                <div>
                  <h4 className="font-bold text-sm text-slate-900">Create an Account</h4>
                  <p className="text-xs text-slate-500 mt-1 leading-relaxed">
                    Sign up as a member and get access to our library catalog and member services.
                  </p>
                </div>
              </div>

              {/* Step 2 */}
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-[#1877F2] text-white flex items-center justify-center font-bold text-sm shadow-sm">
                    2
                  </div>
                  <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
                    <Search className="w-4 h-4" />
                  </div>
                </div>
                <div>
                  <h4 className="font-bold text-sm text-slate-900">Discover a Book</h4>
                  <p className="text-xs text-slate-500 mt-1 leading-relaxed">
                    Search from our vast collection of books and categories by title, author, or shelf.
                  </p>
                </div>
              </div>

              {/* Step 3 */}
              <div className="space-y-3">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-full bg-[#1877F2] text-white flex items-center justify-center font-bold text-sm shadow-sm">
                    3
                  </div>
                  <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
                    <Bookmark className="w-4 h-4" />
                  </div>
                </div>
                <div>
                  <h4 className="font-bold text-sm text-slate-900">Borrow or Reserve</h4>
                  <p className="text-xs text-slate-500 mt-1 leading-relaxed">
                    Take a book, return it on time, and enjoy your reading journey.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 7. CONTACT US SECTION */}
      <section id="contact" className="px-6 md:px-10 max-w-[1500px] mx-auto w-full pb-12 space-y-6">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <Mail className="w-5 h-5 text-blue-600" />
            <h3 className="text-xl font-bold text-slate-900">Contact Us</h3>
          </div>
          <p className="text-xs text-slate-500">
            We're here to help! Reach out to us for any questions, support or feedback.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Phone */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200/90 shadow-sm flex items-start gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Phone className="w-6 h-6" />
            </div>
            <div className="space-y-1">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider block">Phone</span>
              <div className="font-bold text-slate-900 text-base tabular-nums">+251 11 123 4567</div>
              <p className="text-[11px] text-slate-400">Call us during working hours.</p>
            </div>
          </div>

          {/* Email */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200/90 shadow-sm flex items-start gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Mail className="w-6 h-6" />
            </div>
            <div className="space-y-1">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider block">Email</span>
              <div className="font-bold text-slate-900 text-base">info@librarysystem.com</div>
              <p className="text-[11px] text-slate-400">We'll respond as soon as possible.</p>
            </div>
          </div>

          {/* Address */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200/90 shadow-sm flex items-start gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <MapPin className="w-6 h-6" />
            </div>
            <div className="space-y-1">
              <span className="text-xs font-bold text-slate-500 uppercase tracking-wider block">Address</span>
              <div className="font-bold text-slate-900 text-base">Addis Ababa, Ethiopia</div>
              <p className="text-[11px] text-slate-400">Visit us at our library location.</p>
            </div>
          </div>
        </div>
      </section>

      {/* 8. FOOTER */}
      <footer className="bg-[#002D72] text-white pt-12 pb-6 px-6 md:px-12 mt-auto">
        <div className="max-w-[1500px] mx-auto grid grid-cols-1 md:grid-cols-4 gap-10 border-b border-blue-900/60 pb-10">
          {/* Brand */}
          <div className="space-y-3">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-blue-500/40 flex items-center justify-center">
                <BookOpen className="w-5 h-5 text-white" />
              </div>
              <span className="font-bold text-lg text-white">Library Management System</span>
            </div>
            <p className="text-xs text-blue-200 leading-relaxed">
              Read More, Learn More, Grow More.
            </p>
          </div>

          {/* Quick Links */}
          <div className="space-y-2.5 text-xs">
            <h4 className="font-bold text-white text-sm">Quick Links</h4>
            <ul className="space-y-1.5 text-blue-200">
              <li><button onClick={() => handleNavClick('hero', 'Home')} className="hover:text-white">Home</button></li>
              <li><button onClick={() => handleNavClick('featured-books', 'Browse Books')} className="hover:text-white">Browse Books</button></li>
              <li><button onClick={() => handleNavClick('featured-books', 'Categories')} className="hover:text-white">Categories</button></li>
              <li><button onClick={() => handleNavClick('how-it-works', 'About')} className="hover:text-white">About</button></li>
              <li><button onClick={() => handleNavClick('contact', 'Contact')} className="hover:text-white">Contact</button></li>
            </ul>
          </div>

          {/* Library Rules */}
          <div className="space-y-2.5 text-xs">
            <h4 className="font-bold text-white text-sm">Library Rules</h4>
            <ul className="space-y-1.5 text-blue-200">
              <li className="hover:text-white cursor-pointer">Borrowing Limits</li>
              <li className="hover:text-white cursor-pointer">Loan Periods</li>
              <li className="hover:text-white cursor-pointer">Overdue Fines</li>
              <li className="hover:text-white cursor-pointer">FAQs</li>
            </ul>
          </div>

          {/* Follow Us */}
          <div className="space-y-3 text-xs">
            <h4 className="font-bold text-white text-sm">Follow Us</h4>
            <div className="flex items-center gap-2.5">
              {['f', 't', 'in', 'yt'].map((s) => (
                <div
                  key={s}
                  className="w-8 h-8 rounded-full bg-blue-800/80 hover:bg-blue-600 flex items-center justify-center text-white font-bold text-xs cursor-pointer transition-colors"
                >
                  {s}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="max-w-[1500px] mx-auto pt-6 flex flex-col md:flex-row items-center justify-between gap-3 text-xs text-blue-200/80">
          <div>© 2025 Library Management System. All rights reserved.</div>
          <div className="flex items-center gap-2 text-[11px]">
            <span>Better Readers</span>
            <span>·</span>
            <span>Stronger Communities</span>
            <span>·</span>
            <span>Brighter Futures</span>
          </div>
        </div>
      </footer>

      {/* Book Detail Modal */}
      {selectedBookDetail && (
        <div className="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-start gap-4">
              <BookCover
                title={selectedBookDetail.title}
                author={selectedBookDetail.author}
                coverImage={selectedBookDetail.coverImage}
                coverTheme={selectedBookDetail.coverTheme}
                size="md"
              />
              <div className="space-y-1 flex-1">
                <span className="text-[10px] font-bold text-blue-600 uppercase tracking-wide">
                  {selectedBookDetail.category}
                </span>
                <h3 className="font-bold text-base text-slate-900">{selectedBookDetail.title}</h3>
                <p className="text-xs text-slate-500">{selectedBookDetail.author}</p>
                <div className="font-mono text-[11px] text-slate-400">ISBN: {selectedBookDetail.isbn}</div>
                <div className="text-xs text-slate-600 font-medium mt-1">Location: {selectedBookDetail.location}</div>
              </div>
            </div>

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
              <button
                onClick={() => setSelectedBookDetail(null)}
                className="px-4 py-1.5 border border-slate-200 rounded-lg text-slate-700 text-xs font-semibold"
              >
                Close
              </button>
              <button
                onClick={() => {
                  setSelectedBookDetail(null);
                  setSignInInitialRole('reader');
                  setIsSignInOpen(true);
                }}
                className="px-4 py-1.5 bg-[#1877F2] hover:bg-blue-600 text-white text-xs font-semibold rounded-lg cursor-pointer"
              >
                Sign In to Reserve
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Sign In Modal with Hardcoded Default Credentials & 3 Dashboards */}
      <SignInModal
        isOpen={isSignInOpen}
        onClose={() => setIsSignInOpen(false)}
        onSignIn={(role) => onEnterPortal(role)}
        initialRole={signInInitialRole}
      />
    </div>
  );
};
