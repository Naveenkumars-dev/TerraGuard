import React, { useState } from 'react';
import { ShieldAlert, Smartphone, PhoneCall, X, CheckCircle, Radio, Copy, Check } from 'lucide-react';

export const AlertModal = ({ notification, onClose }) => {
  const [copied, setCopied] = useState(false);

  if (!notification) return null;

  const smsText = notification.smsText || 'TERRAGUARD ALERT: EVACUATE NOW. High landslide risk detected in East Khasi Hills. Follow local authority instructions immediately.';

  const handleCopy = () => {
    navigator.clipboard.writeText(smsText);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/85 backdrop-blur-md animate-fade-in">
      <div className="bg-slate-900 border-2 border-gov-gold/80 rounded-3xl max-w-lg w-full p-6 shadow-2xl shadow-gov-gold/30 space-y-5 relative overflow-hidden">
        {/* Top Glow Bar */}
        <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-gov-gold via-gov-gold/70 to-gov-gold animate-pulse"></div>

        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-slate-400 hover:text-white p-1.5 rounded-full bg-slate-800 border border-slate-700 transition-colors"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Modal Header */}
        <div className="flex items-center gap-3.5 pt-1">
          <div className="p-3 gov-emblem rounded-2xl text-gov-gold shadow-lg shadow-gov-gold/40">
            <ShieldAlert className="w-8 h-8" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-gov-gold/20 text-gov-gold font-black text-[10px] uppercase px-2.5 py-0.5 rounded-full tracking-wider shadow border border-gov-gold/40">
                {notification.status || 'EVACUATE'}
              </span>
              <span className="text-xs font-mono text-gov-gold font-extrabold">
                {notification.alertCode || 'TG-ALT-1024'}
              </span>
            </div>
            <h2 className="text-base font-black text-white mt-1">
              {notification.title || 'RISK ESCALATION DETECTED'}
            </h2>
          </div>
        </div>

        {/* Risk Score Jump Card */}
        <div className="bg-gov-blue/80 border border-gov-gold/30 rounded-2xl p-3.5 flex items-center justify-between text-xs shadow-inner">
          <div>
            <span className="text-slate-400 block text-[9px] uppercase font-extrabold tracking-wider">Previous Risk Score</span>
            <span className="text-slate-300 font-black text-sm">{notification.previousRisk || 54} / 100</span>
          </div>
          <div className="text-gov-gold font-extrabold text-xl animate-pulse">➔</div>
          <div className="text-right">
            <span className="text-slate-400 block text-[9px] uppercase font-extrabold tracking-wider">Current Risk Score</span>
            <span className="text-gov-gold font-black text-sm">{notification.currentRisk || 84.5} / 100</span>
          </div>
        </div>

        {/* Smartphone SMS Broadcast Visual Frame */}
        <div className="bg-gov-blue/80 rounded-2xl p-4 border border-gov-gold/30 space-y-3 shadow-inner">
          <div className="flex items-center justify-between text-xs border-b border-gov-gold/20 pb-2.5">
            <div className="flex items-center gap-2 text-slate-200 font-extrabold">
              <Smartphone className="w-4 h-4 text-gov-gold" />
              <span>Official SMS Broadcast Grid</span>
            </div>
            <span className="px-2.5 py-0.5 text-[9px] bg-gov-gold/20 text-gov-gold border border-gov-gold/60 rounded-full font-black flex items-center gap-1">
              <Check className="w-3 h-3 text-gov-gold" /> DELIVERED
            </span>
          </div>

          <div className="space-y-2 text-xs">
            <div className="font-mono text-[10px] text-slate-400">To: +91 98XXX XXXXX (District Officials & Local Cell Network Grid)</div>
            <div className="bg-slate-900 border border-slate-800 p-3 rounded-xl text-slate-200 font-mono text-[11px] leading-relaxed relative">
              "{smsText}"
              <button
                onClick={handleCopy}
                className="absolute top-2 right-2 p-1 text-slate-400 hover:text-white bg-slate-800 rounded"
                title="Copy SMS text"
              >
                {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
              </button>
            </div>
          </div>
        </div>

        {/* IVR Voice Protocol Status */}
        <div className="bg-gov-gold/20 border border-gov-gold/40 rounded-2xl p-3 flex items-center justify-between text-xs shadow-sm">
          <div className="flex items-center gap-2 text-gov-gold font-bold">
            <PhoneCall className="w-4 h-4 text-gov-gold animate-pulse" />
            <span>IVR Automated Voice Call Protocol Triggered</span>
          </div>
          <span className="text-[9px] font-extrabold text-gov-gold bg-gov-blue/80 px-2.5 py-0.5 rounded-full border border-gov-gold/60">
            AUTOMATED
          </span>
        </div>

        {/* Demo Disclaimer */}
        <div className="text-[10px] text-slate-400 text-center font-medium flex items-center justify-center gap-1.5">
          <Radio className="w-3 h-3 text-gov-gold" />
          <span>Official Government System – SIH Prototype Demonstration</span>
        </div>

        {/* Acknowledge Button */}
        <button
          onClick={onClose}
          className="w-full py-3 bg-gradient-to-r from-gov-gold to-gov-gold/80 hover:from-gov-gold/90 hover:to-gov-gold/70 text-gov-blue font-extrabold text-xs rounded-xl shadow-lg shadow-gov-gold/30 transition-all border border-gov-gold/50"
        >
          Acknowledge & Dismiss Alert
        </button>
      </div>
    </div>
  );
};
