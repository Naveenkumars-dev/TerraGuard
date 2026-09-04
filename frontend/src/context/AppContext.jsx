import React, { createContext, useContext, useState, useEffect } from 'react';

const AppContext = createContext();

export const AppProvider = ({ children }) => {
  const [userRole, setUserRole] = useState('District Admin'); // Citizen, Field Official, District Admin, State Authority
  const [lowBandwidthMode, setLowBandwidthMode] = useState(false);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [selectedZoneId, setSelectedZoneId] = useState(1);
  const [selectedDistrict, setSelectedDistrict] = useState('All Districts');
  const [liveAlertNotification, setLiveAlertNotification] = useState(null);
  const [demoModeActive, setDemoModeActive] = useState(false);
  const [demoStep, setDemoStep] = useState(0);
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  const triggerRefresh = () => setRefreshTrigger((prev) => prev + 1);

  return (
    <AppContext.Provider
      value={{
        userRole,
        setUserRole,
        lowBandwidthMode,
        setLowBandwidthMode,
        activeTab,
        setActiveTab,
        selectedZoneId,
        setSelectedZoneId,
        selectedDistrict,
        setSelectedDistrict,
        liveAlertNotification,
        setLiveAlertNotification,
        demoModeActive,
        setDemoModeActive,
        demoStep,
        setDemoStep,
        refreshTrigger,
        triggerRefresh
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => useContext(AppContext);
