import { useCallback, useMemo } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import BrandHeader from './BrandHeader';
import EntityDropdown from './EntityDropdown';
import UserProfile from './UserProfile';
import useEntityName from '@/hooks/useEntityName';
import styles from './TopNav.module.css';

// Parse entity id from pathname (e.g. /partner/3 → 3)
function parseEntityId(pathname) {
  const m = pathname.match(/\/(partner|cliente)\/(\d+)/);
  return m ? m[2] : null;
}

function TopNav({ audience = 'enreach' }) {
  const location = useLocation();

  // Resolve current entity id from the URL
  const entityId = useMemo(() => parseEntityId(location.pathname), [location.pathname]);

  // Fetch real entity name — no fallback with "#" placeholder
  const { name: entityName } = useEntityName(
    audience,
    entityId,
    audience === 'partner' ? 'Partner' : 'Cliente',
  );

  return (
    <header className={styles.topNav}>
      <Link to="/" style={{ textDecoration: 'none' }}>
        <BrandHeader compact />
      </Link>

      <div className={styles.rightRail}>
        {audience !== 'enreach' && entityId && (
          <EntityDropdown
            audience={audience}
            currentName={entityName}
            currentId={entityId}
          />
        )}
        <UserProfile />
      </div>
    </header>
  );
}

export default TopNav;
