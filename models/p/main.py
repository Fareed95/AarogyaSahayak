import cv2
import mediapipe as mp
import numpy as np
import math
from flask import Flask, request, jsonify

app = Flask(__name__)

# ---------------- Pose Detector ----------------
class PoseDetector:
    def __init__(self):
        self.mpDraw = mp.solutions.drawing_utils
        self.mpPose = mp.solutions.pose
        self.pose = self.mpPose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

    def findPose(self, img):
        imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        self.results = self.pose.process(imgRGB)
        if self.results.pose_landmarks:
            self.mpDraw.draw_landmarks(img, self.results.pose_landmarks, self.mpPose.POSE_CONNECTIONS)
        return img

    def getLandmarks(self, img):
        lmList = []
        if self.results.pose_landmarks:
            for id, lm in enumerate(self.results.pose_landmarks.landmark):
                h, w, _ = img.shape
                lmList.append([id, int(lm.x*w), int(lm.y*h)])
        return lmList

# ---------------- Angle Calculation ----------------
def calculate_angle(a,b,c):
    a,b,c = np.array(a), np.array(b), np.array(c)
    radians = math.atan2(c[1]-b[1], c[0]-b[0]) - math.atan2(a[1]-b[1], a[0]-b[0])
    angle = abs(radians*180.0/np.pi)
    return angle if angle <= 180 else 360-angle

# ---------------- Define Poses ----------------
YOGA_POSES = {
    "Tadasana": {"left_knee":180,"right_knee":180,"left_elbow":180,"right_elbow":180},
    "Vrikshasana": {"left_knee":45,"right_knee":180},
    "Virabhadrasana": {"left_knee":90,"right_knee":180},
    "Utkatasana": {"left_knee":90,"right_knee":90},
    "AdhoMukhaSvanasana": {"left_elbow":160,"right_elbow":160,"left_knee":160,"right_knee":160},
    "Trikonasana": {"left_elbow":170,"right_elbow":170,"left_knee":180},
    "Bhujangasana": {"left_elbow":160,"right_elbow":160},
    "SetuBandhasana": {"left_knee":120,"right_knee":120},
    "ArdhaChakrasana": {"left_elbow":150,"right_elbow":150},
    "Padmasana": {"left_knee":45,"right_knee":45}
}

# ---------------- Feedback Function ----------------
def get_feedback(lmList):
    if len(lmList)<33: 
        return "Unknown", {"error":"Body not fully visible"}

    # Landmarks
    left_shoulder, right_shoulder = lmList[11][1:], lmList[12][1:]
    left_elbow, right_elbow = lmList[13][1:], lmList[14][1:]
    left_wrist, right_wrist = lmList[15][1:], lmList[16][1:]
    left_hip, right_hip = lmList[23][1:], lmList[24][1:]
    left_knee, right_knee = lmList[25][1:], lmList[26][1:]
    left_ankle, right_ankle = lmList[27][1:], lmList[28][1:]

    angles = {
        "left_elbow": calculate_angle(left_shoulder,left_elbow,left_wrist),
        "right_elbow": calculate_angle(right_shoulder,right_elbow,right_wrist),
        "left_knee": calculate_angle(left_hip,left_knee,left_ankle),
        "right_knee": calculate_angle(right_hip,right_knee,right_ankle)
    }

    # Compare to poses
    best_pose = None
    best_score = float('inf')
    for pose, ideal in YOGA_POSES.items():
        total_diff = sum(abs(angles[j]-ideal[j]) for j in ideal)
        avg_diff = total_diff / len(ideal)
        if avg_diff<best_score:
            best_score = avg_diff
            best_pose = pose

    feedback={}
    for joint, ideal_angle in YOGA_POSES[best_pose].items():
        diff = abs(angles[joint]-ideal_angle)
        feedback[joint] = "Good" if diff<15 else f"Adjust your {joint.replace('_',' ')}"

    feedback["score"] = round(100-min(best_score,100),2)
    return best_pose, feedback

# ---------------- API Route ----------------
@app.route("/detect_pose", methods=["POST"])
def detect_pose():
    file = request.files['image']
    npimg = np.frombuffer(file.read(), np.uint8)
    img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
    
    detector = PoseDetector()
    detector.findPose(img)
    lmList = detector.getLandmarks(img)
    
    pose_name, feedback = get_feedback(lmList)
    return jsonify({"pose_detected":pose_name,"feedback":feedback})

# ---------------- Run ----------------
if __name__=="__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
