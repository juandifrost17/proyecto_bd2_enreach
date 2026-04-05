import { useMemo } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import TopNav from '@/components/navigation/TopNav';
import Sidebar from '@/components/sidebar/Sidebar';
import styles from './DashboardLayout.module.css';

function getAudienceFromPath(pathname = '/') {
  if (pathname.startsWith('/partner')) return 'partner';
  if (pathname.startsWith('/cliente')) return 'cliente';
  return 'enreach';
}

function DashboardLayout() {
  const location = useLocation();
  const audience = useMemo(() => getAudienceFromPath(location.pathname), [location.pathname]);

  return (
    <div className={styles.shell}>
      <div className={styles.topBar}>
        <TopNav audience={audience} />
      </div>

      <aside className={styles.sidebar}>
        <Sidebar audience={audience} />
      </aside>

      <main className={styles.content}>
        <Outlet context={{ audience }} />
      </main>
    </div>
  );
}

export default DashboardLayout;
