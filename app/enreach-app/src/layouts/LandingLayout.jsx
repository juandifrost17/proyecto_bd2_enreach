import { Outlet } from 'react-router-dom';
import BrandHeader from '@/components/navigation/BrandHeader';
import styles from './LandingLayout.module.css';

function LandingLayout() {
  return (
    <div className={styles.shell}>
      <header className={styles.header}>
        <BrandHeader label="Analytics" />
      </header>

      <main className={styles.main}>
        <Outlet />
      </main>
    </div>
  );
}

export default LandingLayout;
