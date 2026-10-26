import { Book, StaffMember, StaffActivity, BorrowRecord, Reservation, LibraryNotification, SystemSettings, UserProfile } from '../types';

export const INITIAL_USERS: Record<string, UserProfile> = {
  admin: {
    id: 'u-admin',
    name: 'Admin',
    title: 'System Administrator',
    role: 'admin',
    email: 'admin@library.univ.et'
  },
  librarian: {
    id: 'u-librarian',
    name: 'Ms. Sara Ahmed',
    title: 'Librarian',
    role: 'librarian',
    email: 'sara.ahmed@library.univ.et'
  },
  reader: {
    id: 'u-reader',
    name: 'Abiye Tesfaye',
    title: 'Reader',
    role: 'reader',
    email: 'abiye.tesfaye@univ.et'
  }
};

export const INITIAL_BOOKS: Book[] = [
  {
    id: 'b-01',
    title: 'Atomic Habits',
    author: 'James Clear',
    isbn: '978-0735211292',
    category: 'Self-Help',
    totalCopies: 5,
    availableCopies: 3,
    status: 'Available',
    location: 'Shelf A1',
    coverTheme: 'atomic-habits',
    description: 'An Easy & Proven Way to Build Good Habits & Break Bad Ones.',
    publishedYear: 2018
  },
  {
    id: 'b-02',
    title: 'Dune',
    author: 'Frank Herbert',
    isbn: '978-0441013593',
    category: 'Science Fiction',
    totalCopies: 4,
    availableCopies: 1,
    status: 'Low Stock',
    location: 'Shelf B2',
    coverImage: '/web/src/assets/images/book_cover_dune_1791886211742.jpg',
    description: 'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides.',
    publishedYear: 1965
  },
  {
    id: 'b-03',
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    isbn: '978-0743273567',
    category: 'Fiction',
    totalCopies: 6,
    availableCopies: 6,
    status: 'Available',
    location: 'Shelf C3',
    coverImage: '/web/src/assets/images/book_cover_gatsby_1791886212070.jpg',
    description: 'The story of the mysteriously wealthy Jay Gatsby and his love for Daisy Buchanan.',
    publishedYear: 1925
  },
  {
    id: 'b-04',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    isbn: '978-0132350884',
    category: 'Computer Science',
    totalCopies: 3,
    availableCopies: 2,
    status: 'Available',
    location: 'Shelf D1',
    coverImage: '/web/src/assets/images/book_cover_cleancode_1791886211255.jpg',
    description: 'A Handbook of Agile Software Craftsmanship.',
    publishedYear: 2008
  },
  {
    id: 'b-05',
    title: 'Sapiens',
    author: 'Yuval Noah Harari',
    isbn: '978-0062316097',
    category: 'History',
    totalCopies: 5,
    availableCopies: 4,
    status: 'Available',
    location: 'Shelf E2',
    coverTheme: 'sapiens',
    description: 'A Brief History of Humankind exploring how biology and history defined us.',
    publishedYear: 2014
  },
  {
    id: 'b-06',
    title: "Harry Potter and the Sorcerer's Stone",
    author: 'J.K. Rowling',
    isbn: '978-0545582885',
    category: 'Fantasy',
    totalCopies: 7,
    availableCopies: 5,
    status: 'Available',
    location: 'Shelf F1',
    coverTheme: 'harry-potter',
    description: 'Harry discovers his magical heritage on his eleventh birthday.',
    publishedYear: 1997
  },
  {
    id: 'b-07',
    title: '1984',
    author: 'George Orwell',
    isbn: '978-0451524935',
    category: 'Dystopian',
    totalCopies: 4,
    availableCopies: 2,
    status: 'Available',
    location: 'Shelf F3',
    coverTheme: '1984',
    description: 'Winston Smith wrestles with oppression in Oceania.',
    publishedYear: 1949
  },
  {
    id: 'b-08',
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    isbn: '978-0061120084',
    category: 'Classic',
    totalCopies: 6,
    availableCopies: 5,
    status: 'Available',
    location: 'Shelf G1',
    coverTheme: 'mockingbird',
    description: 'A story of racial injustice and the destruction of innocence.',
    publishedYear: 1960
  },
  {
    id: 'b-09',
    title: 'The Martian',
    author: 'Andy Weir',
    isbn: '978-0553418026',
    category: 'Science Fiction',
    totalCopies: 4,
    availableCopies: 1,
    status: 'Low Stock',
    location: 'Shelf B1',
    coverTheme: 'the-martian',
    description: 'Six days ago, astronaut Mark Watney became one of the first people to walk on Mars.',
    publishedYear: 2011
  },
  {
    id: 'b-10',
    title: 'Data Structures and Algorithms',
    author: 'Goodrich & Tamassia',
    isbn: '978-0134260794',
    category: 'Computer Science',
    totalCopies: 5,
    availableCopies: 4,
    status: 'Available',
    location: 'Shelf D3',
    coverTheme: 'data-structures',
    description: 'Comprehensive analysis and design of fundamental data structures.',
    publishedYear: 2014
  },
  {
    id: 'b-11',
    title: 'Introduction to Algorithms',
    author: 'Cormen, Leiserson, Rivest & Stein',
    isbn: '978-0262046305',
    category: 'Computer Science',
    totalCopies: 4,
    availableCopies: 3,
    status: 'Available',
    location: 'Stack A · Shelf 04',
    coverTheme: 'algorithms',
    description: 'The leading reference for algorithms and data structures globally.',
    publishedYear: 2009
  },
  {
    id: 'b-12',
    title: 'Database System Concepts',
    author: 'Silberschatz, Korth & Sudarshan',
    isbn: '978-0078022159',
    category: 'Databases',
    totalCopies: 2,
    availableCopies: 0,
    status: 'Unavailable',
    location: 'Stack B · Shelf 02',
    coverTheme: 'databases',
    description: 'Core concepts of database management and relational design.',
    publishedYear: 2019
  }
];

export const INITIAL_STAFF: StaffMember[] = [
  {
    id: 's-01',
    name: 'Samuel Worku',
    employeeId: 'EMP-7701',
    role: 'Administrator',
    email: 'samuel.w@library.univ.et',
    status: 'Active',
    permissions: {
      addBooks: true,
      waiveFines: true,
      manageStaff: true,
      accessSettings: true,
      manageInventory: true,
      viewRecords: true,
      systemConfig: true
    }
  },
  {
    id: 's-02',
    name: 'Meron Alemu',
    employeeId: 'EMP-7708',
    role: 'Librarian',
    email: 'merona@library.univ.et',
    status: 'Active',
    permissions: {
      addBooks: true,
      waiveFines: false,
      manageStaff: false,
      accessSettings: false,
      manageInventory: true,
      viewRecords: true,
      systemConfig: false
    }
  },
  {
    id: 's-03',
    name: 'Yohannes Girma',
    employeeId: 'EMP-7715',
    role: 'Librarian',
    email: 'yohannes.g@library.univ.et',
    status: 'Active',
    permissions: {
      addBooks: false,
      waiveFines: false,
      manageStaff: false,
      accessSettings: false,
      manageInventory: true,
      viewRecords: true,
      systemConfig: false
    }
  },
  {
    id: 's-04',
    name: 'Hana Girma',
    employeeId: 'EMP-7718',
    role: 'Librarian',
    email: 'hana@library.univ.et',
    status: 'Active',
    permissions: {
      addBooks: true,
      waiveFines: false,
      manageStaff: false,
      accessSettings: false,
      manageInventory: true,
      viewRecords: true,
      systemConfig: false
    }
  },
  {
    id: 's-05',
    name: 'Tesfaye Abebe',
    employeeId: 'EMP-7720',
    role: 'Librarian',
    email: 'tesfaye.a@library.univ.et',
    status: 'Active',
    permissions: {
      addBooks: true,
      waiveFines: true,
      manageStaff: false,
      accessSettings: false,
      manageInventory: true,
      viewRecords: true,
      systemConfig: false
    }
  },
  {
    id: 's-06',
    name: 'Selam Tesfaye',
    employeeId: 'EMP-7721',
    role: 'Assistant Librarian',
    email: 'selam.t@library.univ.et',
    status: 'Active',
    permissions: {
      addBooks: false,
      waiveFines: false,
      manageStaff: false,
      accessSettings: false,
      manageInventory: true,
      viewRecords: true,
      systemConfig: false
    }
  }
];

export const INITIAL_STAFF_ACTIVITY: StaffActivity[] = [
  {
    id: 'act-1',
    dateTime: 'Jun 8, 2025  10:24 AM',
    staffName: 'Samuel Worku',
    action: 'Created',
    details: 'New librarian account (EMP-7701)'
  },
  {
    id: 'act-2',
    dateTime: 'Jun 7, 2025  03:12 PM',
    staffName: 'Meron Alemu',
    action: 'Updated',
    details: 'Role changed to Librarian'
  },
  {
    id: 'act-3',
    dateTime: 'Jun 6, 2025  11:45 AM',
    staffName: 'Hana Girma',
    action: 'Logged In',
    details: 'System access'
  },
  {
    id: 'act-4',
    dateTime: 'Jun 5, 2025  09:32 AM',
    staffName: 'Tesfaye Abebe',
    action: 'Updated',
    details: 'Permissions modified'
  }
];

export const INITIAL_SETTINGS: SystemSettings = {
  institutionName: 'University Central Library & Information Center',
  contactEmail: 'library@univ.et',
  phoneNumber: '+251 11 123 4567',
  address: 'Addis Ababa, Ethiopia.',
  academicYear: '2025 - 2026',
  dateFormat: 'YYYY-MM-DD',
  defaultLanguage: 'English',
  timeFormat: '12 Hours (AM/PM)',
  openingTime: '08:00 AM',
  closingTime: '05:00 PM',
  workingDays: {
    mon: true,
    tue: true,
    wed: true,
    thu: true,
    fri: true,
    sat: false,
    sun: false
  },
  borrowingPeriodDays: 14,
  maxBooksPerStudent: 3,
  reservationDurationDays: 7,
  fineCap: 250,
  fineRatePerDay: 5,
  gracePeriodDays: 0,
  maxHoldDurationDays: 3,
  currencySymbol: 'ETB',
  lastUpdated: 'Jun 8, 2025 • 10:24 AM',
  updatedBy: 'Admin'
};

export const INITIAL_READER_BORROWED: BorrowRecord[] = [
  {
    id: 'br-1',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-01',
    bookTitle: 'Atomic Habits',
    isbn: '978-0735211292',
    borrowDate: 'Oct 2, 2026',
    dueDate: 'Oct 10, 2026',
    status: 'Borrowed'
  },
  {
    id: 'br-2',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-02',
    bookTitle: 'Dune',
    isbn: '978-0441013593',
    borrowDate: 'Sep 28, 2026',
    dueDate: 'Oct 13, 2026',
    status: 'Borrowed'
  },
  {
    id: 'br-3',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-03',
    bookTitle: 'The Great Gatsby',
    isbn: '978-0743273567',
    borrowDate: 'Sep 25, 2026',
    dueDate: 'Oct 15, 2026',
    status: 'Borrowed'
  }
];

export const INITIAL_READER_HISTORY: BorrowRecord[] = [
  {
    id: 'hist-1',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-04',
    bookTitle: 'Clean Code',
    isbn: '978-0132350884',
    borrowDate: 'Sep 15, 2026',
    dueDate: 'Oct 1, 2026',
    returnDate: 'Oct 1, 2026',
    status: 'Returned'
  },
  {
    id: 'hist-2',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-05',
    bookTitle: 'Sapiens',
    isbn: '978-0062316097',
    borrowDate: 'Sep 10, 2026',
    dueDate: 'Sep 27, 2026',
    returnDate: 'Sep 27, 2026',
    status: 'Returned'
  },
  {
    id: 'hist-3',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-07',
    bookTitle: '1984',
    isbn: '978-0451524935',
    borrowDate: 'Sep 5, 2026',
    dueDate: 'Sep 20, 2026',
    returnDate: 'Sep 20, 2026',
    status: 'Returned'
  },
  {
    id: 'hist-4',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-pragmatic',
    bookTitle: 'The Pragmatic Programmer',
    isbn: '978-0201616224',
    borrowDate: 'Aug 20, 2026',
    dueDate: 'Sep 3, 2026',
    returnDate: 'Sep 3, 2026',
    status: 'Returned'
  },
  {
    id: 'hist-5',
    studentId: 'S-00123',
    studentName: 'Abiye Tesfaye',
    bookId: 'b-thinking',
    bookTitle: 'Thinking, Fast and Slow',
    isbn: '978-0374533557',
    borrowDate: 'Aug 5, 2026',
    dueDate: 'Aug 19, 2026',
    returnDate: 'Aug 19, 2026',
    status: 'Returned'
  }
];

export const INITIAL_RESERVATIONS: Reservation[] = [
  {
    id: 'res-1',
    bookId: 'b-03',
    bookTitle: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    studentId: 'S-00123',
    reservedOn: 'May 15, 2026',
    pickupBy: 'May 29, 2026',
    pickupLocation: 'Central Library',
    status: 'Active',
    expiresInDays: 10
  },
  {
    id: 'res-2',
    bookId: 'b-01',
    bookTitle: 'Atomic Habits',
    author: 'James Clear',
    studentId: 'S-00123',
    reservedOn: 'May 10, 2026',
    readySince: 'May 12, 2026',
    pickupBy: 'May 26, 2026',
    pickupLocation: 'Central Library',
    status: 'Ready for Pickup'
  },
  {
    id: 'res-3',
    bookId: 'b-02',
    bookTitle: 'Dune',
    author: 'Frank Herbert',
    studentId: 'S-00123',
    reservedOn: 'Apr 20, 2026',
    pickupBy: 'Apr 27, 2026',
    pickupLocation: 'Central Library',
    status: 'Completed',
    completedOn: 'Apr 27, 2026'
  },
  {
    id: 'res-4',
    bookId: 'b-04',
    bookTitle: 'Clean Code',
    author: 'Robert C. Martin',
    studentId: 'S-00123',
    reservedOn: 'Apr 10, 2026',
    pickupBy: 'Apr 17, 2026',
    pickupLocation: 'Central Library',
    status: 'Completed',
    completedOn: 'Apr 17, 2026'
  },
  {
    id: 'res-5',
    bookId: 'b-05',
    bookTitle: 'Sapiens',
    author: 'Yuval Noah Harari',
    studentId: 'S-00123',
    reservedOn: 'Mar 25, 2026',
    pickupBy: 'Apr 2, 2026',
    pickupLocation: 'Central Library',
    status: 'Completed',
    completedOn: 'Apr 2, 2026'
  },
  {
    id: 'res-6',
    bookId: 'b-07',
    bookTitle: '1984',
    author: 'George Orwell',
    studentId: 'S-00123',
    reservedOn: 'Mar 10, 2026',
    pickupBy: 'Mar 17, 2026',
    pickupLocation: 'Central Library',
    status: 'Completed',
    completedOn: 'Mar 17, 2026'
  },
  {
    id: 'res-7',
    bookId: 'b-thinking',
    bookTitle: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    studentId: 'S-00123',
    reservedOn: 'Feb 20, 2026',
    pickupBy: 'Feb 28, 2026',
    pickupLocation: 'Central Library',
    status: 'Completed',
    completedOn: 'Feb 28, 2026'
  }
];

export const INITIAL_LIBRARIAN_NOTIFICATIONS: LibraryNotification[] = [
  {
    id: 'notif-1',
    title: 'Overdue Book',
    message: "The book 'Atomic Habits' is overdue. It was due on 2025-06-22.",
    type: 'overdue',
    timestamp: '2025-06-27T08:00:00Z',
    timeAgo: '2 hours ago',
    isRead: false,
    studentId: 'S-00123',
    studentName: 'Abebe Kebede',
    bookTitle: 'Atomic Habits',
    dueDate: '2025-06-22'
  },
  {
    id: 'notif-2',
    title: 'Due Soon',
    message: "'The Great Gatsby' will be due in 2 days (2025-06-25).",
    type: 'due_soon',
    timestamp: '2025-06-27T06:00:00Z',
    timeAgo: '4 hours ago',
    isRead: false,
    studentId: 'S-00145',
    studentName: 'Selam Tesfaye',
    bookTitle: 'The Great Gatsby',
    dueDate: '2025-06-25'
  },
  {
    id: 'notif-3',
    title: 'Reservation Available',
    message: "Your reservation for 'Dune' is now available.",
    type: 'reservation',
    timestamp: '2025-06-27T04:00:00Z',
    timeAgo: '6 hours ago',
    isRead: false,
    bookTitle: 'Dune',
    tag: 'Book ID: B-00127'
  },
  {
    id: 'notif-4',
    title: 'Overdue Book',
    message: "The book 'Clean Code' is overdue. It was due on 2025-06-19.",
    type: 'overdue',
    timestamp: '2025-06-26T10:00:00Z',
    timeAgo: '1 day ago',
    isRead: false,
    studentId: 'S-00102',
    studentName: 'Yonas Tadesse',
    bookTitle: 'Clean Code',
    dueDate: '2025-06-19'
  },
  {
    id: 'notif-5',
    title: 'New Reservation',
    message: "A new reservation has been made for 'The Martian'.",
    type: 'reservation',
    timestamp: '2025-06-26T09:00:00Z',
    timeAgo: '1 day ago',
    isRead: true,
    studentId: 'S-00167',
    studentName: 'Mekdes Alemu',
    bookTitle: 'The Martian'
  },
  {
    id: 'notif-6',
    title: 'Library Announcement',
    message: 'The library will be closed on June 28, 2025 for maintenance. All services will resume on June 29, 2025.',
    type: 'announcement',
    timestamp: '2025-06-25T14:00:00Z',
    timeAgo: '2 days ago',
    isRead: true
  },
  {
    id: 'notif-7',
    title: 'Due Soon',
    message: "'Sapiens' will be due in 3 days (2025-06-27).",
    type: 'due_soon',
    timestamp: '2025-06-25T11:00:00Z',
    timeAgo: '2 days ago',
    isRead: true,
    studentId: 'S-00178',
    studentName: 'Hana Girma',
    bookTitle: 'Sapiens',
    dueDate: '2025-06-27'
  },
  {
    id: 'notif-8',
    title: 'Library Announcement',
    message: 'New books have been added to the collection. Check the latest titles in the catalog.',
    type: 'announcement',
    timestamp: '2025-06-24T10:00:00Z',
    timeAgo: '3 days ago',
    isRead: true
  }
];

export const INITIAL_READER_NOTIFICATIONS: LibraryNotification[] = [
  {
    id: 'r-notif-1',
    title: 'Your book "Atomic Habits" is due in 2 days.',
    message: 'Please return or renew it to avoid late fees.',
    type: 'due_soon',
    timestamp: '2026-10-13T01:00:00Z',
    timeAgo: '2 hours ago',
    isRead: false,
    tag: 'Books'
  },
  {
    id: 'r-notif-2',
    title: 'Your reservation for "The Martian" is now available.',
    message: 'Please pick it up by May 20, 2026.',
    type: 'reservation',
    timestamp: '2026-10-12T10:00:00Z',
    timeAgo: '1 day ago',
    isRead: false,
    tag: 'Reservations'
  },
  {
    id: 'r-notif-3',
    title: 'Reservation ready for pickup',
    message: '"The Great Gatsby" is ready for pickup at Central Library.',
    type: 'reservation',
    timestamp: '2026-10-11T12:00:00Z',
    timeAgo: '2 days ago',
    isRead: false,
    tag: 'Reservations'
  },
  {
    id: 'r-notif-4',
    title: '"Dune" has been renewed successfully.',
    message: 'New due date: May 20, 2026.',
    type: 'borrow',
    timestamp: '2026-10-10T14:00:00Z',
    timeAgo: '3 days ago',
    isRead: true,
    tag: 'Books'
  },
  {
    id: 'r-notif-5',
    title: 'Library will be closed on May 26, 2026.',
    message: 'Memorial Day - All branches will remain closed.',
    type: 'announcement',
    timestamp: '2026-10-08T09:00:00Z',
    timeAgo: '5 days ago',
    isRead: true,
    tag: 'General'
  },
  {
    id: 'r-notif-6',
    title: 'Welcome to the Library!',
    message: 'Thank you for being a valued member. Explore, read, and grow.',
    type: 'general',
    timestamp: '2026-05-05T08:00:00Z',
    timeAgo: 'May 5, 2026',
    isRead: true,
    tag: 'General'
  }
];
