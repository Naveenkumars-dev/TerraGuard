import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { executeDemoStep, resetDemo } from '../services/api';
import { Play, RotateCcw, CheckCircle, ChevronRight, Sparkles } from 'lucide-react';

export const DemoModeBar = () => {
  const { demoModeActive, setDemoModeActive, triggerRefresh, setLiveAlertNotification } = useApp();
  const [currentStep, setCurrentStep] = useState(1);
  const [stepData, setStepData] = useState(null);
  const [loading, setLoading] = useState(false);

  if (!demoModeActive) return null;

  const demoSteps = [
    { id: 1, label: 'Baseline Inspection', desc: 'Monitor initial state of East Khasi Hills slope.' },
    { id: 2, label: 'Monsoon Cloudburst', desc: 'Rainfall increases to 145mm; soil moisture reaches 89%.' },
    { id: 3, label: 'Field Report Filed', desc: 'Field official submits tension crack report with photo & GPS.' },
    { id: 4, label: 'Admin Verification', desc: 'Admin verifies report; score updates to EVACUATE.' },
    { id: 5, label: 'SMS & Alert Broadcast', desc: 'Automated EVACUATION alert & SMS fallback triggered.' }
  ];

  const handleNextStep = async () => {
    setLoading(true);
    try {
      const nextStep = currentStep >= 5 ? 1 : currentStep + 1;
      const res = await executeDemoStep(nextStep);
      setStepData(res);
      setCurrentStep(nextStep);
      triggerRefresh();

      if (nextStep === 5) {
        setLiveAlertNotification({
          title: 'EVACUATION ALERT DISPATCHED - East Khasi Hills',
          previousRisk: 74,
          currentRisk: res.currentRiskScore || 86.5,
          status: 'EVACUATE',
          alertCode: 'TG-ALT-DEMO',
          smsText: 'TERRAGUARD ALERT: EVACUATE NOW. High landslide risk detected in East Khasi Hills. Follow local authority instructions immediately.'
        });
      }
    } catch (err) {
      console.warn('Demo step error', err);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = async () => {
    setLoading(true);
    try {
      await resetDemo();
      setCurrentStep(1);
      setStepData(null);
      triggerRefresh();
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-gradient-to-r from-gov-blue via-slate-900 to-gov-green/40 border-b border-gov-gold/40 p-4 text-slate-100 shadow-2xl sticky top-[85px] z-30">
      <div className="max-w-7xl mx-auto flex flex-wrap items-center justify-between gap-4">
        {/* Header Title */}
        <div className="flex items-center gap-3">
          <div className="p-2 gov-emblem text-gov-gold rounded-lg font-bold text-xs uppercase flex items-center gap-1.5 shadow">
            <Sparkles className="w-4 h-4 animate-spin" style={{ animationDuration: '4s' }} />
            <span>Demo Mode</span>
          </div>
          <div>
            <h3 className="text-xs font-bold text-gov-gold">
              Sequential hazard detection workflow demonstration
            </h3>
            <p className="text-[11px] text-slate-300/80">
              Step-by-step landslide risk monitoring and alert system
            </p>
          </div>
        </div>

        {/* Step Buttons Grid */}
        <div className="flex items-center gap-2 overflow-x-auto py-1">
          {demoSteps.map((step) => (
            <div
              key={step.id}
              className={`px-3 py-1.5 rounded-lg border text-xs font-semibold flex items-center gap-1.5 transition-all whitespace-nowrap ${
                currentStep === step.id
                  ? 'bg-gov-gold/30 border-gov-gold text-gov-gold shadow-lg scale-105'
                  : currentStep > step.id
                  ? 'bg-gov-blue/80 border-gov-gold/30 text-slate-400'
                  : 'bg-slate-900/50 border-slate-800 text-slate-500'
              }`}
            >
              <span className="w-4 h-4 rounded-full bg-slate-950 text-[10px] font-bold flex items-center justify-center">
                {step.id}
              </span>
              <span>{step.label}</span>
              {currentStep > step.id && <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />}
            </div>
          ))}
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-2">
          <button
            onClick={handleNextStep}
            disabled={loading}
            className="px-4 py-2 bg-gradient-to-r from-gov-gold to-gov-gold/80 hover:from-gov-gold/90 hover:to-gov-gold/70 text-gov-blue text-xs font-extrabold rounded-lg shadow-lg flex items-center gap-2 transition-all border border-gov-gold/50"
          >
            <span>Execute Step {currentStep >= 5 ? 1 : currentStep + 1}</span>
            <ChevronRight className="w-4 h-4" />
          </button>

          <button
            onClick={handleReset}
            disabled={loading}
            className="p-2 bg-gov-blue/80 hover:bg-gov-blue/70 text-gov-gold rounded-lg text-xs font-semibold border border-gov-gold/40"
            title="Reset Demo Baseline"
          >
            <RotateCcw className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
