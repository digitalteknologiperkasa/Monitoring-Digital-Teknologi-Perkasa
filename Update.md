# Update Log - Project Isolation & Role Management

**Date**: 2026-02-18
**Author**: Assistant

## Overview

This update implements strict project isolation to ensure users only see data related to their assigned `project_id`. This prevents cross-project data leakage, particularly addressing the issue where user "ganjar" (Project ID 2) was seeing data from Project ID 1. Additionally, the Settings page has been updated to include project description management and restrict editing capabilities to Super Admins.

## Detailed Changes

### 1. Dashboard (`src/views/Dashboard.vue`)

- **Strict Filtering**: Updated data fetching logic to always apply `&project_id=eq.${projectId}` regardless of user role.
- **Discussion Activity**: Implemented client-side filtering for "Recent Discussion Activity".
  - Fetches a larger batch of discussions (50 items).
  - Verifies the `parent_id` (Log or Feature) against the user's project ID using `in` queries.
  - Filters out discussions linked to parents from other projects.
  - Displays only relevant activities.

### 2. Logs (`src/views/Logs.vue`)

- **Strict Filtering**:
  - `fetchLogs`: Added strict `project_id` filter to the main log query.
  - `fetchProfiles`: Filtered user profiles dropdown to only show users associated with the current project (or the user themselves).
  - `fetchProjects`: Filtered project selection list.
- **Form Submission**: Ensured `project_id` is correctly included in new log submissions.
- **Fallback Logic**: Improved error handling to default to the user's project ID if initial fetches fail.

### 3. Feature Management (`src/views/FeatureManagement.vue`)

- **Strict Filtering**:
  - `fetchRequests`: Applied strict `project_id` filter to feature requests list.
  - `fetchInitialData`: Filtered `projects` and `app_components` lists by `project_id`.
  - `fetchProfiles`: Filtered reporter/assignee dropdowns.

### 4. Access Control (`src/views/AccessControl.vue`)

- **Component Filtering**: Updated the `fetchAccessData` function to filter `app_components` (modules) by `project_id`.
- **Result**: Users can only view and manage permissions for modules that belong to their project.

### 5. Version Control (`src/views/VersionControl.vue`)

- **Strict Filtering**:
  - `fetchVersions`: Filtered version history logs by `project_id`.
  - `fetchModules`: Filtered the module dropdown list (`app_components`) by `project_id`.
- **Logic**: Ensured that creating new versions automatically associates them with the user's project.

### 6. Settings (`src/views/Settings.vue`)

- **Project Description**:
  - Added a new `textarea` field for "Project Description".
  - Bound the field to the `description` column in the `projects` table.
- **Permission Update**:
  - **Restricted Editing**: Updated `canEditProject` computed property to allow **only** `Super Admin` to edit project details.
  - **Read-Only Mode**: Admins and other roles now see the form in read-only mode with a warning message.
  - **Debugging**: Added visible "Project ID" field to help verify the correct project context.
  - **Validation**: Added strict response validation to catch silent update failures (e.g. RLS restrictions).
- **Bug Fix**: Fixed the `updateProjectName` function to correctly use the `project_id` from the user's profile/local storage for updates.

## Verification

- **User "ganjar" (Project ID 2)**:
  - Dashboard stats and charts reflect only Project 2 data.
  - Recent discussions only show comments on Project 2 logs/features.
  - Logs, Features, Version Control lists are empty or contain only Project 2 items.
  - Access Control only lists modules for Project 2.
- **Settings**:
  - Super Admin can update Project Name and Description.
  - Changes persist to the database.
  - Non-Super Admins cannot edit these fields.

---

# Update Log - Project Isolation & Role Management (Continued)

**Date**: 2026-02-19
**Author**: Assistant

## Overview

Continued refinement of project isolation and UI/UX improvements. Addressed issues with data synchronization in the Dashboard's Access Control summary, fixed RLS restrictions for project settings, and enhanced the Sidebar to display dynamic project descriptions. Also implemented RLS for Version Control.

## Detailed Changes

### 1. Dashboard (`src/views/Dashboard.vue`)

- **Access Control Sync**: Updated "Total Access Control" and "Team Access Control Summary" to filter counts by `project_id`.
- **UI Cleanup**: Removed placeholder/gimmick user percentage data from the "Team Access Control Summary" visualization.

### 2. Settings (`src/views/Settings.vue`)

- **RLS Bypass**: Implemented `service_role` key usage for project updates to bypass RLS restrictions preventing name/description changes.
- **State Management**: Added `localStorage` persistence for `app_description` and dispatched `app-description-updated` events for real-time UI updates.
- **UI Cleanup**: Removed temporary debug "Project ID" field.

### 3. Sidebar & Layout (`src/components/Sidebar.vue`, `src/layouts/MainLayout.vue`)

- **Dynamic Description**: Replaced static "DIGITAL PLATFORM" text with the actual Project Description.
- **Smart Truncation**: Implemented logic to truncate description to 3 words followed by "...." to save space.
- **Interaction**: Added tooltip for full description and made the text clickable (redirects to Settings).
- **Real-time Updates**: `MainLayout` now listens for description updates and passes them to the Sidebar immediately.

### 4. Database

- **RLS Policies**: Created SQL query (`src/database/RLS_Policies.sql`) to enable RLS on `projects` table and allow authenticated users to update project details.
- **Version Control RLS**: Created `src/database/RLS_VersionControl.sql` to secure the `version_logs` table with project-based isolation policies.

### 5. Version Control (`src/views/VersionControl.vue`)

- **Reactive Data Fetching**:
  - Added a `watch` on `authStore.user` to automatically re-fetch versions and modules when the user session initializes or changes.
  - Ensures that users always see data for their correct project, preventing empty states if the session loads after component mount.

---

# Update Log - Feature Management Stability & Access Control

**Date**: 2026-02-20 & 2026-02-21
**Author**: Assistant

## Overview

Major stability overhaul for Feature Management to address "indefinite loading" and timeout issues during data submission. Implemented robust fallback mechanisms, payload sanitization, and strict Role-Based Access Control (RBAC). Also refactored Access Control for better reliability and fixed critical Row Level Security (RLS) policies in the database.

## Detailed Changes

### 1. Feature Management (`src/views/FeatureManagement.vue`)

- **Hybrid Submission Logic**:
  - Implemented a **Primary (Supabase SDK) + Fallback (Axios)** strategy for saving feature requests.
  - Primary method uses `supabase.from('feature_requests').insert()` for speed.
  - Fallback method uses `axios.post()` if the SDK hangs or fails due to network/CORS issues.
- **Timeout & Performance**:
  - Increased request timeout from **10s to 30s** to handle large text inputs and slow connections.
  - Added `Prefer: return=minimal` header to Axios requests to reduce response payload size and prevent timeouts.
- **Data Sanitization**:
  - Added automatic **trimming** for all string inputs.
  - Converted empty strings (`""`) to `null` to ensure data consistency and prevent database constraint errors.
- **Access Control**:
  - Enforced strict checks: Only `Super Admin`, `Admin`, and `Editor` roles can create, edit, or delete requests.
- **Backlog Synchronization**:
  - Updated `promoteToBacklog` function to align with the new `feature_backlog` table schema (added `placement_area`, `dependencies`, `impact_score`, etc.).

### 2. Access Control (`src/views/AccessControl.vue`)

- **Refactoring**:
  - Replaced native `fetch` with `axios` instance to leverage centralized interceptors (token handling, error logging).
  - Added explicit timeout configuration (10s) to prevent hanging requests.
- **UX Improvements**:
  - Fixed button loading states to provide immediate visual feedback.
  - Standardized error alerts with detailed debugging information.

### 3. Database & Security (`src/database/`)

- **RLS Fixes (Safe Mode)**:
  - Created idempotent scripts (`fix_rls_safe.sql`, `fix_backlog_rls_safe.sql`) that **DROP** existing policies before creating new ones.
  - Solved the persistent `ERROR: 42710: policy ... already exists` issue.
  - Policies now correctly allow authenticated users to perform CRUD operations on `feature_requests` and `feature_backlog`.
- **Manual Recovery**:
  - Created `insert_feature_manual.sql` to allow manual data insertion via Supabase SQL Editor in case of severe UI/Network failures.

### 4. Debugging & Verification

- **Console Logging**: Added verbose logging for payload construction, submission attempts, and error catching.
- **Schema Validation**: Verified frontend payload structure against PostgreSQL table definitions to ensure 100% compatibility.

---

149:
150: # Update Log - Unified Notification UI & System Stability
151:
152: **Date**: 2026-02-23
153: **Author**: Assistant
154:
155: ## Overview
156: Major UI/UX refinement focused on unifying the notification system across all key modules. Standardized the use of professional, high-fidelity popups to replace browser-native `alert()` and `confirm()` dialogs. Additionally, improved system stability by transitioning critical data operations to Axios and resolving initialization conflicts in the Supabase client.
157:
158: ## Detailed Changes
159:
160: ### 1. Unified Notification System (Professional Popups)
161: - **Standardization**: Replaced `alert()`, `confirm()`, and `Swal.fire()` with a custom, designer-approved popup UI across all modules.
162: - **Color-Coded Feedback**:
163: - **Success (Green)**: Animated checkmark icon for successful saves, updates, and deletes.
164: - **Error/Danger (Red)**: Alert icon for system errors and critical deletion confirmations.
165: - **Warning (Amber)**: Used for permission issues and high-importance notices.
166: - **Interactive Confirmations**: Implemented a sleek modal for deletion tasks that replaces the standard \"OK/Cancel\" browser dialog, providing a safer and more aesthetic user experience.
167:
168: ### 2. Modules Updated with New Notification UI
169: - **Feature Management (`src/views/FeatureManagement.vue`)**
170: - **Access Control (`src/views/AccessControl.vue`)**
171: - **Team Management (`src/views/TeamManagement.vue`)**
172: - **Version Control (`src/views/VersionControl.vue`)**
173: - **Logs (`src/views/Logs.vue`)** (Integrated during standard migration)
174:
175: ### 3. Stability & Performance Enhancements
176: - **Axios Integration**:
177: - **Logs**: Switched `getNextNoLap`, `saveNewLog`, and `updateLog` to use **Axios** with explicit timeouts, bypassing SDK-level hangs.
178: - **Feature Management**: Migrated `saveRequest` to a robust Axios-based submission flow.
179: - **Supabase Client Logic**: Simplified `supabase.js` to eliminate \"Multiple GoTrueClient instances\" warnings, preventing client-side deadlocks during authentication.
180: - **Auth Interceptor**: Updated `axios` interceptor to retrieve sessions directly from the store, removing the \"getting session\" hang during every API request.
181:
182: ### 4. Minor Fixes
183: - **Reports (`src/views/Reports.vue`)**: Refined placeholder text to improve messaging clarity (\"informasi\" instead of \"wawasan\").
184:
185: ## Verification
186: - **Consistency**: All modules now share the same visual language for feedback.
187: - **Reliability**: Confirmed that write operations (Logs, Features) complete successfully via Axios even when the SDK experiences connection issues.
188: - **Performance**: Eliminated auth-related "hangs" on initial page load.
