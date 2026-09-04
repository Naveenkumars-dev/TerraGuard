import React from 'react';
import { Database, CheckCircle2, AlertCircle, Clock, ShieldAlert } from 'lucide-react';

export const DataSourceStatus = ({ sources = [] }) => {
  const defaultSources = [
    { name: 'IMD Rainfall API', type: 'Meteorological Feed', status: 'Connected', latency: '42ms', lastUpdate: '2 mins ago', isSimulated: true },
    { name: 'ISRO Sentinel-2 Satellite', type: 'EO Remote Sensing', status: 'Connected', latency: '180ms', lastUpdate: '15 mins ago', isSimulated: true },
    { name: 'GSI High-Resolution DEM', type: 'Geospatial GIS Data', status: 'Available', latency: '12ms', lastUpdate: 'Cached static DEM', isSimulated: false },
    { name: 'State Telemetric Soil Sensors', type: 'IoT Hardware Grid', status: '18/24 Sensors Online', latency: '110ms', lastUpdate: '1 min ago', isSimulated: true },
    { name: 'Historical Landslide Archive', type: 'Historical Database', status: 'Available', latency: '5ms', lastUpdate: 'Connected', isSimulated: false }
  ];

  const data = sources.length > 0 ? sources : defaultSources;

  return (
    <div className="bg-slate-900/90 border border-slate-800 rounded-xl p-5 shadow-xl space-y-4">
      <div className="flex items-center justify-between border-b border-slate-800 pb-3">
        <div className="flex items-center gap-2.5">
          <div className="p-2 bg-sky-950/60 border border-sky-500/40 rounded-lg text-sky-400">
            <Database className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-white">Data Source Feeds & Telemetry</h3>
            <p className="text-[11px] text-slate-400">Connected environmental sensors & GIS satellite streams</p>
          </div>
        </div>
        <span className="px-2 py-0.5 text-[9px] font-bold bg-purple-950 text-purple-300 border border-purple-700/50 rounded uppercase">
          Prototype / Simulated Feed
        </span>
      </div>

      <div className="space-y-2.5">
        {data.map((src, idx) => (
          <div
            key={idx}
            className="p-3 bg-slate-800/60 border border-slate-700/50 rounded-lg flex items-center justify-between text-xs"
          >
            <div className="space-y-0.5">
              <div className="flex items-center gap-2 font-bold text-slate-200">
                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                <span>{src.name}</span>
              </div>
              <div className="text-[10px] text-slate-400">{src.type}</div>
            </div>

            <div className="text-right space-y-0.5">
              <span className="text-[11px] font-bold text-emerald-400 bg-emerald-950/80 px-2 py-0.5 rounded border border-emerald-800/60">
                ● {src.status}
              </span>
              <div className="text-[10px] text-slate-400 flex items-center gap-1 justify-end pt-1">
                <Clock className="w-3 h-3 text-slate-500" />
                <span>{src.lastUpdate}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
