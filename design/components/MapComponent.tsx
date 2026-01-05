import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, useMap, Polyline } from 'react-leaflet';
import L from 'leaflet';
import { Place, PlaceCategory, WalkRoute } from '../types';
import { USER_LOCATION } from '../constants';

// Fix for default Leaflet markers in React
const createCustomIcon = (color: string) => L.divIcon({
  className: 'custom-div-icon',
  html: `<div style="background-color: ${color}; width: 16px; height: 16px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.2);"></div>`,
  iconSize: [16, 16],
  iconAnchor: [8, 8]
});

const userIcon = L.divIcon({
  className: 'user-location-pulse',
  html: `<div style="background-color: #3B82F6; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 0 10px rgba(59, 130, 246, 0.2);"></div>`,
  iconSize: [16, 16],
  iconAnchor: [8, 8]
});

interface MapProps {
  places: Place[];
  selectedCategory: PlaceCategory | null;
  onPlaceSelect: (place: Place) => void;
  walkRoute?: WalkRoute | null;
  isDarkMode: boolean;
}

const MapUpdater = ({ center }: { center: { lat: number, lng: number } }) => {
  const map = useMap();
  useEffect(() => {
    map.flyTo([center.lat, center.lng], 15, { duration: 1.5 });
  }, [center, map]);
  return null;
};

const MapComponent: React.FC<MapProps> = ({ places, selectedCategory, onPlaceSelect, walkRoute, isDarkMode }) => {
  const [center] = useState(USER_LOCATION);

  const filteredPlaces = selectedCategory
    ? places.filter(p => p.category === selectedCategory)
    : places;

  const tileLayerUrl = isDarkMode 
    ? 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png'
    : 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png';

  const attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>';

  return (
    <div className="w-full h-full relative z-0">
      <MapContainer 
        center={[center.lat, center.lng]} 
        zoom={16} 
        zoomControl={false}
        className="w-full h-full"
      >
        <TileLayer
          attribution={attribution}
          url={tileLayerUrl}
        />
        
        {/* User Location */}
        <Marker position={[USER_LOCATION.lat, USER_LOCATION.lng]} icon={userIcon} />

        {/* Places */}
        {!walkRoute && filteredPlaces.map(place => (
          <Marker 
            key={place.id}
            position={[place.coordinates.lat, place.coordinates.lng]}
            icon={createCustomIcon(isDarkMode ? '#94A3B8' : '#475569')}
            eventHandlers={{
              click: () => onPlaceSelect(place),
            }}
          />
        ))}

        {/* Walk Route Specifics */}
        {walkRoute && (
          <>
            <Polyline 
              positions={[
                [USER_LOCATION.lat, USER_LOCATION.lng],
                ...walkRoute.points.map(p => [p.coordinates.lat, p.coordinates.lng] as [number, number]),
                [USER_LOCATION.lat, USER_LOCATION.lng]
              ]}
              pathOptions={{ color: isDarkMode ? '#5EEAD4' : '#0F766E', weight: 4, dashArray: '10, 10', opacity: 0.7 }}
            />
            {walkRoute.points.map((place, index) => (
               <Marker 
               key={place.id}
               position={[place.coordinates.lat, place.coordinates.lng]}
               icon={L.divIcon({
                 className: 'route-marker',
                 html: `<div style="background-color: ${isDarkMode ? '#5EEAD4' : '#0F766E'}; color: ${isDarkMode ? '#000' : '#FFF'}; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 12px; border: 2px solid white;">${index + 1}</div>`,
                 iconSize: [24, 24],
                 iconAnchor: [12, 12]
               })}
               eventHandlers={{
                click: () => onPlaceSelect(place),
              }}
             />
            ))}
          </>
        )}

        <MapUpdater center={USER_LOCATION} />
      </MapContainer>
    </div>
  );
};

export default MapComponent;
