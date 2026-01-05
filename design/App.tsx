import React, { useState, useEffect, useMemo } from 'react';
import { 
  AppView, 
  Tab, 
  Place, 
  PlaceCategory, 
  WalkRoute 
} from './types';
import { 
  MOCK_PLACES, 
  CATEGORIES, 
  USER_LOCATION 
} from './constants';
import { 
  Map as MapIcon, 
  List as ListIcon, 
  Footprints, 
  Settings, 
  ChevronRight, 
  Moon, 
  Sun,
  Database,
  ShieldCheck,
  RefreshCw,
  Locate,
  CategoryIcon
} from './components/Icon';
import MapComponent from './components/MapComponent';
import DetailView from './components/DetailView';

const App = () => {
  // State
  const [appView, setAppView] = useState<AppView>(AppView.SPLASH);
  const [activeTab, setActiveTab] = useState<Tab>(Tab.MAP);
  const [selectedCategory, setSelectedCategory] = useState<PlaceCategory | null>(null);
  const [selectedPlace, setSelectedPlace] = useState<Place | null>(null);
  const [walkRoute, setWalkRoute] = useState<WalkRoute | null>(null);
  const [isDarkMode, setIsDarkMode] = useState(false);
  
  // Responsive State
  const [windowWidth, setWindowWidth] = useState(window.innerWidth);
  const isMobile = windowWidth < 1024; // Tailwind lg breakpoint

  useEffect(() => {
    const handleResize = () => setWindowWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    
    // Check system preference for dark mode
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      setIsDarkMode(true);
    }

    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Update HTML class for Tailwind Dark Mode
  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDarkMode]);

  // Splash Screen Timer
  useEffect(() => {
    if (appView === AppView.SPLASH) {
      const timer = setTimeout(() => {
        // Check local storage for onboarding in a real app
        setAppView(AppView.ONBOARDING);
      }, 2500);
      return () => clearTimeout(timer);
    }
  }, [appView]);

  // Generators
  const generateWalk = () => {
    // Pick 3 random places
    const shuffled = [...MOCK_PLACES].sort(() => 0.5 - Math.random());
    const selected = shuffled.slice(0, 3);
    setWalkRoute({
      id: Date.now().toString(),
      points: selected,
      totalDistance: selected.reduce((acc, curr) => acc + curr.distance, 0) + 200, // + return trip approx
      totalTime: 12 // hardcoded for the "12 min" branding
    });
  };

  // Views
  if (appView === AppView.SPLASH) {
    return (
      <div className="h-screen w-screen flex flex-col items-center justify-center bg-kasidie-bg dark:bg-kasidie-bgDark transition-colors">
        <h1 className="text-4xl font-light tracking-tight text-slate-900 dark:text-slate-100 mb-2 font-sans">
          kasidie
        </h1>
        <span className="text-sm font-medium tracking-widest uppercase text-slate-500">City Whisper</span>
        <div className="mt-8 w-12 h-1 bg-slate-200 dark:bg-slate-800 rounded-full overflow-hidden">
          <div className="h-full bg-slate-800 dark:bg-slate-200 w-1/3 animate-[slideUp_1s_infinite_linear] origin-left" style={{ animationName: 'slide' }}></div>
        </div>
        <style>{`
          @keyframes slide {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(300%); }
          }
        `}</style>
      </div>
    );
  }

  if (appView === AppView.ONBOARDING) {
    return (
      <div className="h-screen w-screen flex flex-col p-8 bg-kasidie-bg dark:bg-kasidie-bgDark max-w-md mx-auto">
        <div className="flex-1 flex flex-col justify-center">
          <h1 className="text-3xl font-semibold mb-2 text-slate-900 dark:text-slate-100">Kasidie City Whisper</h1>
          <p className="text-lg text-slate-500 dark:text-slate-400 mb-12">Unusual and useful places around you.</p>

          <div className="space-y-8">
            <div className="flex gap-4">
              <div className="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center shrink-0">
                 <Locate className="w-5 h-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <h3 className="font-medium text-slate-900 dark:text-slate-200">Nearby Gems</h3>
                <p className="text-sm text-slate-500 leading-relaxed">Allow location to find quiet spots and utilities.</p>
              </div>
            </div>
            <div className="flex gap-4">
              <div className="w-10 h-10 rounded-full bg-emerald-100 dark:bg-emerald-900/30 flex items-center justify-center shrink-0">
                 <CategoryIcon category={PlaceCategory.VIEWPOINT} className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
              </div>
              <div>
                <h3 className="font-medium text-slate-900 dark:text-slate-200">Useful Categories</h3>
                <p className="text-sm text-slate-500 leading-relaxed">Museums, water fountains, art, and more.</p>
              </div>
            </div>
            <div className="flex gap-4">
              <div className="w-10 h-10 rounded-full bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center shrink-0">
                 <Footprints className="w-5 h-5 text-purple-600 dark:text-purple-400" />
              </div>
              <div>
                <h3 className="font-medium text-slate-900 dark:text-slate-200">12 min Walk</h3>
                <p className="text-sm text-slate-500 leading-relaxed">Get a quick, curated loop to clear your head.</p>
              </div>
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <p className="text-xs text-center text-slate-400">
            No accounts. No tracking. Uses OpenStreetMap public data.
          </p>
          <button 
            onClick={() => setAppView(AppView.APP)}
            className="w-full py-4 bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 rounded-2xl font-semibold text-lg active:scale-95 transition-transform"
          >
            Start Exploring
          </button>
          <button 
             onClick={() => setAppView(AppView.APP)}
            className="w-full py-2 text-slate-500 text-sm font-medium"
          >
            Continue without location
          </button>
        </div>
      </div>
    );
  }

  // --- Main App Logic ---

  // Layout handling
  const handleTabChange = (tab: Tab) => {
    setActiveTab(tab);
    if (tab === Tab.WALK && !walkRoute) {
      generateWalk();
    }
    if (tab !== Tab.WALK) {
      setWalkRoute(null);
    }
  };

  const renderContent = () => {
    // On Desktop, the right side is always the map. The left side switches content.
    // On Mobile, the whole screen switches.

    const isWalkTab = activeTab === Tab.WALK;
    const isSettingsTab = activeTab === Tab.SETTINGS;
    const isListTab = activeTab === Tab.LIST;

    // --- SETTINGS SCREEN ---
    if (isSettingsTab) {
      return (
        <div className="p-6 max-w-2xl mx-auto w-full">
          <h2 className="text-2xl font-semibold mb-6 text-slate-900 dark:text-slate-100">Settings</h2>
          
          <div className="space-y-8">
            <section>
              <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4">Preferences</h3>
              <div className="bg-white dark:bg-slate-800 rounded-2xl overflow-hidden shadow-sm border border-slate-100 dark:border-slate-700">
                 <div className="p-4 flex items-center justify-between border-b border-slate-100 dark:border-slate-700">
                    <div className="flex items-center gap-3">
                      <div className={`p-2 rounded-lg ${isDarkMode ? 'bg-indigo-900/50 text-indigo-400' : 'bg-amber-100 text-amber-600'}`}>
                        {isDarkMode ? <Moon size={20}/> : <Sun size={20}/>}
                      </div>
                      <span className="font-medium text-slate-700 dark:text-slate-200">Dark Mode</span>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input type="checkbox" checked={isDarkMode} onChange={() => setIsDarkMode(!isDarkMode)} className="sr-only peer" />
                      <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer dark:bg-slate-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-slate-900"></div>
                    </label>
                 </div>
                 <div className="p-4 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="p-2 rounded-lg bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400">
                        <Locate size={20}/>
                      </div>
                      <span className="font-medium text-slate-700 dark:text-slate-200">Search Radius</span>
                    </div>
                    <span className="text-slate-500 font-mono text-sm">500m</span>
                 </div>
              </div>
            </section>

            <section>
              <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4">Data & Privacy</h3>
              <div className="bg-white dark:bg-slate-800 rounded-2xl overflow-hidden shadow-sm border border-slate-100 dark:border-slate-700">
                 <div className="p-4 flex items-center justify-between border-b border-slate-100 dark:border-slate-700">
                    <div className="flex items-center gap-3">
                      <div className="p-2 rounded-lg bg-emerald-100 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400">
                        <Database size={20}/>
                      </div>
                      <div className="flex flex-col">
                        <span className="font-medium text-slate-700 dark:text-slate-200">Offline Cache</span>
                        <span className="text-xs text-slate-500">Maps cached for 7 days</span>
                      </div>
                    </div>
                    <button className="text-sm font-medium text-blue-600 dark:text-blue-400">Clear</button>
                 </div>
                 <div className="p-4">
                    <div className="flex items-start gap-3">
                      <div className="p-2 rounded-lg bg-slate-100 dark:bg-slate-700 text-slate-600 dark:text-slate-400 mt-1">
                        <ShieldCheck size={20}/>
                      </div>
                      <div>
                        <span className="font-medium text-slate-700 dark:text-slate-200 block mb-1">Privacy First</span>
                        <p className="text-sm text-slate-500 leading-relaxed">
                          Kasidie does not store your location history. All processing happens on your device or via anonymous requests to OpenStreetMap.
                        </p>
                      </div>
                    </div>
                 </div>
              </div>
            </section>
          </div>
        </div>
      );
    }

    // --- WALK SCREEN (MOBILE) ---
    // On desktop, this info is shown in the side panel while map is on right
    if (isWalkTab && isMobile) {
      return (
        <div className="h-full flex flex-col relative">
           <div className="absolute top-4 left-4 right-4 z-10 bg-white/90 dark:bg-slate-900/90 backdrop-blur-md p-4 rounded-2xl shadow-sm border border-slate-200 dark:border-slate-800">
              <div className="flex justify-between items-end mb-2">
                <div>
                   <span className="text-xs font-bold text-purple-600 uppercase tracking-wider">Curated Loop</span>
                   <h2 className="text-2xl font-semibold text-slate-900 dark:text-slate-100">12 Minute Walk</h2>
                </div>
                <div className="text-right">
                   <div className="text-xl font-mono font-medium text-slate-900 dark:text-slate-100">~900m</div>
                </div>
              </div>
              <div className="flex gap-2 mt-4">
                 <button onClick={generateWalk} className="flex-1 py-2 bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 rounded-xl text-sm font-medium flex items-center justify-center gap-2">
                    <RefreshCw size={14} /> Regenerate
                 </button>
                 <button className="flex-1 py-2 bg-purple-600 text-white rounded-xl text-sm font-medium">Start</button>
              </div>
           </div>
           <MapComponent 
            places={MOCK_PLACES} 
            selectedCategory={null} 
            onPlaceSelect={setSelectedPlace} 
            walkRoute={walkRoute}
            isDarkMode={isDarkMode}
          />
        </div>
      );
    }
    
    // --- LIST SCREEN ---
    if (isListTab) {
       return (
         <div className="h-full overflow-y-auto p-4 space-y-3 bg-kasidie-bg dark:bg-kasidie-bgDark">
            <h2 className="text-2xl font-semibold mb-4 px-2 text-slate-900 dark:text-slate-100">Nearby</h2>
            {MOCK_PLACES.map(place => (
              <div 
                key={place.id} 
                onClick={() => {
                  if (isMobile) {
                    setSelectedPlace(place);
                    // On mobile list view, we usually just open details
                  } else {
                     setSelectedPlace(place);
                  }
                }}
                className="bg-white dark:bg-slate-800 p-4 rounded-2xl border border-slate-100 dark:border-slate-700 flex items-center justify-between active:scale-[0.98] transition-transform cursor-pointer shadow-sm"
              >
                <div className="flex items-center gap-4">
                   <div className="w-12 h-12 rounded-full bg-slate-50 dark:bg-slate-700 flex items-center justify-center text-slate-500 dark:text-slate-400">
                      <CategoryIcon category={place.category} />
                   </div>
                   <div>
                      <h3 className="font-semibold text-slate-900 dark:text-slate-100">{place.name}</h3>
                      <div className="flex items-center gap-2 text-xs text-slate-500 mt-1">
                        <span>{place.category}</span>
                        <span>•</span>
                        <span>{place.distance}m</span>
                      </div>
                   </div>
                </div>
                <ChevronRight className="text-slate-300" size={20} />
              </div>
            ))}
             <div className="h-20" /> {/* Bottom spacer for nav bar */}
         </div>
       );
    }

    // --- MAP SCREEN (DEFAULT) ---
    return (
      <div className="w-full h-full relative">
        {/* Chips */}
        <div className="absolute top-0 left-0 right-0 z-[400] overflow-x-auto no-scrollbar pt-12 pb-4 px-4 flex gap-2 pointer-events-none">
           <div className="pointer-events-auto flex gap-2 mx-auto sm:mx-0">
            <button 
                onClick={() => setSelectedCategory(null)}
                className={`px-4 py-2 rounded-full text-sm font-medium backdrop-blur-md shadow-sm transition-all border ${
                  selectedCategory === null 
                    ? 'bg-slate-900 text-white border-slate-900 dark:bg-slate-100 dark:text-slate-900' 
                    : 'bg-white/90 text-slate-600 border-slate-200 dark:bg-slate-800/90 dark:text-slate-300 dark:border-slate-700'
                }`}
              >
                All
              </button>
              {CATEGORIES.map(cat => (
                <button 
                  key={cat}
                  onClick={() => setSelectedCategory(selectedCategory === cat ? null : cat)}
                  className={`px-4 py-2 rounded-full text-sm font-medium backdrop-blur-md shadow-sm transition-all whitespace-nowrap border ${
                    selectedCategory === cat 
                      ? 'bg-slate-900 text-white border-slate-900 dark:bg-slate-100 dark:text-slate-900' 
                      : 'bg-white/90 text-slate-600 border-slate-200 dark:bg-slate-800/90 dark:text-slate-300 dark:border-slate-700'
                  }`}
                >
                  {cat}
                </button>
              ))}
           </div>
        </div>
        
        {/* Floating Action Button (Mobile Only Map) */}
        {isMobile && activeTab === Tab.MAP && (
          <button 
            onClick={() => handleTabChange(Tab.WALK)}
            className="absolute bottom-6 right-4 z-[400] bg-white dark:bg-slate-800 text-slate-900 dark:text-white px-5 py-3 rounded-full shadow-lg font-medium flex items-center gap-2 border border-slate-100 dark:border-slate-700 active:scale-95 transition-transform"
          >
            <Footprints size={18} className="text-purple-500" />
            12 min walk
          </button>
        )}

        <MapComponent 
          places={MOCK_PLACES} 
          selectedCategory={selectedCategory} 
          onPlaceSelect={setSelectedPlace}
          isDarkMode={isDarkMode}
        />
      </div>
    );
  };

  const MobileLayout = () => (
    <div className="flex flex-col h-screen w-full relative overflow-hidden">
      {/* Content Area */}
      <div className="flex-1 relative overflow-hidden">
        {renderContent()}
      </div>

      {/* Bottom Sheet Detail View */}
      <DetailView place={selectedPlace} onClose={() => setSelectedPlace(null)} isMobile={true} />

      {/* Bottom Navigation */}
      <div className="h-[88px] bg-white dark:bg-kasidie-bgDark border-t border-slate-200 dark:border-slate-800 flex items-start pt-3 justify-around z-50 shrink-0">
        <NavButton icon={<MapIcon />} label="Map" isActive={activeTab === Tab.MAP} onClick={() => handleTabChange(Tab.MAP)} />
        <NavButton icon={<ListIcon />} label="List" isActive={activeTab === Tab.LIST} onClick={() => handleTabChange(Tab.LIST)} />
        <NavButton icon={<Footprints />} label="12 min" isActive={activeTab === Tab.WALK} onClick={() => handleTabChange(Tab.WALK)} />
        <NavButton icon={<Settings />} label="Settings" isActive={activeTab === Tab.SETTINGS} onClick={() => handleTabChange(Tab.SETTINGS)} />
      </div>
    </div>
  );

  const DesktopLayout = () => (
    <div className="flex h-screen w-full bg-kasidie-bg dark:bg-kasidie-bgDark overflow-hidden">
      {/* Navigation Rail */}
      <div className="w-20 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col items-center py-8 gap-8 z-50">
         <div className="w-10 h-10 bg-slate-100 dark:bg-slate-800 rounded-xl mb-4 flex items-center justify-center font-bold text-slate-900 dark:text-white">k.</div>
         <RailButton icon={<MapIcon />} label="Explore" isActive={activeTab === Tab.MAP} onClick={() => handleTabChange(Tab.MAP)} />
         <RailButton icon={<Footprints />} label="12 min" isActive={activeTab === Tab.WALK} onClick={() => handleTabChange(Tab.WALK)} />
         <RailButton icon={<ListIcon />} label="List" isActive={activeTab === Tab.LIST} onClick={() => handleTabChange(Tab.LIST)} />
         <div className="mt-auto">
           <RailButton icon={<Settings />} label="Settings" isActive={activeTab === Tab.SETTINGS} onClick={() => handleTabChange(Tab.SETTINGS)} />
         </div>
      </div>

      {/* Split View */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left Panel: Contextual based on Tab */}
        <div className="w-[400px] border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-kasidie-bgDark flex flex-col relative z-20 shadow-xl">
           
           {/* If Detail View is open, it overrides the list content in the left panel */}
           {selectedPlace ? (
              <DetailView place={selectedPlace} onClose={() => setSelectedPlace(null)} isMobile={false} />
           ) : (
             <div className="flex-1 overflow-hidden flex flex-col">
               {activeTab === Tab.WALK && (
                 <div className="p-6">
                   <h2 className="text-3xl font-bold mb-4 text-slate-900 dark:text-white">12 Minute Walk</h2>
                   <div className="bg-slate-50 dark:bg-slate-800 p-6 rounded-2xl mb-6">
                     <div className="flex justify-between mb-2">
                       <span className="text-slate-500">Distance</span>
                       <span className="font-mono text-slate-900 dark:text-white font-medium">~{walkRoute?.totalDistance || 0}m</span>
                     </div>
                     <div className="flex justify-between">
                       <span className="text-slate-500">Est. Time</span>
                       <span className="font-mono text-slate-900 dark:text-white font-medium">~12 min</span>
                     </div>
                   </div>
                   <button 
                    onClick={generateWalk}
                    className="w-full py-4 bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 rounded-xl font-bold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity">
                     <RefreshCw size={18} /> Regenerate Loop
                   </button>
                   <p className="mt-6 text-sm text-slate-500 leading-relaxed">
                     This feature generates a circular route passing through 3 interesting points near you. Perfect for a quick mental reset.
                   </p>
                 </div>
               )}

               {(activeTab === Tab.MAP || activeTab === Tab.LIST) && (
                 <div className="h-full overflow-y-auto">
                   <div className="p-6 sticky top-0 bg-white/95 dark:bg-kasidie-bgDark/95 backdrop-blur z-10 border-b border-slate-100 dark:border-slate-800">
                     <h2 className="text-3xl font-bold text-slate-900 dark:text-white">Explore</h2>
                     <div className="flex gap-2 mt-4 flex-wrap">
                        <button 
                          onClick={() => setSelectedCategory(null)}
                          className={`px-3 py-1 rounded-full text-xs font-bold transition-colors ${!selectedCategory ? 'bg-slate-900 text-white' : 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400'}`}
                        >
                          ALL
                        </button>
                        {CATEGORIES.map(cat => (
                          <button 
                            key={cat}
                            onClick={() => setSelectedCategory(selectedCategory === cat ? null : cat)}
                            className={`px-3 py-1 rounded-full text-xs font-bold transition-colors ${selectedCategory === cat ? 'bg-slate-900 text-white dark:bg-slate-100 dark:text-slate-900' : 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400'}`}
                          >
                            {cat.toUpperCase()}
                          </button>
                        ))}
                     </div>
                   </div>
                   <div className="p-4 space-y-3">
                     {MOCK_PLACES.filter(p => !selectedCategory || p.category === selectedCategory).map(place => (
                       <div 
                         key={place.id} 
                         onClick={() => setSelectedPlace(place)}
                         className="p-4 rounded-xl border border-slate-200 dark:border-slate-700 hover:border-slate-400 dark:hover:border-slate-500 cursor-pointer transition-colors group"
                       >
                         <div className="flex justify-between items-start">
                           <div>
                             <h4 className="font-semibold text-slate-900 dark:text-slate-100 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors">{place.name}</h4>
                             <p className="text-xs text-slate-500 mt-1">{place.category} • {place.distance}m</p>
                           </div>
                           <div className="w-8 h-8 rounded-full bg-slate-50 dark:bg-slate-800 flex items-center justify-center">
                              <CategoryIcon category={place.category} className="w-4 h-4 text-slate-400" />
                           </div>
                         </div>
                       </div>
                     ))}
                   </div>
                 </div>
               )}

              {activeTab === Tab.SETTINGS && renderContent()}
             </div>
           )}
        </div>

        {/* Right Panel: Map */}
        <div className="flex-1 relative bg-slate-50 dark:bg-slate-950">
           <MapComponent 
              places={MOCK_PLACES} 
              selectedCategory={selectedCategory} 
              onPlaceSelect={setSelectedPlace} 
              walkRoute={walkRoute}
              isDarkMode={isDarkMode}
            />
        </div>
      </div>
    </div>
  );

  return isMobile ? <MobileLayout /> : <DesktopLayout />;
};

// UI Helper Components

const NavButton = ({ icon, label, isActive, onClick }: { icon: React.ReactNode, label: string, isActive: boolean, onClick: () => void }) => (
  <button onClick={onClick} className="flex flex-col items-center gap-1 w-16 group">
    <div className={`transition-colors ${isActive ? 'text-slate-900 dark:text-white' : 'text-slate-400 group-hover:text-slate-600 dark:group-hover:text-slate-300'}`}>
      {React.cloneElement(icon as React.ReactElement, { size: 24, strokeWidth: isActive ? 2.5 : 2 })}
    </div>
    <span className={`text-[10px] font-medium ${isActive ? 'text-slate-900 dark:text-white' : 'text-slate-400'}`}>{label}</span>
  </button>
);

const RailButton = ({ icon, label, isActive, onClick }: { icon: React.ReactNode, label: string, isActive: boolean, onClick: () => void }) => (
  <button 
    onClick={onClick} 
    className={`w-12 h-12 rounded-2xl flex items-center justify-center transition-all duration-300 ${
      isActive 
        ? 'bg-slate-900 text-white dark:bg-slate-100 dark:text-slate-900 shadow-lg' 
        : 'text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
    }`}
    title={label}
  >
    {React.cloneElement(icon as React.ReactElement, { size: 22, strokeWidth: 2 })}
  </button>
);

export default App;