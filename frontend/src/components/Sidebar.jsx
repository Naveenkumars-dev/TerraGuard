import React from 'react';
import { useApp } from '../context/AppContext';
import {
  LayoutDashboard,
  MapPin,
  FileText,
  BellRing,
  FileSpreadsheet,
  BarChart3,
  Sliders,
  Server,
  Radio,
  ChevronRight,
  ShieldCheck
} from 'lucide-react';

export const Sidebar = () => {
  const { activeTab, setActiveTab, userRole } = useApp();

  const navItems = [
    { id: 'dashboard', label: 'Command Center', icon: LayoutDashboard },
    { id: 'risk-map', label: 'GIS Risk Map', icon: MapPin },
    { id: 'zone-details', label: 'Zone Deep-Dive', icon: FileText },
    { id: 'alerts', label: 'Alert Dispatch', icon: BellRing, badge: 'ACTIVE' },
    { id: 'reports', label: 'Field/Citizen Reports', icon: FileSpreadsheet },
    { id: 'analytics', label: 'Historical Analytics', icon: BarChart3 },
    { id: 'admin', label: 'Administration', icon: Sliders },
    { id: 'system-status', label: 'System Telemetry', icon: Server }
  ];

  return (
    <aside className="w-64 gov-blue border-r-2 border-gov-gold/30 flex flex-col justify-between h-[calc(100vh-85px)] sticky top-[85px] select-none backdrop-blur-md">
      <div className="p-4 space-y-5">
        {/* Official Government Portal Branding */}
        <div className="bg-gov-blue/80 rounded-2xl p-3.5 border border-gov-gold/40 shadow-inner">
          <div className="flex items-center gap-2 text-xs font-extrabold text-gov-gold mb-1">
            <Radio className="w-3.5 h-3.5 text-gov-gold animate-pulse" />
            <span>NATIONAL DISASTER GRID</span>
          </div>
          <p className="text-[11px] text-slate-300 font-medium">North Eastern Region Early Warning Command</p>
          <div className="mt-2 pt-2 border-t border-gov-gold/20">
            <p className="text-[9px] text-slate-400 font-medium tracking-wide">OFFICIAL GOVERNMENT SYSTEM</p>
          </div>
        </div>

        {/* Navigation Section */}
        <nav className="space-y-1">
          <span className="text-[10px] uppercase font-bold text-slate-500 tracking-wider px-3 mb-2 block">
            Navigation Menu
          </span>
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs font-extrabold transition-all group ${
                  isActive
                    ? 'bg-gradient-to-r from-gov-gold/30 to-gov-gold/10 text-gov-gold shadow-lg shadow-gov-gold/20 border border-gov-gold/50 scale-[1.02]'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-gov-blue/70 border border-transparent'
                }`}
              >
                <div className="flex items-center gap-3">
                  <Icon className={`w-4 h-4 transition-transform group-hover:scale-110 ${isActive ? 'text-white' : 'text-slate-400'}`} />
                  <span>{item.label}</span>
                </div>
                {item.badge ? (
                  <span className="px-2 py-0.5 text-[9px] font-black bg-gov-gold/20 text-gov-gold border border-gov-gold/60 rounded-full animate-pulse">
                    {item.badge}
                  </span>
                ) : (
                  <ChevronRight className={`w-3.5 h-3.5 transition-opacity ${isActive ? 'opacity-100 text-gov-gold' : 'opacity-0 group-hover:opacity-100 text-slate-500'}`} />
                )}
              </button>
            );
          })}
        </nav>
      </div>

      {/* Sidebar Footer info */}
      <div className="p-4 border-t border-gov-gold/20 text-[11px] text-slate-400 space-y-2 bg-gov-blue/40">
        <div className="flex justify-between items-center bg-gov-blue/80 px-2.5 py-1.5 rounded-lg border border-gov-gold/30 text-slate-200">
          <span className="text-[10px] uppercase font-bold text-slate-400">Active Role</span>
          <span className="font-extrabold text-xs text-gov-gold">{userRole}</span>
        </div>
        <div className="text-[10px] text-slate-400 text-center font-medium border-t border-gov-gold/20 pt-2">
          <div className="flex items-center justify-center gap-1.5 mb-1">
            <span className="w-1.5 h-1.5 bg-gov-gold rounded-full"></span>
            <span className="text-gov-gold font-bold">OFFICIAL GOVERNMENT SYSTEM</span>
            <span className="w-1.5 h-1.5 bg-gov-gold rounded-full"></span>
          </div>
          <span>Smart India Hackathon 2026 (SIH26001)</span>
        </div>
      </div>
    </aside>
  );
};
