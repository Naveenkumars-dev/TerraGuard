import { simulateRainfallEvent } from './api';

let simulationInterval = null;

export const startRealtimeSimulation = (onEscalation) => {
  if (simulationInterval) clearInterval(simulationInterval);

  // Run simulation tick every 60 seconds to reduce excessive alert generation
  simulationInterval = setInterval(async () => {
    try {
      const res = await simulateRainfallEvent();
      if (res && res.notification && onEscalation) {
        onEscalation(res.notification);
      }
    } catch (err) {
      console.warn('Real-time simulation tick error:', err);
    }
  }, 60000);
};

export const stopRealtimeSimulation = () => {
  if (simulationInterval) {
    clearInterval(simulationInterval);
    simulationInterval = null;
  }
};
