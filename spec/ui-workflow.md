# PromptHub UI Workflow

## Home / Discover

**Path**: `lib/src/ui/home`

### 1. Description

Goal: Let users browse community prompts.

Features:

- Browse prompt feed by visual categories.
- Pull to refresh.
- Infinite scroll.
- Open prompt preview.
- Open Profile from the header.
- Create a prompt from the floating action button.

### 2. UI Structure

- Screen: `HomePage`
- Components: Discover header, profile icon button, horizontal category chips, two-column prompt grid, prompt preview modal, floating create button

### 3. User Flow & Logic

1. `SplashPage` ensures anonymous auth and runs seed if needed.
2. `HomeBloc.loadInitial()` fetches the first page from `PromptRepository`.
3. Category chips update local selected UI state. Category-backed filtering is not enabled because the current `prompts` table has no `category` column.
4. Scrolling near the bottom calls `HomeBloc.loadMore()`.
5. Tapping a prompt opens the prompt preview modal with copy/share actions.
6. Tapping the profile icon opens `ProfilePage`.
7. Tapping the floating plus button opens `CreatePromptPage`.

### 4. Key Dependencies

- `PromptRepository`
- `HomeBloc`
- `PromptImageView`
- `PromptPreviewModal`

## Prompt Detail

**Path**: `lib/src/ui/prompt_detail`

### 1. Description

Goal: Let users inspect, copy, share, and edit a prompt when they own it.

### 2. UI Structure

- Screen: `PromptDetailPage`
- Components: large preview image, prompt card, platform chip, copy button, share button, owner edit action

### 3. User Flow & Logic

1. Page receives prompt id from `Get.arguments`.
2. `PromptDetailBloc.loadPrompt()` loads prompt data.
3. Owner state is derived from `AuthRepository.currentUserId`.
4. Copy writes prompt text to clipboard.
5. Share uses `share_plus` with the stored `share_url`.
6. Owner edit opens `EditPromptPage`.

### 4. Key Dependencies

- `PromptRepository`
- `AuthRepository`
- `PromptDetailBloc`
- `share_plus`

## Create Prompt

**Path**: `lib/src/ui/create_prompt`

### 1. Description

Goal: Let users publish a new prompt with a preview image.

### 2. UI Structure

- Screen: `CreatePromptPage`
- Components: custom top bar, dashed image picker, prompt textarea, optional category chips, publish button

### 3. User Flow & Logic

1. User picks an image from gallery.
2. User enters prompt text.
3. User optionally selects one or more categories. `All` clears selected categories.
4. `CreatePromptBloc.submit()` validates image + prompt, derives the stored title from the prompt, and maps selected categories into the existing prompt metadata field.
5. `PromptRepository.createPrompt()` uploads the image, creates AppsFlyer OneLink share URL when configured, and inserts the row.
6. App opens Prompt Detail after success.

### 4. Key Dependencies

- `CreatePromptBloc`
- `PromptRepository`
- `StorageRepository`
- `ImagePicker`

### 5. Notes & Known Issues

- Category selection currently reuses the existing `platform` field because the current `prompts` table has no dedicated `category` column.

## Profile

**Path**: `lib/src/ui/profile`

### 1. Description

Goal: Let users view their profile summary and manage their own prompts.

### 2. UI Structure

- Screen: `ProfilePage`
- Components: gradient profile header, settings button, post/saved stats, Posts/Saved tabs, empty state, prompt card list, row action menu

### 3. User Flow & Logic

1. `ProfileBloc.loadProfile()` ensures anonymous session and fetches prompts by user id.
2. Posts tab shows the user's prompt cards; empty Posts shows a create prompt call-to-action.
3. Saved tab is available in the UI and currently shows an empty state until saved prompt data is wired.
4. Tapping a prompt card opens Prompt Detail.
5. Edit opens `EditPromptPage`.
6. Delete asks for confirmation, deletes through `PromptRepository`, then reloads profile.
7. Tapping the settings button opens `SettingsPage`.

### 4. Key Dependencies

- `ProfileBloc`
- `PromptRepository`
- `AuthRepository`

## Settings

**Path**: `lib/src/ui/settings`

### 1. Description

Goal: Let users access app-level settings and account actions.

### 2. UI Structure

- Screen: `SettingsPage`
- Components: centered title header with back button, policy/terms menu card, language card, delete data danger card, app version label

### 3. User Flow & Logic

1. User opens Settings from the Profile header.
2. Back button pops to the previous page.
3. Privacy Policy, Terms of Use, Language, and Delete Data are represented as settings rows. Action behavior is not wired yet.

### 4. Key Dependencies

- `AppPages`
- `ProfileHeaderCard`
- GetX navigation

## Edit Prompt

**Path**: `lib/src/ui/edit_prompt`

### 1. Description

Goal: Let owners update or delete an existing prompt.

### 2. UI Structure

- Screen: `EditPromptPage`
- Components: image preview/change, title field, prompt textarea, platform dropdown, save action, delete button

### 3. User Flow & Logic

1. Page receives prompt id from `Get.arguments`.
2. `EditPromptBloc.loadPrompt()` pre-fills the form.
3. Save updates text fields and optionally replaces image in Supabase Storage.
4. Delete asks for confirmation and removes prompt plus stored image.
5. Page pops with `true` so previous screens can refresh.

### 4. Key Dependencies

- `EditPromptBloc`
- `PromptRepository`
- `StorageRepository`

## Sharing And Deep Links

**Path**: `lib/src/core/repository/share_link_repository.dart`

### 1. Description

Goal: Provide a share URL for prompts and parse links back into prompt ids.

### 2. Current Behavior

- Prompt creation uses AppsFlyer OneLink config from `.env` to create share URLs.
- SDK invite-link generation is attempted first on iOS/Android.
- If SDK generation is unavailable, the app creates a OneLink URL with `deep_link_value=prompt_detail` and `deep_link_sub1={prompt_id}`.
- If OneLink config is missing, the app falls back to `prompthub://prompt/{prompt_id}`.
- `MainPage` listens to native app links and AppsFlyer Unified Deep Linking callbacks, then opens Prompt Detail.

### 3. Native Requirements

- Android manifest handles `prompthub://prompt/...` and `https://prompthub.onelink.me/ptgB`.
- iOS uses `Runner.entitlements` with `applinks:prompthub.onelink.me`.
- AppsFlyer dashboard must keep the same OneLink template and app bundle/package values.
