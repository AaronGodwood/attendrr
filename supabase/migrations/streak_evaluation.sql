-- ============================================================
-- Streak Evaluation System: Supabase Migration
-- Run this in your Supabase SQL Editor before using the feature
-- ============================================================

-- 1. Add last_evaluated_date column to streaks
-- ============================================================
ALTER TABLE public.streaks
ADD COLUMN IF NOT EXISTS last_evaluated_date DATE;

-- Backfill existing rows
UPDATE public.streaks
SET last_evaluated_date = last_attendance_date
WHERE last_evaluated_date IS NULL AND last_attendance_date IS NOT NULL;

-- 2. Evaluate Streak RPC (idempotent, lecture-day-aware)
-- ============================================================
CREATE OR REPLACE FUNCTION public.evaluate_streak(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_last_attendance DATE;
  v_last_evaluated DATE;
  v_current INTEGER;
  v_longest INTEGER;
  v_freezes INTEGER;
  v_timetable_id UUID;
  v_check_from DATE;
  v_check_to DATE;
  v_day DATE;
  v_lecture_count INTEGER;
  v_attended_count INTEGER;
  v_freezes_consumed INTEGER := 0;
  v_streak_broken BOOLEAN := FALSE;
BEGIN
  -- Lock the row to prevent concurrent evaluation
  SELECT last_attendance_date, last_evaluated_date,
         current_streak, longest_streak, streak_freezes
  INTO v_last_attendance, v_last_evaluated, v_current, v_longest, v_freezes
  FROM public.streaks
  WHERE user_id = p_user_id
  FOR UPDATE;

  -- Nothing to protect if streak is already 0
  IF v_current = 0 THEN
    RETURN json_build_object(
      'current_streak', v_current,
      'longest_streak', v_longest,
      'streak_freezes', v_freezes,
      'last_attendance_date', v_last_attendance,
      'freezes_consumed', 0,
      'streak_broken', FALSE
    );
  END IF;

  -- Find user's timetable
  SELECT id INTO v_timetable_id
  FROM public.timetables
  WHERE user_id = p_user_id
  LIMIT 1;

  -- No timetable = no lectures to miss = streak safe
  IF v_timetable_id IS NULL THEN
    RETURN json_build_object(
      'current_streak', v_current,
      'longest_streak', v_longest,
      'streak_freezes', v_freezes,
      'last_attendance_date', v_last_attendance,
      'freezes_consumed', 0,
      'streak_broken', FALSE
    );
  END IF;

  -- Determine the range of dates to check
  -- Start from whichever is later: last_evaluated or last_attendance, + 1 day
  v_check_from := GREATEST(
    COALESCE(v_last_evaluated, v_last_attendance),
    COALESCE(v_last_attendance, '1970-01-01'::DATE)
  ) + 1;
  v_check_to := CURRENT_DATE - 1;  -- Don't evaluate today (user might still check in)

  -- Nothing to check if range is empty
  IF v_check_from > v_check_to THEN
    RETURN json_build_object(
      'current_streak', v_current,
      'longest_streak', v_longest,
      'streak_freezes', v_freezes,
      'last_attendance_date', v_last_attendance,
      'freezes_consumed', 0,
      'streak_broken', FALSE
    );
  END IF;

  -- Evaluate each day in the range
  v_day := v_check_from;
  WHILE v_day <= v_check_to AND NOT v_streak_broken LOOP
    -- Count lectures on this day
    SELECT COUNT(*) INTO v_lecture_count
    FROM public.lectures
    WHERE timetable_id = v_timetable_id
      AND DATE(start_time) = v_day;

    IF v_lecture_count > 0 THEN
      -- It was a lecture day; check if user attended
      SELECT COUNT(*) INTO v_attended_count
      FROM public.attendance
      WHERE user_id = p_user_id
        AND DATE(check_in_time) = v_day;

      IF v_attended_count = 0 THEN
        -- Missed a lecture day
        IF v_freezes > 0 THEN
          v_freezes := v_freezes - 1;
          v_freezes_consumed := v_freezes_consumed + 1;
        ELSE
          v_current := 0;
          v_streak_broken := TRUE;
        END IF;
      END IF;
    END IF;

    v_day := v_day + 1;
  END LOOP;

  -- Update the streaks row
  UPDATE public.streaks
  SET current_streak = v_current,
      streak_freezes = v_freezes,
      last_evaluated_date = v_check_to,
      updated_at = NOW()
  WHERE user_id = p_user_id;

  RETURN json_build_object(
    'current_streak', v_current,
    'longest_streak', v_longest,
    'streak_freezes', v_freezes,
    'last_attendance_date', v_last_attendance,
    'freezes_consumed', v_freezes_consumed,
    'streak_broken', v_streak_broken
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Updated update_streak RPC (now calls evaluate_streak first)
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_last_date DATE;
  v_current INTEGER;
  v_longest INTEGER;
BEGIN
  -- First, evaluate any missed days since last activity
  PERFORM evaluate_streak(p_user_id);

  -- Now read the (possibly updated) streak
  SELECT last_attendance_date, current_streak, longest_streak
  INTO v_last_date, v_current, v_longest
  FROM public.streaks WHERE user_id = p_user_id;

  IF v_last_date IS NULL OR v_current = 0 THEN
    -- First ever attendance, or streak was just broken by evaluate_streak
    v_current := 1;
  ELSIF v_last_date = CURRENT_DATE THEN
    -- Already checked in today, no-op
    RETURN;
  ELSE
    -- Streak is still alive (evaluate_streak didn't break it)
    v_current := v_current + 1;
  END IF;

  IF v_current > v_longest THEN
    v_longest := v_current;
  END IF;

  UPDATE public.streaks
  SET current_streak = v_current,
      longest_streak = v_longest,
      last_attendance_date = CURRENT_DATE,
      last_evaluated_date = CURRENT_DATE - 1,
      updated_at = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
