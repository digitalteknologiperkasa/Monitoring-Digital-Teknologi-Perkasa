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
