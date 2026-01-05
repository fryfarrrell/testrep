export enum AppView {
  SPLASH = 'SPLASH',
  ONBOARDING = 'ONBOARDING',
  APP = 'APP',
}

export enum Tab {
  MAP = 'Map',
  LIST = 'List',
  WALK = '12 min',
  SETTINGS = 'Settings',
}

export enum PlaceCategory {
  MUSEUM = 'Museums',
  ART = 'Art',
  VIEWPOINT = 'Viewpoints',
  WATER = 'Water',
  TOILET = 'Toilets',
  BIKE = 'Bike parking',
  QUIET_SPOT = 'Quiet Spot'
}

export interface Coordinates {
  lat: number;
  lng: number;
}

export interface Place {
  id: string;
  name: string;
  category: PlaceCategory;
  coordinates: Coordinates;
  distance: number; // in meters (mocked relative to user)
  walkingTime: number; // in minutes
  tags: string[];
  description?: string;
  isOpen?: boolean;
}

export interface WalkRoute {
  id: string;
  points: Place[];
  totalDistance: number;
  totalTime: number;
}