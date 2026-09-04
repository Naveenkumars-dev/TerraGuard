import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import {
  ShieldAlert,
  Activity,
  Wifi,
  WifiOff,
  UserCheck,
  PlayCircle,
  Clock,
  Filter,
  Radio,
  ChevronDown,
  Sparkles
} from 'lucide-react';

export const Header = () => {
  const {
    userRole,
    setUserRole,
    lowBandwidthMode,
    setLowBandwidthMode,
    selectedDistrict,
    setSelectedDistrict,
    demoModeActive,
    setDemoModeActive
  } = useApp();

  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const districts = [
    'All Districts',
    'East Khasi Hills',
    'East Sikkim',
    'Tawang',
    'Aizawl',
    'Kohima',
    'Dima Hasao',
    'Ri-Bhoi',
    'South Garo Hills'
  ];

  const roleColors = {
    'District Admin': 'bg-red-950 text-red-300 border-red-700/60',
    'Field Official': 'bg-sky-950 text-sky-300 border-sky-700/60',
    'Citizen': 'bg-emerald-950 text-emerald-300 border-emerald-700/60',
    'State Authority': 'bg-purple-950 text-purple-300 border-purple-700/60'
  };

  return (
    <header className="gov-blue backdrop-blur-xl border-b-2 border-d4a574/30 text-slate-100 sticky top-0 z-40 shadow-2xl">
      {/* Official Government Banner */}
      <div className="bg-gradient-to-r from-d4a574/20 via-transparent to-d4a574/20 border-b border-d4a574/20 py-1">
        <div className="max-w-[1700px] mx-auto px-6 flex items-center justify-center gap-4 text-[10px] font-bold tracking-wider text-d4a574">
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 bg-d4a574 rounded-full animate-pulse"></span>
            GOVERNMENT OF INDIA
          </span>
          <span className="text-d4a574/50">|</span>
          <span>MINISTRY OF DEVELOPMENT OF NORTH EASTERN REGION</span>
          <span className="text-d4a574/50">|</span>
          <span>NATIONAL DISASTER MANAGEMENT AUTHORITY</span>
        </div>
      </div>

      {/* Low-Bandwidth Notice Banner */}
      {lowBandwidthMode && (
        <div className="bg-gradient-to-r from-amber-600 to-amber-700 text-amber-5 px-6 py-1 text-xs font-bold flex items-center justify-between shadow-md">
          <div className="flex items-center gap-2">
            <WifiOff className="w-4 h-4 text-amber-200" />
            <span>LOW CONNECTIVITY MODE ACTIVE — Cached GIS risk parameters loaded & SMS fallback protocol enabled.</span>
          </div>
          <span className="text-[10px] bg-amber-900/80 px-2.5 py-0.5 rounded-full border border-amber-500/50 uppercase font-mono tracking-wide">
            Fallback: SMS / IVR Protocol Active
          </span>
        </div>
      )}

      <div className="max-w-[1700px] mx-auto px-6 py-3 flex flex-wrap items-center justify-between gap-4">
        {/* Left Branding */}
        <div className="flex items-center gap-3.5">
          <div className="relative p-2.5 gov-emblem rounded-xl text-d4a574 shadow-lg">
            <ShieldAlert className="w-7 h-7" />
            <span className="absolute -top-1 -right-1 w-3 h-3 bg-d4a574 rounded-full border-2 border-slate-900 animate-pulse"></span>
          </div>

          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-xl font-black tracking-tight text-white flex items-center gap-2">
                TerraGuard NER
              </h1>
              <span className="px-2.5 py-0.5 text-[10px] font-extrabold uppercase tracking-widest bg-d4a574/20 text-d4a574 border border-d4a574/40 rounded-full shadow-inner">
                OFFICIAL SYSTEM
              </span>
            </div>
            <p className="text-[11px] text-slate-300 font-medium tracking-wide">
              AI Landslide Early Warning & Risk Monitoring System • Ministry of Development of North Eastern Region (MDoNER)
            </p>
          </div>
        </div>

        {/* Center Operational Status bar */}
        <div className="hidden lg:flex items-center gap-5 text-xs bg-slate-950/80 px-4 py-2 rounded-xl border border-slate-800 shadow-inner">
          <div className="flex items-center gap-2">
            <Radio className="w-4 h-4 text-emerald-400 animate-pulse" />
            <div>
              <span className="text-slate-500 block text-[9px] uppercase font-bold tracking-wider">Grid Status</span>
              <span className="font-extrabold text-emerald-400 text-[11px]">NER REAL-TIME ACTIVE</span>
            </div>
          </div>

          <div className="h-6 w-px bg-slate-800"></div>

          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-sky-400" />
            <div>
              <span className="text-slate-500 block text-[9px] uppercase font-bold tracking-wider">Current Time</span>
              <span className="font-mono font-bold text-slate-200 text-[11px]">
                {currentTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })} IST
              </span>
            </div>
          </div>

          <div className="h-6 w-px bg-slate-800"></div>

          {/* District Filter */}
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-amber-400" />
            <div>
              <span className="text-slate-500 block text-[9px] uppercase font-bold tracking-wider">District Focus</span>
              <select
                value={selectedDistrict}
                onChange={(e) => setSelectedDistrict(e.target.value)}
                className="bg-slate-900 text-[11px] font-bold text-slate-200 border border-slate-700/80 rounded-md px-2 py-0.5 focus:outline-none focus:border-amber-500 cursor-pointer"
              >
                {districts.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {/* Right Action Controls */}
        <div className="flex items-center gap-3">
          {/* Low Bandwidth Toggle Button */}
          <button
            onClick={() => setLowBandwidthMode(!lowBandwidthMode)}
            className={`px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-2 transition-all border shadow ${
              lowBandwidthMode
                ? 'bg-amber-500/20 text-amber-300 border-amber-500/60 shadow-amber-950/40'
                : 'bg-slate-800/80 text-slate-300 border-slate-700 hover:bg-slate-700/80'
            }`}
            title="Toggle Low Bandwidth Connectivity Mode"
          >
            {lowBandwidthMode ? (
              <WifiOff className="w-4 h-4 text-amber-400" />
            ) : (
              <Wifi className="w-4 h-4 text-emerald-400" />
            )}
            <span className="hidden sm:inline">{lowBandwidthMode ? 'Low Connectivity' : 'Full Bandwidth'}</span>
          </button>

          {/* Role Selector */}
          <div className="flex items-center gap-1.5 bg-slate-800/90 border border-slate-700 rounded-xl px-2.5 py-1 shadow-sm">
            <UserCheck className="w-4 h-4 text-sky-400" />
            <select
              value={userRole}
              onChange={(e) => setUserRole(e.target.value)}
              className="bg-transparent text-xs text-slate-200 font-extrabold focus:outline-none cursor-pointer"
            >
              <option value="District Admin" className="bg-slate-900 text-slate-200">
                District Admin
              </option>
              <option value="Field Official" className="bg-slate-900 text-slate-200">
                Field Official
              </option>
              <option value="Citizen" className="bg-slate-900 text-slate-200">
                Citizen
              </option>
              <option value="State Authority" className="bg-slate-900 text-slate-200">
                State Authority
              </option>
            </select>
          </div>

          {/* Demo Mode Button */}
          <button
            onClick={() => setDemoModeActive(!demoModeActive)}
            className={`px-4 py-1.5 rounded-xl text-xs font-extrabold flex items-center gap-2 transition-all shadow-lg border ${
              demoModeActive
                ? 'bg-purple-600 text-white border-purple-400 shadow-purple-950/60 animate-pulse'
                : 'bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-500 hover:to-indigo-500 text-white border-purple-400/40 shadow-purple-950/30'
            }`}
          >
            <Sparkles className="w-4 h-4" />
            <span>{demoModeActive ? 'Exit Demo' : 'Demo Mode'}</span>
          </button>
        </div>
      </div>
    </header>
  );
};
