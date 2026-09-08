import React, { useState } from 'react';
import { Building2, Mail, Phone, Shield, MapPin, Briefcase, ArrowLeft, CheckCircle, AlertCircle } from 'lucide-react';

export const AdminAuth = ({ onBack, onLoginSuccess }) => {
  const [isLogin, setIsLogin] = useState(false);
  const [step, setStep] = useState(1); // 1: form, 2: verification, 3: success
  const [formData, setFormData] = useState({
    fullName: '',
    officialEmail: '',
    phone: '',
    govIdNumber: '',
    govIdType: 'PAN',
    department: 'Disaster Management',
    designation: 'District Magistrate',
    district: 'East Khasi Hills'
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const districts = [
    'East Khasi Hills',
    'West Khasi Hills',
    'Ri Bhoi',
    'South West Khasi Hills',
    'East Jaintia Hills',
    'West Jaintia Hills'
  ];

  const departments = [
    'Disaster Management',
    'Revenue Department',
    'Public Works Department',
    'Health Department',
    'Police Department',
    'District Administration'
  ];

  const designations = [
    'District Magistrate',
    'Sub-Divisional Magistrate',
    'Block Development Officer',
    'Emergency Response Officer',
    'District Disaster Management Officer'
  ];

  const govIdTypes = [
    'PAN',
    'Employee ID',
    'Government Service ID',
    'Aadhaar'
  ];

  const handleRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('http://localhost:8000/api/citizens/admin/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: formData.fullName,
          official_email: formData.officialEmail,
          phone: formData.phone,
          gov_id_number: formData.govIdNumber,
          gov_id_type: formData.govIdType,
          department: formData.department,
          designation: formData.designation,
          district: formData.district
        })
      });

      const data = await response.json();
      
      if (response.ok) {
        setStep(2); // Move to verification step
      } else {
        setError(data.detail || 'Registration failed');
      }
    } catch (err) {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('http://localhost:8000/api/citizens/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          phone: formData.phone,
          role: 'ADMIN'
        })
      });

      const data = await response.json();
      
      if (response.ok && data.success) {
        onLoginSuccess({
          userCode: data.user_code,
          fullName: data.full_name,
          role: data.role,
          verified: data.verified
        });
      } else {
        setError(data.message || 'Login failed');
      }
    } catch (err) {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerification = () => {
    // Simulate government ID verification
    setStep(3);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-gov-blue/20 flex items-center justify-center p-4">
      <div className="max-w-2xl w-full">
        {/* Header */}
        <button
          onClick={onBack}
          className="flex items-center text-slate-400 hover:text-white mb-6 transition-colors"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back to Role Selection
        </button>

        <div className="bg-slate-800/50 backdrop-blur-sm border-2 border-slate-700 rounded-2xl p-8">
          {/* Title */}
          <div className="text-center mb-8">
            <div className="bg-gov-blue/20 p-4 rounded-xl inline-block mb-4">
              <Building2 className="w-12 h-12 text-gov-blue" />
            </div>
            <h2 className="text-3xl font-bold text-white mb-2">
              {isLogin ? 'Admin Login' : 'Admin Registration'}
            </h2>
            <p className="text-slate-400">
              {isLogin ? 'Access government dashboard' : 'Register as government officer'}
            </p>
          </div>

          {/* Toggle */}
          <div className="flex bg-slate-700 rounded-lg p-1 mb-6">
            <button
              onClick={() => { setIsLogin(false); setStep(1); setError(''); }}
              className={`flex-1 py-2 px-4 rounded-md transition-all ${
                !isLogin ? 'bg-gov-blue text-white' : 'text-slate-400'
              }`}
            >
              Register
            </button>
            <button
              onClick={() => { setIsLogin(true); setStep(1); setError(''); }}
              className={`flex-1 py-2 px-4 rounded-md transition-all ${
                isLogin ? 'bg-gov-blue text-white' : 'text-slate-400'
              }`}
            >
              Login
            </button>
          </div>

          {/* Error */}
          {error && (
            <div className="bg-red-500/20 border border-red-500/50 rounded-lg p-4 mb-6 flex items-start">
              <AlertCircle className="w-5 h-5 text-red-400 mr-3 mt-0.5" />
              <p className="text-red-400 text-sm">{error}</p>
            </div>
          )}

          {/* Step 1: Form */}
          {step === 1 && (
            <form onSubmit={isLogin ? handleLogin : handleRegister} className="space-y-4">
              {!isLogin && (
                <>
                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Full Name</label>
                    <div className="relative">
                      <Building2 className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <input
                        type="text"
                        required
                        value={formData.fullName}
                        onChange={(e) => setFormData({...formData, fullName: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                        placeholder="Enter your full name"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Official Email</label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <input
                        type="email"
                        required
                        value={formData.officialEmail}
                        onChange={(e) => setFormData({...formData, officialEmail: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                        placeholder="official@gov.in"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Government ID Type</label>
                    <div className="relative">
                      <Shield className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <select
                        value={formData.govIdType}
                        onChange={(e) => setFormData({...formData, govIdType: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none appearance-none"
                      >
                        {govIdTypes.map(t => <option key={t} value={t}>{t}</option>)}
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Government ID Number</label>
                    <div className="relative">
                      <Shield className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <input
                        type="text"
                        required
                        value={formData.govIdNumber}
                        onChange={(e) => setFormData({...formData, govIdNumber: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                        placeholder="Enter government ID number"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Department</label>
                    <div className="relative">
                      <Briefcase className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <select
                        value={formData.department}
                        onChange={(e) => setFormData({...formData, department: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none appearance-none"
                      >
                        {departments.map(d => <option key={d} value={d}>{d}</option>)}
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Designation</label>
                    <select
                      value={formData.designation}
                      onChange={(e) => setFormData({...formData, designation: e.target.value})}
                      className="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                    >
                      {designations.map(d => <option key={d} value={d}>{d}</option>)}
                    </select>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">District</label>
                    <div className="relative">
                      <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <select
                        value={formData.district}
                        onChange={(e) => setFormData({...formData, district: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none appearance-none"
                      >
                        {districts.map(d => <option key={d} value={d}>{d}</option>)}
                      </select>
                    </div>
                  </div>
                </>
              )}

              <div>
                <label className="block text-slate-300 text-sm mb-2">Mobile Number</label>
                <div className="relative">
                  <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                  <input
                    type="tel"
                    required
                    value={formData.phone}
                    onChange={(e) => setFormData({...formData, phone: e.target.value})}
                    className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                    placeholder="10-digit mobile number"
                    maxLength={10}
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-gov-blue hover:bg-gov-blue-light text-white font-semibold py-3 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? 'Processing...' : (isLogin ? 'Login' : 'Register & Verify ID')}
              </button>

              {!isLogin && (
                <p className="text-xs text-slate-500 text-center">
                  For demo: Government ID verification will be simulated
                </p>
              )}
            </form>
          )}

          {/* Step 2: Verification */}
          {step === 2 && (
            <div className="space-y-6">
              <div className="text-center">
                <Shield className="w-16 h-16 text-yellow-400 mx-auto mb-4" />
                <h3 className="text-xl font-bold text-white mb-2">Government ID Verification</h3>
                <p className="text-slate-400">Your government credentials are being verified</p>
              </div>

              <div className="bg-yellow-500/20 border border-yellow-500/50 rounded-lg p-4">
                <p className="text-yellow-400 text-sm">
                  <strong>Note:</strong> In production, this would integrate with government identity verification systems. For this prototype, verification is simulated.
                </p>
              </div>

              <div className="bg-slate-700 rounded-lg p-4 space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-slate-400">Name:</span>
                  <span className="text-white">{formData.fullName}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-slate-400">Department:</span>
                  <span className="text-white">{formData.department}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-slate-400">Designation:</span>
                  <span className="text-white">{formData.designation}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-slate-400">District:</span>
                  <span className="text-white">{formData.district}</span>
                </div>
              </div>

              <button
                onClick={handleVerification}
                className="w-full bg-gov-blue hover:bg-gov-blue-light text-white font-semibold py-3 rounded-lg transition-colors"
              >
                Complete Verification
              </button>
            </div>
          )}

          {/* Step 3: Success */}
          {step === 3 && (
            <div className="text-center space-y-6">
              <CheckCircle className="w-20 h-20 text-green-400 mx-auto mb-4" />
              <div>
                <h3 className="text-2xl font-bold text-white mb-2">Verification Complete!</h3>
                <p className="text-slate-400 mb-4">Your admin account is now active</p>
                <div className="bg-green-500/20 border border-green-500/50 rounded-lg p-4">
                  <p className="text-green-400 font-semibold">You can now access the government dashboard</p>
                </div>
              </div>

              <button
                onClick={() => onLoginSuccess({
                  userCode: 'TG-ADM-DEMO',
                  fullName: formData.fullName,
                  role: 'ADMIN',
                  verified: true
                })}
                className="w-full bg-gov-blue hover:bg-gov-blue-light text-white font-semibold py-3 rounded-lg transition-colors"
              >
                Continue to Dashboard
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
