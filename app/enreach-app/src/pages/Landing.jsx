import { Link } from 'react-router-dom';
import {
  ArrowRight,
  Building2,
  ChartNoAxesCombined,
  Layers3,
  ShieldCheck,
} from 'lucide-react';
import styles from './Landing.module.css';

const accessCards = [
  {
    title: 'Vista Enreach',
    summary: 'Consolidado ejecutivo de toda la plataforma.',
    description:
      'Facturación, cobranza, riesgo financiero, calidad de voz, salud de mensajería y tendencia de facturación anual por partner.',
    route: '/enreach',
    meta: '6 KPIs · 9 reportes',
    cta: 'Explorar vista global',
    Icon: Layers3,
  },
  {
    title: 'Vista Partner',
    summary: 'Gestión operativa y comercial del canal.',
    description:
      'Cartera, aging, uso del plan, deterioro de llamadas, crecimiento neto de clientes y vencimientos de contratos del portfolio.',
    route: '/partner/1',
    meta: '6 KPIs · 8 reportes',
    cta: 'Explorar vista partner',
    Icon: ShieldCheck,
  },
  {
    title: 'Vista Cliente',
    summary: 'Control presupuestario y operación del tenant.',
    description:
      'Tendencia de comunicaciones, uso vs capacidad, saturación horaria, embudo de contacto por filial, pagos y calidad operativa.',
    route: '/cliente/1',
    meta: '6 KPIs · 8 reportes',
    cta: 'Explorar vista cliente',
    Icon: Building2,
  },
];

const operationalFacts = [
  { label: 'Audiencias', value: '3', description: 'Enreach, Partner y Cliente' },
  { label: 'Cobertura', value: '25', description: 'Reportes operativos y ejecutivos' },
  { label: 'Periodo', value: 'T/A', description: 'Trimestre y año' },
];

function Landing() {
  return (
    <section className={styles.page}>
      <section className={styles.heroPanel}>
        <div className={styles.heroCopy}>
          <p className={styles.eyebrow}>Access Portal</p>
          <h1 className={styles.title}>Enreach Data Warehouse</h1>
          <p className={styles.description}>
            Dashboards analíticos para operación UCaaS.
          </p>

          <div className={styles.heroMetaRow}>
            <div className={styles.heroBadge}>
              <ChartNoAxesCombined size={16} strokeWidth={1.9} />
              <span>React + Vite</span>
            </div>
            <div className={styles.heroBadge}>
              <ChartNoAxesCombined size={16} strokeWidth={1.9} />
              <span>Java Spring Boot + PostgreSQL</span>
            </div>
          </div>
        </div>

        <aside className={styles.heroAside}>
          <div className={styles.asideHeader}>
            <span className={styles.asideEyebrow}>Estado del portal</span>
            <h2 className={styles.asideTitle}>Listo para navegar por audiencia</h2>
          </div>

          <div className={styles.factGrid}>
            {operationalFacts.map((fact) => (
              <article key={fact.label} className={styles.factCard}>
                <span className={styles.factLabel}>{fact.label}</span>
                <strong className={styles.factValue}>{fact.value}</strong>
                <p className={styles.factDescription}>{fact.description}</p>
              </article>
            ))}
          </div>
        </aside>
      </section>

      <section className={styles.accessSection}>
        <div className={styles.sectionHeading}>
          <p className={styles.sectionEyebrow}>Entradas disponibles</p>
          <h2 className={styles.sectionTitle}>Selecciona el nivel de análisis.</h2>
        </div>

        <div className={styles.cardGrid}>
          {accessCards.map(({ title, summary, description, route, meta, cta, Icon }) => (
            <Link key={title} className={styles.card} to={route}>
              <div className={styles.cardTop}>
                <div className={styles.iconWrap}>
                  <Icon size={22} strokeWidth={1.9} />
                </div>
                <p className={styles.cardMeta}>{meta}</p>
              </div>

              <div className={styles.cardBody}>
                <h3 className={styles.cardTitle}>{title}</h3>
                <p className={styles.cardSummary}>{summary}</p>
                <p className={styles.cardDescription}>{description}</p>
              </div>

              <div className={styles.cardFooter}>
                <span className={styles.cardLink}>
                  {cta}
                  <ArrowRight size={16} strokeWidth={2} />
                </span>
              </div>
            </Link>
          ))}
        </div>
      </section>
    </section>
  );
}

export default Landing;
