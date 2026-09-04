import React from 'react';
import { Shield, Clock, FileText, UserCheck, Bell } from 'lucide-react';

export const AuditLogView = ({ logs = [] }) => {
  const defaultLogs = [
    { id: 1, timestamp: '03:45 PM', event_type: 'SMS fallback triggered', zone_name: 'East Khasi Hills', details: 'Automated SMS broadcast dispatched to 1,200 grid contacts.', action_by: 'System Kernel' },
    { id: 2, timestamp: '03:44 PM', event_type: 'EVACUATE alert generated', zone_name: 'East Khasi Hills', details: 'Risk score reached 84.5. Escalated to EVACUATE status.', action_by: 'AI Risk Engine' },
    { id: 3, timestamp: '03:44 PM', event_type: 'Report verified', zone_name: 'East Khasi Hills', details: 'Citizen report TG-RPT-1040 verified by Field Official.', action_by: 'Inspector R. Sangma' },
    { id: 4, timestamp: '03:43 PM', event_type: 'Citizen report received', zone_name: 'East Khasi Hills', details: 'New tension crack report submitted with photo and GPS.', action_by: 'Citizen User' },
    { id: 5, timestamp: '03:42 PM', event_type: 'Risk score updated', zone_name: 'East Khasi Hills', details: 'Rainfall surge (112mm) updated risk score from 74 -> 84.5.', action_by: 'AI Risk Engine' }
  ];

  const list = logs.length > 0 ? logs : defaultLogs;

  return (
    <div className="bg-slate-900/90 border border-slate-800 rounded-xl p-5 shadow-xl space-y-4">
      <div className="flex items-center justify-between border-b border-slate-800 pb-3">
        <div className="flex items-center gap-2.5">
          <div className="p-2 bg-slate-800 border border-slate-700 rounded-lg text-slate-300">
            <Shield className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-white">System Activity & Audit Log</h3>
            <p className="text-[11px] text-slate-400">Immutable chronological event trail</p>
          </div>
        </div>
        <span className="text-[10px] text-slate-400 font-mono">LIVE FEED</span>
      </div>

      <div className="space-y-3 max-h-72 overflow-y-auto pr-1">
        {list.map((log, idx) => (
          <div key={idx} className="p-3 bg-slate-800/50 border border-slate-700/40 rounded-lg text-xs space-y-1">
            <div className="flex items-center justify-between">
              <span className="font-bold text-slate-200 text-[11px] uppercase tracking-wide flex items-center gap-1.5">
                <span className="w-1.5 h-1.5 rounded-full bg-red-400"></span>
                {log.event_type}
              </span>
              <span className="text-[10px] font-mono text-slate-400 flex items-center gap-1">
                <Clock className="w-3 h-3 text-slate-500" />
                {log.timestamp ? new Date(log.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '03:45 PM'}
              </span>
            </div>
            <p className="text-slate-300 text-[11px] leading-relaxed">{log.details}</p>
            <div className="text-[10px] text-slate-500 flex items-center gap-2 pt-0.5">
              <span>Zone: <strong className="text-slate-400">{log.zone_name || 'System Wide'}</strong></span>
              <span>•</span>
              <span>By: <strong className="text-slate-400">{log.action_by || 'System'}</strong></span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
