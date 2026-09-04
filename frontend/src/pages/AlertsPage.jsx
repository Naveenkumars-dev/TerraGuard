import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { fetchAlerts, acknowledgeAlert, simulateRainfallEvent } from '../services/api';
import { BellRing, CloudRain, ShieldAlert, CheckCircle2, PhoneCall, Smartphone } from 'lucide-react';

export const AlertsPage = () => {
  const { refreshTrigger, triggerRefresh, setLiveAlertNotification } = useApp();
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [simulating, setSimulating] = useState(false);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const data = await fetchAlerts();
        setAlerts(data);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [refreshTrigger]);

  const handleAcknowledge = async (id) => {
    await acknowledgeAlert(id);
    triggerRefresh();
  };

  const handleSimulate = async () => {
    setSimulating(true);
    try {
      const res = await simulateRainfallEvent();
      triggerRefresh();
      if (res && res.notification) {
        setLiveAlertNotification(res.notification);
      }
    } finally {
      setSimulating(false);
    }
  };

  const getAlertBadge = (level) => {
    if (level === 'EVACUATE') return 'bg-red-600 text-white border-red-500 shadow-red-900/50';
    if (level === 'WARNING') return 'bg-orange-600 text-white border-orange-500 shadow-orange-900/50';
    if (level === 'WATCH') return 'bg-yellow-600 text-slate-950 border-yellow-500';
    return 'bg-emerald-600 text-white border-emerald-500';
  };

  return (
    <div className="p-6 space-y-6 max-w-[1600px] mx-auto">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-red-950/60 border border-red-500/40 rounded-lg text-red-400">
            <BellRing className="w-5 h-5 animate-pulse" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">Tiered Alert Dispatch & History</h2>
            <p className="text-xs text-slate-400">Automated warning level dispatches and simulated broadcast logs</p>
          </div>
        </div>

        {/* Action Button */}
        <button
          onClick={handleSimulate}
          disabled={simulating}
          className="px-4 py-2 bg-gradient-to-r from-red-600 to-amber-600 hover:from-red-500 hover:to-amber-500 text-white text-xs font-bold rounded-xl shadow-lg flex items-center gap-2"
        >
          <CloudRain className="w-4 h-4" />
          <span>{simulating ? 'Simulating Event...' : 'Simulate Heavy Rainfall Event'}</span>
        </button>
      </div>

      {/* Alert Level Explanation Legend */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-slate-900 border border-emerald-500/40 p-3.5 rounded-xl space-y-1">
          <div className="flex items-center justify-between">
            <span className="font-bold text-emerald-400 text-xs uppercase">SAFE Level</span>
            <span className="text-[10px] bg-emerald-950 text-emerald-300 px-2 py-0.5 rounded font-mono">0 – 29</span>
          </div>
          <p className="text-[11px] text-slate-400">Normal monitoring. No immediate threat detected.</p>
        </div>

        <div className="bg-slate-900 border border-yellow-500/40 p-3.5 rounded-xl space-y-1">
          <div className="flex items-center justify-between">
            <span className="font-bold text-yellow-400 text-xs uppercase">WATCH Level</span>
            <span className="text-[10px] bg-yellow-950 text-yellow-300 px-2 py-0.5 rounded font-mono">30 – 59</span>
          </div>
          <p className="text-[11px] text-slate-400">Increase monitoring frequency & alert local field officers.</p>
        </div>

        <div className="bg-slate-900 border border-orange-500/40 p-3.5 rounded-xl space-y-1">
          <div className="flex items-center justify-between">
            <span className="font-bold text-orange-400 text-xs uppercase">WARNING Level</span>
            <span className="text-[10px] bg-orange-950 text-orange-300 px-2 py-0.5 rounded font-mono">60 – 79</span>
          </div>
          <p className="text-[11px] text-slate-400">Prepare emergency response units & restrict road access.</p>
        </div>

        <div className="bg-slate-900 border border-red-500/40 p-3.5 rounded-xl space-y-1">
          <div className="flex items-center justify-between">
            <span className="font-bold text-red-400 text-xs uppercase">EVACUATE Level</span>
            <span className="text-[10px] bg-red-950 text-red-300 px-2 py-0.5 rounded font-mono">80 – 100</span>
          </div>
          <p className="text-[11px] text-slate-400">Begin immediate evacuation of vulnerable slope settlements.</p>
        </div>
      </div>

      {/* Alerts Stream List */}
      <div className="space-y-4">
        {alerts.map((alert) => (
          <div
            key={alert.id}
            className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl space-y-3 relative overflow-hidden"
          >
            {/* Top Bar */}
            <div className="flex flex-wrap items-center justify-between gap-3 border-b border-slate-800 pb-3">
              <div className="flex items-center gap-3">
                <span className={`px-3 py-1 text-xs font-black uppercase rounded-lg shadow border ${getAlertBadge(alert.alert_level)}`}>
                  {alert.alert_level}
                </span>
                <div>
                  <h3 className="text-base font-extrabold text-white">{alert.zone_name}</h3>
                  <span className="text-xs text-slate-400">{alert.district} District</span>
                </div>
              </div>

              <div className="text-right">
                <span className="text-xs font-mono font-bold text-red-400 block">{alert.alert_code}</span>
                <span className="text-[10px] text-slate-400 font-mono">
                  {new Date(alert.timestamp).toLocaleString()}
                </span>
              </div>
            </div>

            {/* Alert Content */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
              <div className="bg-slate-800/50 p-3 rounded-xl border border-slate-700/40">
                <span className="text-[10px] uppercase font-bold text-slate-400 block">Trigger Reason</span>
                <p className="text-slate-200 font-semibold mt-0.5">{alert.trigger_reason}</p>
              </div>

              <div className="bg-slate-800/50 p-3 rounded-xl border border-slate-700/40">
                <span className="text-[10px] uppercase font-bold text-slate-400 block">Target Recipients</span>
                <p className="text-slate-300 mt-0.5">{alert.recipients}</p>
              </div>

              <div className="bg-slate-800/50 p-3 rounded-xl border border-slate-700/40 flex items-center justify-between">
                <div>
                  <span className="text-[10px] uppercase font-bold text-slate-400 block">SMS / IVR Delivery</span>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[10px] font-bold text-emerald-400 bg-emerald-950 px-2 py-0.5 rounded border border-emerald-700">
                      SMS SENT
                    </span>
                    {alert.ivr_activated && (
                      <span className="text-[10px] font-bold text-amber-400 bg-amber-950 px-2 py-0.5 rounded border border-amber-700">
                        IVR ACTIVE
                      </span>
                    )}
                  </div>
                </div>

                {!alert.acknowledged ? (
                  <button
                    onClick={() => handleAcknowledge(alert.id)}
                    className="px-3 py-1.5 bg-sky-600 hover:bg-sky-500 text-white font-bold text-xs rounded-lg shadow"
                  >
                    Acknowledge
                  </button>
                ) : (
                  <span className="text-emerald-400 font-bold text-xs flex items-center gap-1">
                    <CheckCircle2 className="w-4 h-4" /> Acknowledged
                  </span>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
