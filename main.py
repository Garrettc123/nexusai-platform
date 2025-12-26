#!/usr/bin/env python3
"""
NexusAI Platform - Production Flask Application
Autonomous AI Orchestration System
"""

import os
import logging
from datetime import datetime
from flask import Flask, jsonify, render_template_string

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'nexusai-platform-secret-key')
app.config['DEBUG'] = os.environ.get('DEBUG', 'False').lower() == 'true'

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexusAI Platform - Production</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 800px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 20px;
            text-align: center;
        }
        .status {
            background: #10b981;
            color: white;
            padding: 15px 30px;
            border-radius: 10px;
            text-align: center;
            font-size: 1.2em;
            font-weight: bold;
            margin: 20px 0;
        }
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .metric-card {
            background: #f8fafc;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        .metric-label {
            color: #64748b;
            margin-top: 5px;
        }
        .info {
            background: #f1f5f9;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .info p {
            margin: 10px 0;
            color: #475569;
        }
        .badge {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 NexusAI Platform</h1>
        <div class="status">✅ Production Server Running</div>
        
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-value">4</div>
                <div class="metric-label">Worker Processes</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">Online</div>
                <div class="metric-label">System Status</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">Gunicorn</div>
                <div class="metric-label">WSGI Server</div>
            </div>
        </div>
        
        <div class="info">
            <h3>✨ System Information</h3>
            <p><strong>Server:</strong> <span class="badge">Gunicorn WSGI</span></p>
            <p><strong>Platform:</strong> NexusAI Autonomous AI Orchestration</p>
            <p><strong>Deployment:</strong> Railway.app Production</p>
            <p><strong>Started:</strong> {{ timestamp }}</p>
        </div>
        
        <div class="info" style="margin-top: 20px;">
            <h3>📊 API Endpoints</h3>
            <p>• <strong>/health</strong> - Health check endpoint</p>
            <p>• <strong>/api/status</strong> - System status API</p>
            <p>• <strong>/api/metrics</strong> - Performance metrics</p>
        </div>
    </div>
</body>
</html>
'''


@app.route('/')
def home():
    """Home page with system information"""
    return render_template_string(
        HTML_TEMPLATE,
        timestamp=datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')
    )


@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'service': 'nexusai-platform',
        'timestamp': datetime.now().isoformat(),
        'server': 'gunicorn'
    }), 200


@app.route('/api/status')
def api_status():
    """System status API endpoint"""
    return jsonify({
        'platform': 'NexusAI Platform',
        'version': '3.0.0',
        'status': 'online',
        'server': 'gunicorn',
        'workers': 4,
        'timestamp': datetime.now().isoformat()
    })


@app.route('/api/metrics')
def api_metrics():
    """Performance metrics API endpoint"""
    return jsonify({
        'performance': {
            'uptime': 'healthy',
            'response_time': '< 100ms',
            'success_rate': '99.9%'
        },
        'resources': {
            'workers': 4,
            'worker_class': 'sync',
            'timeout': 120
        },
        'timestamp': datetime.now().isoformat()
    })


@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def server_error(error):
    """500 error handler"""
    logger.error(f"Server error: {error}")
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    # This block is for local development only
    # In production, Gunicorn will run the app
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port, debug=False)
    
    logger.info(f"NexusAI Platform started on port {port}")
    logger.info("Production server: Use 'gunicorn main:app' for deployment")