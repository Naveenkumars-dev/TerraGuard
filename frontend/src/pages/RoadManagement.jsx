import React, { useState, useEffect } from 'react';
import { MapPin, AlertTriangle, CheckCircle, X, Plus, RefreshCw } from 'lucide-react';

export const RoadManagement = () => {
  const [roads, setRoads] = useState([]);
  const [loading, setLoading] = useState(true);
  const [blockingRoad, setBlockingRoad] = useState(null);
  const [clearingRoad, setClearingRoad] = useState(null);

  useEffect(() => {
    fetchRoads();
  }, []);

  const fetchRoads = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/roads');
      const data = await response.json();
      setRoads(data);
      setLoading(false);
    } catch (err) {
      console.error('Failed to fetch roads:', err);
      setLoading(false);
    }
  };

  const handleBlockRoad = async (roadId) => {
    setBlockingRoad(roadId);
    try {
      const response = await fetch('http://localhost:8000/api/roads/block', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          road_id: roadId,
          blockage_reason: 'LANDSLIDE',
          latitude: 12.58,
          longitude: 78.63,
          risk_score: 92
        })
      });

      if (response.ok) {
        fetchRoads();
      }
    } catch (err) {
      console.error('Failed to block road:', err);
    } finally {
      setBlockingRoad(null);
    }
  };

  const handleClearRoad = async (roadId) => {
    setClearingRoad(roadId);
    try {
      const response = await fetch('http://localhost:8000/api/roads/clear', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ road_id: roadId })
      });

      if (response.ok) {
        fetchRoads();
      }
    } catch (err) {
      console.error('Failed to clear road:', err);
    } finally {
      setClearingRoad(null);
    }
  };

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

  return (
    <div className="p-6">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-white mb-2">🗺️ Road Management</h2>
            <p className="text-slate-400">Monitor and manage road blockages due to landslides</p>
          </div>
          <button
            onClick={fetchRoads}
            className="flex items-center gap-2 px-4 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Refresh</span>
          </button>
        </div>

        {/* Statistics */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="bg-slate-800/50 rounded-lg p-4">
            <div className="flex items-center gap-2 mb-2">
              <MapPin className="w-5 h-5 text-blue-400" />
              <span className="text-slate-400 text-sm">Total Roads</span>
            </div>
            <div className="text-3xl font-bold text-white">{roads.length}</div>
          </div>

          <div className="bg-red-500/20 rounded-lg p-4">
            <div className="flex items-center gap-2 mb-2">
              <AlertTriangle className="w-5 h-5 text-red-400" />
              <span className="text-slate-400 text-sm">Blocked Roads</span>
            </div>
            <div className="text-3xl font-bold text-red-400">
              {roads.filter(r => r.status === 'BLOCKED').length}
            </div>
          </div>

          <div className="bg-green-500/20 rounded-lg p-4">
            <div className="flex items-center gap-2 mb-2">
              <CheckCircle className="w-5 h-5 text-green-400" />
              <span className="text-slate-400 text-sm">Open Roads</span>
            </div>
            <div className="text-3xl font-bold text-green-400">
              {roads.filter(r => r.status === 'OPEN').length}
            </div>
          </div>
        </div>

        {/* Road List */}
        <div className="space-y-4">
          {roads.map((road) => (
            <div
              key={road.id}
              className={`bg-slate-800/50 border-2 rounded-xl p-6 ${
                road.status === 'BLOCKED'
                  ? 'border-red-500/50'
                  : 'border-green-500/50'
              }`}
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-3">
                    <h3 className="text-xl font-bold text-white">{road.road_name}</h3>
                    <span
                      className={`px-3 py-1 rounded-full text-xs font-bold ${
                        road.status === 'BLOCKED'
                          ? 'bg-red-500 text-white'
                          : 'bg-green-500 text-white'
                      }`}
                    >
                      {road.status}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-4 mb-4">
                    <div>
                      <p className="text-slate-400 text-sm">Road ID</p>
                      <p className="text-white font-semibold">{road.road_id}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 text-sm">District</p>
                      <p className="text-white font-semibold">{road.district}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 text-sm">Start Location</p>
                      <p className="text-white font-semibold">{road.start_location}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 text-sm">End Location</p>
                      <p className="text-white font-semibold">{road.end_location}</p>
                    </div>
                  </div>

                  {road.status === 'BLOCKED' && (
                    <div className="bg-red-500/20 rounded-lg p-4 mb-4">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <p className="text-slate-400 text-sm">Blockage Reason</p>
                          <p className="text-red-400 font-semibold">{road.blockage_reason}</p>
                        </div>
                        <div>
                          <p className="text-slate-400 text-sm">Risk Score</p>
                          <p className="text-red-400 font-semibold">{road.risk_score}%</p>
                        </div>
                        <div>
                          <p className="text-slate-400 text-sm">Blocked At</p>
                          <p className="text-white font-semibold">
                            {road.blocked_at ? new Date(road.blocked_at).toLocaleString() : 'N/A'}
                          </p>
                        </div>
                        <div>
                          <p className="text-slate-400 text-sm">Affected Citizens</p>
                          <p className="text-white font-semibold">{road.affected_citizens_count}</p>
                        </div>
                      </div>
                    </div>
                  )}
                </div>

                <div className="flex flex-col gap-2 ml-4">
                  {road.status === 'OPEN' ? (
                    <button
                      onClick={() => handleBlockRoad(road.road_id)}
                      disabled={blockingRoad === road.road_id}
                      className="px-4 py-2 bg-red-600 hover:bg-red-500 text-white font-bold rounded-lg flex items-center gap-2 transition-colors disabled:opacity-50"
                    >
                      {blockingRoad === road.road_id ? (
                        <RefreshCw className="w-4 h-4 animate-spin" />
                      ) : (
                        <AlertTriangle className="w-4 h-4" />
                      )}
                      <span>Block Road</span>
                    </button>
                  ) : (
                    <button
                      onClick={() => handleClearRoad(road.road_id)}
                      disabled={clearingRoad === road.road_id}
                      className="px-4 py-2 bg-green-600 hover:bg-green-500 text-white font-bold rounded-lg flex items-center gap-2 transition-colors disabled:opacity-50"
                    >
                      {clearingRoad === road.road_id ? (
                        <RefreshCw className="w-4 h-4 animate-spin" />
                      ) : (
                        <CheckCircle className="w-4 h-4" />
                      )}
                      <span>Clear Road</span>
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Info */}
        <div className="mt-6 bg-blue-500/20 border border-blue-500/50 rounded-lg p-4">
          <h4 className="font-bold text-blue-400 mb-2">Road Management System</h4>
          <p className="text-blue-300 text-sm mb-2">
            When a road is blocked due to a landslide:
          </p>
          <ul className="text-blue-300 text-sm space-y-1">
            <li>• Citizens using that route are automatically notified</li>
            <li>• Alternative safe routes are suggested via Google Maps</li>
            <li>• Affected citizens count is tracked</li>
            <li>• When cleared, citizens receive restoration notifications</li>
          </ul>
        </div>
      </div>
    </div>
  );
};
