import React, { useState } from 'react';
import { User, Phone, Shield, MapPin, ArrowLeft, CheckCircle, AlertCircle } from 'lucide-react';

export const CitizenAuth = ({ onBack, onLoginSuccess }) => {
  const [isLogin, setIsLogin] = useState(false);
  const [step, setStep] = useState(1); // 1: form, 2: otp, 3: success
  const [formData, setFormData] = useState({
    fullName: '',
    phone: '',
    aadhaar: '',
    district: 'East Khasi Hills',
    vulnerability: 'Normal',
    emergencyContact: ''
  });
  const [otp, setOtp] = useState('');
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

  const vulnerabilityProfiles = [
    'Normal',
    'Elderly (60+)',
    'Children',
    'Disability',
    'Medical Needs'
  ];

  const handleRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await fetch('http://localhost:8000/api/citizens/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: formData.fullName,
          phone: formData.phone,
          gov_id_masked: `Aadhaar XXXX-XXXX-${formData.aadhaar.slice(-4)}`,
          registered_district: formData.district,
          vulnerability_profile: formData.vulnerability,
          emergency_contact: formData.emergencyContact,
          latitude: 25.5788,
          longitude: 91.8933
        })
      });

      const data = await response.json();
      
      if (response.ok) {
        setStep(2); // Move to OTP verification
      } else {
        setError(data.detail || 'Registration failed');
      }
    } catch (err) {
      console.error('Registration error:', err);
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
          role: 'CITIZEN'
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

  const handleOTPVerify = () => {
    // Simulate OTP verification
    if (otp === '123456') {
      setStep(3);
    } else {
      setError('Invalid OTP. Try 123456 for demo.');
    }
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
              <User className="w-12 h-12 text-gov-blue" />
            </div>
            <h2 className="text-3xl font-bold text-white mb-2">
              {isLogin ? 'Citizen Login' : 'Citizen Registration'}
            </h2>
            <p className="text-slate-400">
              {isLogin ? 'Access your citizen dashboard' : 'Register for emergency alerts'}
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
                      <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
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
                    <label className="block text-slate-300 text-sm mb-2">Aadhaar Verification</label>
                    <div className="relative">
                      <Shield className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <input
                        type="text"
                        required
                        value={formData.aadhaar}
                        onChange={(e) => setFormData({...formData, aadhaar: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                        placeholder="XXXX XXXX 1234"
                        maxLength={12}
                      />
                    </div>
                    <p className="text-xs text-slate-500 mt-1">For demo: Enter any 12 digits. Aadhaar verification is simulated.</p>
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

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Vulnerability Profile</label>
                    <select
                      value={formData.vulnerability}
                      onChange={(e) => setFormData({...formData, vulnerability: e.target.value})}
                      className="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                    >
                      {vulnerabilityProfiles.map(v => <option key={v} value={v}>{v}</option>)}
                    </select>
                  </div>

                  <div>
                    <label className="block text-slate-300 text-sm mb-2">Emergency Contact</label>
                    <div className="relative">
                      <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                      <input
                        type="tel"
                        required
                        value={formData.emergencyContact}
                        onChange={(e) => setFormData({...formData, emergencyContact: e.target.value})}
                        className="w-full bg-slate-700 border border-slate-600 rounded-lg pl-10 pr-4 py-3 text-white focus:border-gov-blue focus:outline-none"
                        placeholder="Emergency contact number"
                      />
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
                {loading ? 'Processing...' : (isLogin ? 'Login' : 'Register & Send OTP')}
              </button>

              {!isLogin && (
                <p className="text-xs text-slate-500 text-center">
                  For demo: Use any Aadhaar number. OTP will be 123456
                </p>
              )}
            </form>
          )}

          {/* Step 2: OTP Verification */}
          {step === 2 && (
            <div className="space-y-6">
              <div className="text-center">
                <CheckCircle className="w-16 h-16 text-green-400 mx-auto mb-4" />
                <h3 className="text-xl font-bold text-white mb-2">Registration Successful!</h3>
                <p className="text-slate-400">Enter the OTP sent to your mobile</p>
              </div>

              <div>
                <label className="block text-slate-300 text-sm mb-2">OTP</label>
                <input
                  type="text"
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  className="w-full bg-slate-700 border border-slate-600 rounded-lg px-4 py-3 text-white text-center text-2xl tracking-widest focus:border-gov-blue focus:outline-none"
                  placeholder="Enter 6-digit OTP"
                  maxLength={6}
                />
              </div>

              <button
                onClick={handleOTPVerify}
                className="w-full bg-gov-blue hover:bg-gov-blue-light text-white font-semibold py-3 rounded-lg transition-colors"
              >
                Verify OTP
              </button>

              <p className="text-xs text-slate-500 text-center">
                Demo OTP: 123456
              </p>
            </div>
          )}

          {/* Step 3: Success */}
          {step === 3 && (
            <div className="text-center space-y-6">
              <CheckCircle className="w-20 h-20 text-green-400 mx-auto mb-4" />
              <div>
                <h3 className="text-2xl font-bold text-white mb-2">Aadhaar Verified!</h3>
                <p className="text-slate-400 mb-4">Your citizen account is now active</p>
                <div className="bg-green-500/20 border border-green-500/50 rounded-lg p-4 space-y-2">
                  <div className="flex items-center justify-center gap-2 text-green-400 font-semibold">
                    <CheckCircle className="w-4 h-4" />
                    <span>Identity Verified</span>
                  </div>
                  <div className="flex items-center justify-center gap-2 text-green-400 font-semibold">
                    <CheckCircle className="w-4 h-4" />
                    <span>Mobile Registered</span>
                  </div>
                  <div className="flex items-center justify-center gap-2 text-green-400 font-semibold">
                    <CheckCircle className="w-4 h-4" />
                    <span>Emergency Alerts Enabled</span>
                  </div>
                </div>
              </div>

              <button
                onClick={() => onLoginSuccess({
                  userCode: 'TG-USR-DEMO',
                  fullName: formData.fullName,
                  role: 'CITIZEN',
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
