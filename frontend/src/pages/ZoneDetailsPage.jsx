import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { fetchZones } from '../services/api';
import { ExplainableAI } from '../components/ExplainableAI';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';
import { FileText, TrendingUp, AlertTriangle, ShieldCheck, Activity, Users, Route } from 'lucide-react';

export const ZoneDetailsPage = () => {
  const { selectedZoneId, setSelectedZoneId } = useApp();
  const [zones, setZones] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const data = await fetchZones();
        setZones(data);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const currentZone = zones.find((z) => z.id === selectedZoneId) || zones[0] || null;

  // Mock trend chart data over time
  const trendData = [
    { time: '08:00', riskScore: 42, rainfall: 25 },
    { time: '10:00', riskScore: 51, rainfall: 45 },
    { time: '12:00', riskScore: 63, rainfall: 70 },
    { time: '14:00', riskScore: 72, rainfall: 95 },
    { time: '16:00', riskScore: currentZone ? currentZone.risk_score : 82, rainfall: currentZone ? currentZone.rainfall : 112 }
  ];

  return (
    <div className="p-6 space-y-6 max-w-[1600px] mx-auto">
      {/* Header Selector */}
      <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-sky-950/60 border border-sky-500/40 rounded-lg text-sky-400">
            <FileText className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">Landslide Risk Zone Deep-Dive Inspection</h2>
            <p className="text-xs text-slate-400">Granular indicator breakdown and historical risk progression</p>
          </div>
        </div>

        {/* Zone Selector */}
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-slate-400">Select Monitored Zone:</span>
          <select
            value={currentZone ? currentZone.id : ''}
            onChange={(e) => setSelectedZoneId(Number(e.target.value))}
            className="bg-slate-800 text-xs font-bold text-slate-200 border border-slate-700 rounded-lg px-3 py-1.5 focus:outline-none focus:border-red-500"
          >
            {zones.map((z) => (
              <option key={z.id} value={z.id}>
                {z.name} ({z.risk_level})
              </option>
            ))}
          </select>
        </div>
      </div>

      {currentZone ? (
        <div className="space-y-6">
          {/* Main Overview Row */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Score & Status Card */}
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4 flex flex-col justify-between">
              <div>
                <span className="text-[10px] uppercase font-bold text-slate-400">Target Risk Zone</span>
                <h3 className="text-xl font-extrabold text-white">{currentZone.name}</h3>
                <p className="text-xs text-slate-400 mt-0.5">{currentZone.district}, {currentZone.state}</p>
              </div>

              {/* Big Score Badge */}
              <div className="bg-slate-800/80 border border-slate-700/60 rounded-2xl p-5 text-center space-y-1">
                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Dynamic Risk Score</span>
                <div className="text-4xl font-black text-white">
                  {currentZone.risk_score} <span className="text-lg text-slate-400 font-semibold">/ 100</span>
                </div>
                <span className={`inline-block px-3 py-1 rounded-full text-xs font-black uppercase mt-2 ${
                  currentZone.risk_level === 'EVACUATE' ? 'bg-red-600 text-white shadow-lg shadow-red-950' :
                  currentZone.risk_level === 'WARNING' ? 'bg-orange-600 text-white shadow-lg shadow-orange-950' :
                  currentZone.risk_level === 'WATCH' ? 'bg-yellow-600 text-slate-950' : 'bg-emerald-600 text-white'
                }`}>
                  {currentZone.risk_level}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-3 text-xs">
                <div className="bg-slate-800/50 p-3 rounded-xl border border-slate-700/50 flex items-center gap-2">
                  <Users className="w-4 h-4 text-sky-400" />
                  <div>
                    <span className="text-[10px] text-slate-400 block">Population</span>
                    <strong className="text-white text-xs font-bold">{(currentZone.population_affected || 0).toLocaleString()}</strong>
                  </div>
                </div>
                <div className="bg-slate-800/50 p-3 rounded-xl border border-slate-700/50 flex items-center gap-2">
                  <Route className="w-4 h-4 text-purple-400" />
                  <div>
                    <span className="text-[10px] text-slate-400 block">Roads at Risk</span>
                    <strong className="text-white text-xs font-bold">{currentZone.roads_affected || 0} Cut</strong>
                  </div>
                </div>
              </div>
            </div>

            {/* Risk Trend Chart (Recharts) */}
            <div className="lg:col-span-2 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <TrendingUp className="w-4 h-4 text-red-400" />
                  <h3 className="text-sm font-bold text-white uppercase tracking-wider">
                    Risk Score Progression Trend (Today)
                  </h3>
                </div>
                <span className="text-[10px] text-slate-400 font-mono">08:00 – Present</span>
              </div>

              <div className="h-64 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={trendData}>
                    <defs>
                      <linearGradient id="riskGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#EF4444" stopOpacity={0.8} />
                        <stop offset="95%" stopColor="#EF4444" stopOpacity={0.0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                    <XAxis dataKey="time" stroke="#94a3b8" fontSize={11} />
                    <YAxis domain={[0, 100]} stroke="#94a3b8" fontSize={11} />
                    <Tooltip
                      contentStyle={{ backgroundColor: '#1e293b', borderColor: '#334155', borderRadius: '8px', color: '#fff', fontSize: '12px' }}
                    />
                    <Area type="monotone" dataKey="riskScore" stroke="#EF4444" strokeWidth={3} fillOpacity={1} fill="url(#riskGrad)" name="Risk Score" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>

          {/* Explainable AI & Environmental Indicators */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <ExplainableAI zone={currentZone} />

            {/* Environmental Indicators Grid */}
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
              <h3 className="text-sm font-bold text-white uppercase tracking-wider border-b border-slate-800 pb-3">
                Telemetry & Sensor Indicators
              </h3>

              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 text-xs">
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50">
                  <span className="text-slate-400 text-[10px] block font-semibold">24h Rainfall</span>
                  <span className="text-base font-extrabold text-sky-400">{currentZone.rainfall} mm</span>
                </div>
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50">
                  <span className="text-slate-400 text-[10px] block font-semibold">Soil Saturation</span>
                  <span className="text-base font-extrabold text-amber-400">{currentZone.soil_moisture}%</span>
                </div>
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50">
                  <span className="text-slate-400 text-[10px] block font-semibold">Terrain Slope</span>
                  <span className="text-base font-extrabold text-slate-200">{currentZone.slope}°</span>
                </div>
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50">
                  <span className="text-slate-400 text-[10px] block font-semibold">Historical Risk</span>
                  <span className="text-base font-extrabold text-purple-400">{currentZone.historical_risk}</span>
                </div>
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50">
                  <span className="text-slate-400 text-[10px] block font-semibold">Satellite Change</span>
                  <span className="text-base font-extrabold text-slate-300">{currentZone.satellite_change}</span>
                </div>
                <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50">
                  <span className="text-slate-400 text-[10px] block font-semibold">Field Reports</span>
                  <span className="text-base font-extrabold text-red-400">{currentZone.field_reports_count || 0}</span>
                </div>
              </div>

              <div className="bg-red-950/30 border border-red-800/50 p-4 rounded-xl space-y-1">
                <span className="text-xs font-bold text-red-400 uppercase block">Emergency Protocol Advisory</span>
                <p className="text-xs text-red-200 leading-relaxed font-medium">{currentZone.recommended_action}</p>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="text-center text-slate-400 text-xs py-12">Loading zone metrics...</div>
      )}
    </div>
  );
};
