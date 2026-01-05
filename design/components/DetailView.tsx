import React from 'react';
import { Place } from '../types';
import { CategoryIcon, X, Navigation } from './Icon';

interface DetailViewProps {
  place: Place | null;
  onClose: () => void;
  isMobile: boolean;
}

const DetailView: React.FC<DetailViewProps> = ({ place, onClose, isMobile }) => {
  if (!place) return null;

  const handleOpenMaps = () => {
    // Opens Apple Maps or Google Maps based on device (simplified link)
    window.open(`https://maps.apple.com/?q=${place.coordinates.lat},${place.coordinates.lng}`, '_blank');
  };

  const Content = () => (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="flex justify-between items-start mb-4">
        <div>
          <div className="flex items-center gap-2 text-slate-500 dark:text-slate-400 mb-1">
            <CategoryIcon category={place.category} className="w-4 h-4" />
            <span className="text-xs uppercase tracking-wider font-medium">{place.category}</span>
          </div>
          <h2 className="text-2xl font-semibold text-slate-900 dark:text-slate-100">{place.name}</h2>
        </div>
        <button onClick={onClose} className="p-2 bg-slate-100 dark:bg-slate-800 rounded-full hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors">
          <X className="w-5 h-5 text-slate-600 dark:text-slate-300" />
        </button>
      </div>

      {/* Meta Info */}
      <div className="flex items-center gap-4 mb-6 text-sm text-slate-600 dark:text-slate-400">
        <span>{place.distance}m away</span>
        <span className="w-1 h-1 rounded-full bg-slate-300 dark:bg-slate-600"></span>
        <span>~{place.walkingTime} min walk</span>
      </div>

      {/* Description if any */}
      {place.description && (
        <p className="text-slate-700 dark:text-slate-300 mb-6 leading-relaxed">
          {place.description}
        </p>
      )}

      {/* Tags */}
      <div className="flex flex-wrap gap-2 mb-8">
        {place.tags.map(tag => (
          <span key={tag} className="px-3 py-1 bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 rounded-full text-xs font-medium">
            {tag}
          </span>
        ))}
        {place.isOpen && (
           <span className="px-3 py-1 bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400 rounded-full text-xs font-medium">
           Open Now
         </span>
        )}
      </div>

      {/* Actions */}
      <div className="mt-auto grid grid-cols-1 gap-3">
        <button 
          onClick={handleOpenMaps}
          className="w-full py-3.5 bg-slate-900 dark:bg-slate-100 text-white dark:text-slate-900 rounded-2xl font-semibold flex items-center justify-center gap-2 active:scale-95 transition-transform"
        >
          <Navigation className="w-4 h-4" />
          Open in Apple Maps
        </button>
        {/* <button className="w-full py-3.5 bg-slate-100 dark:bg-slate-800 text-slate-900 dark:text-slate-200 rounded-2xl font-semibold active:scale-95 transition-transform">
          Add to Route
        </button> */}
      </div>
    </div>
  );

  if (isMobile) {
    return (
      <div className="fixed inset-0 z-50 flex items-end justify-center pointer-events-none">
        <div 
          className="absolute inset-0 bg-black/20 backdrop-blur-sm transition-opacity" 
          onClick={onClose}
          style={{ pointerEvents: 'auto' }}
        />
        <div className="bg-white dark:bg-kasidie-bgDark w-full max-w-lg rounded-t-[32px] p-6 shadow-2xl pointer-events-auto animate-slide-up border-t border-slate-100 dark:border-slate-800">
          <div className="w-12 h-1.5 bg-slate-200 dark:bg-slate-700 rounded-full mx-auto mb-6 opacity-50" />
          <Content />
          <div className="h-6" /> {/* Safe area spacer */}
        </div>
      </div>
    );
  }

  return (
    <div className="h-full p-6 bg-white dark:bg-kasidie-bgDark border-l border-slate-200 dark:border-slate-800 overflow-y-auto">
      <Content />
    </div>
  );
};

export default DetailView;