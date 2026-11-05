<<<<<<< HEAD
-- =====================================================
-- BEN RICE | 2026 MLB STATCAST SCOUTING ANALYSIS
-- Database: baseball_analytics
-- Table: ben_rice_pitches
-- =====================================================

-- =====================================================
-- SECTION 1: DATASET VALIDATION
-- Confirm pitch totals, games, and pitch types.
-- =====================================================

SELECT
    COUNT(*) AS total_pitches,
    COUNT(DISTINCT game_pk) AS total_games,
    COUNT(DISTINCT pitch_name) AS pitch_types
FROM ben_rice_pitches;

-- =====================================================
-- SECTION 2: OVERALL SWING AND WHIFF PERFORMANCE
-- Whiff rate = whiffs / swings * 100
-- Foul tips are included as whiffs in this analysis.
-- =====================================================

SELECT
    COUNT(*) AS total_pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS total_swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS total_whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches;

-- =====================================================
-- SECTION 3: WHIFF RATE BY PITCH TYPE
-- Identify which pitch types generate the most
-- swings and misses against Ben Rice.
-- =====================================================

SELECT
    pitch_name,

    COUNT(*) AS pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches

GROUP BY pitch_name

ORDER BY whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 4: PERFORMANCE BY PITCHER HANDEDNESS
-- Compare whiff rates against left- and right-handed
-- pitchers.
-- =====================================================

SELECT
    p_throws AS pitcher_hand,

    COUNT(*) AS pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches

WHERE p_throws IN ('L', 'R')

GROUP BY p_throws

ORDER BY whiff_rate_pct DESC NULLS LAST;


-- =====================================================
-- SECTION 5: PITCH TYPE BY PITCHER HANDEDNESS
-- Identify which pitches generate the highest whiff
-- rates against Rice from each pitcher handedness.
-- =====================================================

SELECT
    p_throws AS pitcher_hand,
    pitch_name,

    COUNT(*) AS pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches

WHERE p_throws IN ('L', 'R')

GROUP BY p_throws, pitch_name

ORDER BY pitcher_hand, whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 6: IN-ZONE WHIFF RATE HEATMAP
-- Divide the approximate strike zone into a 3x3 grid.
-- Horizontal location uses catcher's perspective.
-- =====================================================

WITH pitch_locations AS (
    SELECT
        description,

        CASE
            WHEN plate_z >= sz_bot
                 AND plate_z < sz_bot + (sz_top - sz_bot) / 3.0
                THEN 'Low'
            WHEN plate_z >= sz_bot + (sz_top - sz_bot) / 3.0
                 AND plate_z < sz_bot + 2.0 * (sz_top - sz_bot) / 3.0
                THEN 'Middle'
            WHEN plate_z >= sz_bot + 2.0 * (sz_top - sz_bot) / 3.0
                 AND plate_z <= sz_top
                THEN 'High'
        END AS vertical_zone,


        CASE
            WHEN plate_x >= -0.85 AND plate_x < -0.85 / 3.0
                THEN 'Right'
            WHEN plate_x >= -0.85 / 3.0 AND plate_x < 0.85 / 3.0
                THEN 'Middle'
            WHEN plate_x >= 0.85 / 3.0 AND plate_x <= 0.85
                THEN 'Left'
        END AS horizontal_zone

    FROM ben_rice_pitches
    WHERE plate_x IS NOT NULL
      AND plate_z IS NOT NULL
      AND sz_top IS NOT NULL
      AND sz_bot IS NOT NULL
      AND sz_top > sz_bot
),

zone_summary AS (
    SELECT
        vertical_zone,
        horizontal_zone,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM pitch_locations

    WHERE vertical_zone IS NOT NULL
      AND horizontal_zone IS NOT NULL

    GROUP BY vertical_zone, horizontal_zone
)

SELECT
    vertical_zone,
    horizontal_zone,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM zone_summary

ORDER BY
    CASE vertical_zone
        WHEN 'High' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Low' THEN 3
    END,
    CASE horizontal_zone
        WHEN 'Left' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Right' THEN 3
    END;

-- =====================================================
-- SECTION 7: PERFORMANCE BY PITCH LOCATION
-- Compare swings and misses inside and outside
-- the approximate strike zone.
-- =====================================================

WITH pitch_locations AS (
    SELECT
        pitch_name,
        p_throws,
        description,

        CASE
            WHEN plate_z < sz_bot THEN 'Below Zone'
            WHEN plate_z > sz_top THEN 'Above Zone'
            WHEN plate_x < -0.85 THEN 'Right Outside'
            WHEN plate_x > 0.85 THEN 'Left Outside'
            ELSE 'In Zone'
        END AS pitch_location

    FROM ben_rice_pitches

    WHERE plate_x IS NOT NULL
      AND plate_z IS NOT NULL
      AND sz_top IS NOT NULL
      AND sz_bot IS NOT NULL
      AND sz_top > sz_bot
),

location_summary AS (
    SELECT
        pitch_location,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM pitch_locations
    GROUP BY pitch_location
)

SELECT
    pitch_location,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM location_summary

ORDER BY whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 8: BELOW-ZONE WHIFF RATE BY PITCH TYPE
-- Identify pitch types that generate whiffs when
-- located below the batter's strike zone.
-- =====================================================

WITH below_zone AS (
    SELECT *
    FROM ben_rice_pitches
    WHERE plate_z IS NOT NULL
        AND plate_x IS NOT NULL
        AND sz_top IS NOT NULL
        AND sz_bot IS NOT NULL
        AND sz_top > sz_bot
        AND plate_z < sz_bot
),

pitch_summary AS (
    SELECT
        pitch_name,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM below_zone
    GROUP BY pitch_name
)

SELECT
    pitch_name,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM pitch_summary

ORDER BY whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 9: BELOW-ZONE PITCHES BY PITCHER HAND
-- Evaluate pitch-type effectiveness separately
-- for left- and right-handed pitchers.
-- =====================================================

WITH below_zone AS (
    SELECT *
    FROM ben_rice_pitches
    WHERE plate_z < sz_bot
      AND plate_x IS NOT NULL
      AND sz_top > sz_bot
),

pitch_summary AS (
    SELECT
        p_throws AS pitcher_hand,
        pitch_name,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM below_zone
    WHERE p_throws IN ('L', 'R')
    GROUP BY p_throws, pitch_name
)

SELECT
    pitcher_hand,
    pitch_name,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM pitch_summary

ORDER BY pitcher_hand, whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 10: BELOW-ZONE PERFORMANCE BY STRIKE COUNT
-- Compare pitch effectiveness with fewer than
-- two strikes versus two-strike counts.
-- =====================================================

WITH pitch_summary AS (
    SELECT
        CASE
            WHEN strikes = 2 THEN 'Two Strikes'
            ELSE 'Fewer Than Two Strikes'
        END AS strike_count_group,

        pitch_name,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM ben_rice_pitches

    WHERE plate_z < sz_bot
        AND plate_x IS NOT NULL
        AND sz_top > sz_bot
        AND strikes IN (0, 1, 2)

    GROUP BY strike_count_group, pitch_name
)

SELECT
    strike_count_group,
    pitch_name,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM pitch_summary

ORDER BY
    strike_count_group,
    whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 11: CONTACT QUALITY BY PITCH TYPE
-- Analyze exit velocity and estimated contact value
-- on tracked balls put in play.
-- =====================================================

SELECT
    pitch_name,

    COUNT(*) AS contact_samples,

    ROUND(
        AVG(launch_speed)::numeric,
        2
    ) AS avg_exit_velocity_mph,

    ROUND(
        AVG(estimated_woba_using_speedangle)::numeric,
        3
    ) AS avg_estimated_contact_value

FROM ben_rice_pitches

WHERE description = 'hit_into_play'
  AND launch_speed IS NOT NULL
  AND estimated_woba_using_speedangle IS NOT NULL

GROUP BY pitch_name

ORDER BY avg_estimated_contact_value DESC;

-- =====================================================
-- SECTION 12: CONTACT QUALITY BY VERTICAL ZONE
-- Compare batted-ball quality in the high, middle,
-- and low thirds of the approximate strike zone.
-- =====================================================

WITH in_zone_contact AS (
    SELECT
        launch_speed,
        estimated_woba_using_speedangle,

        CASE
            WHEN plate_z < sz_bot + (sz_top - sz_bot) / 3.0
                THEN 'Low'

            WHEN plate_z < sz_bot + 2.0 * (sz_top - sz_bot) / 3.0
                THEN 'Middle'

            ELSE 'High'
        END AS vertical_zone

    FROM ben_rice_pitches

    WHERE description = 'hit_into_play'
      AND plate_x BETWEEN -0.85 AND 0.85
      AND plate_z BETWEEN sz_bot AND sz_top
      AND sz_top > sz_bot
      AND launch_speed IS NOT NULL
      AND estimated_woba_using_speedangle IS NOT NULL
)

SELECT
    vertical_zone,

    COUNT(*) AS contact_samples,

    ROUND(
        AVG(launch_speed)::numeric,
        2
    ) AS avg_exit_velocity_mph,

    ROUND(
        AVG(estimated_woba_using_speedangle)::numeric,
        3
    ) AS avg_estimated_contact_value

FROM in_zone_contact

GROUP BY vertical_zone

ORDER BY
    CASE vertical_zone
        WHEN 'High' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Low' THEN 3
=======
-- =====================================================
-- BEN RICE | 2026 MLB STATCAST SCOUTING ANALYSIS
-- Database: baseball_analytics
-- Table: ben_rice_pitches
-- =====================================================

-- =====================================================
-- SECTION 1: DATASET VALIDATION
-- Confirm pitch totals, games, and pitch types.
-- =====================================================

SELECT
    COUNT(*) AS total_pitches,
    COUNT(DISTINCT game_pk) AS total_games,
    COUNT(DISTINCT pitch_name) AS pitch_types
FROM ben_rice_pitches;

-- =====================================================
-- SECTION 2: OVERALL SWING AND WHIFF PERFORMANCE
-- Whiff rate = whiffs / swings * 100
-- Foul tips are included as whiffs in this analysis.
-- =====================================================

SELECT
    COUNT(*) AS total_pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS total_swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS total_whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches;

-- =====================================================
-- SECTION 3: WHIFF RATE BY PITCH TYPE
-- Identify which pitch types generate the most
-- swings and misses against Ben Rice.
-- =====================================================

SELECT
    pitch_name,

    COUNT(*) AS pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches

GROUP BY pitch_name

ORDER BY whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 4: PERFORMANCE BY PITCHER HANDEDNESS
-- Compare whiff rates against left- and right-handed
-- pitchers.
-- =====================================================

SELECT
    p_throws AS pitcher_hand,

    COUNT(*) AS pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches

WHERE p_throws IN ('L', 'R')

GROUP BY p_throws

ORDER BY whiff_rate_pct DESC NULLS LAST;


-- =====================================================
-- SECTION 5: PITCH TYPE BY PITCHER HANDEDNESS
-- Identify which pitches generate the highest whiff
-- rates against Rice from each pitcher handedness.
-- =====================================================

SELECT
    p_throws AS pitcher_hand,
    pitch_name,

    COUNT(*) AS pitches,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip',
            'foul',
            'hit_into_play'
        )
    ) AS swings,

    COUNT(*) FILTER (
        WHERE description IN (
            'swinging_strike',
            'swinging_strike_blocked',
            'foul_tip'
        )
    ) AS whiffs,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE description IN (
                    'swinging_strike',
                    'swinging_strike_blocked',
                    'foul_tip',
                    'foul',
                    'hit_into_play'
                )
            ), 0
        ),
        2
    ) AS whiff_rate_pct

FROM ben_rice_pitches

WHERE p_throws IN ('L', 'R')

GROUP BY p_throws, pitch_name

ORDER BY pitcher_hand, whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 6: IN-ZONE WHIFF RATE HEATMAP
-- Divide the approximate strike zone into a 3x3 grid.
-- Horizontal location uses catcher's perspective.
-- =====================================================

WITH pitch_locations AS (
    SELECT
        description,

        CASE
            WHEN plate_z >= sz_bot
                 AND plate_z < sz_bot + (sz_top - sz_bot) / 3.0
                THEN 'Low'
            WHEN plate_z >= sz_bot + (sz_top - sz_bot) / 3.0
                 AND plate_z < sz_bot + 2.0 * (sz_top - sz_bot) / 3.0
                THEN 'Middle'
            WHEN plate_z >= sz_bot + 2.0 * (sz_top - sz_bot) / 3.0
                 AND plate_z <= sz_top
                THEN 'High'
        END AS vertical_zone,


        CASE
            WHEN plate_x >= -0.85 AND plate_x < -0.85 / 3.0
                THEN 'Right'
            WHEN plate_x >= -0.85 / 3.0 AND plate_x < 0.85 / 3.0
                THEN 'Middle'
            WHEN plate_x >= 0.85 / 3.0 AND plate_x <= 0.85
                THEN 'Left'
        END AS horizontal_zone

    FROM ben_rice_pitches
    WHERE plate_x IS NOT NULL
      AND plate_z IS NOT NULL
      AND sz_top IS NOT NULL
      AND sz_bot IS NOT NULL
      AND sz_top > sz_bot
),

zone_summary AS (
    SELECT
        vertical_zone,
        horizontal_zone,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM pitch_locations

    WHERE vertical_zone IS NOT NULL
      AND horizontal_zone IS NOT NULL

    GROUP BY vertical_zone, horizontal_zone
)

SELECT
    vertical_zone,
    horizontal_zone,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM zone_summary

ORDER BY
    CASE vertical_zone
        WHEN 'High' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Low' THEN 3
    END,
    CASE horizontal_zone
        WHEN 'Left' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Right' THEN 3
    END;

-- =====================================================
-- SECTION 7: PERFORMANCE BY PITCH LOCATION
-- Compare swings and misses inside and outside
-- the approximate strike zone.
-- =====================================================

WITH pitch_locations AS (
    SELECT
        pitch_name,
        p_throws,
        description,

        CASE
            WHEN plate_z < sz_bot THEN 'Below Zone'
            WHEN plate_z > sz_top THEN 'Above Zone'
            WHEN plate_x < -0.85 THEN 'Right Outside'
            WHEN plate_x > 0.85 THEN 'Left Outside'
            ELSE 'In Zone'
        END AS pitch_location

    FROM ben_rice_pitches

    WHERE plate_x IS NOT NULL
      AND plate_z IS NOT NULL
      AND sz_top IS NOT NULL
      AND sz_bot IS NOT NULL
      AND sz_top > sz_bot
),

location_summary AS (
    SELECT
        pitch_location,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM pitch_locations
    GROUP BY pitch_location
)

SELECT
    pitch_location,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM location_summary

ORDER BY whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 8: BELOW-ZONE WHIFF RATE BY PITCH TYPE
-- Identify pitch types that generate whiffs when
-- located below the batter's strike zone.
-- =====================================================

WITH below_zone AS (
    SELECT *
    FROM ben_rice_pitches
    WHERE plate_z IS NOT NULL
        AND plate_x IS NOT NULL
        AND sz_top IS NOT NULL
        AND sz_bot IS NOT NULL
        AND sz_top > sz_bot
        AND plate_z < sz_bot
),

pitch_summary AS (
    SELECT
        pitch_name,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM below_zone
    GROUP BY pitch_name
)

SELECT
    pitch_name,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM pitch_summary

ORDER BY whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 9: BELOW-ZONE PITCHES BY PITCHER HAND
-- Evaluate pitch-type effectiveness separately
-- for left- and right-handed pitchers.
-- =====================================================

WITH below_zone AS (
    SELECT *
    FROM ben_rice_pitches
    WHERE plate_z < sz_bot
      AND plate_x IS NOT NULL
      AND sz_top > sz_bot
),

pitch_summary AS (
    SELECT
        p_throws AS pitcher_hand,
        pitch_name,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM below_zone
    WHERE p_throws IN ('L', 'R')
    GROUP BY p_throws, pitch_name
)

SELECT
    pitcher_hand,
    pitch_name,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM pitch_summary

ORDER BY pitcher_hand, whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 10: BELOW-ZONE PERFORMANCE BY STRIKE COUNT
-- Compare pitch effectiveness with fewer than
-- two strikes versus two-strike counts.
-- =====================================================

WITH pitch_summary AS (
    SELECT
        CASE
            WHEN strikes = 2 THEN 'Two Strikes'
            ELSE 'Fewer Than Two Strikes'
        END AS strike_count_group,

        pitch_name,

        COUNT(*) AS pitches,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip',
                'foul',
                'hit_into_play'
            )
        ) AS swings,

        COUNT(*) FILTER (
            WHERE description IN (
                'swinging_strike',
                'swinging_strike_blocked',
                'foul_tip'
            )
        ) AS whiffs

    FROM ben_rice_pitches

    WHERE plate_z < sz_bot
        AND plate_x IS NOT NULL
        AND sz_top > sz_bot
        AND strikes IN (0, 1, 2)

    GROUP BY strike_count_group, pitch_name
)

SELECT
    strike_count_group,
    pitch_name,
    pitches,
    swings,
    whiffs,

    ROUND(
        100.0 * swings / NULLIF(pitches, 0),
        2
    ) AS swing_rate_pct,

    ROUND(
        100.0 * whiffs / NULLIF(swings, 0),
        2
    ) AS whiff_rate_pct

FROM pitch_summary

ORDER BY
    strike_count_group,
    whiff_rate_pct DESC NULLS LAST;

-- =====================================================
-- SECTION 11: CONTACT QUALITY BY PITCH TYPE
-- Analyze exit velocity and estimated contact value
-- on tracked balls put in play.
-- =====================================================

SELECT
    pitch_name,

    COUNT(*) AS contact_samples,

    ROUND(
        AVG(launch_speed)::numeric,
        2
    ) AS avg_exit_velocity_mph,

    ROUND(
        AVG(estimated_woba_using_speedangle)::numeric,
        3
    ) AS avg_estimated_contact_value

FROM ben_rice_pitches

WHERE description = 'hit_into_play'
  AND launch_speed IS NOT NULL
  AND estimated_woba_using_speedangle IS NOT NULL

GROUP BY pitch_name

ORDER BY avg_estimated_contact_value DESC;

-- =====================================================
-- SECTION 12: CONTACT QUALITY BY VERTICAL ZONE
-- Compare batted-ball quality in the high, middle,
-- and low thirds of the approximate strike zone.
-- =====================================================

WITH in_zone_contact AS (
    SELECT
        launch_speed,
        estimated_woba_using_speedangle,

        CASE
            WHEN plate_z < sz_bot + (sz_top - sz_bot) / 3.0
                THEN 'Low'

            WHEN plate_z < sz_bot + 2.0 * (sz_top - sz_bot) / 3.0
                THEN 'Middle'

            ELSE 'High'
        END AS vertical_zone

    FROM ben_rice_pitches

    WHERE description = 'hit_into_play'
      AND plate_x BETWEEN -0.85 AND 0.85
      AND plate_z BETWEEN sz_bot AND sz_top
      AND sz_top > sz_bot
      AND launch_speed IS NOT NULL
      AND estimated_woba_using_speedangle IS NOT NULL
)

SELECT
    vertical_zone,

    COUNT(*) AS contact_samples,

    ROUND(
        AVG(launch_speed)::numeric,
        2
    ) AS avg_exit_velocity_mph,

    ROUND(
        AVG(estimated_woba_using_speedangle)::numeric,
        3
    ) AS avg_estimated_contact_value

FROM in_zone_contact

GROUP BY vertical_zone

ORDER BY
    CASE vertical_zone
        WHEN 'High' THEN 1
        WHEN 'Middle' THEN 2
        WHEN 'Low' THEN 3
>>>>>>> origin/main
    END;