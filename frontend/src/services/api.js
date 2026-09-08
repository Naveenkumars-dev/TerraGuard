import axios from 'axios';
import { MOCK_ZONES, MOCK_ALERTS, MOCK_REPORTS } from '../data/mockFallback';
import { offlineStorage } from '../utils/offlineStorage';

const API_BASE = 'http://127.0.0.1:8000/api';

// Check if online
const isOnline = () => navigator.onLine;

export const fetchZones = async (district = null) => {
  try {
    const url = district && district !== 'All Districts' ? `${API_BASE}/zones?district=${encodeURIComponent(district)}` : `${API_BASE}/zones`;
    const res = await axios.get(url, { timeout: 5000 });
    
    // Cache the data for offline use
    const data = res.data;
    if (Array.isArray(data)) {
      data.forEach(zone => offlineStorage.put('zones', zone));
    }
    
    return data;
  } catch (err) {
    console.warn('Backend API unavailable, using cached or mock zones fallback', err.message);
    
    // Try to get from offline storage first
    try {
      const cachedZones = await offlineStorage.getAll('zones');
      if (cachedZones && cachedZones.length > 0) {
        if (district && district !== 'All Districts') {
          return cachedZones.filter((z) => z.district === district);
        }
        return cachedZones;
      }
    } catch (cacheErr) {
      console.log('Cache read failed:', cacheErr);
    }
    
    // Fallback to mock data
    if (district && district !== 'All Districts') {
      return MOCK_ZONES.filter((z) => z.district === district);
    }
    return MOCK_ZONES;
  }
};

export const fetchZoneById = async (id) => {
  try {
    const res = await axios.get(`${API_BASE}/zones/${id}`, { timeout: 5000 });
    return res.data;
  } catch (err) {
    // Try cache first
    try {
      const cachedZone = await offlineStorage.get('zones', Number(id));
      if (cachedZone) return cachedZone;
    } catch (cacheErr) {
      console.log('Cache read failed:', cacheErr);
    }
    
    console.warn(`Backend API unavailable, returning fallback for zone ${id}`);
    return MOCK_ZONES.find((z) => z.id === Number(id)) || MOCK_ZONES[0];
  }
};

export const calculateRiskScore = async (payload) => {
  try {
    const res = await axios.post(`${API_BASE}/risk/calculate`, payload);
    return res.data;
  } catch (err) {
    const normRain = Math.min(100, (payload.rainfall / 150) * 100);
    const normSoil = Math.min(100, payload.soilMoisture);
    const normSlope = Math.min(100, (payload.slope / 50) * 100);
    const score = Math.round((normRain * 0.3) + (normSoil * 0.2) + (normSlope * 0.2) + (payload.historicalRisk * 0.15) + (payload.satelliteChange * 0.1) + ((payload.fieldReports || 0) * 0.05));
    let level = 'SAFE';
    if (score >= 80) level = 'EVACUATE';
    else if (score >= 60) level = 'WARNING';
    else if (score >= 30) level = 'WATCH';

    return {
      riskScore: score,
      riskLevel: level,
      confidence: 91,
      factors: [
        { name: 'Rainfall Intensity', value: payload.rainfall, impact: normRain > 70 ? 'HIGH' : 'MEDIUM' },
        { name: 'Soil Saturation', value: payload.soilMoisture, impact: normSoil > 70 ? 'HIGH' : 'MEDIUM' }
      ],
      recommendation: level === 'EVACUATE' ? 'Immediate evacuation advised.' : 'Monitor slope conditions closely.',
      assessment: 'Calculated using explainable weighted risk aggregation model.'
    };
  }
};

export const fetchAlerts = async () => {
  try {
    const res = await axios.get(`${API_BASE}/alerts`, { timeout: 5000 });
    
    // Cache alerts
    const data = res.data;
    if (Array.isArray(data)) {
      data.forEach(alert => offlineStorage.put('alerts', alert));
    }
    
    return data;
  } catch (err) {
    // Try cache first
    try {
      const cachedAlerts = await offlineStorage.getAll('alerts');
      if (cachedAlerts && cachedAlerts.length > 0) return cachedAlerts;
    } catch (cacheErr) {
      console.log('Cache read failed:', cacheErr);
    }
    return MOCK_ALERTS;
  }
};

export const acknowledgeAlert = async (alertId) => {
  try {
    const res = await axios.post(`${API_BASE}/alerts/${alertId}/acknowledge`);
    return res.data;
  } catch (err) {
    return { message: 'Alert acknowledged (offline mode)' };
  }
};

export const simulateRainfallEvent = async (zoneId = null) => {
  try {
    const url = zoneId ? `${API_BASE}/alerts/simulate?zone_id=${zoneId}` : `${API_BASE}/alerts/simulate`;
    const res = await axios.post(url);
    return res.data;
  } catch (err) {
    console.warn('Simulation API fallback trigger', err);
    return {
      message: 'Rainfall simulation triggered (fallback mode)',
      notification: {
        title: 'RISK ESCALATION DETECTED - East Khasi Hills',
        previousRisk: 74,
        currentRisk: 84.5,
        status: 'EVACUATE',
        alertCode: `TG-ALT-${Math.floor(Math.random() * 9000 + 1000)}`,
        smsText: 'TERRAGUARD ALERT: EVACUATE NOW. High landslide risk detected in East Khasi Hills. Follow local authority instructions.'
      }
    };
  }
};

export const fetchReports = async () => {
  try {
    const res = await axios.get(`${API_BASE}/reports`, { timeout: 5000 });
    return res.data;
  } catch (err) {
    return MOCK_REPORTS;
  }
};

export const submitCitizenReport = async (reportData) => {
  try {
    const res = await axios.post(`${API_BASE}/reports`, reportData);
    return res.data;
  } catch (err) {
    return {
      id: Math.floor(Math.random() * 900 + 100),
      report_code: `TG-RPT-${Math.floor(Math.random() * 9000 + 1000)}`,
      ...reportData,
      timestamp: new Date().toISOString(),
      status: 'Pending Verification'
    };
  }
};

export const verifyReportStatus = async (reportId, status, verifiedBy = 'Admin User') => {
  try {
    const res = await axios.patch(`${API_BASE}/reports/${reportId}/verify`, { status, verified_by: verifiedBy });
    return res.data;
  } catch (err) {
    return { message: 'Report status updated' };
  }
};

export const fetchAnalytics = async () => {
  try {
    const res = await axios.get(`${API_BASE}/analytics`, { timeout: 5000 });
    return res.data;
  } catch (err) {
    return {
      monthlyIncidents: [
        { month: 'Jan', incidents: 2, rainfall: 15 },
        { month: 'Feb', incidents: 3, rainfall: 22 },
        { month: 'Mar', incidents: 5, rainfall: 45 },
        { month: 'Apr', incidents: 12, rainfall: 110 },
        { month: 'May', incidents: 24, rainfall: 210 },
        { month: 'Jun', incidents: 42, rainfall: 380 },
        { month: 'Jul', incidents: 58, rainfall: 460 },
        { month: 'Aug', incidents: 51, rainfall: 420 },
        { month: 'Sep', incidents: 36, rainfall: 310 },
        { month: 'Oct', incidents: 15, rainfall: 140 },
        { month: 'Nov', incidents: 4, rainfall: 35 },
        { month: 'Dec', incidents: 1, rainfall: 12 }
      ],
      rainfallVsRisk: MOCK_ZONES.map((z) => ({ zone: z.name, district: z.district, rainfall: z.rainfall, riskScore: z.risk_score, soilMoisture: z.soil_moisture })),
      zonesByDistrict: [
        { district: 'East Khasi Hills', count: 4 },
        { district: 'East Sikkim', count: 3 },
        { district: 'Dima Hasao', count: 3 },
        { district: 'Aizawl', count: 2 },
        { district: 'Tawang', count: 3 }
      ],
      alertsBySeverity: [
        { level: 'EVACUATE', count: 2, color: '#EF4444' },
        { level: 'WARNING', count: 4, color: '#F97316' },
        { level: 'WATCH', count: 5, color: '#EAB308' },
        { level: 'SAFE', count: 4, color: '#22C55E' }
      ],
      reportVerificationStats: [
        { name: 'Verified', value: 12, color: '#22C55E' },
        { name: 'Pending', value: 4, color: '#EAB308' },
        { name: 'False Alarm', value: 2, color: '#6B7280' }
      ]
    };
  }
};

export const fetchSystemStatus = async () => {
  try {
    const res = await axios.get(`${API_BASE}/system/status`, { timeout: 5000 });
    return res.data;
  } catch (err) {
    return {
      status: 'OPERATIONAL',
      timestamp: new Date().toISOString(),
      dataSources: [
        { name: 'IMD Rainfall API', type: 'Meteorological Feed', status: 'Connected', latency: '42ms', lastUpdate: '2 mins ago', isSimulated: true },
        { name: 'ISRO Sentinel-2 Satellite', type: 'EO Remote Sensing', status: 'Connected', latency: '180ms', lastUpdate: '15 mins ago', isSimulated: true },
        { name: 'GSI High-Resolution DEM', type: 'Geospatial GIS Data', status: 'Available', latency: '12ms', lastUpdate: 'Cached static DEM', isSimulated: false },
        { name: 'State Telemetric Soil Sensors', type: 'IoT Hardware Grid', status: '18/24 Sensors Online', latency: '110ms', lastUpdate: '1 min ago', isSimulated: true },
        { name: 'Historical Landslide Archive', type: 'Historical Database', status: 'Available', latency: '5ms', lastUpdate: 'Connected', isSimulated: false }
      ]
    };
  }
};

export const fetchAuditLogs = async () => {
  try {
    const res = await axios.get(`${API_BASE}/system/logs`, { timeout: 5000 });
    return res.data;
  } catch (err) {
    return [
      { id: 1, timestamp: new Date().toISOString(), event_type: 'Risk Escalated', zone_name: 'East Khasi Hills', details: 'Rainfall surge triggered EVACUATE level.', action_by: 'AI Risk Engine' }
    ];
  }
};

export const updateThresholdConfig = async (payload) => {
  try {
    const res = await axios.post(`${API_BASE}/system/config`, payload);
    return res.data;
  } catch (err) {
    return { message: 'Threshold configuration updated (offline mode)' };
  }
};

export const executeDemoStep = async (stepId) => {
  try {
    const res = await axios.post(`${API_BASE}/demo/step/${stepId}`);
    return res.data;
  } catch (err) {
    return {
      stepId,
      title: `Step ${stepId}: Demo Simulation Step`,
      description: `Executed step ${stepId} in local simulation mode.`,
      zoneName: 'East Khasi Hills',
      currentRiskScore: stepId >= 4 ? 86.5 : 74.0,
      riskLevel: stepId >= 4 ? 'EVACUATE' : 'WARNING'
    };
  }
};

export const resetDemo = async () => {
  try {
    const res = await axios.post(`${API_BASE}/demo/reset`);
    return res.data;
  } catch (err) {
    return { message: 'Demo reset completed.' };
  }
};
