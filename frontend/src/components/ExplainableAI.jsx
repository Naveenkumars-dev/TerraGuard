import React from 'react';
import { Brain, Sparkles, AlertCircle, CheckCircle2, TrendingUp, Cpu, Info } from 'lucide-react';

export const ExplainableAI = ({ zone }) => {
  if (!zone) {
    return (
      <div className="bg-slate-900/90 border border-slate-800 rounded-2xl p-6 text-center text-slate-400 text-xs">
        Select a landslide risk zone on the map to view Explainable AI Risk Analysis.
      </div>
    );
  }

  // Calculate factor percentages
  const normRainfall = Math.min(100, (zone.rainfall / 150) * 100);
  const normSoil = Math.min(100, zone.soil_moisture);
  const normSlope = Math.min(100, (zone.slope / 50) * 100);

  const getImpact = (val) => {
    if (val >= 70) return { label: 'HIGH', bar: 'bg-red-500', text: 'text-red-400', badge: 'bg-red-950 text-red-300 border-red-700/60' };
    if (val >= 40) return { label: 'MEDIUM', bar: 'bg-orange-500', text: 'text-orange-400', badge: 'bg-orange-950 text-orange-300 border-orange-700/60' };
    return { label: 'LOW', bar: 'bg-emerald-500', text: 'text-emerald-400', badge: 'bg-emerald-950 text-emerald-300 border-emerald-700/60' };
  };

  const factors = [
    {
      name: 'Heavy Rainfall Intensity (24h)',
      value: `${zone.rainfall} mm`,
      norm: normRainfall,
      weight: '30%',
      impact: getImpact(normRainfall)
    },
    {
      name: 'Soil Saturation Index',
      value: `${zone.soil_moisture}%`,
      norm: normSoil,
      weight: '20%',
      impact: getImpact(normSoil)
    },
    {
      name: 'Terrain Slope Gradient',
      value: `${zone.slope}°`,
      norm: normSlope,
      weight: '20%',
      impact: getImpact(normSlope)
    },
    {
      name: 'Historical Landslide Index',
      value: `${zone.historical_risk} / 100`,
      norm: zone.historical_risk,
      weight: '15%',
      impact: getImpact(zone.historical_risk)
    },
    {
      name: 'Satellite Terrain Change',
      value: `${zone.satellite_change} / 100`,
      norm: zone.satellite_change,
      weight: '10%',
      impact: getImpact(zone.satellite_change)
    },
    {
      name: 'Field Distress Reports',
      value: `${zone.field_reports_count || 0} active`,
      norm: Math.min(100, (zone.field_reports_count || 0) * 25),
      weight: '5%',
      impact: getImpact((zone.field_reports_count || 0) * 25)
    }
  ];

  const confidence = Math.min(96, Math.round(85 + (zone.field_reports_count || 0) * 1.5 + (zone.rainfall > 60 ? 4 : 2)));

  return (
    <div className="glass-panel border border-gov-gold/30 rounded-2xl p-5 shadow-2xl space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-gov-gold/20 pb-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 gov-emblem rounded-xl text-gov-gold shadow-md">
            <Brain className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-black text-white flex items-center gap-2">
              Explainable AI Risk Factor Analysis
              <Sparkles className="w-3.5 h-3.5 text-gov-gold animate-pulse" />
            </h3>
            <p className="text-[11px] text-slate-300 font-medium">Model weights & impact breakdown for {zone.name}</p>
          </div>
        </div>

        <div className="text-right">
          <span className="text-[9px] uppercase font-extrabold text-slate-400 block tracking-wider">Prediction Confidence</span>
          <span className="text-xs font-black text-gov-gold bg-gov-blue/80 px-2.5 py-0.5 rounded-full border border-gov-gold/40 font-mono">
            {confidence}%
          </span>
        </div>
      </div>

      {/* Why is this zone at risk? */}
      <div className="space-y-3">
        <h4 className="text-xs font-extrabold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
          <Info className="w-3.5 h-3.5 text-gov-gold" />
          Why is this zone at risk?
        </h4>

        <div className="space-y-3">
          {factors.map((f, i) => (
            <div key={i} className="bg-gov-blue/60 rounded-xl p-3 border border-gov-gold/20 space-y-2">
              <div className="flex items-center justify-between text-xs font-bold">
                <div className="flex items-center gap-2 text-slate-200">
                  <span>{f.name}</span>
                  <span className="text-[10px] text-slate-500 font-mono">({f.weight})</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-mono text-slate-300 font-bold">{f.value}</span>
                  <span className={`px-2 py-0.5 rounded text-[9px] font-black uppercase border ${f.impact.badge}`}>
                    {f.impact.label}
                  </span>
                </div>
              </div>

              {/* Factor Progress Bar */}
              <div className="w-full bg-slate-950 h-2 rounded-full overflow-hidden border border-gov-gold/20">
                <div
                  className={`h-full rounded-full transition-all duration-500 ${f.impact.bar}`}
                  style={{ width: `${Math.max(5, f.norm)}%` }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* AI Narrative Assessment */}
      <div className="bg-gradient-to-r from-gov-blue/60 via-slate-900 to-gov-green/40 border border-gov-gold/30 rounded-2xl p-4 space-y-2 shadow-inner">
        <div className="flex items-center gap-2 text-gov-gold font-extrabold text-xs">
          <Cpu className="w-4 h-4 text-gov-gold" />
          <span>AI Synthesis & Hazard Narrative</span>
        </div>
        <p className="text-xs text-slate-200 leading-relaxed italic font-medium">
          "{zone.rainfall > 70
            ? `The combination of intense rainfall (${zone.rainfall}mm), high soil saturation (${zone.soil_moisture}%) and steep slope terrain (${zone.slope}°) significantly elevates landslide probability in ${zone.name}.`
            : `Parameters indicate moderate soil saturation (${zone.soil_moisture}%) with stable terrain limits in ${zone.name}. Regular monitoring advised.`}"
        </p>
      </div>
    </div>
  );
};
