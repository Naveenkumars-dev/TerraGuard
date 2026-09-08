import React, { useState, useEffect } from 'react';
import { AlertTriangle, MapPin, Navigation, Clock, ArrowRight, CheckCircle, X } from 'lucide-react';

export const RouteAlert = ({ userRole }) => {
  const [roads, setRoads] = useState([]);
  const [blockedRoads, setBlockedRoads] = useState([]);
  const [selectedRoad, setSelectedRoad] = useState(null);
  const [showMap, setShowMap] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchRoads();
  }, []);

  const fetchRoads = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/roads/blocked');
      const data = await response.json();
      setBlockedRoads(data);
      setLoading(false);
    } catch (err) {
      console.error('Failed to fetch roads:', err);
      setLoading(false);
    }
  };

  const handleViewSafeRoute = (road) => {
    setSelectedRoad(road);
    setShowMap(true);
  };

  if (userRole !== 'CITIZEN') {
    return null;
  }

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-4">
          <div className="h-4 bg-slate-700 rounded w-1/4"></div>
          <div className="h-32 bg-slate-700 rounded"></div>
        </div>
      </div>
    );
  }

  if (blockedRoads.length === 0) {
    return (
      <div className="p-6">
        <div className="bg-green-500/20 border border-green-500/50 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-2">
            <CheckCircle className="w-6 h-6 text-green-400" />
            <h3 className="text-lg font-bold text-green-400">All Routes Clear</h3>
          </div>
          <p className="text-green-300">No road blockages detected in your area. Your regular routes are available.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-4xl mx-auto">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-white mb-2">🗺️ Travel & Route Alerts</h2>
          <p className="text-slate-400">Real-time road blockage information and safe alternative routes</p>
        </div>

        <div className="space-y-4">
          {blockedRoads.map((road) => (
            <div key={road.id} className="bg-red-500/20 border-2 border-red-500/50 rounded-xl p-6">
              <div className="flex items-start gap-4">
                <div className="bg-red-500/30 p-3 rounded-lg">
                  <AlertTriangle className="w-8 h-8 text-red-400" />
                </div>
                
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <h3 className="text-xl font-bold text-red-400">🚨 ROUTE ALERT</h3>
                    <span className="px-2 py-1 bg-red-500 text-white text-xs font-bold rounded-full">
                      BLOCKED
                    </span>
                  </div>
                  
                  <p className="text-white mb-4">
                    Your regular route is currently blocked due to a {road.blockage_reason?.toLowerCase() || 'landslide'}.
                  </p>

                  <div className="bg-slate-800/50 rounded-lg p-4 mb-4">
                    <div className="flex items-center gap-2 text-slate-300 mb-2">
                      <MapPin className="w-4 h-4" />
                      <span className="font-semibold">🚫 Road: {road.road_name}</span>
                    </div>
                    <div className="flex items-center gap-2 text-slate-400 text-sm">
                      <span>{road.start_location}</span>
                      <ArrowRight className="w-4 h-4" />
                      <span>{road.end_location}</span>
                    </div>
                    <div className="mt-2 text-slate-400 text-sm">
                      <span>Reason: {road.blockage_reason}</span>
                    </div>
                    <div className="mt-1 text-slate-400 text-sm">
                      <span>Affected Citizens: {road.affected_citizens_count}</span>
                    </div>
                  </div>

                  {road.alternative_route_available && (
                    <div className="bg-green-500/20 border border.green-500/50 rounded-lg p-4 mb-4">
                      <div className="flex items-center gap-2 text-green-400 font-semibold mb-2">
                        <MapPin className="w-4 h-4" />
                        <span>📍 Alternative Route Available</span>
                      </div>
                      <p className="text-green-300 text-sm">
                        A safe alternative route has been identified for your journey.
                      </p>
                    </div>
                  )}

                  <button
                    onClick={() => handleViewSafeRoute(road)}
                    className="w-full bg-gradient-to-r from-green-600 to-green-500 hover:from-green-500 hover:to-green-400 text-white font-bold py-3 rounded-lg flex items-center justify-center gap-2 transition-all"
                  >
                    <Navigation className="w-5 h-5" />
                    <span>VIEW SAFE ROUTE</span>
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Google Maps Modal */}
        {showMap && selectedRoad && (
          <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
            <div className="bg-slate-800 rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden">
              <div className="flex items-center justify-between p-4 border-b border-slate-700">
                <div>
                  <h3 className="text-xl font-bold text-white">Safe Alternative Route</h3>
                  <p className="text-slate-400 text-sm">{selectedRoad.road_name}</p>
                </div>
                <button
                  onClick={() => setShowMap(false)}
                  className="p-2 rounded-lg bg-slate-700 text-slate-400 hover:bg-slate-600 hover:text-white"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="p-4">
                {/* Google Maps Embed */}
                <div className="bg-slate-700 rounded-lg overflow-hidden mb-4">
                  <iframe
                    width="100%"
                    height="400"
                    frameBorder="0"
                    style={{ border: 0 }}
                    src={`https://www.google.com/maps/embed/v1/directions?key=YOUR_API_KEY&origin=${encodeURIComponent(selectedRoad.start_location)}&destination=${encodeURIComponent(selectedRoad.end_location)}&avoid=tolls|highways`}
                    allowFullScreen
                  ></iframe>
                </div>

                {/* Route Information */}
                <div className="bg-slate-700/50 rounded-lg p-4 mb-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="flex items-center gap-2">
                      <Navigation className="w-5 h-5 text-blue-400" />
                      <div>
                        <p className="text-slate-400 text-xs">Distance</p>
                        <p className="text-white font-bold">18.4 km</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Clock className="w-5 h-5 text-green-400" />
                      <div>
                        <p className="text-slate-400 text-xs">Estimated Time</p>
                        <p className="text-white font-bold">32 min</p>
                      </div>
                    </div>
                  </div>
                </div>

                <button className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-3 rounded-lg flex items-center justify-center gap-2 transition-all">
                  <Navigation className="w-5 h-5" />
                  <span>START NAVIGATION</span>
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Route Restored Notification */}
        {blockedRoads.some(road => road.status === 'OPEN') && (
          <div className="fixed bottom-4 right-4 bg-green-500/20 border-2 border-green-500/50 rounded-xl p-6 max-w-md animate-bounce">
            <div className="flex items-center gap-3 mb-2">
              <CheckCircle className="w-6 h-6 text-green-400" />
              <h3 className="text-lg font-bold text-green-400">🟢 ROUTE RESTORED</h3>
            </div>
            <p className="text-green-300 mb-4">
              Your regular route has been cleared and is now available for transportation.
            </p>
            <button className="w-full bg-green-600 hover:bg-green-500 text-white font-bold py-2 rounded-lg">
              VIEW REGULAR ROUTE
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
