# MSME Mobile Application — Project Overview

## 1. Project Overview

This project is a mobile application designed to help Micro, Small, and Medium Enterprises (MSMEs) in Antique establish a digital business presence and promote their businesses to nearby users.

The application has two user groups in the overall project concept:

- MSME/business owners
- General public/tourists

This document covers **only the MSME/business-owner side** of the application. Public-user and tourist features are outside the current development scope.

The MSME side allows a business owner to:

1. Register a personal account.
2. Register and provide business information.
3. Submit documents for business verification.
4. Confirm the business location and establish a fixed **100-meter geofence**.
5. Manage the business information displayed in the application.
6. Create and manage digital promotions.
7. Monitor geofence activity and business-related analytics.
8. Manage account and business settings.

The application should use the information submitted by the MSME during onboarding to build the business profile shown on the Home/Dashboard.

---

# 2. Current MSME Application Workflow

```text
Personal Registration
        ↓
Business Information
        ↓
Verification Documents
        ↓
Business Verification
        ↓
Set Business Location
        ↓
100-Meter Geofence Established
        ↓
MSME Home / Dashboard
        ↓
Manage Promotions / View Business Pulse / Manage Account
```

## 2.1 Personal Registration

The MSME owner creates a personal account before registering the business.

The registration section should contain the necessary personal account information, such as:

- Full name
- Email or mobile number
- Password
- Other required account information

The exact fields may be finalized during development, but unnecessary personal information should not be added without a project requirement.

---

# 3. Business Information

After personal registration, the user provides the information for the business they want to register.

The business information should include the information needed to identify and present the business, such as:

- Business name
- Business category
- Business description
- Business address
- Municipality
- Barangay
- Contact information
- Operating hours
- Other relevant business information

Business categories should be standardized so that the same category data can be used consistently throughout the system.

Example categories may include:

- Coffee Shop
- Restaurant
- Retail
- Salon
- Barbershop
- Services
- Accommodation
- Other MSME categories

---

# 4. Business Verification

The application requires the MSME to submit documents to establish that the registered business is legitimate.

Required verification documents:

- DTI certificate/registration
- BIR certificate/registration
- Mayor's Permit or applicable business permit
- Government-issued ID

The application should show the verification status.

Possible statuses:

- Pending
- Under Review
- Verified
- Requires Correction
- Rejected

The MSME must not be presented as a verified business until the verification process is completed.

---

# 5. Geofence Location Setup

After the business is successfully verified, the user proceeds to the geofence location setup.

## 5.1 Fixed Geofence Range

The geofence range is **fixed at 100 meters**.

The MSME owner does **not** choose or customize the geofence radius.

The system automatically uses:

**100 meters from the confirmed business location.**

## 5.2 Business Pin Location

The owner should be able to adjust the **business location pin** on the map before confirming the location.

The purpose of moving the pin is to make sure the business location is accurately represented.

Example flow:

```text
Open Map
   ↓
Show Business Location Pin
   ↓
Owner Adjusts Pin if Needed
   ↓
Show 100-Meter Coverage Area
   ↓
Owner Confirms Location
   ↓
Geofence Is Established
```

The map should visually show the business pin and its 100-meter coverage area.

## 5.3 Geofence Concept

The geofence is intended to support location-based promotion.

When an eligible application user enters the defined 100-meter area around the business, the system can use the geofence to support a promotional notification.

The exact notification and location-permission behavior is part of later implementation. The MSME-side interface should primarily allow the owner to confirm the location and view/manage the geofence-related information.

---

# 6. MSME Home / Dashboard

After the geofence setup is completed, the MSME enters the main Home/Dashboard.

The Home/Dashboard is an **overview page**, not the location for every business-management function.

Its purpose is to let the owner quickly see the current state of their business.

## 6.1 Business Header

The top of the Home/Dashboard should show the basic business identity.

Content:

- Business logo
- Business name
- Business category
- Verification status
- Business location

Example:

```text
[Business Logo]

Antique Brew Café
Coffee Shop
✓ Verified

San Jose de Buenavista, Antique
```

## 6.2 Store/Business Image

Show the uploaded exterior/storefront photo as a visual representation of the business.

An interior photo may also be shown when one has been uploaded.

## 6.3 Business Information Summary

Show selected information already submitted during onboarding.

Possible summary information:

- Business description
- Operating hours
- Contact information
- Location

The Home/Dashboard should not duplicate every editable field. Detailed editing should be available through the Account/Business settings area.

## 6.4 Products and Services Summary

Show a summary of the products or services added by the business.

Example:

```text
Products & Services
8 items
[View All]
```

Individual products/services may contain:

- Name
- Image
- Description
- Price or price range
- Category

## 6.5 Bestsellers

Display products/services identified by the MSME as bestsellers.

The owner should be able to mark an existing product/service as a bestseller rather than entering the same information a second time.

Example:

```text
Bestsellers

[Product Image] Spanish Latte
[Product Image] Cheesecake
```

## 6.6 Promotions Summary

Show currently active promotions on the Home/Dashboard.

Example:

```text
Active Promotions
2 active
[View Promotions]
```

## 6.7 Reviews

The Home/Dashboard should include a review summary.

When there are no reviews yet, show a placeholder instead of leaving the section empty.

Example:

```text
Reviews
⭐ No reviews yet

Customers have not submitted
a review for this business yet.
```

When reviews exist, show:

- Average rating
- Number of reviews
- Option to view all reviews

---

# 7. Main MSME Navigation

The MSME side should contain four major pages for primary navigation.

```text
Home
Promo Studio
Business Pulse
Account
```

These pages have distinct purposes and should not duplicate one another.

---

# 8. Promo Studio

## Purpose

Promo Studio is the MSME's workspace for creating and managing digital promotions for its business.

This page directly supports the project's goal of helping MSMEs promote their products and services digitally.

## 8.1 Main Content

The page should contain:

- Active promotions
- Draft promotions, when applicable
- Expired promotions
- Create promotion action

Example:

```text
Promo Studio

[ + Create Promotion ]

Active
-------------------------
Buy 1 Take 1
Oct 8 – Oct 15

₱20 Off
Oct 10 – Oct 20

Expired
-------------------------
Student Discount
Sep 20 – Sep 30
```

## 8.2 Create Promotion

A promotion may contain:

- Promotion title
- Description
- Promotion image
- Start date
- End date
- Related product/service
- Promotion details or offer

The interface should make it simple for an MSME owner to create a digital promotion without requiring advanced marketing knowledge.

## 8.3 Promotion Management

The owner should be able to:

- Create a promotion
- View active promotions
- Edit applicable promotion information
- View expired promotions
- Activate or deactivate applicable promotions

Promotions should have clear active, draft, or expired states where applicable.

---

# 9. Business Pulse

## Purpose

**Business Pulse** combines the project's geofence-related information with business analytics.

It replaces the need for separate primary pages for Geofence and Insights.

The page should answer:

> How is my business being reached and interacted with through the application?

## 9.1 Geofence Section

Show:

- Geofence status
- Business location
- Fixed 100-meter radius
- Related promotional activity
- Relevant notification metrics, when available

Example:

```text
Geofence

● Active

Business Location
San Jose de Buenavista

Coverage
100 meters
```

## 9.2 Analytics Section

Show measurable application activity related to the business.

Possible metrics:

- Profile views
- Product/service views
- Promotion views
- Notifications sent
- Notifications opened
- Reviews

Example:

```text
Business Activity

Profile Views       127
Product Views        83
Promotion Views      54
```

## 9.3 Geofence Performance

Where the system collects the required data, show:

```text
Geofence Activity

Notifications Sent     42
Notifications Opened   18
```

An engagement/open rate may be calculated only when the required data exists.

Example calculation:

```text
18 opened ÷ 42 sent × 100 = 42.9%
```

Do not display sales, revenue, or other business outcomes unless the system actually collects and calculates those values.

---

# 10. Account

## Purpose

The Account page is for personal account management, business information management, verification information, and application settings.

## 10.1 Personal Account

Possible sections:

- Personal information
- Email/mobile number
- Password/security
- Account settings

## 10.2 Business Information

The owner should be able to review or edit applicable business information.

Possible sections:

- Business name
- Business category
- Business description
- Contact information
- Operating hours
- Business address
- Business media

## 10.3 Business Media

Manage uploaded business media:

- Logo
- Exterior/storefront photo
- Interior photo
- Other approved business images

## 10.4 Products and Services

Manage:

- Products
- Services
- Product/service images
- Descriptions
- Prices or price ranges
- Bestseller designation

## 10.5 Verification Documents

Allow the owner to view the submitted verification documents and verification status.

Example:

```text
Business Verification

✓ DTI Certificate
✓ BIR Certificate
✓ Mayor's Permit
✓ Government ID

Status: VERIFIED
```

## 10.6 Location

Show the confirmed business location and the fixed 100-meter geofence.

The business pin may be adjusted when the system permits location correction, but the geofence radius remains fixed at 100 meters.

---

# 11. MSME-Side Feature Relationship

The main pages should work together as one workflow:

```text
HOME
  │
  ├── Business Overview
  ├── Products/Services
  ├── Bestsellers
  ├── Active Promotions
  └── Reviews
        │
        ▼
PROMO STUDIO
        │
        └── Create/Manage Promotions
                    │
                    ▼
             GEOFENCE SYSTEM
             Fixed 100 meters
                    │
                    ▼
              BUSINESS PULSE
                    │
             ├── Geofence Status
             ├── Promotion Activity
             ├── Views
             ├── Notifications
             └── Other available metrics

ACCOUNT
  │
  ├── Personal Information
  ├── Business Information
  ├── Business Media
  ├── Products/Services
  ├── Verification Documents
  └── Settings
```

---

# 12. MSME-Side Core Concept

The MSME application should follow this general concept:

```text
VERIFY THE BUSINESS
        ↓
CONFIRM THE LOCATION
        ↓
ESTABLISH 100-METER GEOFENCE
        ↓
PRESENT BUSINESS INFORMATION
        ↓
CREATE DIGITAL PROMOTIONS
        ↓
REACH ELIGIBLE USERS NEAR THE BUSINESS
        ↓
MONITOR BUSINESS/ PROMOTION ACTIVITY
```

The core value of the MSME side is to provide a simple workflow for a legitimate business to establish its online presence, create promotions, use the fixed 100-meter location-based promotion area, and monitor available application activity.

---

# 13. Current Development Scope

The current development should focus only on the MSME side.

### Included

- Personal account registration
- Business registration
- Business verification document upload
- Verification status
- Business profile information
- Business logo
- Exterior/storefront image
- Optional interior image
- Products/services
- Bestseller designation
- Promotions
- Business location pin
- Fixed 100-meter geofence
- Home/Dashboard
- Promo Studio
- Business Pulse
- Account page
- Review placeholder / review summary interface

### Out of Scope for This Stage

- Public/tourist-facing pages
- Public search and filtering
- Public map discovery
- Public user account workflow
- Public user reviews submission flow
- Other features not defined in this document

Do not add major features outside this scope unless they are explicitly approved as part of the project.

---

# 14. UI/UX Direction

The application should be designed for MSME owners who may have limited technical or digital-marketing experience.

The interface should therefore prioritize:

- Simple navigation
- Clear labels
- Readable information
- Minimal unnecessary steps
- Clear status indicators
- Simple promotion creation
- Clear map/location confirmation
- Easy access to business information

The application should not overload the Home/Dashboard with every management function. Each major function should remain within its appropriate page.

Primary navigation:

```text
[ Home ] [ Promo Studio ] [ Business Pulse ] [ Account ]
```

---

# 15. Important Scope Rules for Development

1. The geofence radius is **fixed at 100 meters**.
2. The MSME can adjust the **business location pin**, not the geofence radius.
3. Geofence and analytics are combined under **Business Pulse**.
4. The main MSME pages are **Home, Promo Studio, Business Pulse, and Account**.
5. Business information displayed on Home should come from the information already submitted by the MSME.
6. Reviews should show a clear **"No reviews yet"** state when there are currently no reviews.
7. The public/tourist side is not part of the current development scope.
8. Do not invent additional major workflows, pages, metrics, or business rules that are not specified here.

# 16. Target MSME Navigation Summary

```text
┌─────────────────────────────────────┐
│             MSME APP                │
├─────────────────────────────────────┤
│                                     │
│  HOME                               │
│  • Business overview                │
│  • Profile completion               │
│  • Products/services summary        │
│  • Bestsellers                      │
│  • Active promotions                │
│  • Reviews                          │
│                                     │
│  PROMO STUDIO                       │
│  • Create promotions                │
│  • Active promotions                │
│  • Drafts                           │
│  • Expired promotions               │
│                                     │
│  BUSINESS PULSE                     │
│  • Geofence status                  │
│  • 100-meter coverage               │
│  • Promotion activity               │
│  • Business analytics               │
│                                     │
│  ACCOUNT                            │
│  • Personal information             │
│  • Business information             │
│  • Business media                   │
│  • Products/services                │
│  • Verification documents           │
│  • Location and settings            │
│                                     │
└─────────────────────────────────────┘
```
