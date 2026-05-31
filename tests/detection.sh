#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

assert_output() {
  local fixture="$1"
  local expected="$2"
  local actual

  actual="$("$repo_root/bin/cmuxws" "$fixture" --print)"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected:\n%s\n\nActual:\n%s\n' "$expected" "$actual" >&2
    exit 1
  fi
}

explicit="$tmp_root/explicit"
mkdir -p "$explicit/.cmux"
cat > "$explicit/.cmux/features.txt" <<'EOF'
Dashboard
Pipeline
Settings
EOF
assert_output "$explicit" $'Dashboard\nPipeline\nSettings'

expo_tabs="$tmp_root/expo-tabs"
mkdir -p "$expo_tabs/app/(tabs)"
cat > "$expo_tabs/app/(tabs)/_layout.tsx" <<'EOF'
export default function Layout() {
  return (
    <>
      <Tabs.Screen name="index" options={{ title: 'Dashboard' }} />
      <Tabs.Screen name="contacts" options={{ title: 'Contacts' }} />
    </>
  )
}
EOF
assert_output "$expo_tabs" $'Dashboard\nContacts'

custom_nav="$tmp_root/custom-nav"
mkdir -p "$custom_nav/components/ui"
cat > "$custom_nav/components/ui/app-navigation.tsx" <<'EOF'
const NAV_ITEMS = [
  { label: 'Dashboard', href: '/' },
  { label: 'Source Records', href: '/cases' },
  { label: 'Settings', href: '/settings' },
]
EOF
assert_output "$custom_nav" $'Dashboard\nSource Records\nSettings'

routes="$tmp_root/routes"
mkdir -p "$routes/app/(tabs)"
touch "$routes/app/(tabs)/index.tsx"
touch "$routes/app/(tabs)/clients.tsx"
touch "$routes/app/(tabs)/settings.tsx"
assert_output "$routes" $'Dashboard\nClients\nSettings'

features="$tmp_root/features"
mkdir -p "$features/src/features/pipeline" "$features/src/features/user-settings"
assert_output "$features" $'Pipeline\nUser Settings'

dry_run_order="$tmp_root/dry-run-order"
mkdir -p "$dry_run_order/.cmux"
cat > "$dry_run_order/.cmux/features.txt" <<'EOF'
Dashboard
Companies
Contacts
EOF
dry_run_actual="$("$repo_root/bin/cmuxws" "$dry_run_order" --dry-run --no-agent 2>&1 >/dev/null | sed -n 's/.*--name \([^ ]*\).*/\1/p')"
assert_output_text=$'Contacts\nCompanies\nDashboard'
if [[ "$dry_run_actual" != "$assert_output_text" ]]; then
  printf 'Expected dry-run creation order:\n%s\n\nActual:\n%s\n' "$assert_output_text" "$dry_run_actual" >&2
  exit 1
fi
