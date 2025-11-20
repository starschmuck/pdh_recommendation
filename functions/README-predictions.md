# Prediction Scoring Functions

Daily backend logic to evaluate user meal predictions vs actual community ratings.

## What It Does
- Schedules a job (cron 06:00 local tz) to score yesterday’s predictions.
- Aggregates `reviews` for the date’s meals, computes average rating per meal.
- Determines all top meals (tie-friendly) and stores results under `predictions/{dateKey}/result`.
- Marks each user prediction with `correct`, `points`, `pointsAwarded`, `awardedAt`.
- Increments `users/{uid}.predictionPoints` for correct picks.
- Provides a callable function for manual or forced re-score.

## Firestore Schema Assumed
- Meals of day: `meals/{YYYY-MM-DD}/meals/{mealId}` with `name`.
- Reviews: `reviews` documents: `{ userId, meal, rating, timestamp }`.
- Predictions: `predictions/{YYYY-MM-DD}/users/{uid}` with `{ mealId?, mealName?, pointsAwarded }`.

## Deployment (Windows PowerShell)
```powershell
npm i -g firebase-tools
firebase login
firebase use <your-project-id>
cd functions
npm install
firebase functions:config:set predictions.tz="America/New_York"  # optional
npm run build
npm run deploy
```

## Scheduled Function
- Name: `scoreYesterdayPredictions`
- Runs at: `0 6 * * *` in configured TZ (default UTC).

## Callable Function
- Name: `scorePredictionsForDateCallable`
- Params: `{ dateKey: 'YYYY-MM-DD', force?: true }`
- Set `force: true` to override idempotency and recalc/overwrite.

### Example (Client)
```ts
import { getFunctions, httpsCallable } from 'firebase/functions';
const fn = httpsCallable(getFunctions(), 'scorePredictionsForDateCallable');
await fn({ dateKey: '2025-11-18', force: true });
```

## Result Document Fields
Path: `predictions/{dateKey}/result`
- `status`: `scored | no_meals | no_reviews | already_scored`
- `winningMealNames`: normalized lowercase names
- `winningMealDisplayNames`: original casing for UI
- `winningMealIds`: array of meal document IDs (if matched)
- `topAverage`: highest average rating
- `totals`: `{ normalizedMealName: { average, reviews } }`
- `scoredAt`: server timestamp
- `timeZone`: configured timezone

## Prediction User Subdoc Fields
Path: `predictions/{dateKey}/users/{uid}`
- `mealId`, `mealName`
- `correct`: boolean
- `points`: number (currently 1 or 0)
- `pointsAwarded`: boolean
- `awardedAt`: server timestamp

## Customization Points
- Change cron time: edit schedule string in `index.ts`.
- Change points system: adjust award logic near `const points = correct ? 1 : 0;`.
- Add multiplier: include review count or confidence weighting there.

## Edge Cases
- No meals: status `no_meals` (no scoring done).
- No reviews: status `no_reviews` (no winners).
- Ties: all top meals considered winners.
- Re-run without `force`: returns `already_scored` summary and skips awarding.

## Troubleshooting
- Ensure functions config timezone set if you need local date boundaries.
- Verify review timestamps are server-side to avoid time drift.
- Large user base: batch operations chunked at 450 writes per batch to stay <500 limit.

## Safety / Idempotency
- Scheduled run only awards once unless you call with `force: true`.
- Re-scoring with `force: true` rewrites result and re-awards points (may duplicate totals if not reconciled). Consider adding a historical log if auditing is needed.

## Next Ideas
- Store per-meal median to mitigate outliers.
- Add confidence metric: reviews count threshold.
- Leaderboard endpoint: compute cumulative points server-side periodically.
