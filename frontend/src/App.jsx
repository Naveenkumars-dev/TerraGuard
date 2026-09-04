import React, { useEffect } from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { Header } from './components/Header';
import { Sidebar } from './components/Sidebar';
import { DemoModeBar } from './components/DemoModeBar';
import { AlertModal } from './components/AlertModal';

import { Dashboard } from './pages/Dashboard';
import { RiskMapPage } from './pages/RiskMapPage';
import { ZoneDetailsPage } from './pages/ZoneDetailsPage';
import { AlertsPage } from './pages/AlertsPage';
import { ReportsPage } from './pages/ReportsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { AdminPage } from './pages/AdminPage';
import { SystemStatusPage } from './pages/SystemStatusPage';

import { startRealtimeSimulation, stopRealtimeSimulation } from './services/simulation';

const MainContent = () => {
  const { activeTab, liveAlertNotification, setLiveAlertNotification } = useApp();

  useEffect(() => {
    // Start real-time simulation interval loop (updates data every 20s)
    startRealtimeSimulation((notification) => {
      setLiveAlertNotification(notification);
    });

    return () => stopRealtimeSimulation();
  }, [setLiveAlertNotification]);

  const renderTab = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />;
      case 'risk-map':
        return <RiskMapPage />;
      case 'zone-details':
        return <ZoneDetailsPage />;
      case 'alerts':
        return <AlertsPage />;
      case 'reports':
        return <ReportsPage />;
      case 'analytics':
        return <AnalyticsPage />;
      case 'admin':
        return <AdminPage />;
      case 'system-status':
        return <SystemStatusPage />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans">
      <Header />
      <DemoModeBar />

      <div className="flex flex-1">
        <Sidebar />
        <main className="flex-1 bg-gradient-to-br from-slate-950 via-slate-900 to-gov-blue/20 overflow-y-auto">
          {renderTab()}
        </main>
      </div>

      {/* Live SMS & Alert Notification Popup Modal */}
      {liveAlertNotification && (
        <AlertModal
          notification={liveAlertNotification}
          onClose={() => setLiveAlertNotification(null)}
        />
      )}
    </div>
  );
};

export default function App() {
  return (
    <AppProvider>
      <MainContent />
    </AppProvider>
  );
}
