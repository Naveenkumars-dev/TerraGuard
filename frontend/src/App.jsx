import React, { useEffect, useState } from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { OfflineProvider } from './context/OfflineContext';
import { Header } from './components/Header';
import { Sidebar } from './components/Sidebar';
import { DemoModeBar } from './components/DemoModeBar';
import { AlertModal } from './components/AlertModal';

import { LandingPage } from './pages/LandingPage';
import { CitizenAuth } from './pages/CitizenAuth';
import { AdminAuth } from './pages/AdminAuth';
import { Dashboard } from './pages/Dashboard';
import { RiskMapPage } from './pages/RiskMapPage';
import { ZoneDetailsPage } from './pages/ZoneDetailsPage';
import { AlertsPage } from './pages/AlertsPage';
import { ReportsPage } from './pages/ReportsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { SystemStatusPage } from './pages/SystemStatusPage';
import { EmergencyAlertTrigger } from './pages/EmergencyAlertTrigger';
import { RouteAlert } from './pages/RouteAlert';
import { RoadManagement } from './pages/RoadManagement';

import { startRealtimeSimulation, stopRealtimeSimulation } from './services/simulation';

const MainContent = () => {
  const { activeTab, liveAlertNotification, setLiveAlertNotification } = useApp();
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);
  const [authStep, setAuthStep] = useState('landing'); // landing, citizen-auth, admin-auth, authenticated
  const [userRole, setUserRole] = useState(null); // CITIZEN, ADMIN
  const [userInfo, setUserInfo] = useState(null);

  useEffect(() => {
    // Start real-time simulation interval loop (updates data every 20s)
    startRealtimeSimulation((notification) => {
      setLiveAlertNotification(notification);
    });

    return () => stopRealtimeSimulation();
  }, [setLiveAlertNotification]);

  const handleRoleSelect = (role) => {
    setUserRole(role);
    setAuthStep(role === 'CITIZEN' ? 'citizen-auth' : 'admin-auth');
  };

  const handleLoginSuccess = (userData) => {
    setUserInfo(userData);
    setAuthStep('authenticated');
  };

  const handleBackToLanding = () => {
    setAuthStep('landing');
    setUserRole(null);
    setUserInfo(null);
  };

  const renderAuthStep = () => {
    switch (authStep) {
      case 'landing':
        return <LandingPage onSelectRole={handleRoleSelect} />;
      case 'citizen-auth':
        return <CitizenAuth onBack={handleBackToLanding} onLoginSuccess={handleLoginSuccess} />;
      case 'admin-auth':
        return <AdminAuth onBack={handleBackToLanding} onLoginSuccess={handleLoginSuccess} />;
      case 'authenticated':
        return renderAuthenticatedContent();
      default:
        return <LandingPage onSelectRole={handleRoleSelect} />;
    }
  };

  const renderTab = () => {
    switch (activeTab) {
      case 'dashboard':
        return userRole === 'CITIZEN' ? <RouteAlert userRole={userRole} /> : <Dashboard userRole={userRole} userInfo={userInfo} />;
      case 'risk-map':
        return <RiskMapPage userRole={userRole} />;
      case 'zone-details':
        return <ZoneDetailsPage />;
      case 'alerts':
        return userRole === 'ADMIN' ? <EmergencyAlertTrigger /> : <AlertsPage userRole={userRole} />;
      case 'reports':
        return <ReportsPage userRole={userRole} />;
      case 'analytics':
        return userRole === 'ADMIN' ? <AnalyticsPage /> : <Dashboard userRole={userRole} userInfo={userInfo} />;
      case 'admin':
        return userRole === 'ADMIN' ? <RoadManagement /> : <Dashboard userRole={userRole} userInfo={userInfo} />;
      case 'system-status':
        return userRole === 'ADMIN' ? <SystemStatusPage /> : <Dashboard userRole={userRole} userInfo={userInfo} />;
      default:
        return <Dashboard userRole={userRole} userInfo={userInfo} />;
    }
  };

  const renderAuthenticatedContent = () => {
    return (
      <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans">
        <Header 
          isMobileSidebarOpen={isMobileSidebarOpen} 
          setIsMobileSidebarOpen={setIsMobileSidebarOpen}
          userInfo={userInfo}
          onLogout={handleBackToLanding}
        />
        <DemoModeBar />

        <div className="flex flex-1 relative">
          <Sidebar 
            isMobileSidebarOpen={isMobileSidebarOpen} 
            setIsMobileSidebarOpen={setIsMobileSidebarOpen}
            userRole={userRole}
          />
          <main className="flex-1 bg-gradient-to-br from-slate-950 via-slate-900 to-gov-blue/20 overflow-y-auto min-h-[calc(100vh-85px)] lg:min-h-0">
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

  return renderAuthStep();
};

export default function App() {
  return (
    <OfflineProvider>
      <AppProvider>
        <MainContent />
      </AppProvider>
    </OfflineProvider>
  );
}
