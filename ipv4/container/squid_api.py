from flask import Flask, request, jsonify, render_template
import subprocess
import os

app = Flask(__name__)
PASSWD_FILE = '/etc/squid/.htpasswd'


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/users', methods=['POST'])
def add_user():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    if not username or not password:
        return jsonify({'error': 'Username and password required'}), 400
    try:
        result = subprocess.run(
            ['htpasswd', '-b', PASSWD_FILE, username, password],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            return jsonify({'error': result.stderr.strip()}), 500
        return jsonify({'message': f'User {username} added/updated successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/users/<username>', methods=['DELETE'])
def delete_user(username):
    if not os.path.exists(PASSWD_FILE):
        return jsonify({'error': 'Password file not found'}), 404
    try:
        with open(PASSWD_FILE, 'r') as f:
            lines = f.readlines()
        with open(PASSWD_FILE, 'w') as f:
            found = False
            for line in lines:
                if not line.startswith(f"{username}:"):
                    f.write(line)
                else:
                    found = True
        if found:
            return jsonify({'message': f'User {username} deleted'})
        else:
            return jsonify({'error': 'User not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/users', methods=['GET'])
def list_users():
    if not os.path.exists(PASSWD_FILE):
        return jsonify([])
    try:
        with open(PASSWD_FILE, 'r') as f:
            users = [line.split(':')[0] for line in f if ':' in line]
        return jsonify(users)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
