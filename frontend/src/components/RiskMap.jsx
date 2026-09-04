import React, { useEffect, useRef, useState } from 'react';
import L from 'leaflet';

export const RiskMap = ({ zones = [], reports = [], selectedZoneId, onSelectZone }) => {
  const mapContainerRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const layerGroupRef = useRef(null);
  const [mapType, setMapType] = useState('dark'); // 'dark', 'satellite', 'terrain', 'streets'

  // Helper for risk color
  const getRiskColor = (level, score) => {
    if (level === 'EVACUATE' || score >= 80) return '#EF4444';
    if (level === 'WARNING' || score >= 60) return '#F97316';
    if (level === 'WATCH' || score >= 30) return '#EAB308';
    return '#22C55E';
  };

  // Real-world tile layer configurations
  const tileLayers = {
    dark: {
      url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> &copy; <a href="https://carto.com/">CARTO</a>',
      subdomains: 'abcd'
    },
    satellite: {
      url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      attribution: '&copy; <a href="https://www.esri.com/">Esri</a> &copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>',
      subdomains: null
    },
    terrain: {
      url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> &copy; <a href="https://opentopomap.org/">OpenTopoMap</a>',
      subdomains: 'abc'
    },
    streets: {
      url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>',
      subdomains: 'abc'
    }
  };

  // Helper for Report Icon based on Issue Type
  const getReportIconHtml = (issueType, status) => {
    let color = '#3b82f6';
    let symbol = '●';
    if (status === 'Verified') {
      color = '#22c55e';
      symbol = '✓';
    } else if (issueType === 'Crack') {
      color = '#ef4444';
      symbol = '⚡';
    } else if (issueType === 'Road blockage') {
      color = '#f97316';
      symbol = '⛔';
    } else if (issueType === 'Rockfall') {
      color = '#eab308';
      symbol = '▲';
    } else if (issueType === 'Slope movement') {
      color = '#a855f7';
      symbol = '≈';
    }

    return `
      <div style="
        background-color: ${color};
        color: #ffffff;
        border: 2px solid #ffffff;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 11px;
        font-weight: bold;
        box-shadow: 0 0 10px ${color};
      ">
        ${symbol}
      </div>
    `;
  };

  useEffect(() => {
    if (!mapContainerRef.current) return;

    // Initialize Leaflet map centered on North East India (26.5, 92.0) to cover all NER states
    if (!mapInstanceRef.current) {
      const map = L.map(mapContainerRef.current, {
        center: [26.5, 92.0],
        zoom: 6,
        minZoom: 5,
        maxZoom: 18,
        zoomControl: true,
        touchZoom: true,
        scrollWheelZoom: true,
        doubleClickZoom: true,
        boxZoom: true,
        tap: true,
        tapTolerance: 15
      });

      // Add scale control for real-world distance measurement
      L.control.scale({
        position: 'bottomright',
        imperial: false,
        metric: true
      }).addTo(map);

      // Initial tile layer
      const currentLayer = L.tileLayer(tileLayers.dark.url, {
        attribution: tileLayers.dark.attribution,
        subdomains: tileLayers.dark.subdomains,
        maxZoom: 19
      }).addTo(map);

      // Store current tile layer for switching
      map.currentTileLayer = currentLayer;

      layerGroupRef.current = L.layerGroup().addTo(map);
      mapInstanceRef.current = map;
    }

    const map = mapInstanceRef.current;
    const layerGroup = layerGroupRef.current;
    layerGroup.clearLayers();

    // Render Risk Zone Circles & Polygons
    zones.forEach((zone) => {
      const color = getRiskColor(zone.risk_level, zone.risk_score);
      const isSelected = selectedZoneId === zone.id;

      // Circle marker representing risk radius
      const circle = L.circle([zone.latitude, zone.longitude], {
        color: color,
        fillColor: color,
        fillOpacity: isSelected ? 0.6 : 0.35,
        radius: 12000 + (zone.risk_score * 150),
        weight: isSelected ? 3 : 1.5
      });

      // Popup Content
      const popupHtml = `
        <div style="font-family: inherit; width: 240px; color: #f8fafc;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
            <span style="font-weight: 700; font-size: 13px; color: #ffffff;">${zone.name}</span>
          </div>
          <div style="margin-bottom: 8px;">
            <span style="background-color: ${color}; color: #000; font-weight: 800; font-size: 11px; padding: 2px 6px; border-radius: 4px; text-transform: uppercase;">
              ${zone.risk_level} (${zone.risk_score}/100)
            </span>
            <span style="font-size: 11px; color: #94a3b8; margin-left: 6px;">${zone.district}</span>
          </div>
          <div style="font-size: 11px; line-height: 1.5; background: #0f172a; padding: 6px; border-radius: 4px; border: 1px solid #334155;">
            <div><strong>Rainfall:</strong> ${zone.rainfall} mm</div>
            <div><strong>Soil Moisture:</strong> ${zone.soil_moisture}%</div>
            <div><strong>Slope:</strong> ${zone.slope}°</div>
            <div><strong>Population Affected:</strong> ${(zone.population_affected || 0).toLocaleString()}</div>
          </div>
          <div style="font-size: 10px; color: #cbd5e1; margin-top: 6px; font-style: italic;">
            ${zone.recommended_action || 'Normal monitoring'}
          </div>
        </div>
      `;

      circle.bindPopup(popupHtml);

      circle.on('click', () => {
        if (onSelectZone) onSelectZone(zone.id);
      });

      layerGroup.addLayer(circle);

      // Inner Pulse Marker
      const centerMarker = L.circleMarker([zone.latitude, zone.longitude], {
        radius: isSelected ? 8 : 5,
        color: '#ffffff',
        weight: 2,
        fillColor: color,
        fillOpacity: 1.0
      });
      layerGroup.addLayer(centerMarker);
    });

    // Render Citizen / Field Report Markers with Custom SVGs
    reports.forEach((rpt) => {
      if (rpt.latitude && rpt.longitude) {
        const reportIcon = L.divIcon({
          className: 'custom-report-icon-container',
          html: getReportIconHtml(rpt.issue_type, rpt.status),
          iconSize: [22, 22],
          iconAnchor: [11, 11]
        });

        const rptMarker = L.marker([rpt.latitude, rpt.longitude], { icon: reportIcon });
        rptMarker.bindPopup(`
          <div style="font-size: 11px; color: #fff; width: 180px;">
            <div style="font-weight: bold; color: #60a5fa;">REPORT: ${rpt.report_code}</div>
            <div style="font-weight: 700; color: #fff; margin-top:2px;">${rpt.issue_type} (${rpt.severity})</div>
            <div style="color:#94a3b8; font-size:10px;">${rpt.location_name}</div>
            <div style="margin-top: 4px; padding: 2px 4px; background: #0f172a; border-radius: 3px; font-size: 10px;">
              Status: <strong style="color: ${rpt.status === 'Verified' ? '#4ade80' : '#facc15'};">${rpt.status}</strong>
            </div>
          </div>
        `);
        layerGroup.addLayer(rptMarker);
      }
    });

  }, [zones, reports, selectedZoneId]);

  // Handle map type switching
  const switchMapType = (type) => {
    const map = mapInstanceRef.current;
    if (!map || !map.currentTileLayer) return;

    map.removeLayer(map.currentTileLayer);
    
    const newLayer = L.tileLayer(tileLayers[type].url, {
      attribution: tileLayers[type].attribution,
      subdomains: tileLayers[type].subdomains,
      maxZoom: 19
    }).addTo(map);
    
    map.currentTileLayer = newLayer;
    setMapType(type);
  };

  // Get user's current location
  const getCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const map = mapInstanceRef.current;
          if (map) {
            map.setView([position.coords.latitude, position.coords.longitude], 12);
            
            // Add user location marker
            const userIcon = L.divIcon({
              className: 'user-location-icon',
              html: `<div style="background: #3b82f6; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px #3b82f6;"></div>`,
              iconSize: [16, 16],
              iconAnchor: [8, 8]
            });
            
            L.marker([position.coords.latitude, position.coords.longitude], { icon: userIcon })
              .addTo(map)
              .bindPopup('Your current location');
          }
        },
        (error) => {
          console.error('Geolocation error:', error);
          alert('Unable to get your location. Please enable location services.');
        }
      );
    } else {
      alert('Geolocation is not supported by your browser.');
    }
  };

  return (
    <div className="relative w-full h-full rounded-xl overflow-hidden border border-slate-800 shadow-2xl">
      <div ref={mapContainerRef} className="w-full h-full min-h-[50vh] sm:min-h-[60vh] lg:min-h-[420px]" />

      {/* Map Type Switcher */}
      <div className="absolute top-3 right-3 z-20 bg-slate-900/90 backdrop-blur-md p-2 rounded-lg border border-slate-700/60 shadow-xl">
        <div className="flex flex-col gap-1">
          <button
            onClick={() => switchMapType('dark')}
            className={`px-3 py-1.5 text-[10px] font-bold rounded transition-all ${
              mapType === 'dark' ? 'bg-blue-600 text-white' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Dark
          </button>
          <button
            onClick={() => switchMapType('satellite')}
            className={`px-3 py-1.5 text-[10px] font-bold rounded transition-all ${
              mapType === 'satellite' ? 'bg-blue-600 text-white' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Satellite
          </button>
          <button
            onClick={() => switchMapType('terrain')}
            className={`px-3 py-1.5 text-[10px] font-bold rounded transition-all ${
              mapType === 'terrain' ? 'bg-blue-600 text-white' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Terrain
          </button>
          <button
            onClick={() => switchMapType('streets')}
            className={`px-3 py-1.5 text-[10px] font-bold rounded transition-all ${
              mapType === 'streets' ? 'bg-blue-600 text-white' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Streets
          </button>
        </div>
      </div>

      {/* Location Button */}
      <div className="absolute top-3 left-3 z-20">
        <button
          onClick={getCurrentLocation}
          className="bg-slate-900/90 backdrop-blur-md p-2.5 rounded-lg border border-slate-700/60 shadow-xl hover:bg-slate-800 transition-all"
          title="Get my location"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
            <circle cx="12" cy="10" r="3"></circle>
          </svg>
        </button>
      </div>

      {/* Map Legend Overlay */}
      <div className="absolute bottom-3 sm:bottom-4 left-3 sm:left-4 z-20 bg-slate-900/90 backdrop-blur-md p-2.5 sm:p-3 rounded-lg border border-slate-700/60 shadow-xl text-[10px] sm:text-xs space-y-1.5 max-w-[180px] sm:max-w-[220px]">
        <div className="font-bold text-slate-200 text-[10px] sm:text-[11px] uppercase tracking-wider mb-1">
          Landslide Risk Legend
        </div>
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 sm:w-3 sm:h-3 rounded-full bg-red-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[9px] sm:text-[11px]">EVACUATE (80 – 100)</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 sm:w-3 sm:h-3 rounded-full bg-orange-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[9px] sm:text-[11px]">WARNING (60 – 79)</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 sm:w-3 sm:h-3 rounded-full bg-yellow-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[9px] sm:text-[11px]">WATCH (30 – 59)</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="w-2.5 h-2.5 sm:w-3 sm:h-3 rounded-full bg-emerald-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[9px] sm:text-[11px]">SAFE (0 – 29)</span>
        </div>

        <div className="pt-1.5 border-t border-slate-800 space-y-1">
          <div className="text-[9px] sm:text-[10px] font-bold text-slate-400 uppercase">Field Distress Markers</div>
          <div className="grid grid-cols-2 gap-1 text-[9px] sm:text-[10px] text-slate-300">
            <span>⚡ Crack</span>
            <span>⛔ Block</span>
            <span>▲ Rock</span>
            <span>✓ Verified</span>
          </div>
        </div>
      </div>
    </div>
  );
};
