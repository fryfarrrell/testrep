import React from 'react';
import { 
  Map, 
  List, 
  Footprints, 
  Settings, 
  Navigation, 
  Droplets, 
  Landmark, 
  Palette, 
  Mountain, 
  Bike, 
  Armchair, 
  X,
  ChevronRight,
  Locate,
  Moon,
  Sun,
  Database,
  ShieldCheck,
  RefreshCw,
  Search
} from 'lucide-react';
import { PlaceCategory } from '../types';

export const CategoryIcon = ({ category, className = "w-5 h-5" }: { category: PlaceCategory, className?: string }) => {
  switch (category) {
    case PlaceCategory.MUSEUM: return <Landmark className={className} />;
    case PlaceCategory.ART: return <Palette className={className} />;
    case PlaceCategory.VIEWPOINT: return <Mountain className={className} />;
    case PlaceCategory.WATER: return <Droplets className={className} />;
    case PlaceCategory.TOILET: return <div className={`${className} border-2 border-current rounded-full flex items-center justify-center text-[10px] font-bold`}>WC</div>;
    case PlaceCategory.BIKE: return <Bike className={className} />;
    case PlaceCategory.QUIET_SPOT: return <Armchair className={className} />;
    default: return <Map className={className} />;
  }
};

export { 
  Map, 
  List, 
  Footprints, 
  Settings, 
  Navigation, 
  X, 
  ChevronRight, 
  Locate,
  Moon,
  Sun,
  Database,
  ShieldCheck,
  RefreshCw,
  Search
};