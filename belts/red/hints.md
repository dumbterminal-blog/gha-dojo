# 🔴 Red Belt Hints

There are no code hints for the Red Belt. You have all the tools.

But here are some design prompts if you're staring at a blank file:

**On structure:** Think of a real pipeline you've seen or used. What were the stages? Install → Test → Build → Deploy is a classic starting point.

**On the matrix:** A common pattern is to run tests across multiple Node versions in a `test` job, then only build/deploy on a single version downstream.

**On the deploy-only-on-main pattern:** Use `if: github.ref == 'refs/heads/main' && github.event_name == 'push'` on the deploy job.

**On reuse:** If you find yourself repeating a setup sequence (checkout + install + cache) across jobs, that's a strong candidate for a composite action.

**On the verbal question:** Speak from understanding, not memory. If you've actually done the previous belts, you know this material.
