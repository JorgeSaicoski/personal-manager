# Planned Modules & Project Types

This document outlines the specialized modules planned for the Personal Manager system, each extending the base functionality provided by the Project-Core module.

## 🏗️ Architecture Overview

```
Personal Manager System
├── project-core ✅         ← Base project functionality (IMPLEMENTED)
├── professional-tracker ⏳  ← Time tracking & freelance work
├── education-manager ⏳     ← Course & student management  
└── finance-tracker ⏳       ← Financial goals & investments
```

**Status Legend:**
- ✅ Implemented  
- ⏳ Planned
- 🚧 In Development

---

## 1. Professional-Tracker Module ⏳

### 🎯 Purpose
Advanced time tracking and project cost management for professional work environments.

### 🎪 Target Users
- **Freelancers**: Track time across multiple clients
- **Companies**: Monitor employee project costs
- **Remote Workers**: Manage work sessions across multiple employers
- **Consultants**: Bill clients based on tracked time

### 🚀 Key Features

**Multi-Company Time Tracking:**
- Work for multiple companies simultaneously
- Sequential work sessions (Company A → Freelance Client → Studies)
- Break tracking (lunch, break, brb types)
- Automatic cost calculations

**Project Cost Management:**
- Company projects with employee cost allocation
- Freelance sub-projects (one worker per freelance)
- Client assignment (e.g., TCS project for THD client)
- Privacy-focused reporting (owners see costs, not individual hours)

**Work Session Flow:**
```
Select Company & Project → Start Work → Active Session
├── Take Break (break/lunch/brb)
├── Change Project (within same company)
├── Switch Company (finish current, start new)
└── Finish Day (end all sessions)
```

### 📊 Data Models (Planned)
```go
type ProfessionalProject struct {
    BaseProjectID   string    // Links to project-core
    ClientName      *string   // Optional client (THD for TCS project)
    SalaryPerHour   *float64  // For cost calculations
    TotalSalaryCost float64   // Calculated field
    ProjectAssignments []ProjectAssignment
    TimeSessions     []TimeSession
}

type ProjectAssignment struct {
    ParentProjectID string  // Links to ProfessionalProject
    WorkerUserID    string  // Single worker only
    CostPerHour     float64
    HoursDedicated  float64
    TotalCost       float64 // Calculated
}

type TimeSession struct {
    ProjectID    string
    UserID       string
    StartTime    time.Time
    EndTime      *time.Time
    SessionType  string    // work, break, lunch, brb
    CompanyID    string
}
```

### 🔌 API Endpoints (Planned)
- `POST /professional/sessions/start` - Start work session
- `POST /professional/sessions/break` - Take break
- `POST /professional/sessions/switch` - Switch project/company  
- `GET /professional/reports/costs` - Project cost analysis
- `GET /professional/freelance/{projectId}` - Freelance project details

---

## 2. Education-Manager Module ⏳

### 🎯 Purpose
Complete course and student management system for educational institutions.

### 🎪 Target Users
- **Schools**: Course scheduling and student tracking
- **Dance Studios**: Level-based class management (like Forro School)
- **Training Centers**: Multi-level course progression
- **Private Tutors**: Student payment and progress tracking

### 🚀 Key Features

**Course Management:**
- Multi-level courses (Level 1-4 progression)
- Invitation-only advanced levels
- Teacher assignment with backup teachers
- Flexible pricing (per class / per course)

**Student Management:**
- Enrollment and level progression
- Payment status tracking
- Attendance monitoring
- Level-based access control

**Example Use Case (Forro School):**
- **Level 1**: Open enrollment, anyone can join
- **Level 2-4**: Invitation only based on skill/progress
- **Teachers**: Main + backup teacher assignment
- **Pricing**: Monthly fees or per-class payments
- **Payment Tracking**: Who paid, who's overdue

### 📊 Data Models (Planned)
```go
type EducationProject struct {
    BaseProjectID   string    // Links to project-core
    CourseLevel     string    // lvl1, lvl2, lvl3, lvl4
    PricePerClass   *float64
    PricePerCourse  *float64
    MaxStudents     *int
    TeacherID       string
    BackupTeacherID *string
    Students        []Student
    Classes         []Class
    Payments        []StudentPayment
}

type Student struct {
    ProjectID       string
    UserID          string
    Level           string    // Current level
    PaymentStatus   string    // paid, pending, overdue
    EnrollmentDate  time.Time
    LastPaymentDate *time.Time
}

type Class struct {
    ProjectID   string
    Date        time.Time
    TeacherID   string
    Students    []string  // Who attended
    Status      string    // scheduled, completed, cancelled
}
```

### 🔌 API Endpoints (Planned)
- `POST /education/projects` - Create course
- `POST /education/students/enroll` - Enroll student
- `POST /education/students/invite` - Invite to higher level
- `GET /education/payments/overdue` - Overdue payments report
- `POST /education/classes/attendance` - Mark attendance

---

## 3. Finance-Tracker Module ⏳

### 🎯 Purpose
Personal financial goal management and multi-platform account aggregation.

### 🎪 Target Users
- **Individual Investors**: Track crypto, stocks, and bank accounts
- **Savers**: Goal-based saving plans (house, travel, retirement)
- **Multi-Currency Users**: BTC, USD, BRL, UYU account tracking
- **Financial Planners**: Personal finance consultants

### 🚀 Key Features

**Multi-Platform Account Aggregation:**
- Crypto wallets (Electrum, Jade Wallet, Ripio, MercadoBitcoin)
- Stock platforms (Prex)
- Bank accounts (Nubank, Santander)
- Multi-currency support (BTC, USD, BRL, UYU)

**Goal-Oriented Financial Planning:**
- Savings goals (house, travel, emergency fund, retirement)
- Monthly investment targets
- Progress tracking toward goals
- Timeline and milestone management

**Real-World Use Case:**
> "I have BTC on Electrum, BTC on Jade Wallet, BTC on Ripio, BTC on MercadoBitcoin, stocks on Prex, and bank accounts on Nubank and Santander. I don't know how much I have in total or where my money is."

### 📊 Data Models (Planned)
```go
type FinanceProject struct {
    BaseProjectID    string    // Links to project-core
    GoalType         string    // house, travel, retirement, emergency
    TargetAmount     float64
    CurrentAmount    float64   // Calculated from accounts
    MonthlyTarget    float64
    TargetDate       time.Time
    Accounts         []FinanceAccount
    Transactions     []Transaction
    Milestones       []Milestone
}

type FinanceAccount struct {
    ProjectID       string
    AccountName     string    // Electrum, Nubank, Prex
    AccountType     string    // crypto, stock, bank
    Currency        string    // BTC, USD, BRL, UYU
    CurrentAmount   float64
    ApiEndpoint     *string   // For automatic sync
    ApiCredentials  *string   // Encrypted
    AutoSync        bool
}

type Transaction struct {
    AccountID   string
    Amount      float64
    Type        string    // deposit, withdrawal, transfer
    Date        time.Time
    Category    *string   // investment, expense, income
}
```

### 🔌 API Endpoints (Planned)
- `POST /finance/goals` - Create financial goal
- `GET /finance/accounts/summary` - Account balance overview
- `POST /finance/accounts/sync` - Sync with external platforms
- `GET /finance/projections` - Goal achievement projections
- `POST /finance/transactions` - Log manual transaction

---

## 4. Calendar-Aggregator Module ⏳

### 🎯 Purpose
Unified calendar view aggregating data from all specialized modules.

### 🚀 Key Features

**Cross-Module Event Aggregation:**
- **Professional**: Work sessions, project deadlines, break times
- **Education**: Class schedules, payment due dates, enrollment deadlines
- **Finance**: Goal deadlines, milestone targets, investment reminders
- **Core**: General project dates and company events

**Multiple Calendar Views:**
- Daily work schedule with all companies
- Weekly class and payment overview
- Monthly financial goal progress
- Yearly project and milestone timeline

### 📊 Data Sources (Planned)
```go
type CalendarEvent struct {
    ID          string    `json:"id"`
    Title       string    `json:"title"`
    Start       time.Time `json:"start"`
    End         *time.Time `json:"end"`
    Type        string    `json:"type"`        // work, class, payment, goal
    SourceModule string   `json:"sourceModule"` // professional, education, finance
    ProjectID   string    `json:"projectId"`
    Data        interface{} `json:"data"`      // Module-specific data
}
```

### 🔌 API Endpoints (Planned)
- `GET /calendar/events` - Unified event list
- `GET /calendar/day/{date}` - Daily schedule
- `GET /calendar/week/{date}` - Weekly overview
- `GET /calendar/month/{date}` - Monthly view

---

## 🚀 Development Roadmap

### Phase 1: Foundation (Current)
- ✅ Project-Core module implementation
- ✅ Base authentication and permissions
- ✅ Company and project management

### Phase 2: Professional Tracking (Next)
- ⏳ Time tracking infrastructure
- ⏳ Multi-company session management
- ⏳ Freelance project cost calculations
- ⏳ Privacy-focused reporting

### Phase 3: Education Management
- ⏳ Course and student models
- ⏳ Level-based access control
- ⏳ Payment tracking system
- ⏳ Class scheduling and attendance

### Phase 4: Finance Tracking
- ⏳ Multi-platform account aggregation
- ⏳ Goal-based saving plans
- ⏳ External API integrations
- ⏳ Financial projections and reports

### Phase 5: Calendar Integration
- ⏳ Cross-module event aggregation
- ⏳ Unified calendar interface
- ⏳ Advanced filtering and views
- ⏳ Mobile calendar sync

---

## 🤝 Contributing

Each module will be developed as an independent repository:

- `project-core` → `github.com/JorgeSaicoski/go-project-manager` ✅
- `professional-tracker` → `github.com/JorgeSaicoski/professional-tracker` ⏳
- `education-manager` → `github.com/JorgeSaicoski/education-manager` ⏳
- `finance-tracker` → `github.com/JorgeSaicoski/finance-tracker` ⏳
- `calendar-aggregator` → `github.com/JorgeSaicoski/calendar-aggregator` ⏳

### Development Guidelines
1. Each module extends Project-Core functionality
2. Use shared authentication (keycloak-auth)
3. Follow consistent API patterns
4. Maintain data privacy and security
5. Design for horizontal scaling

---

## 📞 Questions & Feedback

For questions about specific modules or the overall architecture:
- Create issues in the relevant repository
- Discuss architecture decisions in the main project
- Follow the contribution guidelines for each module

This modular approach allows focused development on specific business domains while maintaining a unified user experience across the entire Personal Manager ecosystem.