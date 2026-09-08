import React, { useState } from 'react';
import { Shield, User, AlertTriangle, Home, Map, Building2, Radio, BarChart3 } from 'lucide-react';

export const LandingPage = ({ onSelectRole }) => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-gov-blue/20 flex items-center justify-center p-4">
      <div className="max-w-6xl w-full">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="flex items-center justify-center mb-4">
            <Shield className="w-16 h-16 text-gov-blue" />
          </div>
          <h1 className="text-5xl font-bold text-white mb-2">TERRAGUARD</h1>
          <p className="text-xl text-slate-300 mb-4">AI-Powered Landslide Safety System</p>
          <p className="text-slate-400">Protecting Communities • Saving Lives</p>
        </div>

        {/* Role Selection Cards */}
        <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          {/* Citizen Card */}
          <button
            onClick={() => onSelectRole('CITIZEN')}
            className="bg-slate-800/50 backdrop-blur-sm border-2 border-slate-700 hover:border-gov-blue rounded-2xl p-8 text-left transition-all duration-300 hover:scale-105 hover:bg-slate-800/70 group"
          >
            <div className="flex items-center mb-6">
              <div className="bg-gov-blue/20 p-4 rounded-xl mr-4 group-hover:bg-gov-blue/30 transition-colors">
                <User className="w-8 h-8 text-gov-blue" />
              </div>
              <div>
                <h2 className="text-2xl font-bold text-white">Citizen</h2>
                <p className="text-slate-400 text-sm">Register / Login</p>
              </div>
            </div>

            <div className="space-y-3 mb-6">
              <div className="flex items-center text-slate-300">
                <AlertTriangle className="w-4 h-4 mr-3 text-orange-400" />
                <span className="text-sm">Report landslide hazards</span>
              </div>
              <div className="flex items-center text-slate-300">
                <AlertTriangle className="w-4 h-4 mr-3 text-red-400" />
                <span className="text-sm">View emergency alerts</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Shield className="w-4 h-4 mr-3 text-green-400" />
                <span className="text-sm">Request emergency help</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Home className="w-4 h-4 mr-3 text-blue-400" />
                <span className="text-sm">Find safe shelters</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Map className="w-4 h-4 mr-3 text-purple-400" />
                <span className="text-sm">View blocked roads</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Radio className="w-4 h-4 mr-3 text-yellow-400" />
                <span className="text-sm">Emergency SOS</span>
              </div>
            </div>

            <div className="text-gov-blue font-semibold group-hover:text-gov-blue-light transition-colors">
              Continue as Citizen →
            </div>
          </button>

          {/* Admin Card */}
          <button
            onClick={() => onSelectRole('ADMIN')}
            className="bg-slate-800/50 backdrop-blur-sm border-2 border-slate-700 hover:border-gov-blue rounded-2xl p-8 text-left transition-all duration-300 hover:scale-105 hover:bg-slate-800/70 group"
          >
            <div className="flex items-center mb-6">
              <div className="bg-gov-blue/20 p-4 rounded-xl mr-4 group-hover:bg-gov-blue/30 transition-colors">
                <Building2 className="w-8 h-8 text-gov-blue" />
              </div>
              <div>
                <h2 className="text-2xl font-bold text-white">Admin / Government Officer</h2>
                <p className="text-slate-400 text-sm">Register / Login</p>
              </div>
            </div>

            <div className="space-y-3 mb-6">
              <div className="flex items-center text-slate-300">
                <BarChart3 className="w-4 h-4 mr-3 text-blue-400" />
                <span className="text-sm">Monitor landslide risks</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Shield className="w-4 h-4 mr-3 text-green-400" />
                <span className="text-sm">Verify citizen reports</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Home className="w-4 h-4 mr-3 text-orange-400" />
                <span className="text-sm">Manage shelters</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Map className="w-4 h-4 mr-3 text-purple-400" />
                <span className="text-sm">Allocate resources</span>
              </div>
              <div className="flex items-center text-slate-300">
                <AlertTriangle className="w-4 h-4 mr-3 text-red-400" />
                <span className="text-sm">Manage road blockages</span>
              </div>
              <div className="flex items-center text-slate-300">
                <Radio className="w-4 h-4 mr-3 text-yellow-400" />
                <span className="text-sm">Send emergency alerts</span>
              </div>
            </div>

            <div className="text-gov-blue font-semibold group-hover:text-gov-blue-light transition-colors">
              Continue as Admin →
            </div>
          </button>
        </div>

        {/* Footer */}
        <div className="text-center mt-12 text-slate-500 text-sm">
          <p>Smart India Hackathon 2026 • Ministry of Development of North Eastern Region</p>
        </div>
      </div>
    </div>
  );
};
