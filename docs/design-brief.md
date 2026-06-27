# Design Brief — "Service Request Tracking" Mobile App

You are designing a complete mobile UI kit for a **healthcare service-request tracking app**. Produce a cohesive, production-ready design: a **design system page**, a **component library**, and **all app screens with their state variants**. Optimize for clean, well-named layers so the result can be exported to Figma.

---

## 1. Product context

A healthcare company helps people access quality care. This app lets users **track and manage service requests** ("solicitações") — e.g. scheduling appointments, requesting exams, medication, billing questions, and general support. Users log in, browse a paginated list of their requests filtered by status, open a request to see details and change its status, and create new requests with a validated form. An AI assistant can suggest a category and a summary from the description the user types.

The app is **offline-first**: it stays fully usable with no connection. Requests are cached locally and any change the user makes is applied instantly and synced later. The UI must therefore communicate **sync state** clearly (a change can be "pending sync", "synced", or "failed").

Platform: **mobile** (iOS + Android, single Flutter codebase). Design at **390 × 844 px** frames with standard safe areas. Tone: modern, clean, trustworthy, calm, healthcare-appropriate — generous whitespace, soft rounded shapes, friendly but professional. All copy in **Brazilian Portuguese (pt-BR)**; component/layer names in English.

---

## 2. What to deliver

1. **Design system page** — color tokens, typography scale, spacing, radius, elevation, iconography.
2. **Component library** — every reusable component listed in section 5, each with its interactive states.
3. **Screens** — the 5 screens in section 6, each with all listed state variants as separate frames.
4. **Whitelabel demonstration** — show the primary brand (Brand A) fully, plus a small swatch/preview of a second brand (Brand B) to prove the system is token-driven (see section 4.5).

---

## 3. Art direction

- Flat and clean. White surfaces, soft shadows, thin borders. No heavy gradients, no skeuomorphism.
- Rounded geometry: pill-shaped chips, 12–16 px radius on cards/inputs/buttons.
- Color used with intent: purple is the brand/action color, green is the positive/secondary accent. Status colors carry meaning, never decoration.
- Accessible by default: text on colored fills must meet WCAG AA. Use **tinted backgrounds + dark same-family text** for chips and badges (do not put white text on the bright `#10B981` at small sizes).
- Generous touch targets (min 44 px height for tappable controls).

---

## 4. Design system

### 4.1 Color tokens

Define these as **semantic tokens** (not literal color names) so they can be themed per brand.

Brand (Brand A):
- `primary` `#8D47D6` (purple)
- `primaryDark` `#6D28B5` (text on light, pressed states)
- `onPrimary` `#FFFFFF`
- `secondary` `#10B981` (emerald)
- `secondaryDark` `#059669`
- `onSecondary` `#FFFFFF`

Semantic:
- `success` `#10B981`
- `warning` `#F59E0B`
- `error` `#EF4444`
- `info` `#3B82F6`

Neutrals:
- `background` `#F6F5F8` (app background, subtly purple-tinted)
- `surface` `#FFFFFF` (cards, sheets)
- `border` `#E7E5ED`
- `textPrimary` `#1C1B2E`
- `textSecondary` `#6B6880`
- `textTertiary` `#9B98AD`
- `disabled` `#C7C4D4`

Status of a request → chip color (tinted bg + dark text):
- `open` → info: bg `#DBEAFE`, text `#1E40AF`
- `inProgress` → primary: bg `#F1E6FB`, text `#6D28B5`
- `resolved` → success: bg `#D1FAE5`, text `#065F46`
- `cancelled` → neutral: bg `#ECEAF1`, text `#5B5870`

Sync badge (small pill, leading icon):
- `pending` → bg `#FEF3C7`, text `#92400E`, cloud-upload icon
- `failed` → bg `#FEE2E2`, text `#991B1B`, alert icon
- `synced` → no badge, or a subtle green check `#10B981`

Priority indicator (dot + label):
- `low` → neutral gray · `medium` → amber `#F59E0B` · `high` → error `#EF4444`

### 4.2 Typography — Montserrat

Use **Montserrat** everywhere. Weights: Regular 400, Medium 500, SemiBold 600, Bold 700.

| Style | Size / Weight | Use |
|---|---|---|
| Display | 30 / Bold | Splash, large headers |
| H1 | 24 / SemiBold | Screen titles |
| H2 | 20 / SemiBold | Section headers |
| Title | 17 / SemiBold | Card titles, list item titles |
| Body L | 16 / Regular | Primary body text, inputs |
| Body | 14 / Regular | Secondary text, descriptions |
| Label / Button | 14 / SemiBold | Buttons, chips, tabs |
| Caption | 12 / Medium | Timestamps, helper text, badges |

Line height ~1.4–1.5. Sentence case for all UI copy.

### 4.3 Spacing, radius, elevation

- Spacing scale (px): 4, 8, 12, 16, 20, 24, 32. Screen horizontal padding: 20.
- Radius: inputs/buttons 12, cards 16, chips/pills 999 (full), bottom sheets 20 (top corners).
- Elevation: keep flat. Cards = `surface` + 0.5 px `border` + very soft shadow (`0 1px 2px rgba(28,27,46,0.06)`). Bottom sheets / FAB get a slightly stronger but still subtle shadow.

### 4.4 Iconography

Outline-style icons, 1.5–2 px stroke, 20–24 px (Lucide / Tabler outline family). Consistent line weight throughout. Category icons: appointment (calendar), exam (clipboard/heart-rate), medication (pill), billing (receipt/credit-card), general (help-circle).

### 4.5 Whitelabel / theming

The whole system must be **token-driven** so a brand can be swapped by changing token values + logo only. Design Brand A fully (purple `#8D47D6` + emerald `#10B981`). Then show a compact **Brand B** preview that swaps `primary`/`secondary` to a different harmonious pair (e.g. teal `#0EA5A4` + coral `#F97316`) with a different logo, reusing the exact same layouts and components. The point is to prove layouts never hardcode brand colors.

---

## 5. Component library

Design each with all relevant states (default, hover/pressed, focused, disabled, error):

- **Buttons**: primary (filled `primary`, white text), secondary (outline `secondary`), text/ghost, destructive, icon button. Loading state with spinner. Full-width and inline.
- **Text input**: label, placeholder, value, helper text, error state (red border + message), focused (purple ring), disabled. Variants: single-line, multiline textarea, password (with show/hide), search field.
- **Select / dropdown**: for category and status, with selected and open states.
- **Filter bar**: horizontally scrollable row of status filter chips (All, Open, In progress, Resolved, Cancelled); selected vs unselected states.
- **Chips**: status chip, category chip, filter chip.
- **Badges**: sync badge (pending/failed/synced), priority dot.
- **Request card** (list item): title, category + priority line, status chip, timestamp, sync badge. Show normal, pending-sync, and failed-sync variants.
- **App bar**: brand logo (left), screen title, user avatar/menu (right). Optional offline indicator.
- **Offline banner**: slim banner under the app bar ("Você está offline — alterações serão sincronizadas") with subtle warning styling.
- **Sync status indicator**: small inline element showing "Sincronizando…" with spinner and "X pendentes".
- **FAB / primary CTA**: "Nova solicitação".
- **Bottom sheet**: used for status change and confirmations.
- **Snackbar / toast**: success, error, info.
- **Empty state**: friendly illustration + title + supporting text + action button.
- **Error state**: illustration + message + retry button.
- **Loading skeletons**: for list cards and detail screen.
- **Pull-to-refresh indicator** and **pagination footer loader**.
- **AI suggestion control**: a "Sugerir com IA" button/affordance attached to the description field, plus loading and applied states.

---

## 6. Screens (with states & flows)

Design each screen as its own frame(s). For multi-state screens, create one frame per state.

### 6.1 Splash / boot
Brand logo centered on `background`, subtle loading indicator. Purpose: while the app checks for a stored session. States: `loading`. Transitions to Login (no session) or Requests list (valid session).

### 6.2 Login
Brand logo, email field, password field (show/hide), primary button "Entrar". Small helper/footer.
States:
- `idle` — empty/clean form.
- `submitting` — button shows spinner, fields disabled.
- `invalidCredentials` — error message under the form ("E-mail ou senha inválidos").
- `offline` — info/warning message ("Sem conexão. O login precisa de internet.").
Flow: successful login → Requests list.

### 6.3 Requests list (Home) — the main screen
App bar (logo + title "Minhas solicitações" + avatar). Offline banner when applicable. Filter bar (status chips). Scrollable list of **request cards**. FAB "Nova solicitação". Pull-to-refresh. Pagination footer loader on scroll.
States (separate frames):
- `loading` — skeleton cards.
- `loaded` — list of cards; some cards show a pending/failed sync badge.
- `empty` — empty state ("Nenhuma solicitação ainda") + CTA to create one.
- `error` — error state with retry (only when no cache available).
- `offline` — loaded list + offline banner + cached data.
- `syncing` — list + a "Sincronizando… 2 pendentes" indicator.
- `loadingMore` — list with pagination footer spinner.
- `filtered` — filter chip selected (e.g. "In progress" active) showing filtered results.
Flow: tap card → Detail; tap FAB → Create; pull down → push pending queue then refresh page 1.

### 6.4 Request detail
Header with title and current status chip. Body: description, category, priority, created/updated timestamps, requester. A **"Alterar status"** control (opens a bottom sheet with the 4 status options). Sync badge if the item is pending/failed.
States:
- `loaded` — full detail.
- `changingStatus` — bottom sheet open with options.
- `updating` — optimistic update applied, item marked pending.
- `updateFailed` — failed sync indicator + "Tentar novamente".
- `offline` — status change queued, pending badge, offline banner.
Flow: change status → UI updates immediately (optimistic) → badge shows pending until synced.

### 6.5 Create request
Form: title (single-line), description (multiline textarea) with an attached **"Sugerir com IA"** affordance, category (select), priority (segmented or select). Primary button "Criar solicitação".
States:
- `empty` — clean form.
- `validationErrors` — inline errors (title required, description min length, category required).
- `aiSuggesting` — AI control in loading state ("Gerando sugestão…").
- `aiApplied` — category + a generated summary filled in, editable, with a subtle "Sugerido por IA" hint.
- `aiError` — AI suggestion failed, non-blocking message.
- `submitting` — button spinner.
- `success` — confirmation (snackbar) then return to list with the new item visible (carrying a pending sync badge).
- `offline` — submit still succeeds optimistically; new item appears as pending.

---

## 7. Key flows to keep visually consistent

1. **Auth**: Splash → (no session) Login → success → Requests list.
2. **Browse & filter**: Requests list, tap a status chip to filter reactively, scroll to paginate, pull to refresh.
3. **Create (optimistic)**: List → FAB → Create form → "Sugerir com IA" fills category/summary → submit → back to list with the new request showing a **pending sync** badge.
4. **Update status (optimistic)**: List → Detail → Alterar status (bottom sheet) → status updates instantly with a pending badge.
5. **Offline → reconnect**: Offline banner visible, changes show pending badges → on reconnect, a "Sincronizando…" indicator appears and badges flip to synced (badge disappears / brief green check).

---

## 8. Global states checklist

Every data-bearing screen must visibly handle: **loading**, **loaded**, **empty**, **error/retry**, **offline**, and **syncing/pending**. Make these distinct and reassuring — offline and pending are normal, expected states here, not failures.

---

## 9. Output & export notes

- Use consistent, English layer/component names (e.g. `RequestCard`, `StatusChip`, `SyncBadge`, `FilterBar`, `PrimaryButton`, `TextField/Error`).
- Define reusable color and text styles as named tokens/styles (so they map cleanly to Figma styles and to Flutter theme tokens later).
- Keep components as proper reusable components with variants for states, not one-off copies.
- Deliver: design system page → component library → screen frames (grouped by screen, with state variants) → Brand A full + Brand B preview.