import React from 'react';
import { ShieldCheck, AlertTriangle, HelpCircle, Users } from 'lucide-react';

const EmergencyStatusCounters = ({ sosSummary, onSimulateCheckIn }) => {
  const safe = sosSummary?.safe_count || 124;
  const needHelp = sosSummary?.need_help_count || 18;
  const notResponded = sosSummary?.not_responded_count || 31;
  const total = safe + needHelp + notResponded;

  return (
    <div className="bg-slate-900 border border-slate-800 rounded-xl p-5 shadow-lg mb-6">
      <div className="flex flex-col md:flex-row items-start md:items-center justify-between pb-4 border-b border-slate-800 gap-3">
        <div>
          <div className="flex items-center gap-2">
            <Users className="w-5 h-5 text-indigo-400" />
            <h2 className="text-lg font-bold text-white">Citizen Emergency Status (SOS Network)</h2>
          </div>
          <p className="text-xs text-slate-400">Live response monitoring across East Khasi Hills affected area</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => onSimulateCheckIn && onSimulateCheckIn('SAFE')}
            className="px-3 py-1.5 bg-emerald-500/20 hover:bg-emerald-500/30 text-emerald-400 text-xs font-semibold rounded-lg border border-emerald-500/30 transition-all flex items-center gap-1.5"
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            Simulate Citizen "I AM SAFE"
          </button>
          <button
            onClick={() => onSimulateCheckIn && onSimulateCheckIn('NEED_HELP')}
            className="px-3 py-1.5 bg-rose-500/20 hover:bg-rose-500/30 text-rose-400 text-xs font-semibold rounded-lg border border-rose-500/30 transition-all flex items-center gap-1.5"
          >
            <AlertTriangle className="w-3.5 h-3.5" />
            Simulate Citizen "I NEED HELP"
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-4">
        {/* SAFE COUNTER */}
        <div className="bg-emerald-950/40 border border-emerald-500/30 rounded-lg p-4 flex items-center justify-between">
          <div>
            <span className="text-xs font-bold text-emerald-400 uppercase tracking-wider block">🟢 SAFE</span>
            <span className="text-3xl font-extrabold text-white mt-1 block">{safe}</span>
            <span className="text-xs text-emerald-300/70 mt-1 block">Accounted for & sheltered</span>
          </div>
          <div className="p-3 bg-emerald-500/10 rounded-full border border-emerald-500/20">
            <ShieldCheck className="w-8 h-8 text-emerald-400" />
          </div>
        </div>

        {/* NEED HELP COUNTER */}
        <div className="bg-rose-950/40 border border-rose-500/40 rounded-lg p-4 flex items-center justify-between animate-pulse">
          <div>
            <span className="text-xs font-bold text-rose-400 uppercase tracking-wider block">🔴 NEED HELP</span>
            <span className="text-3xl font-extrabold text-white mt-1 block">{needHelp}</span>
            <span className="text-xs text-rose-300/70 mt-1 block">Priority Rescue Queue</span>
          </div>
          <div className="p-3 bg-rose-500/10 rounded-full border border-rose-500/20">
            <AlertTriangle className="w-8 h-8 text-rose-400" />
          </div>
        </div>

        {/* NOT RESPONDED COUNTER */}
        <div className="bg-slate-800/60 border border-slate-700/50 rounded-lg p-4 flex items-center justify-between">
          <div>
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block">⚪ NOT RESPONDED</span>
            <span className="text-3xl font-extrabold text-white mt-1 block">{notResponded}</span>
            <span className="text-xs text-slate-400 mt-1 block">SMS/IVR verification pending</span>
          </div>
          <div className="p-3 bg-slate-700/20 rounded-full border border-slate-600/30">
            <HelpCircle className="w-8 h-8 text-slate-400" />
          </div>
        </div>
      </div>
    </div>
  );
};

export default EmergencyStatusCounters;
