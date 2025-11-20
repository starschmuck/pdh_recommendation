import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { DateTime } from 'luxon';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall } from 'firebase-functions/v2/https';

admin.initializeApp();
const db = admin.firestore();

// Configure the timezone you want scoring to use (e.g., cafeteria/local time)
// Change via env: firebase functions:config:set predictions.tz="America/New_York"
const DEFAULT_TIMEZONE = 'UTC';

function getTz(): string {
  // firebase-functions v2 types may not expose .config() in TS types; read via any
  const cfg = (functions as any).config || {};
  return cfg?.predictions?.tz || process.env.PREDICTIONS_TZ || DEFAULT_TIMEZONE;
}

function dateKeyFromDate(dt: DateTime): string {
  return dt.toFormat('yyyy-LL-dd');
}

function utcBoundsForDateKey(dateKey: string, tz: string) {
  const start = DateTime.fromISO(dateKey, { zone: tz }).startOf('day');
  const end = start.plus({ days: 1 });
  return { startUtc: start.toUTC().toJSDate(), endUtc: end.toUTC().toJSDate() };
}

function normalizeName(name: string | undefined | null): string {
  return (name ?? '').toString().trim().toLowerCase();
}

interface ScoreResultSummary {
  status: string;
  dateKey?: string;
  winners?: string[];
  skipped?: boolean;
}

async function scorePredictionsForDate(dateKey: string, tz: string, opts: { force?: boolean } = {}): Promise<ScoreResultSummary> {
  const { startUtc, endUtc } = utcBoundsForDateKey(dateKey, tz);

  // Idempotency guard: if already scored and not forcing, skip re-award
  const existingResultDoc = await db.collection('predictions').doc(dateKey).get();
  if (existingResultDoc.exists && !opts.force) {
    const existingResult = existingResultDoc.data()?.result;
    if (existingResult?.status === 'scored') {
      return { status: 'already_scored', dateKey, winners: existingResult.winningMealDisplayNames || existingResult.winningMealNames, skipped: true };
    }
  }

  // Fetch meals for the day to constrain which meals are eligible
  const mealsSnap = await db
    .collection('meals')
    .doc(dateKey)
    .collection('meals')
    .get();

  const mealIdToName = new Map<string, string>();
  const mealNamesSet = new Set<string>();
  for (const doc of mealsSnap.docs) {
    const data = doc.data();
    const name = (data.name || data.title || data.mealName || doc.id) as string;
    mealIdToName.set(doc.id, name);
    mealNamesSet.add(normalizeName(name));
  }

  if (mealNamesSet.size === 0) {
    await db.collection('predictions').doc(dateKey).set({
      result: {
        status: 'no_meals',
        scoredAt: admin.firestore.FieldValue.serverTimestamp(),
        timeZone: tz,
      },
    }, { merge: true });
    return { status: 'no_meals', dateKey };
  }

  // Aggregate reviews within the day for those meals only
  const agg = new Map<string, { sum: number; count: number }>();
  const reviewsSnap = await db
    .collection('reviews')
    .where('timestamp', '>=', startUtc)
    .where('timestamp', '<', endUtc)
    .get();

  for (const doc of reviewsSnap.docs) {
    const data = doc.data();
    const mealName = normalizeName((data.meal as string) ?? '');
    const ratingNum = Number(data.rating ?? 0);
    if (!mealNamesSet.has(mealName)) continue;
    if (!Number.isFinite(ratingNum)) continue;

    const cur = agg.get(mealName) || { sum: 0, count: 0 };
    cur.sum += ratingNum;
    cur.count += 1;
    agg.set(mealName, cur);
  }

  if (agg.size === 0) {
    await db.collection('predictions').doc(dateKey).set({
      result: {
        status: 'no_reviews',
        scoredAt: admin.firestore.FieldValue.serverTimestamp(),
        timeZone: tz,
      },
    }, { merge: true });
    return { status: 'no_reviews', dateKey };
  }

  // Compute averages and winners (handle ties)
  let topAvg = -Infinity;
  const averages: Record<string, number> = {};
  for (const [name, { sum, count }] of agg) {
    const avg = sum / Math.max(1, count);
    averages[name] = avg;
    if (avg > topAvg) topAvg = avg;
  }
  const EPS = 1e-9;
  const winningNamesNormalized = Object.keys(averages).filter((n) => averages[n] >= topAvg - EPS);

  // Build display names preserving original casing from meals collection
  const normalizedToDisplay = new Map<string, string>();
  for (const [id, displayName] of mealIdToName.entries()) {
    normalizedToDisplay.set(normalizeName(displayName), displayName);
  }
  const winningMealDisplayNames = winningNamesNormalized.map(n => normalizedToDisplay.get(n) || n);

  // Map winners back to meal IDs where possible
  const winningMealIds: string[] = [];
  const nameToId = new Map<string, string>();
  for (const [id, nm] of mealIdToName.entries()) {
    nameToId.set(normalizeName(nm), id);
  }
  for (const n of winningNamesNormalized) {
    const id = nameToId.get(n);
    if (id) winningMealIds.push(id);
  }

  await db.collection('predictions').doc(dateKey).set({
    result: {
      status: 'scored',
      winningMealNames: winningNamesNormalized, // normalized (lowercase)
      winningMealDisplayNames, // original casing for UI
      winningMealIds,
      topAverage: topAvg,
      totals: Object.fromEntries(
        Object.entries(averages).map(([k, v]) => [k, { average: v, reviews: agg.get(k)?.count ?? 0 }]),
      ),
      scoredAt: admin.firestore.FieldValue.serverTimestamp(),
      timeZone: tz,
    },
  }, { merge: true });

  // Award points: 1 point for a correct prediction
  const usersCol = db.collection('predictions').doc(dateKey).collection('users');
  const usersSnap = await usersCol.get();
  const batches: admin.firestore.WriteBatch[] = [];
  let batch = db.batch();
  let ops = 0;

  for (const doc of usersSnap.docs) {
    const data = doc.data();
    const predMealId = data.mealId as string | undefined;
    const predMealNameStored = data.mealName as string | undefined;

    const normalizedPred = normalizeName(
      predMealId && mealIdToName.has(predMealId)
        ? mealIdToName.get(predMealId)!
        : predMealNameStored,
    );

    const correct = winningNamesNormalized.includes(normalizedPred);
    const points = correct ? 1 : 0;

    batch.update(doc.ref, {
      correct,
      points,
      pointsAwarded: true,
      awardedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Optional: keep a running tally on the user document
    const uid = doc.id; // prediction doc id under predictions/{date}/users/{uid}
    if (uid) {
      const userDoc = db.collection('users').doc(uid);
      batch.set(userDoc, { predictionPoints: admin.firestore.FieldValue.increment(points) }, { merge: true });
    }

    ops++;
    if (ops >= 450) {
      batches.push(batch);
      batch = db.batch();
      ops = 0;
    }
  }

  if (ops > 0) batches.push(batch);
  for (const b of batches) {
    await b.commit();
  }

  return { status: 'ok', dateKey, winners: winningMealDisplayNames };
}

// Runs daily and scores yesterday's predictions
export const scoreYesterdayPredictions = onSchedule({ schedule: '0 6 * * *', timeZone: getTz() }, async (event: any) => {
  const tz = getTz();
  const nowTz = DateTime.now().setZone(tz);
  const target = nowTz.minus({ days: 1 });
  const dateKey = dateKeyFromDate(target);
  await scorePredictionsForDate(dateKey, tz);
  return;
});

// Callable to score an arbitrary dateKey (admin only)
export const scorePredictionsForDateCallable = onCall(async (req) => {
  const auth = (req as any).auth;
  if (!auth) {
    // v2 onCall handlers should throw the same HttpsError shape for the client
    throw new (functions as any).https.HttpsError('unauthenticated', 'Authentication required');
  }

  const data = (req as any).data as any;
  const dateKey = (data && typeof data.dateKey === 'string') ? data.dateKey : '';
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateKey)) {
    throw new functions.https.HttpsError('invalid-argument', 'Provide dateKey as YYYY-MM-DD');
  }
  const tz = getTz();
  return scorePredictionsForDate(dateKey, tz, { force: data?.force === true });
});
