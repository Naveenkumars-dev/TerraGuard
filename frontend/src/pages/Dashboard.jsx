import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { fetchZones, fetchAlerts, fetchReports, fetchAuditLogs, simulateRainfallEvent } from '../services/api';
import { KPICards } from '../components/KPICards';
import { RiskMap } from '../components/RiskMap';
import { ExplainableAI } from '../components/ExplainableAI';
import { DataSourceStatus } from '../components/DataSourceStatus';
import { AuditLogView } from '../components/AuditLogView';
import { CloudRain, AlertTriangle, ShieldCheck, ArrowRight, Activity, Sparkles, MapPin } from 'lucide-react';

export const Dashboard = () => {
  const {
    selectedDistrict,
    selectedZoneId,
    setSelectedZoneId,
    setActiveTab,
    refreshTrigger,
    triggerRefresh,
    setLiveAlertNotification
  } = useApp();

  const [zones, setZones] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [reports, setReports] = useState([]);
  const [auditLogs, setAuditLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [simulating, setSimulating] = useState(false);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      try {
        const [z, a, r, l] = await Promise.all([
          fetchZones(selectedDistrict),
          fetchAlerts(),
          fetchReports(),
          fetchAuditLogs()
        ]);
        setZones(z);
        setAlerts(a);
        setReports(r);
        setAuditLogs(l);
      } catch (err) {
        console.error('Failed to load dashboard data', err);
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, [selectedDistrict, refreshTrigger]);

  const selectedZone = zones.find((z) => z.id === selectedZoneId) || zones[0] || null;

  const handleSimulateRainfall = async () => {
    setSimulating(true);
    try {
      const res = await simulateRainfallEvent(selectedZone ? selectedZone.id : null);
      triggerRefresh();
      if (res && res.notification) {
        setLiveAlertNotification(res.notification);
      }
    } catch (err) {
      console.error('Rainfall simulation failed', err);
    } finally {
      setSimulating(false);
    }
  };

  return (
    <div className="p-6 space-y-6 max-w-[1700px] mx-auto">
      {/* Official Government Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4 glass-panel p-5 rounded-2xl shadow-2xl border-t-4 border-gov-gold">
        <div>
          <div className="flex items-center gap-2.5 mb-1">
            <h2 className="text-xl font-black text-white tracking-tight flex items-center gap-2.5">
              NER Landslide Risk Monitoring Command Center
            </h2>
            <span className="px-2 py-0.5 text-[9px] font-extrabold uppercase tracking-widest bg-gov-gold/20 text-gov-gold border border-gov-gold/40 rounded-full">
              OFFICIAL
            </span>
          </div>
          <p className="text-xs text-slate-300 mt-1 font-medium">
            Multi-Source Sensor Telemetry • AI Explainable Risk Aggregation • Automated Dispatches
          </p>
        </div>

        {/* Cloudburst Simulator Button */}
        <button
          onClick={handleSimulateRainfall}
          disabled={simulating}
          className="px-5 py-3 bg-gradient-to-r from-gov-gold/80 to-gov-gold/60 hover:from-gov-gold hover:to-gov-gold/70 text-gov-blue font-black text-xs rounded-xl shadow-lg shadow-gov-gold/30 border border-gov-gold/50 flex items-center gap-2.5 transition-all transform hover:scale-[1.02] active:scale-95 cursor-pointer"
        >
          <CloudRain className={`w-4 h-4 ${simulating ? 'animate-spin' : 'animate-bounce'}`} />
          <span>{simulating ? 'Simulating Cloudburst...' : 'Simulate Heavy Rainfall Event'}</span>
        </button>
      </div>

      {/* KPI Metric Cards */}
      <KPICards zones={zones} alerts={alerts} />

      {/* Main Row: Interactive Map + Explainable AI Side Panel */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Large GIS Map */}
        <div className="lg:col-span-2 space-y-4">
          <div className="glass-panel rounded-2xl p-4 shadow-2xl space-y-3 border border-gov-gold/30">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <MapPin className="w-4 h-4 text-gov-gold" />
                <h3 className="text-sm font-extrabold text-white uppercase tracking-wider">
                  Official GIS Landslide Risk Map – North East India
                </h3>
              </div>
              <button
                onClick={() => setActiveTab('risk-map')}
                className="text-xs text-gov-gold hover:text-gov-gold/80 font-extrabold flex items-center gap-1 transition-colors"
              >
                <span>Expanded GIS Map</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="h-[480px] w-full">
              <RiskMap
                zones={zones}
                reports={reports}
                selectedZoneId={selectedZoneId}
                onSelectZone={(id) => setSelectedZoneId(id)}
              />
            </div>
          </div>
        </div>

        {/* Right Column: Explainable AI & Selected Zone Details */}
        <div className="space-y-6">
          <ExplainableAI zone={selectedZone} />

          {/* Quick Zone Details Card */}
          {selectedZone && (
            <div className="glass-panel rounded-2xl p-4 shadow-xl space-y-3 text-xs border border-gov-gold/30">
              <div className="flex items-center justify-between border-b border-gov-gold/20 pb-2.5">
                <div>
                  <span className="text-[9px] uppercase font-extrabold text-slate-400 block">Selected Zone</span>
                  <span className="font-extrabold text-white text-sm">{selectedZone.name}</span>
                </div>
                <button
                  onClick={() => setActiveTab('zone-details')}
                  className="px-3 py-1.5 bg-gov-blue/80 hover:bg-gov-blue/70 text-gov-gold rounded-lg font-bold text-[11px] border border-gov-gold/40 transition-colors"
                >
                  View Full Zone
                </button>
              </div>

              <div className="grid grid-cols-2 gap-2 text-slate-300">
                <div className="bg-gov-blue/60 p-2.5 rounded-xl border border-gov-gold/20">
                  <span className="text-slate-400 text-[10px] block font-bold">Rainfall (24h)</span>
                  <span className="font-extrabold text-gov-gold text-sm">{selectedZone.rainfall} mm</span>
                </div>
                <div className="bg-gov-blue/60 p-2.5 rounded-xl border border-gov-gold/20">
                  <span className="text-slate-400 text-[10px] block font-bold">Soil Saturation</span>
                  <span className="font-extrabold text-gov-gold text-sm">{selectedZone.soil_moisture}%</span>
                </div>
                <div className="bg-gov-blue/60 p-2.5 rounded-xl border border-gov-gold/20">
                  <span className="text-slate-400 text-[10px] block font-bold">Slope Gradient</span>
                  <span className="font-extrabold text-gov-gold text-sm">{selectedZone.slope}°</span>
                </div>
                <div className="bg-gov-blue/60 p-2.5 rounded-xl border border-gov-gold/20">
                  <span className="text-slate-400 text-[10px] block font-bold">Field Reports</span>
                  <span className="font-extrabold text-gov-gold text-sm">{selectedZone.field_reports_count || 0} active</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Bottom Grid: Data Source Feeds + Activity Audit Trail */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <DataSourceStatus />
        <AuditLogView logs={auditLogs} />
      </div>
    </div>
  );
};
