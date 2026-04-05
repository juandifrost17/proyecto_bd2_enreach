import { RouterProvider } from 'react-router-dom';
import router from './router';
import { PeriodProvider } from '@/context/PeriodContext';

function App() {
  return (
    <PeriodProvider>
      <RouterProvider router={router} />
    </PeriodProvider>
  );
}

export default App;
