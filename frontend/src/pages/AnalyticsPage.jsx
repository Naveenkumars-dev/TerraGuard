import React, { useState, useEffect } from 'react';
import { fetchAnalytics } from '../services/api';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import { BarChart3, TrendingUp, Calendar, Filter } from 'lucide-react';

export const AnalyticsPage = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const res = await fetchAnalytics();
        setData(res);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  if (!data) {
    return <div className="p-8 text-center text-slate-400 text-xs">Loading analytics...</div>;
  }

  return (
    <div className="p-6 space-y-6 max-w-[1600px] mx-auto">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-950/60 border border-indigo-500/40 rounded-lg text-indigo-400">
            <BarChart3 className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">Historical Disaster Management & AI Risk Analytics</h2>
            <p className="text-xs text-slate-400">Aggregated rainfall trends, alert frequency, and crowdsourced reporting statistics</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Calendar className="w-4 h-4 text-slate-400" />
          <select className="bg-slate-800 text-xs font-bold text-slate-200 border border-slate-700 rounded-lg px-3 py-1.5 focus:outline-none">
            <option>Current Monsoon Season (2026)</option>
            <option>Last 12 Months</option>
            <option>Historical 5-Year Average</option>
          </select>
        </div>
      </div>

      {/* Grid 1: Monthly Incidents & Rainfall vs Risk Score */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Monthly Incidents Bar Chart */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl space-y-3">
          <h3 className="text-sm font-bold text-white uppercase tracking-wider">
            Landslide Incidents & Monsoon Rainfall (Monthly)
          </h3>
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.monthlyIncidents}>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey="month" stroke="#94a3b8" fontSize={11} />
                <YAxis yAxisId="left" stroke="#94a3b8" fontSize={11} />
                <YAxis yAxisId="right" orientation="right" stroke="#38bdf8" fontSize={11} />
                <Tooltip contentStyle={{ backgroundColor: '#1e293b', borderColor: '#334155', borderRadius: '8px', color: '#fff', fontSize: '12px' }} />
                <Bar yAxisId="left" dataKey="incidents" fill="#EF4444" radius={[4, 4, 0, 0]} name="Incidents" />
                <Line yAxisId="right" type="monotone" dataKey="rainfall" stroke="#38bdf8" strokeWidth={2} name="Rainfall (mm)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Rainfall vs Risk Score */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl space-y-3">
          <h3 className="text-sm font-bold text-white uppercase tracking-wider">
            Rainfall vs Risk Score Correlation per Zone
          </h3>
          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.rainfallVsRisk}>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey="zone" stroke="#94a3b8" fontSize={9} interval={0} angle={-20} textAnchor="end" />
                <YAxis domain={[0, 150]} stroke="#94a3b8" fontSize={11} />
                <Tooltip contentStyle={{ backgroundColor: '#1e293b', borderColor: '#334155', borderRadius: '8px', color: '#fff', fontSize: '12px' }} />
                <Bar dataKey="rainfall" fill="#0284c7" name="Rainfall (mm)" />
                <Bar dataKey="riskScore" fill="#f97316" name="Risk Score" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Grid 2: Alerts by Severity & Report Verification Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Alerts Breakdown Pie Chart */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl space-y-3">
          <h3 className="text-sm font-bold text-white uppercase tracking-wider">
            Alert Distribution by Severity
          </h3>
          <div className="h-56 w-full flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={data.alertsBySeverity} dataKey="count" nameKey="level" cx="50%" cy="50%" outerRadius={70} label>
                  {data.alertsBySeverity.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ backgroundColor: '#1e293b', borderRadius: '8px', color: '#fff' }} />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Report Verification Pie Chart */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl space-y-3">
          <h3 className="text-sm font-bold text-white uppercase tracking-wider">
            Citizen Report Verification Stats
          </h3>
          <div className="h-56 w-full flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={data.reportVerificationStats} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={70} label>
                  {data.reportVerificationStats.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ backgroundColor: '#1e293b', borderRadius: '8px', color: '#fff' }} />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* District Risk Summary Table */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-xl space-y-3">
          <h3 className="text-sm font-bold text-white uppercase tracking-wider">
            Monitored District Coverage
          </h3>
          <div className="space-y-2 max-h-52 overflow-y-auto pr-1 text-xs">
            {data.zonesByDistrict.map((d, i) => (
              <div key={i} className="flex justify-between p-2.5 bg-slate-800/60 rounded-lg border border-slate-700/50">
                <span className="font-bold text-slate-200">{d.district}</span>
                <span className="font-mono text-sky-400 font-extrabold">{d.count} Monitored Zones</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
