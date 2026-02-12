-- ============================================================
-- Leaderboard Revamp + Shop: Supabase Migration
-- Run this in your Supabase SQL Editor before using the new features
-- ============================================================

-- 1. Purchases table for shop transaction history
-- ============================================================
CREATE TABLE IF NOT EXISTS purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL,
  item_cost INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);

ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own purchases"
  ON purchases FOR SELECT
  USING (auth.uid() = user_id);

-- 2. Purchase Streak Freeze RPC (atomic transaction)
-- ============================================================
CREATE OR REPLACE FUNCTION purchase_streak_freeze(
  p_user_id UUID,
  p_cost INT DEFAULT 50
)
RETURNS JSON AS $$
DECLARE
  v_current_points INT;
  v_new_points INT;
  v_new_freezes INT;
BEGIN
  -- Lock the points row to prevent race conditions
  SELECT total_points INTO v_current_points
  FROM points
  WHERE user_id = p_user_id
  FOR UPDATE;

  IF v_current_points IS NULL THEN
    RAISE EXCEPTION 'User points record not found';
  END IF;

  IF v_current_points < p_cost THEN
    RAISE EXCEPTION 'Insufficient points. Have: %, Need: %', v_current_points, p_cost;
  END IF;

  -- Deduct points
  UPDATE points
  SET total_points = total_points - p_cost,
      updated_at = NOW()
  WHERE user_id = p_user_id
  RETURNING total_points INTO v_new_points;

  -- Increment streak freezes
  UPDATE streaks
  SET streak_freezes = streak_freezes + 1,
      updated_at = NOW()
  WHERE user_id = p_user_id
  RETURNING streak_freezes INTO v_new_freezes;

  -- Record purchase
  INSERT INTO purchases (user_id, item_type, item_cost, created_at)
  VALUES (p_user_id, 'streak_freeze', p_cost, NOW());

  RETURN json_build_object(
    'success', true,
    'new_points', v_new_points,
    'new_freezes', v_new_freezes
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Attendance Rate Leaderboard RPC
-- ============================================================
CREATE OR REPLACE FUNCTION get_attendance_rate_leaderboard(
  p_user_ids UUID[] DEFAULT NULL,
  p_limit INT DEFAULT 50
)
RETURNS TABLE (
  user_id UUID,
  username TEXT,
  avatar_url TEXT,
  attended_count BIGINT,
  total_lectures BIGINT,
  attendance_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  WITH user_attendance AS (
    SELECT
      a.user_id AS uid,
      COUNT(*)::BIGINT AS attended
    FROM attendance a
    GROUP BY a.user_id
  ),
  user_lectures AS (
    SELECT
      t.user_id AS uid,
      COUNT(l.id)::BIGINT AS total
    FROM timetables t
    JOIN lectures l ON l.timetable_id = t.id
    WHERE l.end_time <= NOW()
    GROUP BY t.user_id
  )
  SELECT
    p.id AS user_id,
    p.username,
    p.avatar_url,
    COALESCE(ua.attended, 0) AS attended_count,
    COALESCE(ul.total, 0) AS total_lectures,
    CASE
      WHEN COALESCE(ul.total, 0) = 0 THEN 0
      ELSE ROUND((COALESCE(ua.attended, 0)::NUMERIC / ul.total) * 100, 1)
    END AS attendance_rate
  FROM profiles p
  LEFT JOIN user_attendance ua ON ua.uid = p.id
  LEFT JOIN user_lectures ul ON ul.uid = p.id
  WHERE (p_user_ids IS NULL OR p.id = ANY(p_user_ids))
    AND COALESCE(ul.total, 0) > 0
  ORDER BY attendance_rate DESC, attended_count DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
