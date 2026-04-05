import { createBrowserRouter } from 'react-router-dom';
import DashboardLayout from '@/layouts/DashboardLayout';
import LandingLayout from '@/layouts/LandingLayout';
import ClienteDashboard from '@/pages/ClienteDashboard';
import EnreachDashboard from '@/pages/EnreachDashboard';
import Landing from '@/pages/Landing';
import PartnerDashboard from '@/pages/PartnerDashboard';

const router = createBrowserRouter([
  {
    path: '/',
    element: <LandingLayout />,
    children: [{ index: true, element: <Landing /> }],
  },
  {
    element: <DashboardLayout />,
    children: [
      { path: '/enreach', element: <EnreachDashboard /> },
      { path: '/partner/:id', element: <PartnerDashboard /> },
      { path: '/cliente/:id', element: <ClienteDashboard /> },
    ],
  },
]);

export default router;
