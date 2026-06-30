---
name: refresh-kube
description: "Refresh Azure + kube auth so newly-applied RBAC/permissions take effect. Use after granting or changing cluster permissions when kubectl still shows the old access (forbidden, stale token, or a context that hasn't picked up the new role). Re-auths Azure, clears the cached AKS token, re-fetches credentials, selects the env context, and verifies. Optional arg: env (prod|uat|dev|demo)."
---

# Refresh kube — pick up newly-applied permissions

AKS caches the kubelogin token, so a fresh RBAC grant doesn't apply until you re-auth and drop the
cached token. This walks that refresh and confirms the new context is live.

**Argument:** $ARGUMENTS — optional env (`prod` | `uat` | `dev` | `demo`). If omitted, ask which env.

## Steps

1. **Re-auth Azure (interactive — the user runs it).** `az login` opens a browser, so tell the user
   to run it in-session with the `!` prefix:
   ```
   ! az logout && az login
   ```

2. **Clear the cached AKS token.** Stale token is what hides the new permission:
   ```bash
   kubelogin remove-tokens
   ```

3. **Re-fetch credentials.** Lists/refreshes the contexts your user can reach:
   ```bash
   ds k8s get-credentials
   ```

4. **Select the env context.** Read `EXPECTED_CONTEXT` from
   `services/flyway_hacks/ops/envs/<env>.sh`, then:
   ```bash
   kubectx <EXPECTED_CONTEXT>
   ```

5. **Verify.** Context matches and the new permission is live:
   ```bash
   kubectl config current-context
   kubectl auth can-i get pods -n <namespace>
   ```
   `current-context` must equal the env's `EXPECTED_CONTEXT`; `auth can-i` should now return `yes`.
   The first kubectl call after step 2 re-triggers the device login if the token was dropped.
