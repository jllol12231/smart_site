# -*- coding: utf-8 -*-
"""
建筑安全智能监控平台 - AI 推理服务
技术栈: Flask (Python 3.9)
接口:
  POST /api/ai/detect  图片危险行为检测 (multipart, 字段名 image)
  GET  /api/ai/health  健康检查

检测引擎说明:
- 当前为"模拟推理引擎" SimEngine: 演示环境使用, 规则化返回检测结果
- 真实模型接入点: 将 engine.detect() 替换为 YOLO/ONNX 推理即可 (接口已预留)
"""
import os
import random
import time

from flask import Flask, jsonify, request

app = Flask(__name__)

# 危险行为类别 (与《页面功能清单》七、AI智能识别 对应)
LABELS_ZH = {
    "helmet": "安全帽未佩戴",
    "vest":   "安全服未穿",
    "smoke":  "现场吸烟",
    "fire":   "明火",
}


class SimEngine:
    """模拟推理引擎: 40% 概率检测到 1-2 个危险行为"""

    def detect(self, image_path: str) -> list:
        time.sleep(0.3)  # 模拟推理耗时, 贴近真实服务体验
        results = []
        if random.random() < 0.4:
            n = random.randint(1, 2)
            labels = random.sample(list(LABELS_ZH.keys()), n)
            for label in labels:
                results.append({
                    "label": label,
                    "label_zh": LABELS_ZH[label],
                    "confidence": round(random.uniform(0.65, 0.95), 3),
                    "bbox": [
                        random.randint(50, 300),
                        random.randint(30, 200),
                        random.randint(80, 200),
                        random.randint(80, 220),
                    ],
                })
        return results


# 真实模型接入点: 替换为 e.g. YOLO/ONNX 推理
engine = SimEngine()


@app.get("/api/ai/health")
def health():
    return jsonify({"code": 0, "message": "ok", "engine": "sim"})


@app.post("/api/ai/detect")
def detect():
    if "image" not in request.files:
        return jsonify({"code": 400, "message": "缺少 image 文件"}), 400
    f = request.files["image"]
    tmp = os.path.join(app.root_path, "tmp", f"{int(time.time() * 1000)}.jpg")
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    f.save(tmp)
    try:
        results = engine.detect(tmp)
        return jsonify({"code": 0, "data": {"results": results, "count": len(results)}})
    finally:
        try:
            os.remove(tmp)
        except OSError:
            pass


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
