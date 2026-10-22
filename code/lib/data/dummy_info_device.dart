import 'package:flutter/material.dart';
final Map<String, Map<String, dynamic>> deviceContentData = {
  // ==========================================
  // 1. TENSIMETER
  // ==========================================
  "TENSIMETER": {
    "tentang": "Blood pressure measures the force of blood against artery walls. It is shown as two numbers — systolic (when the heart beats) over diastolic (between beats) — in mmHg.",
    "pria_desc": "Ideal blood pressure for adult men is below 120/80 mmHg. Between 120–129 systolic is elevated. At or above 130/80 mmHg may indicate hypertension.",
    "pria_status1": {"title": "NORMAL", "value": "<120 / <80 mmHg", "isAlert": false},
    "pria_status2": {"title": "SEEK CARE", "value": "120–129 / <80 mmHg", "isAlert": true},
    "wanita_desc": "Optimal ranges are the same as men. During pregnancy, readings above 140/90 mmHg indicate high risk. Post-menopause, hypertension risk increases.",
    "wanita_status1": {"title": "NORMAL", "value": "<120 / <80 mmHg", "isAlert": false},
    "wanita_status2": {"title": "PREGNANCY RISK", "value": "Above 140/90", "isAlert": true},
    "tips": [
      {"icon": Icons.access_time, "text": "Rest 5 minutes before measuring. Avoid caffeine or exercise for 30 minutes prior."},
      {"icon": Icons.chair_alt, "text": "Sit with back supported, feet flat, and upper arm at heart level."},
      {"icon": Icons.loop, "text": "Take two readings one minute apart and use the average."}
    ]
  },

  // ==========================================
  // 2. TERMOMETER
  // ==========================================
  "TERMOMETER": {
    "tentang": "A thermometer measures body temperature, which indicates how well the body can generate and get rid of heat to fight off infections or illnesses.",
    "pria_desc": "Normal body temperature for adult men typically ranges from 36.5°C to 37.5°C. A temperature reading of 38°C or above signifies a fever.",
    "pria_status1": {"title": "NORMAL", "value": "36.5°C – 37.5°C", "isAlert": false},
    "pria_status2": {"title": "FEVER", "value": "≥ 38.0°C", "isAlert": true},
    "wanita_desc": "Women's baseline temperature can vary slightly due to hormonal fluctuations during menstrual cycles, ovulation, and pregnancy.",
    "wanita_status1": {"title": "NORMAL", "value": "36.5°C – 37.5°C", "isAlert": false},
    "wanita_status2": {"title": "FEVER", "value": "≥ 38.0°C", "isAlert": true},
    "tips": [
      {"icon": Icons.clean_hands, "text": "Clean the thermometer probe with rubbing alcohol before and after each use."},
      {"icon": Icons.timer, "text": "Wait at least 15 minutes after eating, drinking hot/cold liquids, or exercising."},
      {"icon": Icons.face, "text": "Keep your mouth completely closed or stay still depending on the measurement method."}
    ]
  },

  // ==========================================
  // 3. BPM (HEART RATE)
  // ==========================================
  "BPM": {
    "tentang": "BPM (Beats Per Minute) measures the resting heart rate. It shows how many times your heart beats in one minute and reflects overall cardiovascular fitness.",
    "pria_desc": "For adult men, a normal resting heart rate is between 60–100 BPM. Well-conditioned athletes may have a resting heart rate closer to 40–50 BPM.",
    "pria_status1": {"title": "NORMAL", "value": "60 – 100 BPM", "isAlert": false},
    "pria_status2": {"title": "ABNORMAL", "value": "<60 or >100 BPM", "isAlert": true},
    "wanita_desc": "Adult women typically have slightly higher resting heart rates than men (around 65–100 BPM) due to a smaller heart size pumping less blood per beat.",
    "wanita_status1": {"title": "NORMAL", "value": "60 – 100 BPM", "isAlert": false},
    "wanita_status2": {"title": "ABNORMAL", "value": "<60 or >100 BPM", "isAlert": true},
    "tips": [
      {"icon": Icons.airline_seat_recline_normal, "text": "Sit quietly for at least 5 minutes before checking your pulse rate to get an accurate resting baseline."},
      {"icon": Icons.favorite_border, "text": "Avoid stimulants like nicotine or caffeine prior to measuring, as they artificially raise BPM."},
      {"icon": Icons.monitor_heart, "text": "Track your pulse consistently at the same time each day, preferably right after waking up."}
    ]
  },

  // ==========================================
  // 4. OXIMETER
  // ==========================================
  "OXIMETER": {
    "tentang": "An oximeter measures oxygen saturation (SpO_2) in the blood and pulse rate. It indicates how efficiently oxygen is being carried to the body's extremities.",
    "pria_desc": "Normal oxygen saturation levels for healthy adult men range between 95%–100%. Levels below 90% indicate hypoxemia and require immediate attention.",
    "pria_status1": {"title": "NORMAL", "value": "95% – 100%", "isAlert": false},
    "pria_status2": {"title": "LOW OXYGEN", "value": "< 90%", "isAlert": true},
    "wanita_desc": "Normal ranges are identical to men. Monitoring is crucial during acute respiratory illnesses or dynamic fitness training to track respiratory recovery.",
    "wanita_status1": {"title": "NORMAL", "value": "95% – 100%", "isAlert": false},
    "wanita_status2": {"title": "LOW OXYGEN", "value": "< 90%", "isAlert": true},
    "tips": [
      {"icon": Icons.back_hand, "text": "Ensure your hand is warm, relaxed, and held below heart level during testing."},
      {"icon": Icons.gpp_bad, "text": "Remove nail polish or artificial nails, as they can interfere with light absorption."},
      {"icon": Icons.do_not_disturb, "text": "Stay completely still during the reading; movement causes inaccurate data."}
    ]
  },

  // ==========================================
  // 5. GLUCOSE
  // ==========================================
  /*"GLUCOSE": {
    "tentang": "A glucose meter measures the concentration of glucose (sugar) in the blood, an essential indicator for managing or diagnosing diabetes mellitus.",
    "pria_desc": "Fasting blood sugar should be under 100 mg/dL. Post-meal (2 hours after eating) should be under 140 mg/dL. Higher values indicate prediabetes or diabetes.",
    "pria_status1": {"title": "FASTING", "value": "70 – 99 mg/dL", "isAlert": false},
    "pria_status2": {"title": "POST MEAL", "value": "< 140 mg/dL", "isAlert": false},
    "wanita_desc": "Standard targets match men. However, targets change strictly during pregnancy to monitor and prevent gestational diabetes risk.",
    "wanita_status1": {"title": "FASTING", "value": "70 – 99 mg/dL", "isAlert": false},
    "wanita_status2": {"title": "POST MEAL", "value": "< 140 mg/dL", "isAlert": false},
    "tips": [
      {"icon": Icons.wash, "text": "Wash hands with warm water and soap, then dry completely. Alcohol residue can warp test results."},
      {"icon": Icons.water_drop, "text": "Prick the side of your fingertip rather than the pad to minimize pain and discomfort."},
      {"icon": Icons.verified, "text": "Always verify that your test strips are not expired and match"}
      ]
  }, */
};