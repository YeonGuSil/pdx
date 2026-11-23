# Features

[← Documentation](README.md)

> PDX is pre-release. This page describes what PDX is built to do; no public release has been published yet.

## Work, not a particular AI

PDX is a workspace for work done by people and AI agents together. Everything it holds is about one piece of
**Work**:

| term | meaning |
| --- | --- |
| **Intent** | what is wanted — goal, context, desired outcome, boundary, constraints, success criteria |
| **Work Contract** | what was agreed: the intent, the spec, roles, bounds and gates. Frozen when a person adopts it; changed only by amendment |
| **Evidence** | what proves a claim |
| **Gate** | where a person decides |
| **Knowledge** | what the Work taught |

PDX manages the Work, not the AI. A person, Claude, Codex, Gemini or a future model is a replaceable executor:
replacing one changes nothing about the Work.

## A person judges, an AI executes

| people | AI |
| --- | --- |
| say what outcome is wanted, why, for whom and how far | normalize the words, ask what is missing, propose the contract |
| design the standard — the spec and its verification conditions, the project's rules | generate, compose and verify inside it; the method and the order of tasks are the executor's |
| adopt, decide at gates, authorize every external effect, accept | execute, self-check, submit evidence; propose across the line, never cross it |
| watch exceptions; adopt lessons into the rules | watch everything else; raise what matters; draft lessons |

The process PDX runs:

1. An environment is prepared for the project — its own branch or worktree, the project's rules, tools and
   credentials resolved by PDX and never handed to the agent, the operating system's sandbox.
2. A person, with an AI, plans the work and writes its verification conditions, the way a team lead briefs a team
   member.
3. An agent does the work, checking itself against the plan and writing what it did to the record.
4. A verification agent of another model family checks the result; what stays open goes back to step 3.
5. A person reviews. Rework is an amendment of the plan and starts again at step 2.

## Three kinds of collaboration

| between | what PDX provides |
| --- | --- |
| person and AI | one contract; a confirm-back before work starts; evidence a person can trust without watching; a person before every external effect; one inbox of what needs action |
| person and person | each person's own record, connected by shares and PDX-to-PDX coordination; approvals decided in the approver's own PDX; a board and a work map; co-edited documents |
| AI and AI | delegation under narrower grants; an independent reviewer of another model family; specialists with scoped context |

One rule under all three: collaboration passes through the record. One agent never calls another directly.

## What does not change when the model changes

- **The Work Contract.** Frozen at a person's adoption, changed only by amendment.
- **Evidence.** A claim is closed only by evidence the party doing the work does not control.
- **The Gates.** Every Work passes two — Adoption and Acceptance. Human review is a slot only a person fills.
- **Knowledge.** The record is the source. A lesson is a candidate until a person promotes it into the project's
  rules.
- **The floor.** An external effect needs a person's prior authorization, bound to exactly what will be sent. Where
  independence is required, the one who decides is not the one who produced. A named approver is never replaced by a
  vote. Risk rises by rule and falls only by a person.
- **Vendor neutrality.** Every tool, model and backend is a registry entry you can replace.

## How PDX runs on your machine

PDX is local first: it runs on your own machine and keeps its records under `~/.pdx` (`PDX_HOME`).

| | |
| --- | --- |
| `pdx` | the command you run. In a terminal it opens the workspace in your browser |
| `pdx-session` | your local session; it serves the workspace on an authenticated loopback address |
| `pdx-guard` | a separate process that holds secrets — the vault, model keys, mail |
| the UI | one bundled HTML file |

- **Secrets stay in the guard.** The agent never receives a credential.
- **Sandboxed.** What PDX starts runs under the operating system's isolation; a run that cannot be confined is
  refused, not run unconfined.
- **Verifiable.** The installed release is checked against its release record, offline.
