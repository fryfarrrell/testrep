import { Place, PlaceCategory } from './types';

// Mocking a central location (e.g., San Francisco near Ferry Building for demo)
export const USER_LOCATION = { lat: 37.7955, lng: -122.3937 };

export const MOCK_PLACES: Place[] = [
  {
    id: '1',
    name: 'Hidden Garden Steps',
    category: PlaceCategory.VIEWPOINT,
    coordinates: { lat: 37.7965, lng: -122.3945 },
    distance: 120,
    walkingTime: 2,
    tags: ['Free', 'Quiet', 'Stairs'],
    description: 'A quiet tiled staircase hidden between residential buildings.',
    isOpen: true
  },
  {
    id: '2',
    name: 'Maritime Museum',
    category: PlaceCategory.MUSEUM,
    coordinates: { lat: 37.7940, lng: -122.3920 },
    distance: 350,
    walkingTime: 5,
    tags: ['History', 'Indoors'],
    isOpen: true
  },
  {
    id: '3',
    name: 'Public Water Fountain',
    category: PlaceCategory.WATER,
    coordinates: { lat: 37.7950, lng: -122.3960 },
    distance: 210,
    walkingTime: 3,
    tags: ['Drinking Water', 'Accessible'],
    isOpen: true
  },
  {
    id: '4',
    name: 'Old Brick Lane Art',
    category: PlaceCategory.ART,
    coordinates: { lat: 37.7970, lng: -122.3910 },
    distance: 450,
    walkingTime: 6,
    tags: ['Street Art', 'Photo Op'],
    isOpen: true
  },
  {
    id: '5',
    name: 'Ferry Plaza Restrooms',
    category: PlaceCategory.TOILET,
    coordinates: { lat: 37.7958, lng: -122.3930 },
    distance: 80,
    walkingTime: 1,
    tags: ['Clean', 'Public'],
    isOpen: true
  },
  {
    id: '6',
    name: 'Embarcadero Bike Rack',
    category: PlaceCategory.BIKE,
    coordinates: { lat: 37.7935, lng: -122.3945 },
    distance: 300,
    walkingTime: 4,
    tags: ['Secure', 'Covered'],
    isOpen: true
  },
  {
    id: '7',
    name: 'Pier 14 Quiet Zone',
    category: PlaceCategory.QUIET_SPOT,
    coordinates: { lat: 37.7920, lng: -122.3900 },
    distance: 600,
    walkingTime: 8,
    tags: ['Ocean View', 'Seating'],
    isOpen: true
  },
];

export const CATEGORIES = Object.values(PlaceCategory);
