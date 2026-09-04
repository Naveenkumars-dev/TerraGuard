import React, { useState } from 'react';
import { updateThresholdConfig } from '../services/api';
import { Sliders, Save, ShieldAlert, CheckCircle2, RefreshCcw } from 'lucide-react';

export const AdminPage = () => {
  const [safeMax, setSafeMax] = useState(29);
  const [watchMax, setWatchMax] = useState(59);
  const [warningMax, setWarningMax] = useState(79);
  const [evacuateMax, setEvacuateMax] = useState(100);
  const [monitoredDistrict, setMonitoredDistrict] = useState('All Districts');
  const [saving, setSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState(null);

  const handleSaveConfig = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        safe_max: Number(safeMax),
        watch_max: Number(watchMax),
        warning_max: Number(warningMax),
        evacuate_max: Number(evacuateMax),
        monitored_district: monitoredDistrict
      };
      await updateThresholdConfig(payload);
      setSaveMessage('System Risk Thresholds & Monitored District Configuration updated successfully!');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="p-6 space-y-6 max-w-[1400px] mx-auto">
      {/* Header */}
      <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-red-950/60 border border-red-500/40 rounded-lg text-red-400">
            <Sliders className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">System Administration & AI Model Threshold Configuration</h2>
            <p className="text-xs text-slate-400">Configure alert level cutoffs, notification targets, and operational parameters</p>
          </div>
        </div>
      </div>

      {saveMessage && (
        <div className="bg-emerald-950/90 border border-emerald-500/60 p-4 rounded-xl text-xs font-bold text-emerald-300 flex items-center gap-2">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{saveMessage}</span>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Risk Threshold Configuration Form */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-5">
          <div className="border-b border-slate-800 pb-3">
            <h3 className="text-sm font-bold text-white uppercase tracking-wider">
              Landslide Risk Threshold Configuration
            </h3>
            <p className="text-[11px] text-slate-400">Adjust mathematical limits for automated alert escalation</p>
          </div>

          <form onSubmit={handleSaveConfig} className="space-y-4 text-xs">
            {/* SAFE Threshold */}
            <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 space-y-1">
              <label className="block font-bold text-emerald-400">SAFE Threshold Cutoff (0 to max)</label>
              <input
                type="number"
                value={safeMax}
                onChange={(e) => setSafeMax(e.target.value)}
                className="w-full bg-slate-900 text-slate-200 border border-slate-700 rounded-lg p-2 font-mono font-bold"
              />
              <span className="text-[10px] text-slate-400">Scores below this limit trigger SAFE status.</span>
            </div>

            {/* WATCH Threshold */}
            <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 space-y-1">
              <label className="block font-bold text-yellow-400">WATCH Threshold Upper Cutoff</label>
              <input
                type="number"
                value={watchMax}
                onChange={(e) => setWatchMax(e.target.value)}
                className="w-full bg-slate-900 text-slate-200 border border-slate-700 rounded-lg p-2 font-mono font-bold"
              />
              <span className="text-[10px] text-slate-400">Scores from SAFE+1 to this value trigger WATCH status.</span>
            </div>

            {/* WARNING Threshold */}
            <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 space-y-1">
              <label className="block font-bold text-orange-400">WARNING Threshold Upper Cutoff</label>
              <input
                type="number"
                value={warningMax}
                onChange={(e) => setWarningMax(e.target.value)}
                className="w-full bg-slate-900 text-slate-200 border border-slate-700 rounded-lg p-2 font-mono font-bold"
              />
              <span className="text-[10px] text-slate-400">Scores from WATCH+1 to this value trigger WARNING status.</span>
            </div>

            {/* EVACUATE Threshold */}
            <div className="bg-slate-800/60 p-3 rounded-xl border border-slate-700/50 space-y-1">
              <label className="block font-bold text-red-400">EVACUATE Threshold Max Cutoff</label>
              <input
                type="number"
                value={evacuateMax}
                onChange={(e) => setEvacuateMax(e.target.value)}
                className="w-full bg-slate-900 text-slate-200 border border-slate-700 rounded-lg p-2 font-mono font-bold"
              />
              <span className="text-[10px] text-slate-400">Scores above WARNING cutoff up to 100 trigger EVACUATION protocol.</span>
            </div>

            {/* District Filter */}
            <div>
              <label className="block text-slate-300 font-bold mb-1">Default Operational Monitored District</label>
              <select
                value={monitoredDistrict}
                onChange={(e) => setMonitoredDistrict(e.target.value)}
                className="w-full bg-slate-800 text-slate-200 border border-slate-700 rounded-lg p-2 font-bold"
              >
                <option value="All Districts">All Districts (NER Regional Grid)</option>
                <option value="East Khasi Hills">East Khasi Hills</option>
                <option value="East Sikkim">East Sikkim</option>
                <option value="Tawang">Tawang</option>
                <option value="Aizawl">Aizawl</option>
                <option value="Dima Hasao">Dima Hasao</option>
              </select>
            </div>

            <button
              type="submit"
              disabled={saving}
              className="w-full py-3 bg-red-600 hover:bg-red-500 text-white font-extrabold text-xs rounded-xl shadow-lg flex items-center justify-center gap-2 transition-all"
            >
              <Save className="w-4 h-4" />
              <span>{saving ? 'Updating Configurations...' : 'Save System Configuration'}</span>
            </button>
          </form>
        </div>

        {/* Right Column: Notification Recipients & System Parameters */}
        <div className="space-y-6">
          {/* Notification Recipients Grid */}
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
            <h3 className="text-sm font-bold text-white uppercase tracking-wider border-b border-slate-800 pb-3">
              Automated Alert Notification Recipients
            </h3>

            <div className="space-y-3 text-xs">
              <div className="p-3 bg-slate-800/60 border border-slate-700/50 rounded-xl space-y-1">
                <div className="font-bold text-white flex items-center justify-between">
                  <span>State & District Disaster Authorities (DDMA)</span>
                  <span className="text-[10px] bg-red-950 text-red-300 border border-red-700 px-2 py-0.5 rounded font-bold">PRIMARY</span>
                </div>
                <p className="text-slate-400 text-[11px]">Receives immediate EVACUATE and WARNING dispatches via SMS, Email & IVR priority channel.</p>
              </div>

              <div className="p-3 bg-slate-800/60 border border-slate-700/50 rounded-xl space-y-1">
                <div className="font-bold text-white flex items-center justify-between">
                  <span>Field Inspection Officers & Highway Engineers</span>
                  <span className="text-[10px] bg-orange-950 text-orange-300 border border-orange-700 px-2 py-0.5 rounded font-bold">SECONDARY</span>
                </div>
                <p className="text-slate-400 text-[11px]">Receives WATCH & WARNING alerts for ground slope assessment and drainage clearing.</p>
              </div>

              <div className="p-3 bg-slate-800/60 border border-slate-700/50 rounded-xl space-y-1">
                <div className="font-bold text-white flex items-center justify-between">
                  <span>Registered Local Citizens & Cell Broadcast Grid</span>
                  <span className="text-[10px] bg-purple-950 text-purple-300 border border-purple-700 px-2 py-0.5 rounded font-bold">PUBLIC</span>
                </div>
                <p className="text-slate-400 text-[11px]">Receives localized SMS hazard warnings when EVACUATION threshold is crossed.</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
