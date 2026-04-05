import styles from './UserProfile.module.css';

function getInitials(name = '') {
  return String(name)
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join('')
    .toUpperCase();
}

function UserProfile({ name = 'Admin', role = 'Global Admin' }) {
  return (
    <div className={styles.profile} aria-label="Perfil de usuario">
      <span className={styles.avatar}>{getInitials(name)}</span>
      <span className={styles.meta}>
        <span className={styles.name}>{name}</span>
        <span className={styles.role}>{role}</span>
      </span>
    </div>
  );
}

export default UserProfile;
