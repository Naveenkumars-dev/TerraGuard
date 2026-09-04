import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { fetchZones, fetchReports } from '../services/api';
import { RiskMap } from '../components/RiskMap';
import { MapPin, Filter, Layers, Info, ArrowRight } from 'lucide-react';

export const RiskMapPage = () => {
  const { selectedZoneId, setSelectedZoneId, setActiveTab } = useApp();
  const [zones, setZones] = useState([]);
  const [reports, setReports] = useState([]);
  const [filterLevel, setFilterLevel] = useState('ALL');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadMapData = async () => {
      setLoading(true);
      try {
        const [z, r] = await Promise.all([fetchZones(), fetchReports()]);
        setZones(z);
        setReports(r);
      } finally {
        setLoading(false);
      }
    };
    loadMapData();
  }, []);

  const filteredZones = zones.filter((z) => {
    if (filterLevel === 'ALL') return true;
    return z.risk_level === filterLevel;
  });

  const selectedZone = zones.find((z) => z.id === selectedZoneId) || filteredZones[0] || null;

  return (
    <div className="p-6 space-y-6 max-w-[1700px] mx-auto h-[calc(100vh-80px)] flex flex-col">
      {/* Top Controls Bar */}
      <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-red-950/60 border border-red-500/40 rounded-lg text-red-400">
            <MapPin className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">Full GIS Risk Map Command Interface</h2>
            <p className="text-xs text-slate-400">
              Showing {filteredZones.length} of {zones.length} North Eastern Region slope monitoring zones
            </p>
          </div>
        </div>

        {/* Filter buttons */}
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-slate-400 flex items-center gap-1">
            <Filter className="w-3.5 h-3.5" /> Level:
          </span>
          {['ALL', 'EVACUATE', 'WARNING', 'WATCH', 'SAFE'].map((lvl) => (
            <button
              key={lvl}
              onClick={() => setFilterLevel(lvl)}
              className={`px-3 py-1 rounded-lg text-xs font-bold transition-all border ${
                filterLevel === lvl
                  ? 'bg-red-600 text-white border-red-500 shadow'
                  : 'bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700'
              }`}
            >
              {lvl}
            </button>
          ))}
        </div>
      </div>

      {/* Map + Inspector Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 flex-1 min-h-0">
        {/* Map Container (Takes 3 Columns) */}
        <div className="lg:col-span-3 bg-slate-900 border border-slate-800 rounded-2xl p-2 shadow-xl h-full min-h-[500px]">
          <RiskMap
            zones={filteredZones}
            reports={reports}
            selectedZoneId={selectedZoneId}
            onSelectZone={(id) => setSelectedZoneId(id)}
          />
        </div>

        {/* Zone Inspector Drawer (Takes 1 Column) */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl flex flex-col justify-between overflow-y-auto">
          {selectedZone ? (
            <div className="space-y-5 text-xs">
              <div className="border-b border-slate-800 pb-3">
                <span className="text-[10px] uppercase font-bold text-slate-400">Zone Inspector</span>
                <h3 className="text-base font-extrabold text-white">{selectedZone.name}</h3>
                <p className="text-slate-400">{selectedZone.district}, {selectedZone.state}</p>
              </div>

              {/* Status Badge */}
              <div className="bg-slate-800/80 p-3 rounded-xl border border-slate-700/60 flex items-center justify-between">
                <div>
                  <span className="text-[10px] text-slate-400 block uppercase font-bold">Landslide Risk Level</span>
                  <span className="text-sm font-black text-red-400">{selectedZone.risk_level}</span>
                </div>
                <span className="text-xl font-extrabold text-white bg-slate-900 px-3 py-1 rounded-lg border border-slate-700">
                  {selectedZone.risk_score} / 100
                </span>
              </div>

              {/* Metrics */}
              <div className="space-y-2">
                <h4 className="font-bold text-slate-300 text-[11px] uppercase tracking-wider">Environmental Metrics</h4>
                <div className="space-y-1.5 font-mono">
                  <div className="flex justify-between bg-slate-800/50 p-2 rounded text-slate-200">
                    <span>Rainfall (24h):</span>
                    <strong className="text-sky-400">{selectedZone.rainfall} mm</strong>
                  </div>
                  <div className="flex justify-between bg-slate-800/50 p-2 rounded text-slate-200">
                    <span>Soil Moisture:</span>
                    <strong className="text-amber-400">{selectedZone.soil_moisture}%</strong>
                  </div>
                  <div className="flex justify-between bg-slate-800/50 p-2 rounded text-slate-200">
                    <span>Slope Gradient:</span>
                    <strong className="text-slate-200">{selectedZone.slope}°</strong>
                  </div>
                  <div className="flex justify-between bg-slate-800/50 p-2 rounded text-slate-200">
                    <span>Historical Risk Index:</span>
                    <strong className="text-purple-400">{selectedZone.historical_risk}</strong>
                  </div>
                  <div className="flex justify-between bg-slate-800/50 p-2 rounded text-slate-200">
                    <span>Satellite Change:</span>
                    <strong className="text-slate-300">{selectedZone.satellite_change}</strong>
                  </div>
                </div>
              </div>

              {/* Vulnerability Impact */}
              <div className="space-y-2">
                <h4 className="font-bold text-slate-300 text-[11px] uppercase tracking-wider">Vulnerability & Impact</h4>
                <div className="grid grid-cols-2 gap-2 text-center">
                  <div className="bg-slate-800/60 p-2.5 rounded border border-slate-700">
                    <span className="text-[10px] text-slate-400 block">Population</span>
                    <span className="font-bold text-white text-sm">{(selectedZone.population_affected || 0).toLocaleString()}</span>
                  </div>
                  <div className="bg-slate-800/60 p-2.5 rounded border border-slate-700">
                    <span className="text-[10px] text-slate-400 block">Roads at Risk</span>
                    <span className="font-bold text-white text-sm">{selectedZone.roads_affected || 0}</span>
                  </div>
                </div>
              </div>

              {/* Recommended Action */}
              <div className="bg-red-950/30 border border-red-800/50 p-3 rounded-xl space-y-1">
                <span className="text-[10px] font-bold text-red-400 uppercase block">Recommended Action</span>
                <p className="text-[11px] text-red-200 italic">{selectedZone.recommended_action}</p>
              </div>

              <button
                onClick={() => setActiveTab('zone-details')}
                className="w-full py-2.5 bg-red-600 hover:bg-red-500 text-white font-bold text-xs rounded-xl shadow-lg flex items-center justify-center gap-2"
              >
                <span>View Full Zone Details & Trends</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          ) : (
            <div className="text-center text-slate-400 text-xs py-10">Select a zone on the map to inspect.</div>
          )}
        </div>
      </div>
    </div>
  );
};
