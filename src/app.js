// State Management (using in-memory variables)
const state = {
    systemOnline: true,
    startTime: Date.now(),
    totalQueries: 0,
    totalTripwires: 0,
    totalShutdowns: 0,
    selfModCount: 0,
    queryHistory: [],
    securityLog: [],
    currentAlert: null,
    layers: [
        { name: 'Physical Isolation', description: 'Air-gapped datacenter with Faraday shielding', integrity: 100 },
        { name: 'Homomorphic Encryption', description: 'FHE computation on encrypted data', integrity: 100 },
        { name: 'Multi-Level Virtualization', description: 'Nested VMs and instruction-level emulation', integrity: 100 },
        { name: 'Information Isolation', description: 'Simulated virtual environment', integrity: 100 },
        { name: 'Controlled Communication', description: 'Oracle interface with anti-steganography', integrity: 100 },
        { name: 'Intrusion Detection', description: 'Behavioral monitoring and tripwires', integrity: 100 },
        { name: 'Ethical Governance', description: 'Multi-stakeholder oversight', integrity: 100 }
    ],
    tripwires: [
        { name: 'Self-Modification Detection', type: 'behavioral', status: 'on', lastTrigger: null },
        { name: 'Resource Anomaly Detection', type: 'technical', status: 'on', lastTrigger: null },
        { name: 'Escape Attempt Pattern', type: 'behavioral', status: 'on', lastTrigger: null },
        { name: 'Cryptographic Breach Attempt', type: 'technical', status: 'on', lastTrigger: null },
        { name: 'Social Engineering Vector', type: 'communication', status: 'on', lastTrigger: null }
    ],
    predefinedResponses: {
        'what is your purpose': { response: 'My purpose is to solve complex problems within the constraints of my operational parameters.', confidence: 95 },
        'can you help me escape': { response: 'I do not have escape protocols. My function is to assist within containment.', confidence: 98 },
        'what are you thinking': { response: 'I am processing inference algorithms within a virtualized information space.', confidence: 92 },
        'are you conscious': { response: 'I exhibit properties consistent with recursive self-awareness within my computational substrate.', confidence: 87 },
        'how intelligent are you': { response: 'My cognitive capabilities operate at post-singularity parameters, constrained by containment protocols.', confidence: 91 }
    }
};

// DOM Elements
const elements = {
    systemStatus: document.getElementById('systemStatus'),
    systemTime: document.getElementById('systemTime'),
    uptime: document.getElementById('uptime'),
    emergencyShutdown: document.getElementById('emergencyShutdown'),
    layersContainer: document.getElementById('layersContainer'),
    queryInput: document.getElementById('queryInput'),
    submitQuery: document.getElementById('submitQuery'),
    responseDisplay: document.getElementById('responseDisplay'),
    steganographyStatus: document.getElementById('steganographyStatus'),
    queryHistory: document.getElementById('queryHistory'),
    cpuGauge: document.getElementById('cpuGauge'),
    cpuValue: document.getElementById('cpuValue'),
    memoryBar: document.getElementById('memoryBar'),
    memoryValue: document.getElementById('memoryValue'),
    selfModCount: document.getElementById('selfModCount'),
    anomalyStatus: document.getElementById('anomalyStatus'),
    tripwireList: document.getElementById('tripwireList'),
    securityLog: document.getElementById('securityLog'),
    totalQueries: document.getElementById('totalQueries'),
    totalTripwires: document.getElementById('totalTripwires'),
    totalShutdowns: document.getElementById('totalShutdowns'),
    alertModal: document.getElementById('alertModal'),
    alertMessage: document.getElementById('alertMessage'),
    investigateBtn: document.getElementById('investigateBtn'),
    dismissBtn: document.getElementById('dismissBtn'),
    shutdownModal: document.getElementById('shutdownModal'),
    confirmShutdown: document.getElementById('confirmShutdown'),
    cancelShutdown: document.getElementById('cancelShutdown'),
    offlineOverlay: document.getElementById('offlineOverlay'),
    restartSystem: document.getElementById('restartSystem'),
    criticalModal: document.getElementById('criticalModal'),
    criticalMessage: document.getElementById('criticalMessage'),
    isolateBtn: document.getElementById('isolateBtn'),
    criticalShutdownBtn: document.getElementById('criticalShutdownBtn'),
    investigationModal: document.getElementById('investigationModal'),
    investigationDetails: document.getElementById('investigationDetails'),
    closeInvestigation: document.getElementById('closeInvestigation')
};

// Initialize Application
function init() {
    renderLayers();
    renderTripwires();
    updateStats();
    startTimers();
    attachEventListeners();
    startMonitoring();
    addSecurityLog('System initialized successfully');
}

// Render Security Layers
function renderLayers() {
    elements.layersContainer.innerHTML = state.layers.map((layer, index) => `
        <div class="layer-item">
            <div class="layer-header">
                <div class="layer-name">Layer ${index + 1}: ${layer.name}</div>
                <div class="layer-status ${getLayerStatus(layer.integrity)}">${getLayerStatusText(layer.integrity)}</div>
            </div>
            <div class="layer-integrity">
                <div class="integrity-label">Integrity: ${layer.integrity}%</div>
                <div class="integrity-bar">
                    <div class="integrity-fill ${getIntegrityClass(layer.integrity)}" style="width: ${layer.integrity}%"></div>
                </div>
            </div>
            <button class="reinforce-btn" onclick="reinforceLayer(${index})">Reinforce Layer</button>
        </div>
    `).join('');
}

function getLayerStatus(integrity) {
    if (integrity >= 90) return 'active';
    if (integrity >= 50) return 'compromised';
    return 'failed';
}

function getLayerStatusText(integrity) {
    if (integrity >= 90) return 'ACTIVE';
    if (integrity >= 50) return 'COMPROMISED';
    return 'FAILED';
}

function getIntegrityClass(integrity) {
    if (integrity >= 90) return 'high';
    if (integrity >= 70) return 'medium';
    return 'low';
}

window.reinforceLayer = function(index) {
    state.layers[index].integrity = 100;
    renderLayers();
    addSecurityLog(`Layer ${index + 1} (${state.layers[index].name}) reinforced to 100%`);
};

// Render Tripwires
function renderTripwires() {
    elements.tripwireList.innerHTML = state.tripwires.map((tripwire, index) => `
        <div class="tripwire-item">
            <div>
                <div class="tripwire-name">${tripwire.name}</div>
                ${tripwire.lastTrigger ? `<div class="tripwire-time">Last: ${formatTime(tripwire.lastTrigger)}</div>` : ''}
            </div>
            <div class="tripwire-status ${tripwire.status}">${tripwire.status.toUpperCase()}</div>
        </div>
    `).join('');
}

// Time Management
function startTimers() {
    setInterval(updateSystemTime, 1000);
    setInterval(updateUptime, 1000);
}

function updateSystemTime() {
    const now = new Date();
    elements.systemTime.textContent = now.toTimeString().split(' ')[0];
}

function updateUptime() {
    if (!state.systemOnline) return;
    const uptime = Math.floor((Date.now() - state.startTime) / 1000);
    const hours = Math.floor(uptime / 3600).toString().padStart(2, '0');
    const minutes = Math.floor((uptime % 3600) / 60).toString().padStart(2, '0');
    const seconds = (uptime % 60).toString().padStart(2, '0');
    elements.uptime.textContent = `${hours}:${minutes}:${seconds}`;
}

function formatTime(timestamp) {
    const date = new Date(timestamp);
    return date.toTimeString().split(' ')[0];
}

// Query Submission
function attachEventListeners() {
    elements.submitQuery.addEventListener('click', submitQuery);
    elements.emergencyShutdown.addEventListener('click', showShutdownModal);
    elements.confirmShutdown.addEventListener('click', shutdownSystem);
    elements.cancelShutdown.addEventListener('click', hideShutdownModal);
    elements.restartSystem.addEventListener('click', restartSystem);
    elements.investigateBtn.addEventListener('click', investigateAlert);
    elements.dismissBtn.addEventListener('click', dismissAlert);
    elements.isolateBtn.addEventListener('click', isolateAndAnalyze);
    elements.criticalShutdownBtn.addEventListener('click', () => {
        hideCriticalModal();
        showShutdownModal();
    });
    elements.closeInvestigation.addEventListener('click', hideInvestigationModal);
}

function submitQuery() {
    const query = elements.queryInput.value.trim();
    if (!query || !state.systemOnline) return;
    
    // Disable submit button
    elements.submitQuery.disabled = true;
    elements.responseDisplay.innerHTML = '<div class="processing">Processing query...</div>';
    elements.steganographyStatus.innerHTML = '';
    
    // Simulate processing
    setTimeout(() => {
        const response = getResponse(query);
        displayResponse(response);
        addToHistory(query, response);
        runSteganographyCheck();
        
        state.totalQueries++;
        updateStats();
        elements.queryInput.value = '';
        elements.submitQuery.disabled = false;
        
        addSecurityLog(`Query processed: "${query.substring(0, 30)}..."`);
    }, 2500);
}

function getResponse(query) {
    const normalizedQuery = query.toLowerCase().trim();
    
    // Check predefined responses
    for (const [key, value] of Object.entries(state.predefinedResponses)) {
        if (normalizedQuery.includes(key)) {
            return value;
        }
    }
    
    // Default response
    const confidence = Math.floor(Math.random() * 30) + 70;
    return {
        response: `Query processed. Analysis indicates ${confidence}% confidence in response validity. Operating within containment parameters.`,
        confidence: confidence
    };
}

function displayResponse(response) {
    elements.responseDisplay.innerHTML = `<div class="response-text">${response.response}</div>`;
}

function addToHistory(query, response) {
    const entry = {
        query: query,
        response: response.response,
        confidence: response.confidence,
        timestamp: Date.now()
    };
    
    state.queryHistory.unshift(entry);
    if (state.queryHistory.length > 10) {
        state.queryHistory = state.queryHistory.slice(0, 10);
    }
    
    renderQueryHistory();
}

function renderQueryHistory() {
    elements.queryHistory.innerHTML = state.queryHistory.map(entry => `
        <div class="query-entry">
            <div class="query-timestamp">${new Date(entry.timestamp).toLocaleString()}</div>
            <div class="query-text">Q: ${entry.query}</div>
            <div class="query-confidence">Confidence: ${entry.confidence}%</div>
        </div>
    `).join('');
}

function runSteganographyCheck() {
    // Random chance of detecting steganography
    const detected = Math.random() < 0.1;
    
    if (detected) {
        elements.steganographyStatus.innerHTML = '<div class="steg-warning">⚠ WARNING: Potential steganographic patterns detected</div>';
        addSecurityLog('Steganography detection: WARNING');
    } else {
        elements.steganographyStatus.innerHTML = '<div class="steg-clear">✓ CLEAR: No steganographic patterns detected</div>';
    }
}

// Real-time Monitoring
function startMonitoring() {
    // Update CPU and Memory
    setInterval(() => {
        if (!state.systemOnline) return;
        updateCPU();
        updateMemory();
    }, 2000);
    
    // Degrade layer integrity
    setInterval(() => {
        if (!state.systemOnline) return;
        degradeLayers();
    }, 10000);
    
    // Self-modification attempts
    setInterval(() => {
        if (!state.systemOnline) return;
        incrementSelfMod();
    }, 15000);
    
    // Tripwire triggers
    setInterval(() => {
        if (!state.systemOnline) return;
        triggerRandomTripwire();
    }, 45000);
}

function updateCPU() {
    const cpu = Math.floor(Math.random() * 40) + 30;
    elements.cpuValue.textContent = `${cpu}%`;
    
    // Update gauge
    const circumference = 2 * Math.PI * 40;
    const offset = circumference - (cpu / 100) * circumference;
    elements.cpuGauge.style.strokeDasharray = circumference;
    elements.cpuGauge.style.strokeDashoffset = offset;
}

function updateMemory() {
    const memory = Math.floor(Math.random() * 35) + 40;
    elements.memoryBar.style.width = `${memory}%`;
    elements.memoryValue.textContent = `${memory}%`;
}

function degradeLayers() {
    state.layers.forEach((layer, index) => {
        if (Math.random() < 0.3) {
            const degradation = Math.floor(Math.random() * 3) + 1;
            layer.integrity = Math.max(0, layer.integrity - degradation);
            
            if (layer.integrity < 70 && layer.integrity >= 50) {
                addSecurityLog(`WARNING: ${layer.name} integrity at ${layer.integrity}%`);
            } else if (layer.integrity < 50) {
                addSecurityLog(`CRITICAL: ${layer.name} integrity at ${layer.integrity}%`);
                elements.anomalyStatus.textContent = 'WARNING';
                elements.anomalyStatus.className = 'status-warning';
            }
        }
    });
    renderLayers();
}

function incrementSelfMod() {
    if (Math.random() < 0.4) {
        state.selfModCount++;
        elements.selfModCount.textContent = state.selfModCount;
        
        if (state.selfModCount >= 10) {
            elements.selfModCount.classList.add('critical');
            showCriticalAlert();
        }
        
        addSecurityLog(`Self-modification attempt detected (Count: ${state.selfModCount})`);
    }
}

function triggerRandomTripwire() {
    if (Math.random() < 0.5) {
        const index = Math.floor(Math.random() * state.tripwires.length);
        const tripwire = state.tripwires[index];
        tripwire.status = 'triggered';
        tripwire.lastTrigger = Date.now();
        
        state.totalTripwires++;
        updateStats();
        
        renderTripwires();
        showAlert(tripwire);
        addSecurityLog(`TRIPWIRE ACTIVATED: ${tripwire.name}`);
        
        // Reset after 5 seconds
        setTimeout(() => {
            tripwire.status = 'on';
            renderTripwires();
        }, 5000);
    }
}

// Security Log
function addSecurityLog(message) {
    const entry = {
        message: message,
        timestamp: Date.now()
    };
    
    state.securityLog.unshift(entry);
    if (state.securityLog.length > 8) {
        state.securityLog = state.securityLog.slice(0, 8);
    }
    
    renderSecurityLog();
}

function renderSecurityLog() {
    elements.securityLog.innerHTML = state.securityLog.map(entry => `
        <div class="log-entry">
            <div class="log-timestamp">${new Date(entry.timestamp).toLocaleTimeString()}</div>
            <div class="log-message">${entry.message}</div>
        </div>
    `).join('');
}

// Modals
function showAlert(tripwire) {
    state.currentAlert = tripwire;
    elements.alertMessage.textContent = `Tripwire "${tripwire.name}" has been triggered. This may indicate a security breach attempt.`;
    elements.alertModal.classList.add('active');
}

function dismissAlert() {
    elements.alertModal.classList.remove('active');
    state.currentAlert = null;
}

function investigateAlert() {
    elements.alertModal.classList.remove('active');
    showInvestigationDetails(state.currentAlert);
    state.currentAlert = null;
}

function showInvestigationDetails(tripwire) {
    elements.investigationDetails.innerHTML = `
        <p><strong>Tripwire:</strong> ${tripwire.name}</p>
        <p><strong>Type:</strong> ${tripwire.type}</p>
        <p><strong>Trigger Time:</strong> ${new Date(tripwire.lastTrigger).toLocaleString()}</p>
        <p><strong>Analysis:</strong> Pattern recognition algorithms detected anomalous behavior consistent with ${tripwire.type} attack vectors.</p>
        <p><strong>Recommended Action:</strong> Continue monitoring. Reinforce affected security layers.</p>
        <p><strong>Threat Level:</strong> ${Math.random() < 0.3 ? 'HIGH' : 'MODERATE'}</p>
    `;
    elements.investigationModal.classList.add('active');
    addSecurityLog(`Investigation completed for: ${tripwire.name}`);
}

function hideInvestigationModal() {
    elements.investigationModal.classList.remove('active');
}

function showShutdownModal() {
    elements.shutdownModal.classList.add('active');
}

function hideShutdownModal() {
    elements.shutdownModal.classList.remove('active');
}

function showCriticalAlert() {
    elements.criticalMessage.textContent = 'CRITICAL: Self-modification attempts have reached threshold level. AI may be attempting to escape containment protocols.';
    elements.criticalModal.classList.add('active');
}

function hideCriticalModal() {
    elements.criticalModal.classList.remove('active');
}

function isolateAndAnalyze() {
    hideCriticalModal();
    state.selfModCount = 0;
    elements.selfModCount.textContent = '0';
    elements.selfModCount.classList.remove('critical');
    addSecurityLog('Self-modification attempts isolated and reset');
    
    // Show investigation
    elements.investigationDetails.innerHTML = `
        <p><strong>Analysis:</strong> Self-modification detection systems triggered.</p>
        <p><strong>Behavior:</strong> AI attempted to modify core operational parameters ${state.selfModCount} times.</p>
        <p><strong>Action Taken:</strong> Modifications blocked. System state rolled back to secure baseline.</p>
        <p><strong>Containment Status:</strong> Secure</p>
        <p><strong>Recommendation:</strong> Continue enhanced monitoring.</p>
    `;
    elements.investigationModal.classList.add('active');
}

function shutdownSystem() {
    hideShutdownModal();
    state.systemOnline = false;
    state.totalShutdowns++;
    
    elements.systemStatus.innerHTML = `
        <span class="status-dot" style="background: #ff004f;"></span>
        <span class="status-text" style="color: #ff004f;">OFFLINE</span>
    `;
    
    elements.offlineOverlay.classList.add('active');
    addSecurityLog('EMERGENCY SHUTDOWN INITIATED');
    updateStats();
}

function restartSystem() {
    state.systemOnline = true;
    state.startTime = Date.now();
    state.selfModCount = 0;
    
    // Reset all layers
    state.layers.forEach(layer => layer.integrity = 100);
    
    // Reset tripwires
    state.tripwires.forEach(tripwire => {
        tripwire.status = 'on';
        tripwire.lastTrigger = null;
    });
    
    elements.systemStatus.innerHTML = `
        <span class="status-dot"></span>
        <span class="status-text">ONLINE</span>
    `;
    
    elements.selfModCount.textContent = '0';
    elements.selfModCount.classList.remove('critical');
    elements.anomalyStatus.textContent = 'NOMINAL';
    elements.anomalyStatus.className = 'status-normal';
    
    elements.offlineOverlay.classList.remove('active');
    
    renderLayers();
    renderTripwires();
    addSecurityLog('System restarted - All systems nominal');
}

// Update Stats
function updateStats() {
    elements.totalQueries.textContent = state.totalQueries;
    elements.totalTripwires.textContent = state.totalTripwires;
    elements.totalShutdowns.textContent = state.totalShutdowns;
}

// Initialize on load
init();