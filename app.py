from flask import Flask, jsonify, request
import redis
import os
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
ALERT_THRESHOLD = 25

http_requests_total = Counter(
    'http_requests_total',
    'Total des requêtes HTTP',
    ['method', 'endpoint', 'status']
)

def get_redis_client():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "redis"),
        port=6379,
        socket_timeout=1
    )

def alert_threshold():
    return ALERT_THRESHOLD

def sanitize_input(value):
    return value.replace("<", "&lt;").replace(">", "&gt;")

@app.after_request
def record_metrics(response):
    if request.path != '/metrics':
        http_requests_total.labels(
            method=request.method,
            endpoint=request.path,
            status=response.status_code
        ).inc()
    return response

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route("/health")
def health():
    try:
        get_redis_client().ping()
        return jsonify(status="ok"), 200
    except Exception:
        return jsonify(status="redis unavailable"), 503

@app.route("/status")
def status():
    return jsonify(
        service="projet-devops-groupe-demo",
        version="1.0",
        color=os.getenv("APP_COLOR", "unknown"),
        commit_sha=os.getenv("COMMIT_SHA", "unknown")
    ), 200

@app.route("/visits")
def visits():
    r = get_redis_client()
    count = r.incr("visits")
    return jsonify(visits=count), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
