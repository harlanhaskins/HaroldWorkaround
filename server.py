from flask import Flask, jsonify, Response, request
import os
import sys
import json
import argparse

app = Flask(__name__)
selected = None
password = None

def my_dir(name=None):
    path = os.path.expanduser('~')
    if name is not None:
        path = os.path.join(path, name)
    return path

harold_path = my_dir(name='harold')
harold_files_path = my_dir(name='harold_files')
harold_mp3_path = my_dir(name='harold.mp3')
harold_config_path = my_dir(name='.harold')

def body_from_request(request):
    if request.method == "GET" or request.method == "DELETE":
        body = request.args
    else:
        body = request.get_json(force=True, silent=True)
        if body is None:
            body = request.form
    return body

@app.before_request
def setup_request():
    if request.headers.get('X-Authorization') != password:
        return Response(json.dumps({'error': 'Invalid Password'}), 403)
    request.body = body_from_request(request)

def current_files():
    filenames = [f for f in os.listdir(harold_files_path) if os.path.isfile(os.path.join(harold_files_path, f))]
    mp3s = [x for x in filenames if x.endswith('.mp3')]
    mp3s.append('random')
    return mp3s

@app.route('/')
def files():
    return jsonify(files=current_files(), selected=selected)

@app.route('/select', methods=['POST'])
def select():
    global selected
    name = request.body.get('name')
    if name is None:
        return Response(json.dumps({'error': 'Invalid selection.'}), 412)
    selected = name
    with open(harold_config_path, 'w') as config:
        config.write(name)
    if os.path.islink(harold_mp3_path):
        os.remove(harold_mp3_path)
    if selected == 'random':
        if not os.path.islink(harold_path):
            os.symlink(harold_files_path, harold_path)
    else:
        if os.path.islink(harold_path):
            os.remove(harold_path)
        os.symlink(os.path.join(harold_files_path, name), harold_mp3_path)
    return jsonify(status='success')

with open(harold_config_path, 'r') as config:
    name = config.readline().strip()
    if name in current_files():
        print(name)
        selected = name

if __name__ == '__main__':
    password = sys.argv[1]
    port_start = 4000
    for n in range(port_start, port_start + 50):
        try:
            app.run(debug=True, host='0.0.0.0', port=n)
            break
        except PermissionError:
            print('Port %d unavailable. Trying %d.' % n, n+1)
        except KeyboardInterrupt:
            break
