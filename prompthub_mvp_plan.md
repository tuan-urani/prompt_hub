# PromptHub MVP Implementation Plan

## 1. Goal

Build the PromptHub MVP as a Flutter mobile app where users can discover, copy, share, create, edit, and delete AI image prompts.

Current scope excludes Firebase Analytics and Firebase Crashlytics.

## 2. MVP Scope

### Included

- Anonymous login with Supabase Auth
- Prompt feed with search, pull to refresh, and infinite scroll
- Prompt detail screen
- Copy prompt to clipboard
- Share prompt link
- Create prompt with uploaded preview image
- Profile screen with user's own prompts
- Edit prompt
- Delete prompt
- Supabase database
- Supabase Storage
- AppsFlyer OneLink short links and deep link handling

### Excluded For Now

- Firebase Analytics
- Firebase Crashlytics
- Paid accounts
- Prompt likes/comments
- Public user profiles
- Moderation dashboard
- Push notifications

## 3. Target Screens

### Home / Discover

Purpose: Let users explore prompts from the community.

Main UI:

- Discover title
- Search bar
- Filter/settings icon button
- Two-column prompt image grid
- Bottom navigation with Home, Create, Profile

Main actions:

- Search prompts
- Open prompt detail
- Pull to refresh
- Infinite scroll

### Prompt Detail

Purpose: Let users inspect and reuse a prompt.

Main UI:

- Large preview image
- Back button
- More menu
- Prompt text card
- Copy icon
- Platform chip
- Copy Prompt button
- Share Prompt button
- Edit action when current user owns the prompt

Main actions:

- Copy prompt
- Share prompt
- Open edit screen if owner

### Create Prompt

Purpose: Let users publish a new prompt.

Main UI:

- Image upload area
- Title input
- Prompt textarea with character counter
- Platform dropdown
- Publish button

Main actions:

- Pick image
- Remove/change image
- Enter prompt details
- Publish prompt

### Profile

Purpose: Let users manage their own prompts.

Main UI:

- Avatar
- Username
- My Prompts list
- Prompt rows with image, title/prompt preview, platform, and menu

Main actions:

- Open own prompt
- Edit prompt
- Delete prompt

### Edit Prompt

Purpose: Let users update or delete an existing prompt.

Main UI:

- Existing image
- Change image button
- Title input
- Prompt textarea with character counter
- Platform dropdown
- Save button
- Delete Prompt button

Main actions:

- Update prompt data
- Change image
- Save changes
- Delete prompt

## 4. Tech Stack

### Frontend

- Flutter
- GetX for routing
- flutter_bloc for state management
- equatable for events/states
- Existing `lib/src` architecture

### Backend

- Supabase Auth
- Supabase Database
- Supabase Storage

### Sharing

- AppsFlyer OneLink for short links
- AppsFlyer deep link handling to open Prompt Detail
- Development fallback deep link only for local testing before OneLink config is available

## 5. Flutter Dependencies

Add or verify these dependencies in `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
  image_picker: ^1.0.0
  share_plus: ^10.0.0
  appsflyer_sdk: <latest-compatible-version>
```

Clipboard can use Flutter SDK:

```dart
import 'package:flutter/services.dart';
```

No Firebase dependencies are required in the current scope.

## 6. Environment Configuration

Use existing environment files:

- `.env`
- `.env.staging`
- `.env.prod`

Required keys:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
APPSFLYER_DEV_KEY=
APPSFLYER_APP_ID=
APPSFLYER_ONELINK_DOMAIN=
APPSFLYER_ONELINK_TEMPLATE_ID=
```

AppsFlyer OneLink format:

```text
https://{APPSFLYER_ONELINK_DOMAIN}/{APPSFLYER_ONELINK_TEMPLATE_ID}?pid=share&c=prompt_share&deep_link_value=prompt_detail&deep_link_sub1={prompt_id}
```

Example:

```text
https://prompthub.onelink.me/AbCd?pid=share&c=prompt_share&deep_link_value=prompt_detail&deep_link_sub1={prompt_id}
```

Development fallback link format:

```text
prompthub://prompt/{prompt_id}
```

## 7. Database Design

### Table: prompts

```sql
create table public.prompts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  platform text not null,
  prompt text not null,
  image_url text not null,
  share_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### Indexes

```sql
create index prompts_created_at_idx on public.prompts (created_at desc);
create index prompts_user_id_idx on public.prompts (user_id);
create index prompts_platform_idx on public.prompts (platform);
```

### Updated At Trigger

```sql
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger prompts_set_updated_at
before update on public.prompts
for each row
execute function public.set_updated_at();
```

## 8. Supabase Storage

### Bucket

```text
prompt-images
```

### Upload Path

```text
prompts/{user_id}/{prompt_id}.jpg
```

### Storage Rules

- Public read for MVP, or signed URL if stricter access is required later
- Authenticated anonymous users can upload to their own folder
- Prompt owner can replace/delete their own image

## 9. Row Level Security

Enable RLS:

```sql
alter table public.prompts enable row level security;
```

Read policy:

```sql
create policy "Anyone can read prompts"
on public.prompts
for select
using (true);
```

Insert policy:

```sql
create policy "Users can insert own prompts"
on public.prompts
for insert
with check (auth.uid() = user_id);
```

Update policy:

```sql
create policy "Users can update own prompts"
on public.prompts
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

Delete policy:

```sql
create policy "Users can delete own prompts"
on public.prompts
for delete
using (auth.uid() = user_id);
```

## 10. Recommended Folder Structure

```text
lib/src/
  api/
    supabase/
      supabase_prompt_api.dart
      supabase_storage_api.dart
  core/
    model/
      prompt.dart
      platform_type.dart
    repository/
      auth_repository.dart
      prompt_repository.dart
      storage_repository.dart
      share_link_repository.dart
  ui/
    home/
      binding/
      bloc/
      components/
      home_page.dart
    prompt_detail/
      binding/
      bloc/
      components/
      prompt_detail_page.dart
    create_prompt/
      binding/
      bloc/
      components/
      create_prompt_page.dart
    profile/
      binding/
      bloc/
      components/
      profile_page.dart
    edit_prompt/
      binding/
      bloc/
      components/
      edit_prompt_page.dart
    main/
      main_page.dart
    widgets/
```

## 11. Core Models

### Prompt

Fields:

- `id`
- `userId`
- `title`
- `platform`
- `prompt`
- `imageUrl`
- `shareUrl`
- `createdAt`
- `updatedAt`

### PlatformType

Supported values:

- OpenAI
- Gemini
- Midjourney
- Flux
- Stable Diffusion

## 12. Repository Responsibilities

### AuthRepository

- Ensure anonymous session exists
- Return current user id
- Expose auth state if needed

### PromptRepository

- Fetch prompt feed
- Search prompts
- Fetch prompt detail
- Fetch current user's prompts
- Create prompt
- Update prompt
- Delete prompt

### StorageRepository

- Upload prompt image
- Replace prompt image
- Delete prompt image
- Return public image URL

### ShareLinkRepository

- Generate AppsFlyer OneLink short URL
- Attach prompt id to OneLink parameters
- Parse AppsFlyer deep link payload
- Return prompt id from `deep_link_sub1`
- Use local fallback deep link only in development when OneLink config is missing

## 13. BLoC Plan

### HomeBloc

Events:

- `HomeStarted`
- `HomeRefreshed`
- `HomeSearchChanged`
- `HomeLoadMoreRequested`

State:

- `status`
- `prompts`
- `searchQuery`
- `hasMore`
- `isLoadingMore`
- `errorMessage`

### PromptDetailBloc

Events:

- `PromptDetailStarted`
- `PromptDetailCopyRequested`
- `PromptDetailShareRequested`
- `PromptDetailDeleteRequested`

State:

- `status`
- `prompt`
- `isOwner`
- `errorMessage`

### CreatePromptBloc

Events:

- `CreatePromptImagePicked`
- `CreatePromptImageRemoved`
- `CreatePromptTitleChanged`
- `CreatePromptPlatformChanged`
- `CreatePromptBodyChanged`
- `CreatePromptSubmitted`

State:

- `imageFile`
- `title`
- `platform`
- `prompt`
- `isValid`
- `isSubmitting`
- `errorMessage`

### ProfileBloc

Events:

- `ProfileStarted`
- `ProfileRefreshed`
- `ProfilePromptDeleteRequested`

State:

- `status`
- `userId`
- `username`
- `prompts`
- `errorMessage`

### EditPromptBloc

Events:

- `EditPromptStarted`
- `EditPromptImageChanged`
- `EditPromptTitleChanged`
- `EditPromptPlatformChanged`
- `EditPromptBodyChanged`
- `EditPromptSaveRequested`
- `EditPromptDeleteRequested`

State:

- `status`
- `promptId`
- `imageUrl`
- `newImageFile`
- `title`
- `platform`
- `prompt`
- `isValid`
- `isSubmitting`
- `errorMessage`

## 14. Navigation Plan

Use GetX according to the existing project standard.

Root routes in `AppPages`:

- `/splash`
- `/`
- `/prompt-detail`
- `/edit-prompt`

Bottom navigation in `MainPage`:

- Home
- Create
- Profile

Suggested behavior:

- Home, Create, Profile remain under bottom navigation
- Prompt Detail opens full-screen
- Edit Prompt opens full-screen
- Back uses `Navigator.pop(context)`

## 15. Implementation Phases

### Phase 1: Foundation

Tasks:

- Add required dependencies
- Load env variables
- Initialize Supabase
- Ensure anonymous auth on app startup
- Add app theme colors/styles
- Update route definitions

Deliverable:

- App boots with Supabase configured and anonymous user available.

### Phase 2: Database And Storage

Tasks:

- Create `prompts` table
- Add indexes
- Add updated_at trigger
- Enable RLS
- Add read/insert/update/delete policies
- Create `prompt-images` bucket
- Add storage policies

Deliverable:

- Backend supports prompt CRUD and image uploads securely.

### Phase 3: Models And Repositories

Tasks:

- Create `Prompt` model
- Create `PlatformType`
- Create repository interfaces/implementations
- Add Supabase API classes
- Register dependencies in DI

Deliverable:

- UI/BLoC can call repositories without direct Supabase access.

### Phase 4: Main Navigation And Shared UI

Tasks:

- Build bottom navigation
- Create shared prompt card component
- Create platform chip
- Create gradient primary button
- Create image picker component
- Create empty/loading/error states

Deliverable:

- App shell matches the target visual direction.

### Phase 5: Home / Discover

Tasks:

- Build Home UI
- Wire `HomeBloc`
- Implement feed loading
- Implement search
- Implement pull to refresh
- Implement infinite scroll
- Navigate to Prompt Detail

Deliverable:

- Users can browse and search community prompts.

### Phase 6: Prompt Detail

Tasks:

- Build detail UI
- Load prompt by id
- Detect owner
- Copy prompt to clipboard
- Share prompt link
- Show edit action for owner

Deliverable:

- Users can view, copy, and share prompts.

### Phase 7: Create Prompt

Tasks:

- Build create form
- Pick/upload image
- Validate required fields
- Publish prompt
- Generate AppsFlyer OneLink share URL
- Navigate to created prompt detail or profile after success

Deliverable:

- Users can publish new prompts with images.

### Phase 8: Profile

Tasks:

- Build profile header
- Load current user's prompts
- Render prompt list
- Add edit/delete actions
- Refresh after create/edit/delete

Deliverable:

- Users can manage their own prompts.

### Phase 9: Edit Prompt

Tasks:

- Build edit form
- Prefill existing data
- Save changes
- Replace image if changed
- Delete prompt

Deliverable:

- Owners can update or remove their prompts.

### Phase 10: Sharing And Deep Links

Tasks:

- Configure AppsFlyer SDK
- Generate AppsFlyer OneLink share URLs
- Store generated link in `prompts.share_url`
- Parse AppsFlyer deep link callbacks
- Extract prompt id from `deep_link_sub1`
- Open Prompt Detail from incoming link
- Keep local fallback deep link parsing for development only

Deliverable:

- AppsFlyer short links open the correct Prompt Detail when the app is installed, and route users through the configured OneLink flow when the app is not installed.

### Phase 11: Polish

Tasks:

- Match target spacing, colors, typography, and radius
- Improve loading skeletons
- Add empty states
- Add error toasts
- Add image fallback
- Handle keyboard and safe areas
- Test small and large phone screens

Deliverable:

- MVP feels consistent with the target design.

### Phase 12: Testing And QA

Tasks:

- Run `flutter analyze`
- Run `flutter test`
- Add BLoC tests for key state transitions
- Add widget tests for validation and owner-only edit visibility
- Manual QA on iOS/Android simulator

Manual QA checklist:

- Anonymous login works
- Feed loads
- Search works
- Pull refresh works
- Infinite scroll works
- Detail opens
- Copy prompt works
- Share prompt works
- Create prompt works
- Image upload works
- Profile shows own prompts
- Edit prompt works
- Delete prompt works
- Non-owner cannot edit/delete
- Deep link opens correct prompt

### Phase 13: Release Preparation

Tasks:

- Configure Android application id
- Configure iOS bundle id
- Configure Supabase production environment
- Configure AppsFlyer OneLink production settings
- Configure Android intent filters for OneLink/deep links
- Configure iOS Associated Domains for OneLink
- Verify RLS policies
- Build Android release
- Build iOS release

Commands:

```sh
flutter analyze
flutter test
flutter build apk --release
flutter build ios --release
```

Deliverable:

- App is ready for store submission or internal distribution.

## 16. Recommended Build Order

1. Supabase setup and anonymous auth
2. Core models and repositories
3. Bottom navigation and shared UI
4. Home with mock data
5. Detail with mock data
6. Create/Profile/Edit with mock data
7. Replace mock data with Supabase
8. Add image upload
9. Add copy/share
10. Add deep link handling
11. Add tests
12. Polish UI
13. Prepare release builds

## 17. Acceptance Criteria

The MVP is considered complete when:

- Users can anonymously open the app
- Users can browse prompts
- Users can search prompts
- Users can open prompt detail
- Users can copy prompt text
- Users can share prompt link
- Users can create a prompt with image
- Users can see their own prompts in Profile
- Users can edit their own prompts
- Users can delete their own prompts
- Public users cannot edit/delete prompts they do not own
- Supabase RLS protects user-owned data
- App passes `flutter analyze`
- App passes required tests
- Android/iOS release builds can be generated
