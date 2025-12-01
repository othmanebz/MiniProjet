from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# In-memory store (pour la démo)
NOTES = [
    {"id": 1, "title": "Bienvenue", "content": "Ceci est une note de démonstration."},
    {"id": 2, "title": "Infrastructure", "content": "Déployé via Docker + Minikube + Terraform + Ansible."},
]


@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/api/notes", methods=["GET"])
def list_notes():
    return jsonify(NOTES), 200


@app.route("/api/notes", methods=["POST"])
def create_note():
    data = request.get_json(force=True)
    next_id = max(n["id"] for n in NOTES) + 1 if NOTES else 1
    note = {
        "id": next_id,
        "title": data.get("title", f"Note {next_id}"),
        "content": data.get("content", ""),
    }
    NOTES.append(note)
    return jsonify(note), 201


if __name__ == "__main__":
    # Pour le debug local uniquement
    app.run(host="0.0.0.0", port=5000)
