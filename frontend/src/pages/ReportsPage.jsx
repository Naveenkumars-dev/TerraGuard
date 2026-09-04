import React, { useState, useEffect } from 'react';
import { useApp } from '../context/AppContext';
import { fetchReports, submitCitizenReport, verifyReportStatus } from '../services/api';
import { FileSpreadsheet, MapPin, Camera, CheckCircle2, XCircle, AlertTriangle, ShieldCheck, Upload, Image as ImageIcon } from 'lucide-react';

export const ReportsPage = () => {
  const { userRole, refreshTrigger, triggerRefresh } = useApp();
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(null);

  // Form State
  const [reporterType, setReporterType] = useState('Citizen');
  const [district, setDistrict] = useState('East Khasi Hills');
  const [locationName, setLocationName] = useState('Nongpriang Slope Road km 14');
  const [issueType, setIssueType] = useState('Crack');
  const [severity, setSeverity] = useState('High');
  const [description, setDescription] = useState('Observed 3-inch tension crack propagating along highway embankment after heavy rain.');
  const [photoUrl, setPhotoUrl] = useState('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80');
  const [photoPreview, setPhotoPreview] = useState('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80');
  const [gpsCoords, setGpsCoords] = useState({ lat: 25.3210, lng: 91.7015 });

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const data = await fetchReports();
        setReports(data);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [refreshTrigger]);

  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPhotoUrl(reader.result);
        setPhotoPreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmitReport = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const payload = {
        reporter_type: reporterType,
        district,
        location_name: locationName,
        latitude: gpsCoords.lat,
        longitude: gpsCoords.lng,
        issue_type: issueType,
        severity,
        description,
        photo_url: photoUrl
      };
      const res = await submitCitizenReport(payload);
      setSubmitSuccess(res);
      triggerRefresh();
    } finally {
      setSubmitting(false);
    }
  };

  const handleVerify = async (id, status) => {
    await verifyReportStatus(id, status, userRole);
    triggerRefresh();
  };

  const handleGetGps = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          setGpsCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude });
        },
        () => {
          setGpsCoords({ lat: 25.5788, lng: 91.8933 });
        }
      );
    }
  };

  const isAdminOrOfficial = userRole === 'District Admin' || userRole === 'Field Official' || userRole === 'State Authority';

  return (
    <div className="p-6 space-y-6 max-w-[1600px] mx-auto">
      {/* Page Title */}
      <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl shadow-lg flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-purple-950/60 border border-purple-500/40 rounded-lg text-purple-400">
            <FileSpreadsheet className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white">Citizen & Field Slope Distress Reporting</h2>
            <p className="text-xs text-slate-400">Crowdsourced ground verification & admin validation queue</p>
          </div>
        </div>
        <span className="text-xs font-semibold text-slate-300 bg-slate-800 px-3 py-1 rounded-lg border border-slate-700">
          User Role: <strong className="text-purple-300">{userRole}</strong>
        </span>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Submit Report Form */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-5">
          <div className="border-b border-slate-800 pb-3">
            <h3 className="text-sm font-bold text-white uppercase tracking-wider">Report Slope Distress</h3>
            <p className="text-[11px] text-slate-400">Submit field distress observations to trigger AI risk re-calculation</p>
          </div>

          {submitSuccess && (
            <div className="bg-emerald-950/80 border border-emerald-500/60 p-3 rounded-xl text-xs space-y-1">
              <div className="flex items-center gap-2 text-emerald-300 font-bold">
                <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                <span>Report Submitted Successfully</span>
              </div>
              <p className="text-slate-300">
                Generated Report ID: <strong className="font-mono text-emerald-300">{submitSuccess.report_code || 'TG-RPT-1042'}</strong>
              </p>
              <span className="text-[10px] text-amber-400 block font-semibold pt-1">
                Status: Pending Admin Verification
              </span>
            </div>
          )}

          <form onSubmit={handleSubmitReport} className="space-y-4 text-xs">
            {/* Reporter Type */}
            <div>
              <label className="block text-slate-400 font-bold mb-1">Reporter Category</label>
              <div className="grid grid-cols-2 gap-2">
                {['Citizen', 'Field Official'].map((t) => (
                  <button
                    type="button"
                    key={t}
                    onClick={() => setReporterType(t)}
                    className={`py-2 rounded-lg font-bold border transition-all ${
                      reporterType === t
                        ? 'bg-purple-600 text-white border-purple-500 shadow'
                        : 'bg-slate-800 text-slate-300 border-slate-700'
                    }`}
                  >
                    {t}
                  </button>
                ))}
              </div>
            </div>

            {/* District & Location */}
            <div className="space-y-3">
              <div>
                <label className="block text-slate-400 font-bold mb-1">District</label>
                <select
                  value={district}
                  onChange={(e) => setDistrict(e.target.value)}
                  className="w-full bg-slate-800 text-slate-200 border border-slate-700 rounded-lg p-2 font-semibold"
                >
                  <option value="East Khasi Hills">East Khasi Hills</option>
                  <option value="East Sikkim">East Sikkim</option>
                  <option value="Tawang">Tawang</option>
                  <option value="Aizawl">Aizawl</option>
                  <option value="Kohima">Kohima</option>
                  <option value="Dima Hasao">Dima Hasao</option>
                </select>
              </div>

              <div>
                <label className="block text-slate-400 font-bold mb-1">Location / Landmark Name</label>
                <input
                  type="text"
                  value={locationName}
                  onChange={(e) => setLocationName(e.target.value)}
                  className="w-full bg-slate-800 text-slate-200 border border-slate-700 rounded-lg p-2 font-medium"
                  required
                />
              </div>
            </div>

            {/* Issue Type & Severity */}
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-slate-400 font-bold mb-1">Issue Type</label>
                <select
                  value={issueType}
                  onChange={(e) => setIssueType(e.target.value)}
                  className="w-full bg-slate-800 text-slate-200 border border-slate-700 rounded-lg p-2 font-semibold"
                >
                  <option value="Crack">Crack</option>
                  <option value="Slope movement">Slope movement</option>
                  <option value="Rockfall">Rockfall</option>
                  <option value="Road blockage">Road blockage</option>
                  <option value="Water seepage">Water seepage</option>
                </select>
              </div>

              <div>
                <label className="block text-slate-400 font-bold mb-1">Severity</label>
                <select
                  value={severity}
                  onChange={(e) => setSeverity(e.target.value)}
                  className="w-full bg-slate-800 text-slate-200 border border-slate-700 rounded-lg p-2 font-semibold"
                >
                  <option value="Low">Low</option>
                  <option value="Medium">Medium</option>
                  <option value="High">High</option>
                  <option value="Critical">Critical</option>
                </select>
              </div>
            </div>

            {/* Description */}
            <div>
              <label className="block text-slate-400 font-bold mb-1">Field Observation Details</label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                rows={3}
                className="w-full bg-slate-800 text-slate-200 border border-slate-700 rounded-lg p-2 font-medium"
                required
              />
            </div>

            {/* Upload Photo (File or Link) */}
            <div className="space-y-2">
              <label className="block text-slate-400 font-bold">Photo Attachment</label>

              <div className="flex items-center gap-2">
                <label className="cursor-pointer px-3 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 rounded-lg text-xs font-bold flex items-center gap-1.5 shadow">
                  <Upload className="w-4 h-4 text-purple-400" />
                  <span>Upload Local Image</span>
                  <input type="file" accept="image/*" onChange={handleFileUpload} className="hidden" />
                </label>
                <span className="text-[10px] text-slate-400 font-medium">Or paste image URL below</span>
              </div>

              <input
                type="text"
                value={photoUrl}
                onChange={(e) => {
                  setPhotoUrl(e.target.value);
                  setPhotoPreview(e.target.value);
                }}
                className="w-full bg-slate-800 text-slate-300 border border-slate-700 rounded-lg p-2 font-mono text-[10px]"
              />

              {photoPreview && (
                <div className="h-24 w-full rounded-lg overflow-hidden border border-slate-700 relative">
                  <img src={photoPreview} alt="Preview" className="w-full h-full object-cover" />
                  <span className="absolute bottom-1 right-1 text-[9px] bg-slate-900/90 text-slate-300 px-1.5 py-0.5 rounded font-mono">Photo Preview</span>
                </div>
              )}

              <div className="flex items-center justify-between bg-slate-800/60 p-2 rounded-lg border border-slate-700/50">
                <div className="text-[11px] text-slate-300 font-mono">
                  GPS: {gpsCoords.lat.toFixed(4)}, {gpsCoords.lng.toFixed(4)}
                </div>
                <button
                  type="button"
                  onClick={handleGetGps}
                  className="px-2.5 py-1 bg-purple-950 hover:bg-purple-900 text-purple-300 border border-purple-700 rounded text-[10px] font-bold flex items-center gap-1"
                >
                  <MapPin className="w-3 h-3" /> Get Current GPS
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={submitting}
              className="w-full py-3 bg-purple-600 hover:bg-purple-500 text-white font-extrabold text-xs rounded-xl shadow-lg transition-all"
            >
              {submitting ? 'Submitting Report...' : 'Submit Field Report'}
            </button>
          </form>
        </div>

        {/* Right Column: Submitted Reports & Admin Verification Queue */}
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-sm font-bold text-white uppercase tracking-wider">
                Submitted Reports & Admin Verification Queue
              </h3>
              <span className="text-xs font-mono text-slate-400">{reports.length} Total Submissions</span>
            </div>

            <div className="space-y-4 max-h-[680px] overflow-y-auto pr-1">
              {reports.map((rpt) => (
                <div
                  key={rpt.id}
                  className="bg-slate-800/60 border border-slate-700/60 rounded-xl p-4 space-y-3 shadow-lg"
                >
                  <div className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-700/50 pb-2">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-purple-400 text-xs">{rpt.report_code}</span>
                      <span className="px-2 py-0.5 text-[10px] font-bold bg-slate-700 text-slate-200 rounded">
                        {rpt.reporter_type}
                      </span>
                      <span className={`px-2 py-0.5 text-[10px] font-bold rounded ${
                        rpt.severity === 'Critical' ? 'bg-red-950 text-red-300 border border-red-700' :
                        rpt.severity === 'High' ? 'bg-orange-950 text-orange-300 border border-orange-700' : 'bg-slate-700 text-slate-300'
                      }`}>
                        {rpt.issue_type} ({rpt.severity})
                      </span>
                    </div>

                    <span className={`text-[11px] font-bold px-2.5 py-0.5 rounded ${
                      rpt.status === 'Verified' ? 'bg-emerald-950 text-emerald-300 border border-emerald-700' :
                      rpt.status === 'False Alarm' ? 'bg-slate-700 text-slate-400' : 'bg-amber-950 text-amber-300 border border-amber-700 animate-pulse'
                    }`}>
                      {rpt.status}
                    </span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
                    {/* Photo preview */}
                    {rpt.photo_url && (
                      <div className="h-28 rounded-lg overflow-hidden border border-slate-700">
                        <img src={rpt.photo_url} alt="Report distress" className="w-full h-full object-cover" />
                      </div>
                    )}

                    <div className="sm:col-span-2 space-y-1.5">
                      <div className="font-bold text-white text-xs">{rpt.location_name} ({rpt.district})</div>
                      <p className="text-slate-300 text-xs leading-relaxed">{rpt.description}</p>
                      <div className="text-[10px] text-slate-400 font-mono pt-1">
                        GPS: {rpt.latitude ? rpt.latitude.toFixed(4) : '25.3210'}, {rpt.longitude ? rpt.longitude.toFixed(4) : '91.7015'} • Submitted: {new Date(rpt.timestamp).toLocaleString()}
                      </div>
                    </div>
                  </div>

                  {/* Admin Verification Action Buttons */}
                  <div className="flex items-center justify-between border-t border-slate-700/50 pt-2.5 text-xs">
                    <div className="text-slate-400 text-[11px]">
                      {rpt.verified_by ? <span>Verified by: <strong className="text-slate-200">{rpt.verified_by}</strong></span> : <span>Requires Verification</span>}
                    </div>

                    {isAdminOrOfficial ? (
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleVerify(rpt.id, 'Verified')}
                          className="px-3 py-1 bg-emerald-600 hover:bg-emerald-500 text-white font-bold rounded-lg text-xs shadow flex items-center gap-1"
                        >
                          <CheckCircle2 className="w-3.5 h-3.5" /> Verify & Escalate Risk
                        </button>
                        <button
                          onClick={() => handleVerify(rpt.id, 'False Alarm')}
                          className="px-3 py-1 bg-slate-700 hover:bg-slate-600 text-slate-300 font-bold rounded-lg text-xs flex items-center gap-1"
                        >
                          <XCircle className="w-3.5 h-3.5" /> False Alarm
                        </button>
                      </div>
                    ) : (
                      <span className="text-[10px] text-slate-500 font-semibold bg-slate-800 px-2 py-1 rounded">
                        Switch role to District Admin to verify
                      </span>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
