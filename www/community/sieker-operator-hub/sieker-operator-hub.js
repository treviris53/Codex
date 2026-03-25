export const HOME_STATUS_ENTITIES = [
  "input_boolean.anwesend",
  "sensor.heizung_sollprofil",
  "sensor.rollladen_open_ts",
  "sensor.rollladen_close_ts",
  "sensor.saros_20_set_status",
  "sensor.hamburg_fu_wetterzustand",
  "sensor.eaton_3s850d_batterie_ladung",
];

export const ROOMS_CONFIG = {
  hidden_areas: [],
  area_order: [],
  allowed_domains: ["light", "climate", "cover", "binary_sensor", "sensor"],
  max_entities_per_room: 4,
};

export const MODULES = [
  {
    id: "heating",
    title: "Heizung",
    icon: "mdi:radiator",
    description:
      "Erste echte MVP-Vertikale mit kuratierten Safe-Aktionen, Diagnose und Tuning.",
    summary_entities: [
      "sensor.heizung_sollprofil",
      "input_select.heizung_aktives_profil",
      "input_boolean.heizung_override",
      "input_datetime.heizung_last_applied",
    ],
    status_entities: [
      "input_boolean.heizung_automatik",
      "input_boolean.heizung_urlaub",
      "binary_sensor.anwesend_stabil",
      "binary_sensor.winterbetrieb_empfohlen",
      "sensor.hamburg_fu_temp_next12h_max",
    ],
    safe_actions: [
      {
        label: "Sollprofil anwenden",
        service: "script.heizung_profil_anwenden_pkg",
        style: "primary",
      },
    ],
    diagnostic_entities: [
      {
        entity: "sensor.heizung_sollprofil",
        attributes: [
          "grund",
          "decision_chain",
          "automatik_enabled",
          "last_profile",
          "last_applied_local",
          "last_scene",
          "last_action_text",
        ],
      },
      {
        entity: "input_text.heizung_last_action",
      },
      {
        entity: "input_text.heizung_last_scene",
      },
    ],
    tuning_entities: [
      "input_number.heizung_abwesenheit_stunden",
      "input_number.heizung_temperatur_sommer",
      "input_boolean.heizung_debug",
    ],
    service_entities: [
      "timer.heizung_override",
      "input_boolean.heizung_override",
    ],
    legacy_note:
      "Das bestehende Hub-Fachmodul in dashboards/sieker_hub.yaml bleibt bis zur spaeteren Migration der Referenzpfad.",
  },
  {
    id: "shutters",
    title: "Rolllaeden",
    icon: "mdi:window-shutter",
    description:
      "Kuratiertes Fachmodul mit Fokus auf Automatikstatus, Debug-Sensoren und Apply-Skripte.",
    summary_entities: [
      "input_boolean.rollladen_automation_enabled",
      "sensor.rollladen_open_ts",
      "sensor.rollladen_close_ts",
    ],
    status_entities: [
      "binary_sensor.rollladen_day_window",
      "input_boolean.rollladen_override_ost",
      "input_boolean.rollladen_override_west",
      "input_boolean.beschattung_ost",
      "input_boolean.beschattung_west",
    ],
    safe_actions: [
      {
        label: "Ost anwenden",
        service: "script.rollladen_ost_apply",
      },
      {
        label: "West anwenden",
        service: "script.rollladen_apply_west",
      },
      {
        label: "Nord anwenden",
        service: "script.rollladen_apply_nord",
      },
    ],
    diagnostic_entities: [
      { entity: "sensor.rollladen_ost_debug" },
      { entity: "sensor.rollladen_west_debug" },
      { entity: "sensor.rollladen_nord_debug" },
    ],
    tuning_entities: [
      "input_number.rollladen_offset_morgen_min",
      "input_number.rollladen_offset_abend_min",
      "input_datetime.rollladen_latest_close",
    ],
    legacy_note:
      "Beschattung, Diagnose und Service bleiben vorerst im bestehenden YAML-Fachmodul.",
  },
  {
    id: "roborock",
    title: "Roborock",
    icon: "mdi:robot-vacuum",
    description:
      "MVP-Bridge auf sichere Programmstarts und Diagnose. Karte, Wartung und Wochenplan bleiben noch im YAML-Dashboard.",
    summary_entities: [
      "sensor.saros_20_set_status",
      "binary_sensor.roborock_program_ready",
      "binary_sensor.roborock_program_blocked",
      "input_boolean.roborock_busy",
    ],
    status_entities: [
      "sensor.saros_20_set_batterie",
      "sensor.saros_20_set_staubsauger_fehler",
      "input_text.roborock_current_program",
      "input_text.roborock_last_error",
    ],
    safe_actions: [
      {
        label: "Schlaf saugen",
        service: "script.roborock_run_named_program",
        data: { program_id: "schlaf_saug" },
        style: "primary",
      },
      {
        label: "Flur vac+mop",
        service: "script.roborock_run_named_program",
        data: { program_id: "flur_vac_mop" },
      },
      {
        label: "Wohn saugen",
        service: "script.roborock_run_named_program",
        data: { program_id: "wohn_saug" },
      },
    ],
    diagnostic_entities: [
      { entity: "input_datetime.roborock_busy_since" },
      { entity: "input_text.roborock_last_slot" },
      { entity: "input_text.roborock_last_job" },
      { entity: "input_text.roborock_last_program_sequence" },
    ],
    service_entities: ["input_boolean.roborock_schedule_enabled"],
    legacy_note:
      "Map-Card, Wartung und Wochenplan bleiben bis Phase 2 im bestehenden Roborock-Dashboard.",
  },
  {
    id: "weather",
    title: "Wetter",
    icon: "mdi:weather-partly-cloudy",
    description:
      "Verdichtete Lagekarte. Radar, DWD-Details und Spezialvisualisierungen bleiben vorerst im YAML-Dashboard.",
    summary_entities: [
      "sensor.hamburg_fu_temperatur",
      "sensor.hamburg_fu_wetterzustand",
      "sensor.hamburg_fu_precip_probability_next1h",
      "sensor.hamburg_fu_windgeschwindigkeit",
    ],
    status_entities: [
      "sensor.hamburg_fu_windboen",
      "sensor.hamburg_fu_sichtweite",
      "sensor.hamburg_fu_sonneneinstrahlung",
      "sensor.hamburg_fu_vorhersagezeit_local",
    ],
    safe_actions: [],
    diagnostic_entities: [
      { entity: "weather.hamburg_fu" },
      { entity: "sensor.hamburg_fu_precip_sum_24h" },
      { entity: "sensor.hamburg_fu_temp_next12h_max" },
      { entity: "sensor.hamburg_fu_temp_next12h_min" },
    ],
    legacy_note:
      "Radar, Weather Chart Card und Horizon Card bleiben zunaechst im bestehenden Wetter-Dashboard.",
  },
];

export function getModuleById(moduleId) {
  return MODULES.find((moduleConfig) => moduleConfig.id === moduleId) || MODULES[0];
}

const CARD_VERSION = "0.1.0";
const DOMAIN_PRIORITY = ["light", "climate", "cover", "binary_sensor", "sensor"];
const AREA_REGISTRY_WS_TYPE = "config/area_registry/list";
const DEVICE_REGISTRY_WS_TYPE = "config/device_registry/list";
const ENTITY_REGISTRY_WS_TYPE = "config/entity_registry/list";

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function friendlyNameForState(stateObj, entityId) {
  if (stateObj?.attributes?.friendly_name) {
    return stateObj.attributes.friendly_name;
  }

  return entityId.split(".").slice(1).join(".").replaceAll("_", " ");
}

function iconForState(stateObj) {
  return stateObj?.attributes?.icon || "mdi:checkbox-blank-circle-outline";
}

function formatTimestamp(rawValue) {
  if (!rawValue || rawValue === "unknown" || rawValue === "unavailable") {
    return rawValue;
  }

  const dateValue = new Date(rawValue);
  if (Number.isNaN(dateValue.getTime())) {
    return rawValue;
  }

  return dateValue.toLocaleString("de-DE", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatStateValue(entityId, stateObj) {
  if (!stateObj) {
    return "nicht verfuegbar";
  }

  if (entityId.startsWith("input_datetime.") || entityId.endsWith("_local")) {
    return formatTimestamp(stateObj.state);
  }

  const unit = stateObj.attributes?.unit_of_measurement;
  if (unit) {
    return `${stateObj.state} ${unit}`;
  }

  return stateObj.state;
}

function severityForState(entityId, stateObj) {
  if (!stateObj) {
    return "muted";
  }

  const state = stateObj.state;
  const warningStates = new Set(["on", "open", "opening", "unlocked", "problem", "error", "unavailable"]);

  if (
    entityId.includes("override") ||
    entityId.includes("blocked") ||
    entityId.includes("busy") ||
    entityId.includes("error") ||
    entityId.includes("fehler")
  ) {
    return warningStates.has(state) ? "warn" : "ok";
  }

  if (entityId.includes("batterie_ladung")) {
    const numericValue = Number.parseFloat(state);
    if (Number.isFinite(numericValue) && numericValue < 30) {
      return "warn";
    }
  }

  if (entityId.includes("precip_probability") || entityId.includes("windboen")) {
    const numericValue = Number.parseFloat(state);
    if (Number.isFinite(numericValue) && numericValue >= 70) {
      return "warn";
    }
  }

  if (state === "unknown" || state === "unavailable") {
    return "warn";
  }

  return "ok";
}

function normalizeRegistryMap(items, idKey) {
  return Object.fromEntries(
    (items || [])
      .filter((item) => item?.[idKey])
      .map((item) => [item[idKey], item]),
  );
}

function getAreaEntityIds(registries, areaId) {
  const entityRegistry = Object.values(registries?.entities || {});
  const deviceRegistry = registries?.devices || {};
  const entityIds = [];

  for (const entity of entityRegistry) {
    if (!entity?.entity_id) {
      continue;
    }

    if (entity.hidden_by || entity.disabled_by) {
      continue;
    }

    if (entity.entity_category === "config" || entity.entity_category === "diagnostic") {
      continue;
    }

    const domain = entity.entity_id.split(".")[0];
    if (!ROOMS_CONFIG.allowed_domains.includes(domain)) {
      continue;
    }

    const isDirectAreaMatch = entity.area_id === areaId;
    const isDeviceAreaMatch =
      entity.device_id &&
      deviceRegistry[entity.device_id] &&
      deviceRegistry[entity.device_id].area_id === areaId;

    if (isDirectAreaMatch || isDeviceAreaMatch) {
      entityIds.push(entity.entity_id);
    }
  }

  return entityIds.sort((left, right) => {
    const leftDomain = left.split(".")[0];
    const rightDomain = right.split(".")[0];
    const leftPriority = DOMAIN_PRIORITY.indexOf(leftDomain);
    const rightPriority = DOMAIN_PRIORITY.indexOf(rightDomain);

    if (leftPriority !== rightPriority) {
      return leftPriority - rightPriority;
    }

    return left.localeCompare(right, "de");
  });
}

function selectRoomCards(registries) {
  const areas = Object.values(registries?.areas || {});
  if (!areas.length) {
    return [];
  }

  const hiddenAreas = new Set(ROOMS_CONFIG.hidden_areas || []);
  const orderMap = new Map((ROOMS_CONFIG.area_order || []).map((areaId, index) => [areaId, index]));

  return areas
    .filter((area) => !hiddenAreas.has(area.area_id))
    .sort((left, right) => {
      const leftOrder = orderMap.has(left.area_id) ? orderMap.get(left.area_id) : 999;
      const rightOrder = orderMap.has(right.area_id) ? orderMap.get(right.area_id) : 999;

      if (leftOrder !== rightOrder) {
        return leftOrder - rightOrder;
      }

      return left.name.localeCompare(right.name, "de");
    })
    .map((area) => {
      const entityIds = getAreaEntityIds(registries, area.area_id);
      return {
        area,
        entityIds: entityIds.slice(0, ROOMS_CONFIG.max_entities_per_room),
        entityCount: entityIds.length,
      };
    });
}

function renderEntityItem(hass, entityId) {
  const stateObj = hass.states[entityId];
  const severity = severityForState(entityId, stateObj);

  return `
    <div class="entity-row severity-${severity}">
      <div class="entity-meta">
        <span class="entity-name">${escapeHtml(friendlyNameForState(stateObj, entityId))}</span>
        <span class="entity-id">${escapeHtml(entityId)}</span>
      </div>
      <div class="entity-state">${escapeHtml(formatStateValue(entityId, stateObj))}</div>
    </div>
  `;
}

function renderDiagnosticEntry(hass, entry) {
  const stateObj = hass.states[entry.entity];
  const attributes = entry.attributes || [];
  const rows = [`<div class="diagnostic-head">${renderEntityItem(hass, entry.entity)}</div>`];

  for (const attributeName of attributes) {
    const attributeValue = stateObj?.attributes?.[attributeName];
    rows.push(`
      <div class="attribute-row">
        <span>${escapeHtml(attributeName)}</span>
        <span>${escapeHtml(attributeValue ?? "—")}</span>
      </div>
    `);
  }

  return `<div class="diagnostic-card">${rows.join("")}</div>`;
}

class SiekerOperatorHub extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: "open" });
    this._config = {};
    this._hass = null;
    this._page = "home";
    this._moduleId = "heating";
    this._registries = { areas: {}, devices: {}, entities: {} };
    this._registryLoaded = false;
    this._registryLoading = false;
    this._registryError = "";
  }

  setConfig(config) {
    this._config = config || {};
    this._page = this._config.default_page || "home";
    this._render();
  }

  set hass(hass) {
    this._hass = hass;
    this._ensureRegistriesLoaded();
    this._render();
  }

  getCardSize() {
    return 8;
  }

  static getStubConfig() {
    return {
      type: "custom:sieker-operator-hub",
    };
  }

  _setPage(nextPage, moduleId = this._moduleId) {
    this._page = nextPage;
    this._moduleId = moduleId;
    this._render();
  }

  async _runService(service, data) {
    if (!this._hass || !service) {
      return;
    }

    const [domain, action] = service.split(".");
    if (!domain || !action) {
      return;
    }

    await this._hass.callService(domain, action, data || {});
  }

  async _ensureRegistriesLoaded() {
    if (!this._hass?.callWS || this._registryLoaded || this._registryLoading) {
      return;
    }

    this._registryLoading = true;
    this._registryError = "";
    this._render();

    try {
      const [areas, devices, entities] = await Promise.all([
        this._hass.callWS({ type: AREA_REGISTRY_WS_TYPE }),
        this._hass.callWS({ type: DEVICE_REGISTRY_WS_TYPE }),
        this._hass.callWS({ type: ENTITY_REGISTRY_WS_TYPE }),
      ]);

      this._registries = {
        areas: normalizeRegistryMap(areas, "area_id"),
        devices: normalizeRegistryMap(devices, "id"),
        entities: normalizeRegistryMap(entities, "entity_id"),
      };
      this._registryLoaded = true;
    } catch (error) {
      console.error("Sieker Operator Hub: Registry-Daten konnten nicht geladen werden.", error);
      this._registryError = error?.message || "Registry-Daten konnten nicht geladen werden.";
    } finally {
      this._registryLoading = false;
      this._render();
    }
  }

  _bindEvents() {
    this.shadowRoot.querySelectorAll("[data-page]").forEach((button) => {
      button.addEventListener("click", () => {
        const nextPage = button.getAttribute("data-page");
        const moduleId = button.getAttribute("data-module") || this._moduleId;
        this._setPage(nextPage, moduleId);
      });
    });

    this.shadowRoot.querySelectorAll("[data-service]").forEach((button) => {
      button.addEventListener("click", async () => {
        const service = button.getAttribute("data-service");
        const rawData = button.getAttribute("data-service-data");
        const payload = rawData ? JSON.parse(rawData) : {};
        await this._runService(service, payload);
      });
    });
  }

  _renderHome() {
    const statusCards = HOME_STATUS_ENTITIES.map((entityId) => {
      const stateObj = this._hass.states[entityId];
      const severity = severityForState(entityId, stateObj);

      return `
        <div class="status-card severity-${severity}">
          <div class="status-card-head">
            <span class="status-icon">${escapeHtml(iconForState(stateObj))}</span>
            <span class="status-title">${escapeHtml(friendlyNameForState(stateObj, entityId))}</span>
          </div>
          <div class="status-value">${escapeHtml(formatStateValue(entityId, stateObj))}</div>
          <div class="status-id">${escapeHtml(entityId)}</div>
        </div>
      `;
    }).join("");

    const moduleTiles = MODULES.map((moduleConfig) => `
      <button class="nav-tile" data-page="module" data-module="${escapeHtml(moduleConfig.id)}">
        <span class="nav-icon">${escapeHtml(moduleConfig.icon)}</span>
        <span class="nav-title">${escapeHtml(moduleConfig.title)}</span>
        <span class="nav-desc">${escapeHtml(moduleConfig.description)}</span>
      </button>
    `).join("");

    return `
      <section class="page-section">
        <div class="section-head">
          <h2>Lagebild</h2>
          <p>Kompakter Einstieg fuer Bedienung, Status und den Weg in die Fachmodule.</p>
        </div>
        <div class="status-grid">${statusCards}</div>
      </section>
      <section class="page-section">
        <div class="section-head">
          <h2>Fachmodule</h2>
          <p>Fachliche Bedienung bleibt kuratiert und script-zentriert.</p>
        </div>
        <div class="nav-grid">${moduleTiles}</div>
      </section>
    `;
  }

  _renderRooms() {
    if (this._registryLoading) {
      return `
        <section class="page-section">
          <div class="section-head">
            <h2>Raeume</h2>
            <p>Area-, Device- und Entity-Registry werden gerade geladen.</p>
          </div>
        </section>
      `;
    }

    if (this._registryError) {
      return `
        <section class="page-section">
          <div class="section-head">
            <h2>Raeume</h2>
            <p>Registry-Daten konnten nicht geladen werden: ${escapeHtml(this._registryError)}</p>
          </div>
        </section>
      `;
    }

    const roomCards = selectRoomCards(this._registries);

    if (!roomCards.length) {
      return `
        <section class="page-section">
          <div class="section-head">
            <h2>Raeume</h2>
            <p>Keine Registry-Daten fuer Areas verfuegbar. Der Raum-View bleibt damit bewusst defensiv.</p>
          </div>
        </section>
      `;
    }

    return `
      <section class="page-section">
        <div class="section-head">
          <h2>Raeume</h2>
          <p>Generischer Raumzugriff fuer Alltag und Orientierung. Tiefe Fachlogik bleibt in den Modulen.</p>
        </div>
        <div class="room-grid">
          ${roomCards
            .map(
              ({ area, entityIds, entityCount }) => `
                <div class="room-card">
                  <div class="room-head">
                    <h3>${escapeHtml(area.name)}</h3>
                    <span>${escapeHtml(String(entityCount))} Entitaeten</span>
                  </div>
                  <div class="entity-list">
                    ${entityIds.length
                      ? entityIds.map((entityId) => renderEntityItem(this._hass, entityId)).join("")
                      : `<div class="empty-note">Keine kuratierten Entitaeten im MVP sichtbar.</div>`}
                  </div>
                </div>
              `,
            )
            .join("")}
        </div>
      </section>
    `;
  }

  _renderModule() {
    const moduleConfig = getModuleById(this._moduleId);
    const summaryMarkup = moduleConfig.summary_entities.map((entityId) => renderEntityItem(this._hass, entityId)).join("");
    const statusMarkup = moduleConfig.status_entities.map((entityId) => renderEntityItem(this._hass, entityId)).join("");
    const actionMarkup = moduleConfig.safe_actions.length
      ? moduleConfig.safe_actions
          .map(
            (action) => `
              <button
                class="action-button action-${escapeHtml(action.style || "secondary")}" 
                data-service="${escapeHtml(action.service)}"
                data-service-data='${escapeHtml(JSON.stringify(action.data || {}))}'
              >
                ${escapeHtml(action.label)}
              </button>
            `,
          )
          .join("")
      : `<div class="empty-note">Im MVP sind hier noch keine direkten Safe-Aktionen hinterlegt.</div>`;

    const diagnosticMarkup = moduleConfig.diagnostic_entities.length
      ? moduleConfig.diagnostic_entities.map((entry) => renderDiagnosticEntry(this._hass, entry)).join("")
      : `<div class="empty-note">Keine Diagnoseeintraege konfiguriert.</div>`;

    const tuningMarkup = (moduleConfig.tuning_entities || []).length
      ? (moduleConfig.tuning_entities || []).map((entityId) => renderEntityItem(this._hass, entityId)).join("")
      : `<div class="empty-note">Tuning bleibt in diesem MVP schlank.</div>`;

    const serviceMarkup = (moduleConfig.service_entities || []).length
      ? (moduleConfig.service_entities || []).map((entityId) => renderEntityItem(this._hass, entityId)).join("")
      : `<div class="empty-note">Keine separaten Service-Entitaeten konfiguriert.</div>`;

    return `
      <section class="page-section">
        <div class="section-head">
          <h2>${escapeHtml(moduleConfig.title)}</h2>
          <p>${escapeHtml(moduleConfig.description)}</p>
        </div>
        <div class="module-layout">
          <div class="module-column">
            <div class="panel">
              <h3>Zusammenfassung</h3>
              <div class="entity-list">${summaryMarkup}</div>
            </div>
            <div class="panel">
              <h3>Status</h3>
              <div class="entity-list">${statusMarkup}</div>
            </div>
            <div class="panel">
              <h3>Aktionen</h3>
              <div class="action-grid">${actionMarkup}</div>
            </div>
          </div>
          <div class="module-column">
            <div class="panel">
              <h3>Diagnose</h3>
              <div class="diagnostic-list">${diagnosticMarkup}</div>
            </div>
            <div class="panel">
              <h3>Tuning</h3>
              <div class="entity-list">${tuningMarkup}</div>
            </div>
            <div class="panel">
              <h3>Service</h3>
              <div class="entity-list">${serviceMarkup}</div>
            </div>
          </div>
        </div>
        <div class="legacy-note">${escapeHtml(moduleConfig.legacy_note || "")}</div>
      </section>
    `;
  }

  _render() {
    if (!this.shadowRoot) {
      return;
    }

    try {
      if (!this._hass) {
        this.shadowRoot.innerHTML = `
          <style>${this._styles()}</style>
          <ha-card header="${escapeHtml(this._config.title || "Operator Hub")}">
            <div class="loading-state">Warte auf Home Assistant Daten…</div>
          </ha-card>
        `;
        return;
      }

      const activeModule = getModuleById(this._moduleId);
      const moduleButtons = MODULES.map((moduleConfig) => `
        <button
          class="subnav-button ${moduleConfig.id === activeModule.id ? "is-active" : ""}"
          data-page="module"
          data-module="${escapeHtml(moduleConfig.id)}"
        >
          ${escapeHtml(moduleConfig.title)}
        </button>
      `).join("");

      let pageMarkup = this._renderHome();
      if (this._page === "rooms") {
        pageMarkup = this._renderRooms();
      } else if (this._page === "module") {
        pageMarkup = this._renderModule();
      }

      this.shadowRoot.innerHTML = `
        <style>${this._styles()}</style>
        <ha-card header="${escapeHtml(this._config.title || "Operator Hub")}">
          <div class="app-shell">
            <div class="topnav">
              <button class="topnav-button ${this._page === "home" ? "is-active" : ""}" data-page="home">Home</button>
              <button class="topnav-button ${this._page === "rooms" ? "is-active" : ""}" data-page="rooms">Raeume</button>
              <div class="subnav">${moduleButtons}</div>
            </div>
            <div class="page-content">${pageMarkup}</div>
            <div class="footer-note">Sieker Operator Hub MVP ${escapeHtml(CARD_VERSION)} · buildloses Repo-Geruest fuer die naechste App-Stufe</div>
          </div>
        </ha-card>
      `;

      this._bindEvents();
    } catch (error) {
      console.error("Sieker Operator Hub: Render-Fehler.", error);
      this.shadowRoot.innerHTML = `
        <style>${this._styles()}</style>
        <ha-card header="${escapeHtml(this._config.title || "Operator Hub")}">
          <div class="loading-state">
            Frontend-Fehler im Operator Hub: ${escapeHtml(error?.message || "unbekannt")}
          </div>
        </ha-card>
      `;
    }
  }

  _styles() {
    return `
      :host {
        display: block;
      }

      ha-card {
        overflow: hidden;
      }

      .app-shell {
        padding: 16px;
        background:
          radial-gradient(circle at top left, rgba(56, 114, 212, 0.12), transparent 28%),
          radial-gradient(circle at bottom right, rgba(28, 167, 133, 0.10), transparent 26%),
          var(--card-background-color);
      }

      .topnav {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-bottom: 18px;
      }

      .subnav {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
      }

      .topnav-button,
      .subnav-button,
      .nav-tile,
      .action-button {
        border: 1px solid var(--divider-color);
        border-radius: 14px;
        background: rgba(127, 127, 127, 0.05);
        color: var(--primary-text-color);
        cursor: pointer;
        transition: transform 120ms ease, border-color 120ms ease, background 120ms ease;
      }

      .topnav-button,
      .subnav-button {
        padding: 10px 14px;
        font: inherit;
      }

      .topnav-button.is-active,
      .subnav-button.is-active {
        background: rgba(56, 114, 212, 0.16);
        border-color: rgba(56, 114, 212, 0.45);
      }

      .topnav-button:hover,
      .subnav-button:hover,
      .nav-tile:hover,
      .action-button:hover {
        transform: translateY(-1px);
      }

      .page-section {
        margin-bottom: 22px;
      }

      .section-head {
        margin-bottom: 12px;
      }

      .section-head h2 {
        margin: 0 0 4px;
        font-size: 1.15rem;
      }

      .section-head p,
      .legacy-note,
      .footer-note,
      .empty-note,
      .loading-state {
        color: var(--secondary-text-color);
        line-height: 1.45;
      }

      .status-grid,
      .nav-grid,
      .room-grid {
        display: grid;
        gap: 12px;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      }

      .status-card,
      .room-card,
      .panel,
      .diagnostic-card {
        border: 1px solid rgba(127, 127, 127, 0.20);
        border-radius: 16px;
        background: rgba(127, 127, 127, 0.04);
        padding: 14px;
      }

      .status-card-head,
      .room-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 10px;
        margin-bottom: 8px;
      }

      .status-title,
      .room-head h3,
      .panel h3 {
        margin: 0;
        font-size: 0.98rem;
        font-weight: 600;
      }

      .status-icon,
      .nav-icon {
        font-family: monospace;
        color: var(--secondary-text-color);
      }

      .status-value {
        font-size: 1.15rem;
        font-weight: 700;
        margin-bottom: 4px;
      }

      .status-id,
      .entity-id {
        font-size: 0.78rem;
        color: var(--secondary-text-color);
      }

      .nav-tile {
        padding: 16px;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
        text-align: left;
      }

      .nav-title {
        font-size: 1rem;
        font-weight: 700;
      }

      .nav-desc {
        color: var(--secondary-text-color);
        line-height: 1.4;
      }

      .module-layout {
        display: grid;
        gap: 14px;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      }

      .module-column {
        display: grid;
        gap: 14px;
      }

      .entity-list,
      .diagnostic-list {
        display: grid;
        gap: 10px;
      }

      .entity-row {
        display: flex;
        justify-content: space-between;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 12px;
        background: rgba(127, 127, 127, 0.05);
      }

      .entity-meta {
        display: grid;
        gap: 4px;
      }

      .entity-name {
        font-weight: 600;
      }

      .entity-state {
        text-align: right;
        font-weight: 600;
      }

      .severity-warn {
        border-left: 4px solid rgba(201, 79, 79, 0.75);
      }

      .severity-ok {
        border-left: 4px solid rgba(74, 152, 109, 0.65);
      }

      .severity-muted {
        border-left: 4px solid rgba(127, 127, 127, 0.45);
      }

      .action-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
      }

      .action-button {
        padding: 10px 14px;
        font: inherit;
      }

      .action-primary {
        background: rgba(56, 114, 212, 0.16);
        border-color: rgba(56, 114, 212, 0.45);
      }

      .action-warn {
        background: rgba(201, 79, 79, 0.12);
        border-color: rgba(201, 79, 79, 0.35);
      }

      .attribute-row {
        display: flex;
        justify-content: space-between;
        gap: 10px;
        padding-top: 8px;
        font-size: 0.88rem;
        color: var(--secondary-text-color);
      }

      .footer-note {
        margin-top: 8px;
        font-size: 0.82rem;
      }

      @media (max-width: 700px) {
        .app-shell {
          padding: 12px;
        }

        .entity-row {
          flex-direction: column;
        }

        .entity-state {
          text-align: left;
        }
      }
    `;
  }
}

if (!customElements.get("sieker-operator-hub")) {
  customElements.define("sieker-operator-hub", SiekerOperatorHub);
}

window.customCards = window.customCards || [];
if (!window.customCards.some((card) => card.type === "sieker-operator-hub")) {
  window.customCards.push({
    type: "sieker-operator-hub",
    name: "Sieker Operator Hub",
    description: "MVP custom card shell for the next operator-focused dashboard application.",
  });
}

