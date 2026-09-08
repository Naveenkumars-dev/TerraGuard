import React, { useState } from 'react';
import { AlertTriangle, Shield, Users, MapPin, Activity, Send, Clock } from 'lucide-react';

const NER_DISTRICTS = [
  'East Khasi Hills',
  'West Khasi Hills',
  'Ri-Bhoi',
  'West Garo Hills',
  'East Garo Hills',
  'South Garo Hills',
  'East Jaintia Hills',
  'West Jaintia Hills',
  'Tawang',
  'West Kameng',
  'Papum Pare',
  'Lower Dibang Valley',
  'Dima Hasao',
  'Karbi Anglong',
  'Kamrup Metropolitan',
  'Imphal East',
  'Imphal West',
  'Senapati',
  'Churachandpur',
  'Aizawl',
  'Lunglei',
  'Champhai',
  'Kohima',
  'Mokokchung',
  'Dimapur',
  'East Sikkim',
  'West Sikkim',
  'North Sikkim',
  'South Sikkim',
  'West Tripura',
  'Dhalai'
];

export const EmergencyAlertTrigger = () => {
  const [isTriggering, setIsTriggering] = useState(false);
  const [alertSent, setAlertSent] = useState(false);
  const [currentRisk, setCurrentRisk] = useState('HIGH');
  const [riskScore, setRiskScore] = useState(92);
  const [affectedArea, setAffectedArea] = useState('East Khasi Hills');
  const [citizensAffected, setCitizensAffected] = useState(1248);
  const [ivrStatus, setIvrStatus] = useState('IDLE');
  const [smsStatus, setSmsStatus] = useState('PENDING');

  const handleTriggerAlert = async () => {
    setIsTriggering(true);
    setSmsStatus('SENDING');
    
    // Simulate API call to trigger emergency alert
    try {
      const response = await fetch('http://localhost:8000/api/citizens/trigger-alarm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          district: affectedArea,
          risk_score: riskScore,
          trigger_message: `CRITICAL LANDSLIDE RISK: Risk score ${riskScore}%. Move to safe location immediately.`
        })
      });

      const data = await response.json();
      
      if (response.ok) {
        setAlertSent(true);
        setSmsStatus('DELIVERED');
        // Trigger alarm simulation on frontend
        triggerAlarmSimulation();
      }
    } catch (err) {
      console.error('Failed to trigger alert:', err);
      setSmsStatus('FAILED');
    } finally {
      setIsTriggering(false);
    }
  };

  const triggerIVRCall = () => {
    setIvrStatus('CALLING');
    
    // Open device call prompt
    const emergencyNumber = '+919876543210';
    window.location.href = `tel:${emergencyNumber}`;
    
    // Simulate connection after 2 seconds
    setTimeout(() => {
      setIvrStatus('CONNECTED');
    }, 2000);
  };

  const triggerAlarmSimulation = () => {
    // Generate alarm sound using Web Audio API
    try {
      const audioContext = new (window.AudioContext || window.webkitAudioContext)();
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);

      oscillator.frequency.value = 800; // 800 Hz alarm tone
      oscillator.type = 'square';
      gainNode.gain.value = 0.3;

      oscillator.start();

      // Create pulsing alarm pattern
      const pulseInterval = setInterval(() => {
        gainNode.gain.value = gainNode.gain.value > 0 ? 0 : 0.3;
      }, 500);

      // Stop after 60 seconds
      setTimeout(() => {
        clearInterval(pulseInterval);
        oscillator.stop();
        audioContext.close();
      }, 60000);
    } catch (err) {
      console.log('Audio generation failed:', err);
    }

    // Vibrate device if supported
    if (navigator.vibrate) {
      navigator.vibrate([500, 200, 500, 200, 500, 200, 500]);
    }

    // Show emergency alert modal
    setTimeout(() => {
      setAlertSent(false);
    }, 60000); // 60 seconds
  };

  const riskColors = {
    'SAFE': 'bg-green-500',
    'WATCH': 'bg-yellow-500',
    'WARNING': 'bg-orange-500',
    'HIGH': 'bg-red-500',
    'CRITICAL': 'bg-red-600 animate-pulse'
  };

  return (
    <div className="p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-white mb-2">Emergency Alert Trigger</h2>
          <p className="text-slate-400">Send critical landslide alerts to registered citizens</p>
        </div>

        {/* Current Risk Status Card */}
        <div className="bg-slate-800/50 backdrop-blur-sm border-2 border-slate-700 rounded-2xl p-8 mb-6">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-white">Current Risk Status</h3>
            <div className={`px-4 py-2 rounded-full ${riskColors[currentRisk]} text-white font-bold`}>
              {currentRisk}
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <div className="bg-slate-700/50 rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <Activity className="w-5 h-5 text-red-400" />
                <span className="text-slate-400 text-sm">Risk Score</span>
              </div>
              <div className="text-3xl font-bold text-white">{riskScore}%</div>
            </div>

            <div className="bg-slate-700/50 rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <MapPin className="w-5 h-5 text-blue-400" />
                <span className="text-slate-400 text-sm">Affected Area</span>
              </div>
              <div className="text-lg font-bold text-white">{affectedArea}</div>
            </div>

            <div className="bg-slate-700/50 rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <Users className="w-5 h-5 text-green-400" />
                <span className="text-slate-400 text-sm">Citizens Affected</span>
              </div>
              <div className="text-3xl font-bold text-white">{citizensAffected.toLocaleString()}</div>
            </div>
          </div>

          {/* Alert Configuration */}
          <div className="space-y-4 mb-6">
            <div>
              <label className="block text-slate-300 text-sm mb-2">Risk Level</label>
              <select
                value={currentRisk}
                onChange={(e) => setCurrentRisk(e.target.value)}
                className="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-3 text-white focus:border-gov-blue focus:outline-none"
              >
                <option value="SAFE">SAFE</option>
                <option value="WATCH">WATCH</option>
                <option value="WARNING">WARNING</option>
                <option value="HIGH">HIGH</option>
                <option value="CRITICAL">CRITICAL</option>
              </select>
            </div>

            <div>
              <label className="block text-slate-300 text-sm mb-2">Risk Score: {riskScore}%</label>
              <input
                type="range"
                min="0"
                max="100"
                value={riskScore}
                onChange={(e) => setRiskScore(parseInt(e.target.value))}
                className="w-full"
              />
            </div>

            <div>
              <label className="block text-slate-300 text-sm mb-2">Affected Area</label>
              <select
                value={affectedArea}
                onChange={(e) => setAffectedArea(e.target.value)}
                className="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-3 text-white focus:border-gov-blue focus:outline-none"
              >
                {NER_DISTRICTS.map((district) => (
                  <option key={district} value={district}>
                    {district}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Trigger Button */}
          <button
            onClick={handleTriggerAlert}
            disabled={isTriggering || alertSent}
            className={`w-full py-4 rounded-xl font-bold text-white flex items-center justify-center gap-3 transition-all ${
              alertSent
                ? 'bg-green-600'
                : currentRisk === 'CRITICAL'
                ? 'bg-red-600 hover:bg-red-500 animate-pulse'
                : 'bg-orange-600 hover:bg-orange-500'
            } disabled:opacity-50 disabled:cursor-not-allowed`}
          >
            {isTriggering ? (
              <>
                <Clock className="w-5 h-5 animate-spin" />
                <span>Sending Alert...</span>
              </>
            ) : alertSent ? (
              <>
                <Shield className="w-5 h-5" />
                <span>Alert Sent Successfully</span>
              </>
            ) : (
              <>
                <AlertTriangle className="w-5 h-5" />
                <span>🚨 SEND EMERGENCY ALERT</span>
              </>
            )}
          </button>
        </div>

        {/* Alert Simulation Info */}
        <div className="bg-blue-500/20 border border-blue-500/50 rounded-lg p-4">
          <h4 className="font-bold text-blue-400 mb-2">Emergency Alert Simulation</h4>
          <p className="text-blue-300 text-sm mb-3">
            When triggered, registered devices will receive:
          </p>
          <ul className="text-blue-300 text-sm space-y-1">
            <li>• 🔊 60-second emergency alarm sound</li>
            <li>• 📳 Device vibration pattern</li>
            <li>• 📱 Full-screen emergency notification</li>
            <li>• ⚠️ Critical landslide risk alert message</li>
          </ul>
          <p className="text-blue-300 text-xs mt-3">
            <strong>Note:</strong> In production, this uses Firebase Cloud Messaging (FCM) for Android and APNs for iOS to deliver alerts even when the app is not actively running.
          </p>
        </div>

        {/* SMS & IVR Status */}
        {alertSent && (
          <div className="bg-slate-800/50 border-2 border-slate-700 rounded-xl p-6">
            <h3 className="text-xl font-bold text-white mb-4">📡 Alert Delivery Status</h3>
            
            {/* SMS Status */}
            <div className="bg-slate-700/50 rounded-lg p-4 mb-4">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Shield className="w-5 h-5 text-blue-400" />
                  <span className="text-white font-semibold">Official SMS Broadcast Grid</span>
                </div>
                <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                  smsStatus === 'DELIVERED' ? 'bg-green-600 text-white' :
                  smsStatus === 'SENDING' ? 'bg-yellow-600 text-white' :
                  'bg-red-600 text-white'
                }`}>
                  {smsStatus}
                </span>
              </div>
              <p className="text-slate-400 text-sm mb-2">
                To: +91 98XXX XXXXX (District Officials & Local Cell Network Grid)
              </p>
              <div className="bg-slate-600/50 rounded p-3 text-slate-300 text-sm">
                `TERRAGUARD ALERT: EVACUATE NOW. High landslide risk detected in ${affectedArea}. Follow local authority instructions immediately.`
              </div>
            </div>

            {/* IVR Status */}
            <div className="bg-slate-700/50 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Activity className="w-5 h-5 text-purple-400" />
                  <span className="text-white font-semibold">IVR Automated Voice Call Protocol</span>
                </div>
                <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                  ivrStatus === 'CONNECTED' ? 'bg-green-600 text-white' :
                  ivrStatus === 'CALLING' ? 'bg-yellow-600 text-white' :
                  'bg-slate-600 text-white'
                }`}>
                  {ivrStatus}
                </span>
              </div>
              
              {ivrStatus === 'IDLE' && (
                <button
                  onClick={triggerIVRCall}
                  className="w-full mt-3 bg-purple-600 hover:bg-purple-500 text-white font-bold py-3 rounded-lg flex items-center justify-center gap-2 transition-all"
                >
                  <Activity className="w-5 h-5" />
                  <span>📞 Trigger IVR Call</span>
                </button>
              )}

              {ivrStatus === 'CALLING' && (
                <div className="mt-3 text-center">
                  <div className="flex items-center justify-center gap-2 text-yellow-400 mb-2">
                    <Clock className="w-5 h-5 animate-spin" />
                    <span className="font-semibold">CALLING</span>
                  </div>
                  <p className="text-slate-400 text-sm">District Emergency Cell</p>
                  <p className="text-slate-400 text-sm">+91 98XXX XXXXX</p>
                </div>
              )}

              {ivrStatus === 'CONNECTED' && (
                <div className="mt-3 text-center">
                  <div className="flex items-center justify-center gap-2 text-green-400 mb-2">
                    <Shield className="w-5 h-5" />
                    <span className="font-semibold">CONNECTED</span>
                  </div>
                  <p className="text-green-300 text-sm">Emergency voice alert delivered successfully.</p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Emergency Alert Modal */}
        {alertSent && (
          <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
            <div className="bg-red-600 border-4 border-red-400 rounded-2xl p-8 max-w-md w-full text-center animate-pulse">
              <AlertTriangle className="w-24 h-24 text-white mx-auto mb-4" />
              <h2 className="text-3xl font-bold text-white mb-2">🚨 EMERGENCY ALERT</h2>
              <h3 className="text-2xl font-bold text-white mb-4">CRITICAL LANDSLIDE RISK</h3>
              <div className="bg-white/20 rounded-lg p-4 mb-4">
                <p className="text-white text-lg font-semibold">Risk Score: {riskScore}%</p>
                <p className="text-white">Area: {affectedArea}</p>
              </div>
              <p className="text-white text-xl font-bold mb-4">
                Move to a safe location immediately
              </p>
              <div className="flex items-center justify-center gap-2 text-white">
                <Clock className="w-5 h-5" />
                <span>Alert active for 60 seconds</span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
