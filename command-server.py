#!/usr/bin/env python3
"""
Simple HTTP server to handle system commands from the dashboard.
Runs on localhost:8765 and only accepts local connections.
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess
import os

class CommandHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress logging
    
    def do_GET(self):
        # Only allow localhost
        if self.client_address[0] not in ('127.0.0.1', '::1'):
            self.send_error(403, 'Forbidden')
            return
        
        # CORS headers for local file access
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        path = self.path.strip('/')
        
        if path == 'poweroff':
            self.wfile.write(b'Shutting down...')
            subprocess.Popen(['systemctl', 'poweroff'])
        
        elif path == 'restart':
            self.wfile.write(b'Restarting...')
            subprocess.Popen(['systemctl', 'reboot'])
        
        elif path == 'firefox':
            self.wfile.write(b'Opening Firefox...')
            # Open Firefox in normal mode (not kiosk)
            env = os.environ.copy()
            subprocess.Popen(['firefox', '--new-window'], 
                           env=env,
                           start_new_session=True,
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
        
        else:
            self.wfile.write(b'Unknown command')

if __name__ == '__main__':
    server = HTTPServer(('127.0.0.1', 8765), CommandHandler)
    print('Command server running on http://localhost:8765')
    server.serve_forever()
    server.serve_forever()
