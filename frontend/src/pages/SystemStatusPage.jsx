import React, { useState, useEffect } from 'react';
import { fetchSystemStatus, fetchAuditLogs } from '../services/api';
import { DataSourceStatus } from '../components/DataSourceStatus';
import { AuditLogView } from '../components/AuditLogView';
import { Server, Activity, Cpu, Wifi, CheckCircle2, ShieldAlert } from 'lucide-react';

export const SystemStatusPage = () => {
  const [status, setStatus] = useState(null);
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const [s, l] = await Promise.all([fetchSystemStatus(), fetchAuditLogs()]);
        setStatus(s);
        setLogs(l);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  return (
    <div className="p-6 space-y-6 max-w-[1600px] mx-auto">
      {/* Header */}
      <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-emerald-950/60 border border-emerald-500/40 rounded-lg text-emerald-400">
            <Server className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">System Operational Status & Telemetry</h2>
            <p className="text-xs text-slate-400">Kernel health, micro-service status, and external API data feeds</p>
          </div>
        </div>

        <div className="flex items-center gap-2 bg-emerald-950/80 text-emerald-300 border border-emerald-700/60 px-3 py-1 rounded-lg text-xs font-extrabold">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span>ALL SYSTEMS OPERATIONAL</span>
        </div>
      </div>

      {/* KPI Status Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-xs">
        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow space-y-1">
          <span className="text-[10px] uppercase font-bold text-slate-400 block">FastAPI Backend Engine</span>
          <div className="text-lg font-black text-emerald-400 flex items-center gap-2">
            <Activity className="w-4 h-4 text-emerald-400" /> Healthy (Port 8000)
          </div>
          <span className="text-[10px] text-slate-500 font-mono">Response latency: 14ms</span>
        </div>

        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow space-y-1">
          <span className="text-[10px] uppercase font-bold text-slate-400 block">Database Storage</span>
          <div className="text-lg font-black text-sky-400 flex items-center gap-2">
            <Cpu className="w-4 h-4 text-sky-400" /> SQLite Active
          </div>
          <span className="text-[10px] text-slate-500 font-mono">Persistence: terraguard.db</span>
        </div>

        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow space-y-1">
          <span className="text-[10px] uppercase font-bold text-slate-400 block">AI Risk Engine</span>
          <div className="text-lg font-black text-purple-400 flex items-center gap-2">
            <Cpu className="w-4 h-4 text-purple-400" /> Explainable Model
          </div>
          <span className="text-[10px] text-slate-500 font-mono">Scikit-learn / Weighted Fusion</span>
        </div>

        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow space-y-1">
          <span className="text-[10px] uppercase font-bold text-slate-400 block">Network & Fallback</span>
          <div className="text-lg font-black text-amber-400 flex items-center gap-2">
            <Wifi className="w-4 h-4 text-amber-400" /> SMS / IVR Gateway
          </div>
          <span className="text-[10px] text-slate-500 font-mono">Simulated Broadcast Grid</span>
        </div>
      </div>

      {/* Grid 2: Data Source Feeds + Audit Trail */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <DataSourceStatus sources={status ? status.dataSources : []} />
        <AuditLogView logs={logs} />
      </div>
    </div>
  );
};
