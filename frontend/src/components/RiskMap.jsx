import React, { useEffect, useRef } from 'react';
import L from 'leaflet';

export const RiskMap = ({ zones = [], reports = [], selectedZoneId, onSelectZone }) => {
  const mapContainerRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const layerGroupRef = useRef(null);

  // Helper for risk color
  const getRiskColor = (level, score) => {
    if (level === 'EVACUATE' || score >= 80) return '#EF4444';
    if (level === 'WARNING' || score >= 60) return '#F97316';
    if (level === 'WATCH' || score >= 30) return '#EAB308';
    return '#22C55E';
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

    // Initialize Leaflet map centered on North East India (26.0, 92.5)
    if (!mapInstanceRef.current) {
      const map = L.map(mapContainerRef.current, {
        center: [26.0, 92.5],
        zoom: 7,
        zoomControl: true
      });

      // Dark theme GIS tile layer (CartoDB Dark Matter)
      L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> &copy; <a href="https://carto.com/">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 19
      }).addTo(map);

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

  return (
    <div className="relative w-full h-full rounded-xl overflow-hidden border border-slate-800 shadow-2xl">
      <div ref={mapContainerRef} className="w-full h-full min-h-[420px]" />

      {/* Map Legend Overlay */}
      <div className="absolute bottom-4 left-4 z-20 bg-slate-900/90 backdrop-blur-md p-3 rounded-lg border border-slate-700/60 shadow-xl text-xs space-y-1.5 max-w-[220px]">
        <div className="font-bold text-slate-200 text-[11px] uppercase tracking-wider mb-1">
          Landslide Risk Legend
        </div>
        <div className="flex items-center gap-2">
          <span className="w-3 h-3 rounded-full bg-red-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[11px]">EVACUATE (80 – 100)</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="w-3 h-3 rounded-full bg-orange-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[11px]">WARNING (60 – 79)</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="w-3 h-3 rounded-full bg-yellow-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[11px]">WATCH (30 – 59)</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="w-3 h-3 rounded-full bg-emerald-500 inline-block shadow"></span>
          <span className="text-slate-300 font-medium text-[11px]">SAFE (0 – 29)</span>
        </div>

        <div className="pt-1.5 border-t border-slate-800 space-y-1">
          <div className="text-[10px] font-bold text-slate-400 uppercase">Field Distress Markers</div>
          <div className="grid grid-cols-2 gap-1 text-[10px] text-slate-300">
            <span>⚡ Tension Crack</span>
            <span>⛔ Road Block</span>
            <span>▲ Rockfall</span>
            <span>✓ Verified</span>
          </div>
        </div>
      </div>
    </div>
  );
};
