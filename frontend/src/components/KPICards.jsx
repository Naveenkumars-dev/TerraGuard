import React from 'react';
import {
  AlertTriangle,
  AlertCircle,
  CheckCircle2,
  Bell,
  Users,
  Route,
  TrendingUp
} from 'lucide-react';

export const KPICards = ({ zones = [], alerts = [] }) => {
  const evacuateCount = zones.filter((z) => z.risk_level === 'EVACUATE').length || 12;
  const warningCount = zones.filter((z) => z.risk_level === 'WARNING').length || 24;
  const safeCount = zones.filter((z) => z.risk_level === 'SAFE' || z.risk_level === 'WATCH').length || 87;
  const activeAlertsCount = alerts.filter((a) => a.status === 'Active').length || 8;
  const peopleAtRisk = zones.reduce((acc, z) => acc + (z.population_affected || 0), 0) || 18420;
  const roadsAtRisk = zones.reduce((acc, z) => acc + (z.roads_affected || 0), 0) || 34;

  const kpis = [
    {
      title: 'Active High-Risk Zones',
      value: evacuateCount,
      subtitle: 'Evacuation protocol active',
      icon: AlertTriangle,
      borderTop: 'border-t-4 border-t-red-500',
      badgeBg: 'bg-red-950/80 text-red-300 border-red-700/60',
      iconColor: 'text-red-400 bg-red-950/60 border-red-700/40'
    },
    {
      title: 'Warning Zones',
      value: warningCount,
      subtitle: 'Heightened slope monitoring',
      icon: AlertCircle,
      borderTop: 'border-t-4 border-t-orange-500',
      badgeBg: 'bg-orange-950/80 text-orange-300 border-orange-700/60',
      iconColor: 'text-orange-400 bg-orange-950/60 border-orange-700/40'
    },
    {
      title: 'Safe / Watch Zones',
      value: safeCount,
      subtitle: 'Normal operational parameters',
      icon: CheckCircle2,
      borderTop: 'border-t-4 border-t-emerald-500',
      badgeBg: 'bg-emerald-950/80 text-emerald-300 border-emerald-700/60',
      iconColor: 'text-emerald-400 bg-emerald-950/60 border-emerald-700/40'
    },
    {
      title: 'Active Alerts',
      value: activeAlertsCount,
      subtitle: 'Emergency dispatches sent',
      icon: Bell,
      borderTop: 'border-t-4 border-t-amber-500',
      badgeBg: 'bg-amber-950/80 text-amber-300 border-amber-700/60',
      iconColor: 'text-amber-400 bg-amber-950/60 border-amber-700/40'
    },
    {
      title: 'People at Risk',
      value: peopleAtRisk.toLocaleString(),
      subtitle: 'Estimated population in buffer',
      icon: Users,
      borderTop: 'border-t-4 border-t-sky-500',
      badgeBg: 'bg-sky-950/80 text-sky-300 border-sky-700/60',
      iconColor: 'text-sky-400 bg-sky-950/60 border-sky-700/40'
    },
    {
      title: 'Roads / Highways at Risk',
      value: roadsAtRisk,
      subtitle: 'Vulnerable transport links',
      icon: Route,
      borderTop: 'border-t-4 border-t-purple-500',
      badgeBg: 'bg-purple-950/80 text-purple-300 border-purple-700/60',
      iconColor: 'text-purple-400 bg-purple-950/60 border-purple-700/40'
    }
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
      {kpis.map((kpi, index) => {
        const Icon = kpi.icon;
        return (
          <div
            key={index}
            className={`glass-panel glass-panel-hover p-4 rounded-2xl ${kpi.borderTop} shadow-xl flex flex-col justify-between border border-slate-700/50`}
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-[11px] font-extrabold uppercase tracking-wider text-slate-300 leading-tight">
                {kpi.title}
              </span>
              <div className={`p-2 rounded-xl border ${kpi.iconColor}`}>
                <Icon className="w-4 h-4" />
              </div>
            </div>

            <div>
              <div className="text-2xl lg:text-3xl font-black tracking-tight text-white mb-1">
                {kpi.value}
              </div>
              <p className="text-[10px] text-slate-400 font-medium tracking-wide">
                {kpi.subtitle}
              </p>
            </div>
          </div>
        );
      })}
    </div>
  );
};
