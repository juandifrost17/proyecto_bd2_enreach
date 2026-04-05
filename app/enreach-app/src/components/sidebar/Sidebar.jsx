import { NavLink } from 'react-router-dom';
import { Layers3, ShieldCheck, Building2 } from 'lucide-react';
import styles from './Sidebar.module.css';

const NAV_ITEMS = [
  { label: 'Vista Enreach', to: '/enreach', audience: 'enreach', Icon: Layers3 },
  { label: 'Vista Partner', to: '/partner/1', audience: 'partner', Icon: ShieldCheck },
  { label: 'Vista Cliente', to: '/cliente/1', audience: 'cliente', Icon: Building2 },
];

function Sidebar({ audience = 'enreach' }) {
  return (
    <aside className={styles.sidebar}>
      <section className={styles.section}>
        <p className={styles.eyebrow}>Navegación</p>
        <nav className={styles.navGroup}>
          {NAV_ITEMS.map((item) => {
            const active = audience === item.audience;
            return (
              <NavLink
                key={item.audience}
                to={item.to}
                className={`${styles.navItem} ${active ? styles.navItemActive : ''}`.trim()}
              >
                <item.Icon size={16} strokeWidth={1.9} />
                <span>{item.label}</span>
              </NavLink>
            );
          })}
        </nav>
      </section>
    </aside>
  );
}

export default Sidebar;
