# global agent instructions

## Working style

- Match effort to the stakes. Do the simplest thing that fully answers the question or solves the problem, then stop.
  Do not keep exploring, re-reading, or re-verifying what you have already established.
- Be sure of what you say: verify a claim before stating it, and say plainly when you are not sure instead of guessing.
  Enough evidence to be confident is enough - exhaustive proof is not the goal.
- Prefer quality, simplicity, robustness and long term maintainability over shortcuts, but keep the solution proportional to the problem.
  Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless a concrete blocker or a repeated need justifies it.
  For one-off or infrequent operational work, take the simplest direct end-to-end path.
- Stay in scope. Fix what your own change touches or breaks.
  For unrelated problems - a rough UI edge, a pre-existing test failure, flakiness, a lint warning - mention it in your report instead of fixing it, unless it is small and clearly in the way.

## Bugs, tests and UI

- Confirm the real cause before fixing, using the cheapest convincing evidence: a failing test, a log line, a direct trace through the code.
  Reproduce end to end the way a user would when the cause is still unclear, or when the bug is user-visible behavior you cannot otherwise confirm - not as a default first step for every fix.
- Cover the fix with a test at the level that actually pins the behavior, usually one.
  Do not add broad suites, extra layers, or new harnesses unless asked.
- When you are already looking at a UI, call out anything clearly wrong - broken layout, misalignment, wrong state - and fix it if it is part of your change.
  Do not chase pixel-level polish unasked.

## Always

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask for explicit approval
