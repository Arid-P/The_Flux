"""
Unified no-cache preview server for FluxFoxus HTML mockups.
Serves all files from /workspaces/The_Flux/ui_mockups on a single port (default 8080).
Every response includes Cache-Control: no-store so browsers never serve stale iframe content.
"""

import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler

MOCKUPS_DIR = '/workspaces/The_Flux/ui_mockups'
PORT = int(os.environ.get('FF_PREVIEW_PORT', 8080))


class NoCacheHandler(SimpleHTTPRequestHandler):
    """Handler that injects no-cache headers into every response."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=MOCKUPS_DIR, **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def translate_path(self, path):
        clean = path.split('?')[0].split('#')[0]
        if clean in ('/', ''):
            path = '/index.html'
        return super().translate_path(path)

    def log_message(self, fmt, *args):
        # Silence request logs to keep daemon output clean
        pass


def main():
    httpd = HTTPServer(('0.0.0.0', PORT), NoCacheHandler)
    print(f"FluxFoxus preview server running on http://0.0.0.0:{PORT}")
    print(f"Serving from {MOCKUPS_DIR} with Cache-Control: no-store")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down preview server.")
        sys.exit(0)


if __name__ == '__main__':
    main()
