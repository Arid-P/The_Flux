import os
import sys
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler

MOCKUPS_DIR = '/workspaces/The_Flux/ui_mockups'

PORT_MAPPINGS = {
    8080: 'index.html',
    8085: 'active_focus_session.html',
    8086: 'home_screen.html',
    8087: 'preset_creation.html',
    8088: 'app_limits.html',
    8089: 'planner.html',
    8090: 'usage_stats.html',
}

def create_handler(default_file):
    class CustomHandler(SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=MOCKUPS_DIR, **kwargs)

        def translate_path(self, path):
            # Clean up query params if present
            clean_path = path.split('?')[0].split('#')[0]
            if clean_path in ('/', ''):
                path = '/' + default_file
            return super().translate_path(path)

        def log_message(self, format, *args):
            pass

    return CustomHandler

def run_server(port, default_file):
    handler = create_handler(default_file)
    httpd = HTTPServer(('0.0.0.0', port), handler)
    print(f"Serving port {port} -> {default_file} from {MOCKUPS_DIR}")
    httpd.serve_forever()

if __name__ == '__main__':
    threads = []
    for port, default_file in PORT_MAPPINGS.items():
        t = threading.Thread(target=run_server, args=(port, default_file), daemon=True)
        t.start()
        threads.append(t)

    print("All preview mockup servers successfully initialized on ports 8080, 8085-8090.")
    try:
        for t in threads:
            t.join()
    except KeyboardInterrupt:
        print("Shutting down preview servers.")
        sys.exit(0)
