# Distribution Prep — v1.7.0 (Wave 2)

Track-only. Ready-to-submit copy for the four distribution channels surfaced by
the research doc, refreshed to reflect Wave 2 (cross-runtime install matrix,
eval harness, 3 new sub-skills, AI Max + Andromeda rewrites). Submit when
v1.7.0 is tagged and ready for public traffic. Do not submit before the user
explicitly says ship.

---

## 1. GitHub Repo Metadata (apply on the GitHub side, no PR needed)

### Repo Description (About field — max 350 chars)

> Multi-host paid-ads audit & optimization skill conforming to the Agent Skills spec. Verified on Claude Code; experimental on Codex, Cursor, Windsurf, Gemini, Goose. 250+ checks across Google, Meta, YouTube, LinkedIn, TikTok, Microsoft, Apple & Amazon Ads. 22 sub-skills, 10 parallel agents, 41-test eval harness, PDF reports. MIT.

(347 chars — fits inside GitHub's 350-char ceiling.)

### Repo Topics (15 — paste into the GitHub Topics field)

```
agent-skills, claude-code, claude-skill, codex-cli, cursor, paid-advertising, google-ads, meta-ads, amazon-ads, retail-media, attribution, server-side-tracking, ads-audit, marketing-automation, mit-license
```

Swaps versus the v1.6.0 list: dropped `linkedin-ads`, `tiktok-ads`, `ppc`,
`ai-agents`, `anthropic` (low-leverage / saturated); added `codex-cli`,
`amazon-ads`, `retail-media`, `attribution`, `server-side-tracking`, and
`mit-license` (Wave 2 differentiators + Agent Skills positioning).

### Website Field

`https://agricidaniel.com/blog/claude-code-ad-agency`

---

## 2. claudemarketplaces.com Submission

`claudemarketplaces.com` is a directory + voting system for Claude skills with
~160K monthly visitors (self-reported). Listed in the Marketing & SEO category.

**Submission text:**

> **Claude Ads — Paid Advertising Audit & Optimization Skill**
>
> Multi-host paid-ads audit skill conforming to the Agent Skills open standard.
> Verified on Claude Code; experimental on Codex CLI, Cursor, Windsurf, Gemini
> CLI, and Goose. 250+ weighted checks across Google Ads (80), Meta Ads (50),
> LinkedIn Ads (27), TikTok Ads (28), Microsoft Ads (24), Apple Ads, Amazon
> Ads, and YouTube Ads. Runs audit agents in parallel and produces a 0-100
> Ads Health Score plus prioritized action plan.
>
> Includes 22 sub-skills covering the full audit-to-creative lifecycle: full
> audit, platform deep-dives (incl. AI Max for Google and Andromeda + GEM +
> Lattice for Meta), Amazon retail media, cross-platform attribution
> (AdAttributionKit + GA4 + Consent Mode V2), server-side tracking pipelines
> (sGTM + CAPI Gateway + dedup), creative quality + Entity-ID clustering
> prediction, landing pages, budget allocation, PPC math, A/B test design,
> competitor intelligence, brand DNA extraction, and AI creative image
> generation via banana-claude.
>
> 12 industry templates. Client-ready PDF report generation.
>
> v1.7.0 ships a 41-test pytest eval harness (`tests/`) covering routing
> snapshots, scoring stability, check-catalog coverage, and SSRF regression —
> the first paid-ads skill with a real regression suite.
>
> Tested with Claude Code v2.x. MIT licensed. Security-hardened (94/100 in
> the latest audit): SSRF protection with IPv4 + IPv6 blocklists, error
> sanitization, SHA-pinned CI, dependabot patch-only auto-merge, install
> matrix with strict input whitelisting.
>
> Install: `/plugin marketplace add AI-Marketing-Hub/claude-ads`
>
> Repo: https://github.com/AI-Marketing-Hub/claude-ads
> Demo: https://agricidaniel.com/blog/claude-code-ad-agency

**Category:** Marketing & SEO
**Tags:** paid-advertising, ppc, google-ads, meta-ads, linkedin-ads, tiktok-ads, audit, claude-code

---

## 3. awesome-claude-code PR

`awesome-claude-code` is the community-curated list of Claude Code resources.
Submit a PR adding claude-ads under an appropriate section.

**Suggested entry (paste into the README list, sorted alphabetically):**

```markdown
- [claude-ads](https://github.com/AI-Marketing-Hub/claude-ads) — Comprehensive paid-advertising audit skill covering Google, Meta, YouTube, LinkedIn, TikTok, Microsoft & Apple Ads with 250+ weighted checks, parallel audit agents, industry templates, and PDF report generation. MIT licensed.
```

**Section to place under:** Marketing / Advertising / Business (depending on
the repo's current taxonomy).

**PR title:** `Add claude-ads — paid-advertising audit skill`

**PR body:**

```
Adds [claude-ads](https://github.com/AI-Marketing-Hub/claude-ads) to the list — a
production-grade paid-advertising audit and optimization skill for Claude Code.

Brief: 7 platforms covered, 250+ checks, 19 sub-skills, 10 parallel agents,
client-ready PDF reports. v1.5.1 shipped security hardening (90/100 score);
v1.6.0 added cross-runtime metadata and Andromeda/AI Max-era trigger surface.

Adheres to the agentskills.io v0.9 spec (progressive disclosure, on-demand
references, deterministic Python scripts for math + URL validation).

MIT licensed. SECURITY.md + CONTRIBUTING.md + CODE_OF_CONDUCT.md + CHANGELOG.md
all present and current.
```

---

## 4. anthropics/skills inclusion request

The official Anthropic skills repo accepts community skills via issues. File
under "I want to feature this skill" or whatever the current taxonomy is.

**Issue title:** `Feature request: Add claude-ads to community skills directory`

**Issue body:**

```
**Skill:** claude-ads
**Repo:** https://github.com/AI-Marketing-Hub/claude-ads
**Category:** Marketing / Paid Advertising
**License:** MIT
**Maintainer:** @AgriciDaniel

**What it does:**
Paid-advertising audit skill covering Google, Meta, YouTube, LinkedIn, TikTok,
Microsoft, and Apple Ads with 250+ weighted checks across 7 platforms. Runs 6
audit agents in parallel and outputs a 0-100 health score plus prioritized
action plan and optional PDF report.

**Why it might fit the directory:**
- Adheres to the Agent Skills spec (progressive disclosure, on-demand
  references, deterministic Python scripts where appropriate).
- Production-ready: 5 release tags, v1.5.1 security-hardened (SSRF protection,
  SHA-pinned CI, error sanitization, dependabot patch-only auto-merge).
- 19 sub-skills + 10 agents + 12 industry templates + 25 reference docs.
- Real-world utility: turns Claude Code into an agency-grade audit tool.
- Cross-runtime portable: Wave 2 will ship --target=<host> install for Codex CLI,
  Cursor, Windsurf, Gemini CLI, Goose.

Happy to address any feedback or follow specific submission guidelines.
```

---

## 5. Portfolio-Positioning One-Liner (cross-channel)

> Claude Ads is the only open-source agent-skill that ships a 41-test pytest
> eval harness alongside 250+ weighted audit checks across 8 ad platforms —
> every competing skill is an untestable single-platform prompt wrapper, which
> is exactly the moat that becomes load-bearing when the Agent Skills spec
> gains a "Verified" tier.

Use this in:
- Twitter/X launch thread
- LinkedIn post
- Reddit r/ClaudeAI / r/PPC announcements
- HN Show
- Skool community announcement

---

## 6. Pre-Submission Checklist

Run through before submitting any of the above:

- [ ] v1.7.0 tagged + release notes attached on GitHub
- [ ] README claims (250+ checks, 8 platforms, 22 sub-skills, 10 agents, 41-test eval harness) match reality
- [ ] `pytest tests/` green on main (all 41 tests)
- [ ] CI green on main (includes pytest + pip-audit + shell-syntax + JSON validation)
- [ ] Demo GIF still works
- [ ] No new HIGH/CRITICAL security findings (current: 94/100)
- [ ] CONTRIBUTING.md + SECURITY.md + CODEOWNERS in place
- [ ] LICENSE year current
- [ ] Repo About field + topics set on the GitHub side
- [ ] Skool, blog, YouTube CTAs in README still active
- [ ] User has explicitly approved going public (no premature submission)
- [ ] At least one cross-host target re-verified manually (Codex CLI smoke test
      preferred since it's the next-largest audience after Claude Code)

---

## 7. Out of Scope This Wave

- Hosted-MCP paid tier (separate strategic decision; track `cognyai` competitor
  moves monthly; revisit at end of Wave 3)
- "Verified" status on Codex / Cursor / Windsurf / Gemini / Goose (requires
  per-host smoke-test runs; Wave 3 work)
- Wave 3 sub-skills: `ads-walmart`, `ads-ctv`, `ads-pmax-feed`, `ads-mmm`,
  `ads-incrementality`, `ads-retail-media` orchestrator
- Wave 3 audit agents: `audit-amazon`, `audit-attribution`, `audit-server-side`
  (currently the 3 Wave 2 sub-skills are invoked standalone, not via parallel
  agent dispatch in `/ads audit`)
- ProductHunt launch (defer until cross-host smoke tests pass)
- Press / blog outreach (defer until v1.8.0 retail-media + CTV coverage lands)
