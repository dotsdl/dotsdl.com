# dotsdl.com

Personal site: short build logs in `/notes`, longer pieces in `/essays`. Static Hugo site with a small custom theme, deployed to GitHub Pages by GitHub Actions. New posts reach email subscribers through Buttondown's RSS-to-email.

Publishing is `make publish` on a draft branch: it squash-merges into `main` and pushes, and the push deploys.

## Requirements

| Tool | Version | Notes |
| --- | --- | --- |
| [Hugo](https://github.com/gohugoio/hugo/releases) **extended** | **0.169.0** (pinned) | CI installs exactly this; see "Upgrading Hugo" |
| [lychee](https://github.com/lycheeverse/lychee/releases) | 0.24.2 | link checker used by `make check` |
| git, make, bash | any recent | |

No Node, npm, or JS framework. Don't add a `package.json`.

On Linux, both binaries can go in `~/.local/bin` straight from their release tarballs; check them against the published checksums the way `.github/workflows/deploy.yml` does.

## Commands

| Command | Does |
| --- | --- |
| `make note T="Title"` | Creates branch `draft/<slug>` and `content/notes/YYYY-MM-DD-<slug>/index.md`, commits it, opens `$EDITOR` |
| `make essay T="Title"` | Same for `content/essays/<slug>/index.md` |
| `make serve` | `hugo server -D`: drafts and live reload on the current branch |
| `make drafts` | Lists `draft/*` branches with age in days and title |
| `make publish` | On a draft branch: commits pending edits, sets `draft: false` and `date` to now, checks the build, squash-merges into `main`, pushes, deletes the branch |
| `make check` | Production build (warnings fail it) + offline internal link check + a warning listing any `TODO(David)` left |
| `make` | Lists all commands |

## Writing workflow

The repo is public, so unfinished posts never sit on `main`. Each draft lives on its own `draft/<slug>` branch; `main` holds only published posts.

1. `make note T="Linear as an agent interface"` → you're on `draft/linear-as-an-agent-interface` with the file open.
2. Write. Commit whenever you like; pushing the branch runs the build checks in CI but deploys nothing.
3. `make publish` → live after the Action finishes (about a minute).

Front matter (both sections):

```yaml
title: "Linear as an agent interface"
date: 2026-11-10T09:00:00-08:00   # set to "now" by make publish
draft: true                         # set to false by make publish
tags: [agents, linear]
summary: ""        # required for essays; notes fall back to their first paragraph
math: false        # true adds a "Best read on the site" line to the feed item
canonical: ""      # set only if the post originated elsewhere
syndication: []    # URLs of cross-posts, shown as "Also on" links
```

Essays also take `series: [name]` for multi-part pieces. Images go in the post's folder next to `index.md` and are referenced by file name: `![alt](diagram.png)`.

Math: `\( … \)` inline, `$$ … $$` or `\[ … \]` for display. It is rendered to MathML at build time; no math JavaScript loads.

**URLs are frozen.** Permalinks are `/notes/<slug>/` and `/essays/<slug>/`, and feed item IDs are those permalinks. Changing a slug after publishing breaks inbound links and makes Buttondown send the post again.

## Deployment

`.github/workflows/deploy.yml`:

- Every push to `main` or `draft/**`, and every pull request: install pinned Hugo and lychee (checksums verified), then `make check`.
- Pushes to `main` only: upload `public/` and deploy it to GitHub Pages.

The deploy uses the built-in `GITHUB_TOKEN`; no secrets are needed.

### Upgrading Hugo

Change `HUGO_VERSION` in the workflow, install the same version locally, run `make check`, and say so in the PR description. Hugo deprecates config keys and template functions regularly. 0.169.0 already required `locale` instead of `languageCode` and `hugo.Data` instead of `.Site.Data`, and `--panicOnWarning` turns any new deprecation into a failed build.

## One-time setup (David)

These happen outside the repo. Do them in this order.

### 1. Domain and DNS

- [ ] Confirm the registrar for `dotsdl.com` and that you can edit its DNS.
- [ ] Apex records pointing at GitHub Pages ([GitHub's docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)):

  | Type | Name | Value |
  | --- | --- | --- |
  | A | `@` | `185.199.108.153` |
  | A | `@` | `185.199.109.153` |
  | A | `@` | `185.199.110.153` |
  | A | `@` | `185.199.111.153` |
  | AAAA | `@` | `2606:50c0:8000::153` |
  | AAAA | `@` | `2606:50c0:8001::153` |
  | AAAA | `@` | `2606:50c0:8002::153` |
  | AAAA | `@` | `2606:50c0:8003::153` |
  | CNAME | `www` | `dotsdl.github.io` |

- [ ] Verify the domain for your GitHub account (Settings → Pages → Add a domain). This adds a `_github-pages-challenge-dotsdl` TXT record and stops anyone else's repo from claiming the domain.

### 2. GitHub repository

- [ ] Create the public repo `dotsdl/dotsdl.com` and push `main`.
- [ ] Settings → Pages → Build and deployment → Source: **GitHub Actions**.
- [ ] Settings → Pages → Custom domain: `dotsdl.com`. With Actions deployments this setting is what counts; `static/CNAME` is kept as a record of the domain but GitHub ignores it here.
- [ ] Tick **Enforce HTTPS** once the certificate is issued (can take up to a day after DNS resolves).
- [ ] Optional: protect `main` so that PRs must pass the "Build and deploy / build" check. If you do, let yourself bypass it, or `make publish`'s direct push to `main` will be rejected.

### 3. Buttondown (email)

Set this up only after `https://dotsdl.com/index.xml` is live on the real domain, so the feed item IDs Buttondown records are the final permalinks.

- [ ] Create the account and newsletter.
- [ ] Add a custom sending domain and the SPF and DKIM DNS records Buttondown gives you.
- [ ] Set up RSS-to-email on **`https://dotsdl.com/index.xml`** (the combined feed: every note and essay, full content).
- [ ] Start in **draft** mode: each new post becomes a draft email you review. Switch to auto-send once a few look right.
- [ ] Send yourself a test of the sample math essay and check that it reads acceptably. The post opens with a "Best read on the site" link because many email clients don't render MathML.
- [ ] If Buttondown offers subscribers a digest (batched) delivery option, turn it on so readers can choose it. The site sends every post by default and needs no scheduled job either way.
- [ ] Put your Buttondown username in `hugo.toml` → `params.buttondown`. The subscribe form appears on the home page and under every post once it is set. Compare the form's `action` URL in `layouts/_partials/subscribe.html` with the embed code Buttondown shows you, and update it if it differs.

### 4. GoatCounter (analytics)

- [ ] Create a GoatCounter account and site.
- [ ] Put the site code (the `code` in `code.goatcounter.com`) in `hugo.toml` → `params.goatcounter`. Leave it empty to turn analytics off. No cookies are set, so no consent banner is needed.

### 5. Content before launch

- [ ] Replace every `TODO(David)`: `make check` lists them (home thesis and intro, About, Now, project descriptions and roles, the two `hugo.toml` params).
- [ ] Replace the placeholder social card `static/images/card.png` (1200×630).
- [ ] Have two or three real posts ready, then delete the three sample posts (`content/notes/*sample*`, `content/essays/sample-essay`).

## Theme notes

- Colors are custom properties at the top of `assets/css/main.css`: mint is the primary accent, gold a sparse one. Text colors meet WCAG AA in light and dark mode; keep that when changing them.
- Type rule: Source Serif 4 for prose body text, system sans for everything else. The fonts are self-hosted in `static/fonts/` (SIL Open Font License, see `static/fonts/OFL-source-serif-4.txt`).
- The glow at the top of each page is tinted by the reader's local hour (`assets/js/glow.js`). Preview any hour with `?hour=19`. It lives in a file rather than inline because an inline script stops lychee from reading the rest of the page.
- Syntax highlighting colors are in `assets/css/chroma.css` and use the same custom properties.

## Licenses

Code and templates: MIT (`LICENSE`). Posts and other writing in `content/`: CC BY 4.0 (`LICENSE-content`). Source Serif 4: SIL OFL 1.1.
