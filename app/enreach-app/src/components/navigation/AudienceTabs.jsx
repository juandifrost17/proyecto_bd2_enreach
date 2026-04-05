import { NavLink } from 'react-router-dom';
import styles from './AudienceTabs.module.css';

const tabs = [
  { label: 'Vista Enreach', to: '/enreach', audience: 'enreach' },
  { label: 'Vista Partner', to: '/partner/1', audience: 'partner' },
  { label: 'Vista Cliente', to: '/cliente/1', audience: 'cliente' },
];

function AudienceTabs({ audience = 'enreach' }) {
  return (
    <nav className={styles.tabs} aria-label="Selección de audiencia">
      {tabs.map((tab) => (
        <NavLink
          key={tab.audience}
          to={tab.to}
          className={({ isActive }) => {
            const active = isActive || audience === tab.audience;
            return `${styles.tab} ${active ? styles.tabActive : ''}`.trim();
          }}
        >
          {tab.label}
        </NavLink>
      ))}
    </nav>
  );
}

export default AudienceTabs;
